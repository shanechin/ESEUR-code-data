#
# antlrpdg.R,  8 Jun 20
#
# Data from:
# Hussain Abdullah A. Al-Mutawa
# On the Classification of Cyclic Dependencies in Java Programs
#
# Example from:
# Evidence-based Software Engineering: based on the publicly available data
# Derek M. Jones
#
# TAG Java dependency-cycles


source("ESEUR_config.r")

library("igraph")
library("plyr")
library("jsonlite")


pal_col=rainbow(2)


# Increasing default_width does not seem to have any/much effect
plot_layout(3, 2, max_width=ESEUR_default_width+2)
par(oma=OMA_default+c(-1.5, -1.0, -0.2, -0.5))
par(mar=MAR_default+c(-1.5, -3, -0.1, -0.5))


# Remove last name on path (which is assumed to be method name)
remove_last=function(name_str)
{
sub("\\.[a-zA-Z0-9$_]+$", "", name_str)
}

get_src_tgt=function(df)
{
t=c(remove_last(df$src), remove_last(df$tar))
# remove self references
if (t[1] == t[2])
   return(NULL)
return(t)
}

plot_PDG=function(file_str)
{
ant=fromJSON(paste0(dir_str, file_str))

from_to=adply(ant$edges, 1, get_src_tgt)
f_t=data.frame(from=from_to$V1, to=from_to$V2)

ant_g=graph.data.frame(unique(f_t), directed=TRUE)
V(ant_g)$label=NA
V(ant_g)$color=pal_col[1]
E(ant_g)$arrow.size=0.3
E(ant_g)$color=pal_col[2]

plot(ant_g, # main=sub("\\.json.xz", "", file_str), # cex.main=2 has no effect!
	vertex.frame.color="white")
title(sub("\\.json.xz", "", file_str), cex.main=1.6)
}


dir_str=paste0(ESEUR_dir, "ecosystems/")
top_files=list.files(dir_str)
top_files=top_files[grep("antlr-.*\\.json.xz$", top_files)]

dummy=sapply(top_files, plot_PDG)

