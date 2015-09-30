library(dplyr)
library(VariantAnnotation)
library(magrittr)


###  Functions  BLOCK Start ###################
#Test if variant column is empty
vector.is.empty <- function(x) return(length(x) ==0 )

## Add a new field to the header.
#Make New Field
add_a_field <- function(x, vcf = vcf, vAF_result = vAF_result){
  name = paste("VAF",which(colnames(vAF_result) == x),sep="")
  desc = paste("Variant Allele Frequency, for each ALT allele, in the same order as listed for sample ",x,sep="")
  
  newInfo <- DataFrame(Number=1, Type="Float",
                       Description=desc,
                       row.names=name)
  #Add New Field to VCF
  info(header(vcf)) <- rbind(info(header(vcf)), newInfo)
  #Add VAF field to the Info file
  info(vcf)[,name] <- vAF_result[,x]
  return(vcf)
}

##Caller specific Function
#HaplotypeCaller
HaplotypeCaller <- function(vcf){
  #make VAF for HaplotypeCaller /Unified Genotyper
  VCF_Stat <- as.data.frame(geno(vcf)$AD)
  VAF_df <- apply(VCF_Stat, 1, 
                       function(x){ index_0 <- which( sapply(x,vector.is.empty),arr.ind=TRUE)
                                    if(length(index_0) > 0 ){ x[[unname(index_0)]] <- c(0,0) }
                                    return(apply( as.data.frame(x), 2, function(x){ return( paste(signif(x[-1]/sum(x),digits=3),collapse=",") ) }))
                                    
                       }
  )
  return(t(VAF_df))
}

#FreeBayes
FreeBayes <- function(vcf){
  samples <- samples(header(vcf))
  Ref_df <- cbind( geno(vcf)$RO)
  Alt_df <- cbind( geno(vcf)$AO)
  
  vaf_df <- sapply(samples, function(x){ 
    each_sample_df <- cbind(Ref_df[,x],Alt_df[,x]); 
    vaf <- apply(each_sample_df,1,function(x){ y <- unlist(x); return(paste( signif(y[-1]/sum(y),digits=3), collapse=",")) })
    return(vaf)
  })

  return(vaf_df)
}

#PlatyPus
PlatyPus <- function(vcf){
  samples <- samples(header(vcf))
  Ref_df <- cbind( geno(vcf)$NR)
  Alt_df <- cbind( geno(vcf)$NV)
  
  vaf_df <- sapply(samples, function(x){ 
    each_sample_df <- cbind(Ref_df[,x],Alt_df[,x]); 
    vaf <- apply(each_sample_df,1,function(x){ y <- unlist(x); return(paste( signif(y[-1]/sum(y),digits=3), collapse=",")) })
    return(vaf)
  })
  
  return(vaf_df)
}

#Strelka
Strelka <- function(vcf){
  samples <- samples(header(vcf))
  #make VAF for Strelka
  Strelka_VCF_df <- cbind( cbind(
    Ref=as.data.frame(ref(vcf))[,"x"],
    ALT=aggregate(value ~ group ,data=as.data.frame(alt(vcf)),FUN=paste, collapse=",")[,"value"]),
    #t(as.data.frame((lapply(split(seq(nrow(data)), data$group), function(x){ y<-paste(data$value[x],collapse=",") }))) ),
    DP=as.data.frame(geno(vcf)$DP),
    AU=as.data.frame(geno(vcf)$AU),
    CU=as.data.frame(geno(vcf)$CU),
    GU=as.data.frame(geno(vcf)$GU),
    TU=as.data.frame(geno(vcf)$TU)
  )
  vaf_df <- sapply(samples, function(each_sample){ 
                     Strelka_VCF_df_1 <- Strelka_VCF_df %>% 
                                                dplyr::select( Ref,ALT,contains(each_sample),-contains("2")) 
                    vAF_result <- apply(Strelka_VCF_df_1, 1, function(x){
                      y <- as.data.frame(t(sapply(x[-c(1:2)], as.numeric)))
                      z <- as.data.frame(t(x[c(1:2)]),stringsAsFactors=FALSE)
                      v <- cbind(z,y) ;
                      index_0 <- which( sapply(v,vector.is.empty),arr.ind=TRUE)
                      if(length(index_0) > 0 ){ v[[unname(index_0)]] <- c("X") }
                      val <- paste( signif(v[,-c(1:3)]/v[,3],digits=3) %>% 
                               dplyr::select(matches( paste( paste ( unlist(lapply( unlist(strsplit(as.character(v$ALT), ",", fixed = TRUE)) ,
                                                                           function(x){ return(paste(x)) })),"U.",each_sample,sep=""),collapse="|") )),collapse=",")
                    })
                    return(vAF_result)
                }) 
  return(vaf_df)
}
###  Functions  BLOCK End ###################

#Gather all the arguments 
args<-commandArgs(trailingOnly = TRUE)
CallerType <- args[1]
filename <- args[2]

##Read VCF
sample_vcf <- paste(getwd(),filename,sep="/")
vcf <- readVcf(sample_vcf, "hg19")

#Call Caller Command
vAF_result = switch(CallerType,
                    UnifiedGenotyper  = HaplotypeCaller(vcf),
                    HaplotypeCaller   = HaplotypeCaller(vcf),
                    FreeBayes         = FreeBayes(vcf),
                    PlatyPus          = PlatyPus(vcf),
                    Strelka           = Strelka(vcf)
)

#Making the final vcf file
for( i in 1:length(colnames(vAF_result)) ) {
vcf <- sapply(colnames(vAF_result)[i],add_a_field,vcf = vcf , vAF_result = vAF_result)[[1]]
}

##Write the VCF file
outfile <- gsub("vcf","VAF.vcf",filename )
writeVcf(vcf,outfile)
