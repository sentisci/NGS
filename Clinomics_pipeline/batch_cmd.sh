#!/bin/sh
module load python/3.4.3
module load snakemake/20150924
##module load R/3.2.0

#Initialize Serpentine directory
export SERPENTINE_HOME="/projects/Clinomics/Tools/serpentine_Tgen/"
export RESULT_DIR="/projects/Clinomics/Tools/"

#Initialize Basic Variables
NOW=$(date +"%H%M%S_%m%d%Y")
WORKING_DIR=${RESULT_DIR}/Clinomics_Run/
##WORKING_DIR=${RESULT_DIR}/Clinomics_Run_Test_2/
SNAKEFILE=${SERPENTINE_HOME}/Snakefile

cd $WORKING_DIR
snakemake\
	--nolock \
        --jobname 'cln.{rulename}.{jobid}' \
        --directory $WORKING_DIR \
        --snakefile $SNAKEFILE \
        -k -p -w 10 -T \
	--rerun-incomplete \
	--stats serpentine_${NOW}.stats \
        -j 16 \
        --cluster "qsub -V -e ${WORKING_DIR}/log_error/ -o ${WORKING_DIR}/log_error/ {params.batch}" \
        >& Clinomics_${NOW}.log

##Runs
# Summary
#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE --configfile $SAMPLE_CONFIG --summary


## DRY Run with Print out the shell commands that will be executed
#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE --configfile $SAMPLE_CONFIG --dryrun -p
#cd $WORKING_DIR
#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE  --dryrun -p
#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE


#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE -n --forceall --rulegraph | dot -Tpng >  ../serpentine_Tgen_extras/dag.png
#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE -n --forceall --rulegraph | dot -Tpdf >  ../serpentine_Tgen_extras/dag.pdf


#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE --forceall --dag | dot -Tpdf > ../serpentine_Tgen_extras/dag.pdf
#snakemake --directory $WORKING_DIR --snakefile $SNAKEFILE --forceall --dag | dot -Tpng > ../serpentine_Tgen_extras/dag.png

#echo DAG |mutt -s "DAG" -a dag.pdf -- sindiris@mail.nih.gov
 
