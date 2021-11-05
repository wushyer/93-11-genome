Args <- commandArgs()
file=Args[6]
tag=Args[7]
out=Args[8]

rsem=read.table(file,header = T,row.names=1,quote="", comment="", check.names=F)

nr=dim(rsem)[1]

OutM <- matrix(nr=nr,nc=3)
rownames(OutM)=rownames(rsem)
colnames(OutM)=c("GeneID","R-sqr","p-value")

for (i in 1:nr){
        val=cor.test(as.numeric(rsem[tag,]),as.numeric(rsem[i,]), method = "pearson")
        OutM[i,]=c(tag,val$estimate,val$p.value)
}


write.table(OutM,out,quote = F, sep = "\t")
