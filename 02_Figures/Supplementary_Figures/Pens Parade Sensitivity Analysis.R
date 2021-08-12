###############################################################################
#############################    PEN'S PARADE    ##############################
######################     Code by Nel Jason L. Haw      ######################
###############################################################################

###############################################################################
####### Load libraries
library(tidyverse)
library(ggplot2)
library(reshape)      # reshaping files
library(stringr)      # string detection
library(scales)       # additional options for x and y-axis scales in ggplot
library(haven)        # for importing Stata dta files
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
##### Import Pen's parade data
data_pens <- read_dta("../01_Intermediate_Extracts/tob_alc_health_final_net_pens.dta")
###############################################################################


###############################################################################
#### Create a function to generate the Pen's parade
pens_parade <- function(a, b, d, e, f, g, h, i, j) {
  ## Creating the Pen's parade involves three steps:
  # First, create a scatterplot of per capita income arranged by rank of per capita income
  # Second, create a scatterplot of net income after expenditure arranged by rank of per capita income
  # Make sure the scatterplot points are invisible
  # Third, connect the two points with a vertical line to resemble the paint drips
  # Ideally, there is a fourth step, which is to create a line graph of the first scatterplot, but it can clutter the graph
  ## Elements of the function
  # a = survey year
  # b = per capita income variable
  # d = net income after expenditure variable
  # e = fractional rank of per capita income variable
  # f = pov_change variable
  # g, h = xlim lower/upper
  # i, j = ylim lower/upper
  
  ## Functions handle data frame columns a little differently.
  # When using dplyr functions, use the enquo() & !! operators under tidyeval
  b_e <- enquo(b)
  d_e <- enquo(d)
  e_e <- enquo(e)
  f_e <- enquo(f)
  
  ## Filter the relevant variables and store in data frame called extract
  extract <- data_pens %>% filter(survey == a) %>%
    select(id, !!b_e, !!d_e, !!e_e, !!f_e)
  
  ## Transform the data frame extract in preparation for ggplot
  ## and store in data frame called pens_data
  id <- extract %>% select(id) %>% pull()
  id <- data.frame(id = rep(id, 2))
  x <- extract %>% select(!!e_e) %>% pull()
  x <- data.frame(x = rep(x, 2))
  y_1 <- extract %>% select(!!b_e) %>% pull() %>% as.vector()
  y_2 <- extract %>% select(!!d_e) %>% pull() %>% as.vector()
  y <- rbind(data.frame(y = y_1), data.frame(y = y_2))
  z <- extract %>% select(!!f_e) %>% pull() %>% as.vector()
  z <- data.frame(z = rep(z, 2))
  pens_data <- cbind(id, x, y, z)
  
  ## Store a data frame called linetrick for the poverty threshold line
  linetrick <- data.frame(m = 0, n = 1)
  
  ## Main ggplot function
  pen <- ggplot(data = pens_data, aes(x = x, y = y)) +
    # Add the scatterplot of endpoints (hidden from view)
    geom_point(color = "transparent", size = 0.5) + 
    # Add the paint drips
    geom_line(aes(group = id, color = as.factor(z)), size = 0.00001) +
    ylim(i, j) +
    # Manual color scale
    scale_color_manual(breaks = c(0, 1), values=c("lightgray", poor_maroon)) +
    # Axis titles
    xlab("Cumulative proportion of households ranked by per capita income") +
    ylab("Multiples of provincial urban/rural poverty threshold") +
    # x-axis to percent
    scale_x_continuous(labels = scales::percent_format(accuracy = 1),
                       lim = c(g, h)) +
    # Add pov_thres = 1 horizontal line
    geom_hline(yintercept = 1, size = 1, linetype = "dashed", color = "gray") +
    # Theme
    theme(
      text = element_text("HelveticaNeueforSAS"),
      plot.title = element_blank(),
      axis.text.x = element_text(size = 14, color = "black"),
      axis.text.y = element_text(size = 14, color = "black"),
      axis.title.x = element_text(face = "bold", size = 16, color = "black"),
      axis.title.y = element_text(face = "bold", size = 16, color = "black"),
      axis.ticks = element_blank(),
      legend.position = "none",
      panel.background = element_blank())
  return(pen)
}

