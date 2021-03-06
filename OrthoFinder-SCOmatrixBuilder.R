#!/usr/bin/env Rscript
library("optparse")
library(reshape2)
library(ggplot2)
library(grid)
 
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="Number of genes per orthogroups per species", metavar="character"),
	make_option(c("-o", "--out"), type="character", default=NULL, 
              help="output prefix file name", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$file) | is.null(opt$out)){
  print_help(opt_parser)
  stop("Two arguments must be supplied (input and output file name).n", call.=FALSE)
}



data = read.csv(opt$file, sep="\t", h=T)

##Extracting Orthogroups containing 1 or 0 genes per species :
##------------------------------------------------------------
SCO = data[apply(data[,2:length(data[1,])], 1, function(x) sum(x<2)==length(x)),]

##Extracting SCO present at least in 100%, 75%, 50% and 37.5% in the dataset :
##----------------------------------------------------------------------
SCO100 = SCO[apply(SCO[,2:length(SCO[1,])], 1, function(x) sum(x)==length(x)),]
SCO75 = SCO[apply(SCO[,2:length(SCO[1,])], 1, function(x) sum(x)> length(x)*0.75),]
SCO50 = SCO[apply(SCO[,2:length(SCO[1,])], 1, function(x) sum(x)> length(x)*0.5),]
SCO375 = SCO[apply(SCO[,2:length(SCO[1,])], 1, function(x) sum(x)> length(x)*0.375),]

##Preparing ggplot2 object
##------------------------
mm = melt(SCO, id="X"  )
mm$value = as.factor(mm$value)
mm$X=as.factor(as.character(mm$X))
mmNscoSp = aggregate(as.numeric(as.character(mm$value)), by=list(mm$variable), sum)

mm75 = melt(SCO75, id="X"  )
mm75$value = as.factor(mm75$value)
mm75$X=as.factor(as.character(mm75$X))
mm75NscoSp = aggregate(as.numeric(as.character(mm75$value)), by=list(mm75$variable), sum)

mm5 = melt(SCO50, id="X"  )
mm5$value = as.factor(mm5$value)
mm5$X=as.factor(as.character(mm5$X))
mm5NscoSp = aggregate(as.numeric(as.character(mm5$value)), by=list(mm5$variable), sum)

mm375 = melt(SCO375, id="X"  )
mm375$value = as.factor(mm375$value)
mm375$X=as.factor(as.character(mm375$X))
mm375NscoSp = aggregate(as.numeric(as.character(mm375$value)), by=list(mm375$variable), sum)

#sum(as.numeric(as.character(mm[mm$variable=="ARBO05",3]))) # -> Number of positiv SCO

##writing result (list of Orthogoups IDs and graphical representation of the matrix) :
##------------------------------------------------------------------------------------
write.table(SCO100$X, file=paste(opt$out,"SCO100.list", sep=''), quote=F, row.names=F, col.names=F)
write.table(SCO50$X, file=paste(opt$out,"SCO50.list", sep=''), quote=F, row.names=F, col.names=F)
write.table(SCO375$X, file=paste(opt$out,"SCO375.list", sep=''), quote=F, row.names=F, col.names=F)
pdf(file=paste(opt$out,"SCO375.pdf", sep=''))
ggplot(mm375,aes(x=X,y=variable,fill=value)) +
   geom_tile() + 
   labs(x="gene occupancy", y="species") +
   scale_y_discrete(limits=mm375NscoSp$Group.1[order(mm375NscoSp$x, decreasing=F)]) +
   scale_fill_manual(values = c("0"="white", "1"="black")) +
   theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
dev.off()
pdf(file=paste(opt$out,"SCO50.pdf", sep=''))
ggplot(mm5,aes(x=X,y=variable,fill=value)) +
   geom_tile() + 
   labs(x="gene occupancy", y="species") +
   scale_y_discrete(limits=mm5NscoSp$Group.1[order(mm5NscoSp$x, decreasing=F)]) +
   scale_fill_manual(values = c("0"="white", "1"="black")) +
   theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
dev.off()
pdf(file=paste(opt$out,"SCO75.pdf", sep=''))
ggplot(mm75,aes(x=X,y=variable,fill=value)) +
   geom_tile() + 
   labs(x="gene occupancy", y="species") +
   scale_y_discrete(limits=mm75NscoSp$Group.1[order(mm75NscoSp$x, decreasing=F)]) +
   scale_fill_manual(values = c("0"="white", "1"="black")) +
   theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
dev.off()
pdf(file=paste(opt$out,"SCO.pdf", sep=''))
ggplot(mm,aes(x=X,y=variable,fill=value)) +
   geom_tile() + 
   labs(x="gene occupancy", y="species") +
   scale_y_discrete(limits=mmNscoSp$Group.1[order(mmNscoSp$x, decreasing=F)]) +
   scale_fill_manual(values = c("0"="white", "1"="black")) +
   theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) 
dev.off()

## Creation of the SCO matrix representation with color frames
##-------------------------------------------------------------
# pdf(file="SCOmatrixColor.pdf", width=300, height=100)
png(file=paste(opt$out,"SCOmatrixColor.png", sep=''), width=3000, height=1000, res=162)
testGG = ggplot(mm375,aes(x=X,y=variable,fill=value)) +
   geom_tile() + 
   labs(x="gene occupancy", y="species") +
   scale_y_discrete(limits=mm375NscoSp$Group.1[order(mm375NscoSp$x, decreasing=F)]) +
   scale_fill_manual(values = c("0"="white", "1"="black"),labels=c("Absent", "Present")) +
   theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
   theme(plot.margin=unit(c(1,1,1.5,1.2),"cm"))
axisPosY = -0.8
testGG + geom_rect(aes(xmin=0.5, xmax=nlevels(mm75$X)+0.5, ymin=1-0.5, ymax=nlevels(mm75$variable)+0.5), alpha=0.002, fill ="purple") +
geom_rect(aes(xmin=0.5, xmax=nlevels(mm5$X)+0.5, ymin=1-0.5, ymax=nlevels(mm5$variable)+0.5), alpha=0.002, fill ="blue") +
  geom_segment(aes(x=0, xend=nlevels(mm375$X)+0.5, y=axisPosY, yend=axisPosY) ) +
  geom_segment(aes(x=0, xend=0, y=axisPosY-0.2, yend=axisPosY+0.2) ) +
  geom_segment(aes(x=nlevels(mm5$X)+0.5, xend=nlevels(mm5$X)+0.5, y=axisPosY-0.2, yend=axisPosY+0.2) ) +
  geom_segment(aes(x=nlevels(mm75$X)+0.5, xend=nlevels(mm75$X)+0.5, y=axisPosY-0.2, yend=axisPosY+0.2) ) +
  geom_segment(aes(x=nlevels(mm375$X)+0.5, xend=nlevels(mm375$X)+0.5, y=axisPosY-0.2, yend=axisPosY+0.2) ) +
  annotate("text", x=nlevels(mm5$X)+0.5, y=axisPosY+0.6, label=nlevels(mm5$X) )+
  annotate("text", x=nlevels(mm75$X)+0.5, y=axisPosY+0.6, label=nlevels(mm75$X) )+
  annotate("text",x=nlevels(mm375$X)-(0.01*nlevels(mm375$X)), y=axisPosY+0.6, label=nlevels(mm375$X) )
dev.off()
