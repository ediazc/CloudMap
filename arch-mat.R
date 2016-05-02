#!/usr/bin/env Rscript

options(digits=3)

norm_mat = function(frame) {
  frame = frame / max(frame, na.rm=T) * 10
 return(frame)
}

args = commandArgs(trailingOnly=TRUE)

if (length(args) < 1)
  stop("Usage: arch-mat.R nodesnum <CommPattern.csv> > <outputfilename.csv>\n")

size=as.integer(args[1])
filename=args[2]
output=args[3]

df <- read.csv(filename, header=FALSE, strip.white=TRUE, sep="\t")

mat=matrix(0.0,nrow=size,ncol=size)

for (i in 1:size)
  for (j in 1:size){
    index=paste0(sprintf("%02d", i),"-",sprintf("%02d", j))
    value=df[grep(index, df$V1),]$V2
    if (length(value) > 0)
      mat[j,i] = mat[i,j] = value
#      mat[j,i] = mat[i,j] = as.integer(value*100)
  }

rotate <- function(x) t(apply(x, 2, rev))

mat=rotate(mat)

mat=norm_mat(mat)

mat=matrix(as.integer(unlist(mat)),nrow=nrow(mat))

write.table(mat,file=output, col.names=FALSE, row.names=FALSE,sep = ",")
