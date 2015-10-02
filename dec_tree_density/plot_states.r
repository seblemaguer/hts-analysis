### Install libraries
## install.packages("ggplot")
## install.packages("reshape")
## install.packages("plyr")
## install.packages("tikzDevice")
## install.packages("gridExtra")

# Loading libraries
library(ggplot2)
library(reshape)
library(scales)
library(gridExtra)
                                        # library(plyr)
require(grid)
require(tikzDevice)

scientific_10 <- function(x) {
  parse(text=gsub("e", " %*% 10^", scientific_format()(x)))
}

## options(tikzSanitizeCharacters = c('%','$','}','{','^', '_'))
## options(tikzReplacementCharacters = c('\\%','\\$','\\}','\\{', '\\^{}', '\\textunderscore'))

# Dealing with arguments
args <- commandArgs(trailingOnly = TRUE)

output_dir <- "./"

# Loading data
csv_filename <- "tree/categories/full_mgc_2.csv"
data_state1<- read.csv(csv_filename, sep=";")
data_state1$state <- as.factor(2)

# Loading data
csv_filename <- "tree/categories/full_mgc_4.csv"
data_state2 <- read.csv(csv_filename, sep=";")
data_state2$state <- as.factor(4)

# Loading data
csv_filename <- "tree/categories/full_mgc_6.csv"
data_state3 <- read.csv(csv_filename, sep=";")
data_state3$state <- as.factor(6)

# Appending datas
data <- rbind(data_state1, data_state2, data_state3)

#
data$X.categories <- as.character(data$X.categories)
data$X.categories <- factor(data$X.categories, levels=unique(data$X.categories))
data.m <- melt(data)
gsub("_", "\\_", data.m)

# Individual curve
p1 <- ggplot(data.m, aes(X.categories, value)) +
    geom_bar(aes(fill = variable), position = "dodge", stat="identity") +
    facet_grid(state ~ .) +
    labs(x = "Categories", y = "Proportion of uses", fill="experiments") +
    scale_y_continuous(breaks=NULL) +
                                        # scale_y_continuous(label=scientific_10) +
    theme(axis.text.x = element_text(angle = 30, hjust = 1), plot.background=element_blank())
## arrangeGrob(p1 ,p2, p3, ncol=1, heights=heights)
ggsave(sprintf("%s/%s", output_dir, "flat_version.pdf"), width=24, height=12, units="cm")

# tikz(sprintf("%s/%s", output_dir, "flat_version.pgf"), sanitize=TRUE)# standAlone = TRUE) #, width=24, height=8, units="cm")

# dev.off()
