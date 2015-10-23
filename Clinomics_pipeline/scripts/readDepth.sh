#!/bin/bash

## caculate read depth for a given bed file or bam file


if [ $# -lt 2 ]
then
    echo "Usage: `basename $0` <bamFile or bedFile> <bedFile> [outDir]"
    exit 65
fi

if [ $# -lt 3 ]
then
    outDir='./'
else
	outDir=$3
fi

if [[ $1 = *.bam ]]; then
	a='-abam'
elif [[ $1 = *.bed ]]; then
	a='-a'
fi
	

outBase=`basename $1`
echo $'chr\tstart\tend\tgene\tbaits\tbases_covered\ttotal_bases\tfraction_covered' >  ${outDir}/${outBase}.basecoverage
/home/zhujack/bin/coverageBed $a ${1} -b <(cut -f1-4 ${2}) >> ${outDir}/${outBase}.basecoverage

echo $'chr\tstart\tend\tgene\tdepth\tbases_covered\ttotal_bases\tfraction_covered' >  ${outDir}/${outBase}.depth.tmp
/home/zhujack/bin/coverageBed $a ${1} -b <(cut -f1-4 ${2}) -hist >>  ${outDir}/${outBase}.depth.tmp

grep "^all" ${outDir}/${outBase}.depth.tmp | cut -f 2-3 > ${outDir}/${outBase}.hist
grep -v "^all" ${outDir}/${outBase}.depth.tmp > ${outDir}/${outBase}.depth
rm -f ${outDir}/${outBase}.depth.tmp
/home/zhujack/bin/do_hist.R -f ${outDir}/${outBase}.hist -o ${outDir}

echo $'chr\tstart\tend\tgene\tposition\tdepth' >  ${outDir}/${outBase}.depth_per_base
/home/zhujack/bin/coverageBed  $a ${1} -b <(cut -f1-4 ${2}) -d >> ${outDir}/${outBase}.depth_per_base

# do_sumDepth.R -f ${outDir}/${outBase}.depth -b  ${2/cds/design}.depth -o $outDir
#########################################################################
