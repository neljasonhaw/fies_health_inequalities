###############################################################################
##################    DUMBBELL PLOTS OF FIES 2012 to 2018    ##################
######################     Code by Nel Jason L. Haw      ######################
###############################################################################

# Helpful guide: https://towardsdatascience.com/create-dumbbell-plots-to-visualize-group-differences-in-r-3536b7d0a19a

###############################################################################
####### Load libraries
library(tidyverse)
library(ggplot2)
library(scales)       # additional options for x and y-axis scales in ggplot
library(haven)        # for importing Stata dta files
library(ggalt)        # dumbbell plot extension of ggplot
library(grid)         # for plotting grids
library(gridExtra)    # grid extension
library(ggpubr)       # more ggplot extensions
library(extrafont)    # custom font

##### Install all fonts - only import once 
# font_import()
# loadfonts(device = "win", quiet = TRUE)
# fonts() to show fonts

##### Set colors of poor and nonpoor points on dumbbell plot
nonpoor_navy <- "#1a476f"
poor_maroon <- "#90353b"

###############################################################################


###############################################################################
##### Import dumbbell data
data_dumbbell <- read_dta("dumbbell.dta")
## Create a new column that combines the survey round
## Select columns
data_dumbbell <- data_dumbbell %>% select(outcome, survey, nonpoor, poor, diff, N)
## Convert survey to string
data_dumbbell$survey <- as.character(data_dumbbell$survey)

##### Subset all nine outcomes
outcomelist <- data_dumbbell %>% group_split(outcome, keep = FALSE) 
## Retrieve names
outcomelist_names <- data_dumbbell %>% group_keys(outcome)
## Apply names to the list
names(outcomelist) <- outcomelist_names %>% pull()

## Can also do:
## outcomelist <- lapply(outcomelist, function(i) {data_dumbbell %>% filter(outcome == i) %>%
##         select(survey, nonpoor, poor, diff)})
###############################################################################


###############################################################################
##### Create ggplot function (since we will do this 9 times)
dumbbell_pov <- function(i) {
  # Deprecated code - only needed when one wants N displayed on the figure
  # Store numbers as string with commas every three places
  # n_values <- as.character(format(i$N, big.mark = ","))
  # Create labels for y-axis
  # y_axis_labels <- c(bquote(paste("2012 (", italic("N"), " = ", .(n_values[1]), ")")),
  #                   bquote(paste("2015 (", italic("N"), " = ", .(n_values[2]), ")")),
  #                   bquote(paste("2018 (", italic("N"), " = ", .(n_values[3]), ")")))
  i <- ggplot() +
    # Add the dumbbell plot
    # Note the British spelling of color for colour_x and colour_xend
    geom_dumbbell(data = i,
                  aes(y = survey, x = nonpoor, xend = poor),
                  size = 2, color = "gray50", 
                  size_x = 6, size_xend = 6,
                  colour_x = nonpoor_navy, colour_xend = poor_maroon) +
    # Fix y-axis
    scale_y_discrete(name = "") +
    # Theme
    theme(
      text = element_text("HelveticaNeueforSAS"),
      plot.title = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_text(size = 16, color = "black"),
      axis.title.x = element_text(face = "bold", size = 16, color = "black"),
      axis.title.y = element_blank(),
      axis.ticks = element_blank())
      # panel.background = element_blank())
  return(i)
}

#### Apply the dumbbell plot to all data frames in list all_dumbbell
all_dumbbell <- lapply(outcomelist, function(i) dumbbell_pov(i))


#### Set the layout - 3 x 3 grid where
#### Row = Tobacco, Alcohol, OOP
#### Column = Prev, Share_Totex, absolute value in 2018 PHP

