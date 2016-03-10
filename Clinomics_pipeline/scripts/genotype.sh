#!/bin/sh

DIR="/projects/Clinomics/Tools/Genotyping/"
#GenotypeFiles
#RATIO
rm -f $DIR/RATIO/*
da=`date +"%m-%d-%y"`
echo -e "#!/bin/sh">main.sh
echo -e "cd $DIR">>main.sh
echo -e "echo -e \"Sample\" >RATIO/FirstColumn" >>main.sh
echo -e "for i in GenotypeFiles/*.gt" >>main.sh
echo -e "do	" >>main.sh
echo -e "	file=\`basename \$i .gt\`" >>main.sh
echo -e "	echo -e "\${file}" >>RATIO/FirstColumn" >>main.sh
echo -e "done" >>main.sh



echo "sh main.sh" >swarm

cd $DIR/GenotypeFiles

for i in *.gt
do

echo -e "cd $DIR" >../$i.sh
echo -e "file=\`basename $i .gt\`" >>../$i.sh
echo -e "echo \${file} >RATIO/\${file}.ratio">>../$i.sh
echo -e "for j in GenotypeFiles/*.gt" >>../$i.sh
echo -e "do">>../$i.sh
echo -e "/data/Clinomics/Tools/Genotyping/CountOverlap.pl GenotypeFiles/$i \$j >>RATIO/\${file}.ratio">>../$i.sh
echo -e "done">>../$i.sh
echo -e "rm $DIR/$i.sh">>../$i.sh
echo -e "sh $i.sh" >>../swarm
done


cd $DIR
echo -e "#!/bin/sh">Final
echo -e "cd $DIR" >>Final
echo "paste RATIO/FirstColumn RATIO/*.ratio >MATRIX_${da}.txt">>Final
echo "samp=\`wc -l RATIO/FirstColumn |sed -e 's/ /\\t/g' |cut -f 1\`">>Final
echo "samp=\$((\$samp - 1))">>Final
echo "rm -rf rm -rf main.sh swarm Final GT_*.e GT_*.o">>Final
echo "chgrp -R Clinomics $DIR/">>Final
##echo -e "echo -e \"Genotyping matrix attached.\\\n\\\n\\\tSamples Processed \$samp\\\n\\\nRegards,\\\nClinOmics Team, NCI\" |mutt -s \"Genotyping Job Status\" -a MATRIX_${da}.txt -- patidarr@mail.nih.gov `whoami`@mail.nih.gov CLINOMICS-BIOINFO@LIST.NIH.GOV " >>Final

d=`qsub -N GT $DIR/swarm`
final_run=`qsub -o $DIR/gt.o -e $DIR/gt.e depend=afterany:$d $DIR/Final`


#d=`swarm -q ccr -f $DIR/swarm -N GT --jobarray --singleout`
#final_run=`qsub -e $DIR/gt.e -o $DIR/gt.o -W depend=afterany:$d -q ccr -l nodes=1 $DIR/Final`
