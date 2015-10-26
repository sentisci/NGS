#!/usr/bin/env Rscript
# This script is to plot density plot from coverageBed depth file
## example: 
# do_hist.R -f SUBJECT/GIST109/109T_500_SS/ucsc.hg19.bwamem/qc/109T_500_SS.final.bam.depth.hist
# opt=NULL
# opt$histFile="SUBJECT/GIST109/109T_500_SS/ucsc.hg19.bwamem/qc/109T_500_SS.final.bam.depth.hist"
# opt$outDir = 'SUBJECT/GIST109/109T_500_SS/ucsc.hg19.bwamem/qc'


suppressPackageStartupMessages(library("optparse"))
option_list <- list( 
	make_option(c("-f", "--histFile"), help="histFile, required"),
	make_option(c("-o", "--outDir"), default='./', help="output dir. [default: %default]"),
	make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
	help="to output some information about a job.  [default: %default]")		
    )

# get command line options, if help option encountered print help and exit,
opt <- parse_args(OptionParser(option_list=option_list))

if( ! is.element('histFile', names(opt)) ) stop("Options for histFile is required. ")
# if( ! is.element('genes', names(opt)) ) stop("Options for gene names is required. ")

outDir = opt$outDir
histFile = opt$histFile
hist = read.delim(histFile, header=F)
names(hist) = c('Depth', 'Bases')
outName = file.path(outDir, sub('.hist', '.hist.png', basename(histFile)) )
png(filename=outName)
plot(hist)
dev.off()
