#!/usr/bin/env Rscript
# This script is to convert Meltzerlab NGS samplesheet to a json file and merge to config_common.json
# Author: Jack Zhu
# Date: 04/16/2015
# verstion: 0.01
# example: $ do_samplesheet2json.R samplesheet.txt config_common.json
# opt=NULL
# opt$sampleSheetFile = 'samplesheet.txt'
# opt$commonConfigureFile = 'config_common.json'
# opt$outDir = getwd()

suppressPackageStartupMessages(library("optparse"))
option_list <- list( 
	make_option(c("-s", "--sampleSheetFile"), 
	        help="This samplesheet should be generated from Meltzer solexaDB." ),	
	make_option(c("-c", "--commonConfigureFile"), default='', 
	        help="Common snakemake configure file. [default: %default]"),	
	make_option(c("-o", "--outDir"), default=getwd(), 
	        help="Directory for saving output files. [default: %default]"),
	make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
	    	help="to output some information about a job.  [default: %default]")		
)

opt <- parse_args(OptionParser(option_list=option_list))

if( ! is.element('sampleSheetFile', names(opt)) ) stop("Options for sampleSheetFile is required. ")
	
if ( opt$verbose ) { 
    write("The fun gets started...\n", stderr()) 
}

s = as.matrix(read.delim(opt$sampleSheetFile, as.is=T, comment.char = "#"))

# colnames(s)
#  [1] "result_id"    "run_id"       "run_date"     "SampleName"   "source"
#  [6] "sample"       "normal.tumor" "sampleN"      "library"      "library_id"
# [11] "lane_id"      "partitioning" "sample_type"  "read1"        "read2"
# [16] "study_id"     "note"

objL <- list(
		'studies' = c('study_id','sample'), 
		'subjects' = c('source','sample'), 
		'samples' = c('sample', 'library'),
		'libraries' = c('library', 'result_id'), 
		'units' = c('result_id', 'read1', 'read2'),
		'sample_TN' = c('sample', 'normal.tumor'),
		'subject_TN' = c('source', 'normal.tumor'),
		'subject_captures' = c('source', 'partitioning'),
		'sample_captures' = c('sample', 'partitioning'),
		'sample_references' = c('sample', 'sampleN')
)

source("/projects/Clinomics/Tools/serpentine_Tgen/scripts/col2list.R")


objList <- list()
for (L in names(objL) ) {
	objList_1 <- col2list( s[, objL[[L]]] )
	names(objList_1) <- L
	objList <- c(objList, objList_1)
}

library("jsonlite")
outSample <- file.path(opt$outDir, "config_sample.json")
outConfig <- file.path(opt$outDir, "config.json")

jsonS <- toJSON( objList, pretty=T )
writeLines(jsonS, outSample)

## merge common and sample config files
if( opt$commonConfigureFile == '' ) {
	system( paste("cp", outSample, outConfig, sep=' ' ))
} else {
	system( paste("cat", opt$commonConfigureFile, outSample, "| /projects/Clinomics/Tools/serpentine_Tgen/scripts/json --merge >", outConfig, sep=" ") )
}

file.remove("config_sample.json")