#### Zoom in theme
zoom_in <- theme(axis.title.x = element_blank(), 
                 axis.title.y = element_blank(), 
                 plot.background = element_rect(color = "black", fill = "transparent", size = 2),
                 axis.text.x = element_text(size = 10, color = "black"),
                 axis.text.y = element_text(size = 10, color = "black"))


#### Create another function that creates the final plot per expenditure - survey year
pens_parade_plot <- function(a, b, d, e, f, g, h, i, j, k, l, m, n, o, p1, q1, r1, p2, q2, r2, s, t, u, v) {
  ## Create a main plot, then a zoomed in plot around the area where the impoverishment occurs,
  ## then put them altogether
  ## Elements of the function
  # a = survey year
  # b = per capita income variable
  # d = net income after expenditure variable
  # e = fractional rank of per capita income variable
  # f = pov_change variable
  # g, h = xlim lower/upper in main plot
  # i, j = ylim lower/upper in main plot
  # k, l = xlim lower/upper in zoom plot
  # m, n = ylim lower/upper in zoom plot
  # o = plot title (enclose in quotes)
  # p1 = manual point estimate of impoverishment (copy from Stata)
  # q1 = lower 95% CI of impoverishment (copy from Stata)
  # r1 = upper 95% CI of impoverishment (copy from Stata)
  # p2 = manual point estimate of relative change in poverty gap (copy from Stata)
  # q2 = lower 95% CI of relative change in poverty gap (copy from Stata)
  # r2 = upper 95% CI of relative change in poverty gap (copy from Stata)
  # s, t, u, v = xmin, xmax, ymin, ymax of location of zoom plot
  
  ## Functions handle data frame columns a little differently.
  # When using dplyr functions, use the enquo() & !! operators under tidyeval
  b_e <- enquo(b)
  d_e <- enquo(d)
  e_e <- enquo(e)
  f_e <- enquo(f)
  
  ## Create the plots
  mainplot <- pens_parade(a, !!b_e, !!d_e, !!e_e, !!f_e, g, h, i, j)
  zoomplot <- pens_parade(a, !!b_e, !!d_e, !!e_e, !!f_e, k, l, m, n) + zoom_in
  finalplot <- mainplot +
    labs(title = o) +
    geom_text(data = data.frame(x = 0, y = j),
              aes(x = x, y = y, hjust = 0, fontface = "bold",
                  label = paste0("Additional poor households: ", 
                                 format(p1, nsmall = 2), "% (95% CI: ", 
                                 format(q1, nsmall = 2), "% - ", 
                                 format(r1, nsmall = 2), "%) \n",
                                 "Absolute increase in poverty gap: ",
                                 format(p2, nsmall = 2), "% (95% CI: ", 
                                 format(q2, nsmall = 2), "% - ", 
                                 format(r2, nsmall = 2), "%)")),
              color = poor_maroon, size = 5) +
    annotate("rect", xmin = k, xmax = l, ymin = m, ymax = n, color = "black", size = 1, fill = "transparent") +
    annotation_custom(ggplotGrob(zoomplot), xmin = s, xmax = t, ymin = u, ymax = v) +
    theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
          plot.title = element_text(face = "bold", size = 18, color = "black", hjust = 0.5))
  return(finalplot)            
}
###############################################################################


###############################################################################
#### Manually set each plot
## Tobacco
# 2015 Original
tobacco_2015_old2015_pen_final <-
  pens_parade_plot(a = 2, b = poor_old2015_mult, d = diff_poor_old2015_mult_tobacco,
                   e = fracrank_poor_old2015_mult, f = pov_change_old2015_tobacco,
                   g = 0, h = 0.30, i = 0, j = 1.5, k = 0.195, l = 0.22, m = 0.8, n = 1.1,
                   o = "Tobacco 2015 (Original Threshold)", p1 = 0.85, q1 = 0.76, r1 = 0.95,
                   p2 = 0.27, q2 = 0.26, r2 = 0.29,
                   s = 0.05, t = 0.3, u = 0, v = 0.5) +
  theme(axis.title.x = element_blank())
tobacco_2015_old2015_pen_final
# 2015 Revised
tobacco_2015_new2015_pen_final <-
  pens_parade_plot(a = 2, b = poor_new2015_mult, d = diff_poor_new2015_mult_tobacco,
                   e = fracrank_poor_new2015_mult, f = pov_change_new2015_tobacco,
                   g = 0, h = 0.30, i = 0, j = 1.5, k = 0.21, l = 0.245, m = 0.7, n = 1.1,
                   o = "Tobacco 2015 (Revised Threshold)", p1 = 0.84, q1 = 0.75, r1 = 0.94,
                   p2 = 0.29, q2 = 0.27, r2 = 0.31,
                   s = 0.05, t = 0.3, u = 0, v = 0.5) +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_blank())

