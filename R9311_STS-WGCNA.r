library(WGCNA)
library(reshape2)
library(stringr)
options(stringsAsFactors = FALSE)
enableWGCNAThreads(nThreads=16)

type = "unsigned"
corType = "pearson"

rsem=read.table("R9311.gene.F1.log2.STS.tpm",header = T,row.names=1,quote="", comment="", check.names=F)

dataExpr <- as.data.frame(t(rsem))
gsg = goodSamplesGenes(dataExpr, verbose = 3)
gsg$allOK

pdf("R9311.STS_Gene.sampleTree.pdf")
sampleTree = hclust(dist(dataExpr), method = "average")
par(cex = 0.6)
par(mar = c(0,4,2,0))
plot(sampleTree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5   ,cex.axis = 1.5, cex.main = 2)
dev.off()

powers = c(c(1:10), seq(from = 12, to=30, by=2))
sft = pickSoftThreshold(dataExpr, powerVector = powers, networkType=type,  RsquaredCut = 0.80,verbose = 5)
sft
powerE = sft$powerEstimate
powerE

pdf("R9311.STS_Gene.power.pdf")
par(mfrow = c(1,2))
cex1 = 0.9
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",main = paste("Scale independence"   ))
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],labels=powers,cex=cex1,col="red")
abline(h=0.8,col="green")
plot(sft$fitIndices[,1], sft$fitIndices[,5],xlab="Soft Threshold (power)",ylab="Mean Connectiv   ity", type="n", main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=powers, cex=cex1,col="red")
dev.off()

nGenes = ncol(dataExpr)
nSamples = nrow(dataExpr)

net = blockwiseModules(dataExpr, power =6, maxBlockSize = nGenes,TOMType = type, minModuleSize = 30,reassignThreshold = 0, mergeCutHeight = 0.1,numericLabels = TRUE, pamRespectsDendro = FALSE,saveTOMs = TRUE,corType = corType, loadTOMs=TRUE, saveTOMFileBase = "R9311.STS_Gene.TOMFileBase",verbose = 3)

moduleLabels = net$colors
moduleColors = labels2colors(moduleLabels)
table(net$colors)
write.table(moduleColors,"R9311.STS_Gene.Gene_color.out",quote = F, sep = "\t",row.names=colnames(dataExpr),col.names="")

pdf("R9311.STS_Gene.module.pdf")
plotDendroAndColors(net$dendrograms[[1]], moduleColors[net$blockGenes[[1]]],"Module colors",dendroLabels = FALSE, hang = 0.03,addGuide = TRUE, guideHang = 0.05)
dev.off()

MEs = net$MEs
MEs_col = MEs
colnames(MEs_col) = paste0("ME", labels2colors(as.numeric(str_replace_all(colnames(MEs),"ME",""))))
MEs_col = orderMEs(MEs_col)

pdf("R9311.STS_Gene.EigengeneNetwork.pdf")
plotEigengeneNetworks(MEs_col, "Eigengene adjacency heatmap", marDendro = c(3,3,2,4),marHeatmap = c(3,4,2,2), plotDendrograms = T,  xLabelsAngle = 90)
dev.off()

load(net$TOMFiles[1], verbose=T)
TOM <- as.matrix(TOM)
dissTOM = 1-TOM
plotTOM = dissTOM^7
diag(plotTOM) = NA

probes = colnames(dataExpr)
dimnames(TOM) <- list(probes, probes)
cyt = exportNetworkToCytoscape(TOM, edgeFile = "R9311.STS_Gene.edge.txt" ,nodeFile = "R9311.STS_Gene.node.txt", weighted = TRUE, threshold = 0, nodeNames = probes, nodeAttr = moduleColors)

modules = c("black")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("blue")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("brown")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("green")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("magenta")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("pink")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("red")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("turquoise")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])

modules = c("yellow")
probes = names(dataExpr)
inModule = is.finite(match(moduleColors, modules))
modProbes = probes[inModule]
modTOM = TOM[inModule, inModule]
dimnames(modTOM) = list(modProbes, modProbes)
cyt = exportNetworkToCytoscape(modTOM,edgeFile = paste("R9311.STS_Gene.edge-", paste(modules, collapse="-"), ".txt", sep=""),nodeFile = paste("R9311.STS_Gene.node-", paste(modules, collapse="-"), ".txt", sep=""),weighted = TRUE,threshold = 0.1,nodeNames = modProbes,nodeAttr = moduleColors[inModule])
