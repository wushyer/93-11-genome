library(Mfuzz)
x<-read.table("R9311.gene.F1.tpm",header=T,row.names=1)
tpm <- data.matrix(x)
eset <- new("ExpressionSet",exprs = tpm)
eset <- filter.std(eset,min.std=0)
eset <- standardise(eset)
m <- mestimate(eset)


c25 <- mfuzz(eset, c = 25, m = m)
mfuzz.plot(eset,c25,mfrow=c(5,5),new.window= FALSE)

cselection(eset,m=m,crange=seq(4,64,4),repeats=2,visu=TRUE)
Dmin(eset,m=m,crange=seq(4,32,4),repeats=5,visu=TRUE)

write.table(c25$cluster,"R9311.c25.cluster.txt",sep="\t",quote = F)
write.table(c25$centers,"R9311.c25.center.txt",sep="\t",quote = F)
write.table(c25$size,"R9311.c25.size.txt",sep="\t",quote = F)
write.table(c25$membership,"R9311.c25.membership.txt",sep="\t",quote = F)

pdf("R9311.c25.cluster.pdf")
mfuzz.plot(eset,c25,mfrow=c(5,5),new.window= FALSE)
dev.off()