#### Manually add elements in specific plots
## The upper left plot is prev_tobacco, we will add the color labels poor and non-poor here
all_dumbbell$prev_tobacco <- all_dumbbell$prev_tobacco +
  geom_text(data = filter(data_dumbbell, survey == "2018" & outcome == "prev_tobacco"),
            aes(x = nonpoor, y = "2018", label = "NONPOOR"),
            color = nonpoor_navy, size = 5, vjust = -1.5, hjust = 0.75,
            fontface = "bold", family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, survey == "2018" & outcome == "prev_tobacco"),
            aes(x = poor, y = "2018", label = "POOR"),
            color = poor_maroon, size = 5, vjust = -1.5, hjust = 0,
            fontface = "bold", family = "HelveticaNeueforSAS") +
  # Add the x-scale
  scale_x_continuous(name = "", limits = c(0.4, 1), breaks = seq(0.4, 1.0, 0.2)) +
  # Remove the x-axis labels
  theme(axis.text.x = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "prev_tobacco"),
            aes(x = nonpoor, y = survey, label = format(nonpoor*100, digits = 3)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "prev_tobacco"),
            aes(x = poor, y = survey, label = format(poor*100, digits = 3)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The middle left plot if prev_alcohol
all_dumbbell$prev_alcohol <- all_dumbbell$prev_alcohol +
  # Add the x-scale
  scale_x_continuous(name = "", limits = c(0.4, 1), breaks = seq(0.4, 1.0, 0.2)) +
  # Remove the x-axis labels
  theme(axis.text.x = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "prev_alcohol"),
            aes(x = nonpoor, y = survey, label = format(nonpoor*100, digits = 3),
                hjust = ifelse(abs(diff) < 0.05, 1, 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "prev_alcohol"),
            aes(x = poor, y = survey, label = format(poor*100, digits = 3),
                hjust = ifelse(abs(diff) < 0.05, 0, 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The lower left plot is prev_health, we will add the complete x-axis scale below
all_dumbbell$prev_health <- all_dumbbell$prev_health +
  # Add the x-scale
  scale_x_continuous(name = "Weighted proportion (%) of households \n reporting some expenditure",
                     limits = c(0.4, 1), breaks = seq(0.4, 1.0, 0.2)) + 
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "prev_health"),
            aes(x = nonpoor, y = survey, label = format(nonpoor*100, digits = 3),
                hjust = ifelse(abs(diff) < 0.05, 0, 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "prev_health"),
            aes(x = poor, y = survey, label = format(poor*100, digits = 3),
                hjust = ifelse(abs(diff) < 0.05, 1, 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The upper middle plot is share_tobacco_totex
all_dumbbell$share_tobacco_totex <- all_dumbbell$share_tobacco_totex +
  # Add the x-scale
  scale_x_continuous(name = "", limits = c(0.01, 0.04), breaks = seq(0.01, 0.04, 0.01)) +
  # Remove the x-axis and y-axis labels
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "share_tobacco_totex"),
            aes(x = nonpoor, y = survey, label = format(nonpoor*100, digits = 2),
                hjust = ifelse(abs(diff) < 0.001, 1, 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "share_tobacco_totex"),
            aes(x = poor, y = survey, label = format(poor*100, digits = 2),
                hjust = ifelse(abs(diff) < 0.001, 0, 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")


## The middle middle plot is share_alcohol_totex
all_dumbbell$share_alcohol_totex <- all_dumbbell$share_alcohol_totex +
  # Add the x-scale
  scale_x_continuous(name = "", limits = c(0.01, 0.04), breaks = seq(0.01, 0.04, 0.01)) +
  # Remove the x-axis and y-axis labels
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "share_alcohol_totex"),
            aes(x = nonpoor, y = survey, label = format(nonpoor*100, digits = 2),
                hjust = case_when(abs(diff) < 0.001 & nonpoor > poor ~ 0,
                                  abs(diff) < 0.001 & nonpoor < poor ~ 1,
                                  NA ~ 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "share_alcohol_totex"),
            aes(x = poor, y = survey, label = format(poor*100, digits = 2),
                hjust = case_when(abs(diff) < 0.001 & nonpoor > poor ~ 1,
                                  abs(diff) < 0.001 & nonpoor < poor ~ 0,
                                  NA ~ 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The lower middle plot is share_health_totex
all_dumbbell$share_health_totex <- all_dumbbell$share_health_totex +
  # Add the x-scale
  scale_x_continuous(name = "Mean share (%) of household expenditure \n among households reporting", 
                     limits = c(0.00, 0.04), breaks = seq(0.00, 0.04, 0.01)) +
  # Remove the y-axis labels
  theme(axis.text.y = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "share_health_totex"),
            aes(x = nonpoor, y = survey, label = format(nonpoor*100, digits = 2),
                hjust = case_when(abs(diff) < 0.001 & nonpoor > poor ~ 0,
                                  abs(diff) < 0.001 & nonpoor < poor ~ 1,
                                  NA ~ 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "share_health_totex"),
            aes(x = poor, y = survey, label = format(poor*100, digits = 2),
                hjust = case_when(abs(diff) < 0.001 & nonpoor > poor ~ 1,
                                  abs(diff) < 0.001 & nonpoor < poor ~ 0,
                                  NA ~ 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The upper right plot is tobacco_2018
all_dumbbell$tobacco_2018 <- all_dumbbell$tobacco_2018 +
  # Add the x-scale
  scale_x_continuous(name = "", limits = c(0, 12000), breaks = seq(0, 12000, 4000)) +
  # Remove the x-axis and y-axis labels
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "tobacco_2018"),
            aes(x = nonpoor, y = survey, label = format(nonpoor, digits = 4, big.mark = ","),
                hjust = ifelse(abs(diff) < 2000, 0, 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "tobacco_2018"),
            aes(x = poor, y = survey, label = format(poor, digits = 4, big.mark = ","),
                hjust = ifelse(abs(diff) < 2000, 1, 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The middle right plot is alcohol_2018
all_dumbbell$alcohol_2018 <- all_dumbbell$alcohol_2018 +
  # Add the x-scale
  scale_x_continuous(name = "", limits = c(0, 12000), breaks = seq(0, 12000, 4000)) +
  # Remove the x-axis and y-axis labels
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "alcohol_2018"),
            aes(x = nonpoor, y = survey, label = format(nonpoor, digits = 4, big.mark = ","),
                hjust = ifelse(abs(diff) < 2000, 0, 0.5)),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "alcohol_2018"),
            aes(x = poor, y = survey, label = format(poor, digits = 4, big.mark = ","),
                hjust = ifelse(abs(diff) < 2000, 1, 0.5)),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

## The lower right plot is health_2018
all_dumbbell$health_2018 <- all_dumbbell$health_2018 +
  # Add the x-scale
  scale_x_continuous(name = "Mean absolute expenditure in 2018 prices (PHP) \n among households reporting", 
                     limits = c(0, 12000), breaks = seq(0, 12000, 4000)) +
  # Remove the y-axis labels
  theme(axis.text.y = element_blank()) + 
  # Add dot labels
  geom_text(data = filter(data_dumbbell, outcome == "health_2018"),
            aes(x = nonpoor, y = survey, label = format(nonpoor, digits = 4, big.mark = ",")),
            color = nonpoor_navy, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS") +
  geom_text(data = filter(data_dumbbell, outcome == "health_2018"),
            aes(x = poor, y = survey, label = format(poor, digits = 4, big.mark = ",")),
            color = poor_maroon, size = 5, vjust = 2,
            family = "HelveticaNeueforSAS")

#### Putting them altogether
## Splitting the plots by expenditure type
tobacco_plots <- all_dumbbell[c("prev_tobacco", "share_tobacco_totex", "tobacco_2018")]
alcohol_plots <- all_dumbbell[c("prev_alcohol", "share_alcohol_totex", "alcohol_2018")]
health_plots <- all_dumbbell[c("prev_health", "share_health_totex", "health_2018")]

## Customize title
tobacco_title <- text_grob("TOBACCO EXPENDITURE", size = 18, family = "HelveticaNeueforSAS", face = "bold")
alcohol_title <- text_grob("ALCOHOL EXPENDITURE", size = 18, family = "HelveticaNeueforSAS", face = "bold")
health_title <- text_grob("HEALTH OUT-OF-POCKET EXPENDITURE", size = 18, family = "HelveticaNeueforSAS", face = "bold")

grid.newpage()
dumbbell_plot <- grid.arrange(arrangeGrob(grobs = tobacco_plots, top = tobacco_title, nrow = 1, heights = 4),
             arrangeGrob(grobs = alcohol_plots, top = alcohol_title, nrow = 1, heights = 4),
             arrangeGrob(grobs = health_plots, top = health_title, nrow = 1, heights = 5), 
             vp = viewport(width = 0.95, height = 0.95))
ggsave("dumbbell_plot.tiff", plot = dumbbell_plot, width = 24, height = 15, units = "cm", scale = 1.75)
###############################################################################

