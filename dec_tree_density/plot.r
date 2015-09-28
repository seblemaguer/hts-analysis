### Install libraries
## install.packages("ggplot")
## install.packages("reshape")
## install.packages("plyr")

# Loading libraries
library(ggplot2)
library(reshape)
library(scales)
library(plyr)
require(grid)

# Dealing with arguments
args <- commandArgs(trailingOnly = TRUE)
csv_filename <- args[1]
output_dir <- args[2]

# Loading data
data <- read.csv(csv_filename, sep=";")

# Force order
data$X.categories <- as.character(data$X.categories)
data$X.categories <- factor(data$X.categories, levels=unique(data$X.categories))

# Individual curve
ggplot(data, aes(x=X.categories, y=baseline)) +
    geom_bar(stat="identity", fill="lightblue", colour="black") +
   labs(x = "Categories", y = "Nb. occurences")
ggsave(sprintf("%s/%s", output_dir, "baseline_start.pdf"), width=24, height=8, units="cm")

ggplot(data, aes(x=X.categories, y=with_surprisal)) +
    geom_bar(stat="identity", fill="lightblue", colour="black") +
   labs(x = "Categories", y = "Nb. occurences")
ggsave(sprintf("%s/%s", output_dir, "with_surprisal_start.pdf"), width=24, height=8, units="cm")

ggplot(data, aes(x=X.categories, y=only_surprisal)) +
    geom_bar(stat="identity", fill="lightblue", colour="black") +
   labs(x = "Categories", y = "Nb. occurences")
ggsave(sprintf("%s/%s", output_dir, "only_surprisal_start.pdf"), width=24, height=8, units="cm")


# Merging
data.m <- melt(data)
base_size <- 9

data.m$value <- log(data.m$value)

ggplot(data.m, aes(y=X.categories, x=variable)) +
    geom_tile(aes(fill = value), colour = "black") +
	scale_fill_gradient(low = "white", high = "#00BA38", na.value = "white", guide = "legend",
                        limits=c(0,max(data.m$value, na.rm=TRUE)))  +
	labs(x = "Experiments", y = "Categories", fill = "Nb occurrences") +
    theme_bw() +
    theme_grey(base_size = base_size)  +
    scale_x_discrete(expand = c(0, 0))

ggsave(sprintf("%s/%s", output_dir, "heatmap.pdf"), width=24, height=8, units="cm")


data.m$value <- log(data.m$value)

ggplot(data.m, aes(y=X.categories, x=variable)) +
    geom_tile(aes(fill = value), colour = "black") +
	scale_fill_gradient(low = "white", high = "#00BA38", na.value = "white", guide = "legend",
                        limits=c(0,max(data.m$value, na.rm=TRUE)))  +
	labs(x = "Experiments", y = "Categories", fill = "Nb occurrences") +
    theme_bw() +
    theme_grey(base_size = base_size)  +
    scale_x_discrete(expand = c(0, 0))

ggsave(sprintf("%s/%s", output_dir, "heatmap_log.pdf"), width=24, height=8, units="cm")
