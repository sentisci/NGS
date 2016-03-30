#!/usr/bin/env Rscript
# This script is to convert Meltzerlab NGS samplesheet to a json file and merge to config_common.json
# Author: Jack Zhu
# Date: 04/16/2015
# verstion: 0.01
# example: $ do_samplesheet2json.R -s samplesheet.txt
# opt=NULL
# opt$sampleSheetFile = '/data/CCRBioinfo/zhujack/projects/TargetOsteosarcomaRNA/samplesheet_test.txt'
# opt$outDir = getwd()

suppressPackageStartupMessages(library("optparse"))
option_list <- list( 
    make_option(c("-s", "--sampleSheetFile"), 
            help="This samplesheet should be generated from Meltzer solexaDB." ),    
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

print(opt)

df = read.delim(opt$sampleSheetFile, as.is=TRUE, strip.white=TRUE, comment.char = "#")
## remove all padded leading spaces when doing matrix conversion
s = data.frame(lapply(df, as.character))

# colnames(s)
#  [1] "result_id"    "run_id"       "run_date"     "sample"   "source"
#  [6] "sample"       "normal.tumor" "sampleN"      "library"      "library_id"
# [11] "lane_id"      "partitioning" "sample_type"  "read1"        "read2"
# [16] "study_id"     "note"

# > colnames(s)
#  [1] "result_id"    "source"       "sample"       "library"      "library_id"
#  [6] "lane_id"      "capture"      "partitioning" "normal.tumor" "sample_type"
# [11] "read1"        "read2"        "note"

objL <- list(
        'subjects' = c('source','sample'),
	'samples' = c('sample', 'library'),
	'libraries' = c('library', 'result_id'),
	'units' = c('result_id', 'read1', 'read2'), 
        'sample_TN' = c('sample', 'normal.tumor'),
	'DNA_DNAref' = c('sample', 'DNAref'),
        'DNA_RNAref' = c('sample', 'RNAref'),
        'sample_captures' = c('sample', 'capture'),
        'seq_type' = c('sample_type','sample')
)

source("/projects/Clinomics/Tools/serpentine_Tgen_extras/scripts/col2list.R")

objList <- list()
for (L in names(objL) ) {
   	
    objList_1 <- col2list( s[, objL[[L]]] ) 
    names(objList_1) <- L
    objList <- c(objList, objList_1)
}

library("jsonlite")
outSample <- file.path(opt$outDir, "samplesheet.json")
#if( file.exists(outSample) ) {
#    timestamp <- format(Sys.time(), "_%Y%m%d_%H%M%S")
#    file.rename(outSample, sub('.json', paste(timestamp, '.json', sep=''), outSample))
#}
jsonS <- toJSON( objList, pretty=T )
writeLines(jsonS, outSample)