## Alcohol
# 2015 Original
alcohol_2015_old2015_pen_final <-
  pens_parade_plot(a = 2, b = poor_old2015_mult, d = diff_poor_old2015_mult_alcohol,
                   e = fracrank_poor_old2015_mult, f = pov_change_old2015_alcohol,
                   g = 0, h = 0.30, i = 0, j = 1.5, k = 0.19, l = 0.22, m = 0.8, n = 1.1,
                   o = "Alcohol 2015 (Original Threshold)", p1 = 0.34, q1 = 0.28, r1 = 0.40,
                   p2 = 0.093, q2 = 0.087, r2 = 0.101,
                   s = 0.05, t = 0.3, u = 0, v = 0.5) +
  theme(axis.title.x = element_blank())
# 2015 Revised
alcohol_2015_new2015_pen_final <-
  pens_parade_plot(a = 2, b = poor_new2015_mult, d = diff_poor_new2015_mult_alcohol,
                   e = fracrank_poor_new2015_mult, f = pov_change_new2015_alcohol,
                   g = 0, h = 0.30, i = 0, j = 1.5, k = 0.21, l = 0.245, m = 0.7, n = 1.1,
                   o = "Alcohol 2015 (Revised Threshold)", p1 = 0.36, q1 = 0.30, r1 = 0.42,
                   p2 = 0.10, q2 = 0.09, r2 = 0.11,
                   s = 0.05, t = 0.3, u = 0, v = 0.5) +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_blank())

## Health OOP
# 2015 Original
health_2015_old2015_pen_final <-
  pens_parade_plot(a = 2, b = poor_old2015_mult, d = diff_poor_old2015_mult_health,
                   e = fracrank_poor_old2015_mult, f = pov_change_old2015_health,
                   g = 0, h = 0.90, i = 0, j = 6, k = 0.19, l = 0.29, m = 0.5, n = 1.2,
                   o = "Health OOP 2015 (Original Threshold)", p1 = 1.00, q1 = 0.90, r1 = 1.11,
                   p2 = 0.36, q2 = 0.29, r2 = 0.42,
                   s = 0, t = 0.65, u = 2.6, v = 5.5)
# 2015 Revised
health_2015_new2015_pen_final <-
  pens_parade_plot(a = 2, b = poor_new2015_mult, d = diff_poor_new2015_mult_health,
                   e = fracrank_poor_new2015_mult, f = pov_change_new2015_health,
                   g = 0, h = 0.90, i = 0, j = 6, k = 0.21, l = 0.3, m = 0.4, n = 1.2,
                   o = "Health OOP 2015 (Revised Threshold)", p1 = 1.01, q1 = 0.92, r1 = 1.12,
                   p2 = 0.38, q2 = 0.32, r2 = 0.44,
                   s = 0, t = 0.65, u = 2.6, v = 5.5) +
  theme(axis.title.y = element_blank())
###############################################################################


###############################################################################
#### Putting them altogether
tobacco_plots <- list(tobacco_2015_old2015_pen_final, tobacco_2015_new2015_pen_final)
alcohol_plots <- list(alcohol_2015_old2015_pen_final, alcohol_2015_new2015_pen_final)
health_plots <- list(health_2015_old2015_pen_final, health_2015_new2015_pen_final)

grid.newpage()
pens_parade_full <- 
  grid.arrange(arrangeGrob(grobs = tobacco_plots, nrow = 1, heights = 4),
               arrangeGrob(grobs = alcohol_plots, nrow = 1, heights = 4),
               arrangeGrob(grobs = health_plots, nrow = 1, heights = 4),
               vp = viewport(width = 0.95, height = 0.95))

ggsave("Supplementary_Figures/pens_parade_sensi.tiff", plot = pens_parade_full, width = 18, height = 18, units = "cm", scale = 2.8)

# Add the poverty threshold text
# geom_text(data = linetrick, aes(x = m, y = n, label = "poverty threshold", vjust = -0.5, hjust = 0), size = 14)