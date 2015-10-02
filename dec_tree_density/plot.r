### Install libraries
## install.packages("ggplot")
## install.packages("reshape")
## install.packages("plyr")
## install.packages("tikzDevice")

# Loading libraries
library(ggplot2)
library(reshape)
library(scales)
# library(plyr)
# require(grid)
# require(tikzDevice)

# Dealing with arguments
args <- commandArgs(trailingOnly = TRUE)
csv_filename <- args[1]
output_dir <- args[2]

# Loading data
data <- read.csv(csv_filename, sep=";")

# Force order
data$X.categories <- as.character(data$X.categories)
data$X.categories <- factor(data$X.categories, levels=unique(data$X.categories))
data.m <- melt(data)

# Individual curve
p <- ggplot(data.m, aes(X.categories, value)) +
    geom_bar(aes(fill = variable), position = "dodge", stat="identity") +
    labs(x = "Categories", y = "Nb. occurences", fill="experiments") +
    scale_y_continuous(breaks=NULL) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1), plot.background=element_blank())
ggsave(sprintf("%s/%s", output_dir, "flat_version.pdf"), width=24, height=8, units="cm")

# Merging
base_size <- 9

ggplot(data.m, aes(y=X.categories, x=variable)) +
    geom_tile(aes(fill = value), colour = "black") +
	scale_fill_gradient(low = "lightblue", high = "#CD3333", na.value = "white", guide = "legend",
                        limits=c(0,max(data.m$value, na.rm=TRUE)))  +
	labs(x = "Experiments", y = "Categories", fill = "Nb occurrences") +
    theme_bw() +
    theme_grey(base_size = base_size)  +
    theme(plot.background=element_blank()) +
    scale_x_discrete(expand = c(0, 0))

ggsave(sprintf("%s/%s", output_dir, "heatmap.pdf"), width=24, height=8, units="cm")


data.m$value <- log(data.m$value)

ggplot(data.m, aes(y=X.categories, x=variable)) +
    geom_tile(aes(fill = value), colour = "black") +
	scale_fill_gradient(low = "lightblue", high = "#CD3333", na.value = "white", guide = "legend",
                        limits=c(0,max(data.m$value, na.rm=TRUE)))  +
	labs(x = "Experiments", y = "Categories", fill = "Nb occurrences") +
    theme_bw() +
    theme_grey(base_size = base_size)  +
    theme(plot.background=element_blank()) +
    scale_x_discrete(expand = c(0, 0))

ggsave(sprintf("%s/%s", output_dir, "heatmap_log.pdf"), width=24, height=8, units="cm")
