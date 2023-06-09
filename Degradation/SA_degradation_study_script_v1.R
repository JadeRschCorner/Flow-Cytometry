---
# title: "Calculating the Concentration of Salicylic acid in backwash water and media"
# Description: Using Standard Curve to calculate concentration of SA from degradation study UV absorbance (298nm) data
# author: "Natchaya Luangphairin"
# date last revised: "5/17/2023"
# output: R Script
---
# install and load pacman if not already installed
install.packages("pacman")
library(pacman)
# This will install the libraries if they are not already installed, and then load them into your R session.
p_load(ggpmisc, ggplot2, readxl, openxlsx) 

  #################################################################################
  ################### script to analyze media UV standard curve ###################
  #################################################################################
    media_conc_oct22 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 10/19/2022, media sample
    media_abs_oct22 <- c(2.174, 1.415, 0.53, 0.25, 0.118, 0.05, 0.023)

    media_conc_nov22 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 11/3/2022, media sample
    media_abs_nov22 <- c(2.294, 1.308, 0.646, 0.316, 0.161, 0.087, 0.032)

    media_conc_dec22 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 12/28/2022, media sample
    media_abs_dec22 <- c(1.775, 0.784, 0.383, 0.195, 0.098, 0.045, 0.026)

    media_conc_feb23 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 2/17/2023, media sample
    media_abs_feb23 <- c(1.775, 0.784, 0.383, 0.195, 0.098, 0.045, 0.026)

    media_conc_mar23 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 3/12/2023, media sample
    media_abs_mar23 <- c(1.551, 0.889, 0.404, 0.187, 0.092, 0.038, 0.011)

    media_conc_apr23 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 4/12/2023, media sample
    media_abs_apr23 <- c(2.143, 1.099, 0.568, 0.284, 0.145, 0.075, 0.038)

  ##########################################################################################
  ################### script to analyze backwash water UV standard curve ###################
  ##########################################################################################

    bw_conc_nov22 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 11/3/2022, bw sample
    bw_abs_nov22 <- c(1.759, 0.907, 0.454, 0.228, 0.114, 0.057, 0.028)

    bw_conc_dec22 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 12/28/2022, bw sample
    bw_abs_dec22 <- c(1.889, 1.156, 0.562, 0.347, 0.273, 0.198, 0.1)

    bw_conc_feb23 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 2/17/2023, bw sample
    bw_abs_feb23 <- c(1.889, 1.156, 0.562, 0.347, 0.273, 0.198, 0.1)

    # bw_conc_mar23 <- c() # from 3/12/2023, missed bw sample collection
    # media_abs_mar23 <- c()

    bw_conc_apr23 <- c(100, 50, 25, 12.5, 6.25, 3.125, 1.5625) # from 4/12/2023
    bw_abs_apr23 <- c(2.190, 1.394, 0.787, 0.320, 0.148, 0.067, 0.031)

  #########################################################################
  ###################  script to plot UV standard curve ###################
  #########################################################################
    # define input UV curve data
    Conc <- media_conc_apr23
    Abs <- media_abs_apr23

    my.formula <- 42.0659*(Abs)-0.5157

    # plot all
      ggplot(mapping = aes(x = Conc, y = Abs)) + 
        geom_point() +
        xlab("Concentration (mg/L)") +
        ylab("Absorbance") +
        ggtitle("Standard curve for salicylic acid in backwash water on UV-VIS, 70 mg/L to 0.55 mg/L") +
        geom_smooth(method = "lm", se=FALSE, color="black", formula = my.formula) +
        stat_poly_eq(formula = my.formula,
                      eq.with.lhs = "italic(hat(y))~`=`~",
                      aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
                      parse = TRUE) +
        theme_bw()

  ###############################################################################################
  ###################  script to calculate UV Absorbance to SA Concentrations ###################
  ###############################################################################################
    # input month of interest
    Conc <- media_conc_apr23
    Abs <- media_abs_apr23

    Conc <- bw_conc_apr23
    Abs <- bw_abs_apr23

    fit <- lm(Conc ~ Abs)
    summary(fit) # from data4 we get slope of 56.7262 and intercept of -0.3957. So, conc = (56.7262*(Abs)-0.3957

    # First, define your standard curve equation by fitting standard UV curve data
    std_curve_eqn <- function(x, fit) {
      m <- fit$coefficients[2]
      b <- fit$coefficients[1]
      sigma <- summary(fit)$sigma
      
      # Calculate the predicted y-values using the equation y = mx + b
      y_pred <- m*x + b
      
      # Return a list containing the predicted y-values and the residual standard error
      return(list(y_pred = y_pred, sigma = sigma))
    }


    # Use the standard curve equation to calculate the concentrations of salicylic acid
    # set the path to the Excel file
    excel_file <- "C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Degradation Research/data/processed/SA_data_BW_Media.xlsx"
    # read in the data from the sheet
    sheet_name = "media_apr23" # change sheet name
    my_data <- read.xlsx(excel_file, sheet = sheet_name) 
     
    # extract the data from the 'UV_Abs' row
    uv_abs_data <- my_data$UV_Abs

    conc_data  <- std_curve_eqn(uv_abs_data, fit) 
    y_pred <- conc_data$y_pred
    sigma <- conc_data$sigma 

    print(conc_data)

    wb <- loadWorkbook(excel_file)
    # Write the numeric list to a column in the sheet
    writeData(wb, sheet = sheet_name, x = y_pred, startCol = 9, startRow = 2, colNames = FALSE)

    # Save the changes to the workbook
    saveWorkbook(wb, excel_file, overwrite = TRUE)



---
# title: "Script to process the SA degradation experiments, both Backwash and Media"
# Description: Used to plot SA concentrauin over time of degradation study data for media and backwash water
# author: "Natchaya Luangphairin"
# date last revised: "5/17/2023"
# output: R Script
---

  setwd("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Degradation Research")
  # to choose a folder interactively:
    #setwd("C://Users/nluan/")
    #setwd(choose.dir())

  #Choose the location of file, a pop-up window.
      #path <- choose.dir(default = "", caption = "Select folder that contains the .fcs files to analyze")
      path <- "C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Degradation Research"


    # Create a new folder in this path called "plots" that will be written to later:
      dir.create(paste(path, "/plots_auto_folder", sep = ""))

  # Open the data file
    SA_data_BW_Media <- read_excel("data/processed/SA_data_BW_Media_Master.xlsx",sheet = "Master")
    View(SA_data_BW_Media)


  ###########################################################################
  ###################  script to plot the various figures ###################
  ###########################################################################

    # create new column for grouping by last 5 characters
    SA_data_BW_Media$month <- substr(SA_data_BW_Media$experiment_type, nchar(SA_data_BW_Media$experiment_type)-5, nchar(SA_data_BW_Media$experiment_type))
    SA_data_BW_Media$month <- factor(SA_data_BW_Media$month, levels = c("Oct 22", "Nov 22", "Dec 22", "Feb 23", "Mar 23", "Apr 23"))

    SA_data_BW_Media$study_type <- substr(SA_data_BW_Media$experiment_type, 1, regexpr(" ", SA_data_BW_Media$experiment_type)-1)

    # define marker shapes for each month, solid line for media and dotted for bw
    markers <- c("circle", "square", "triangle", "diamond", "8", "1")

      SA_conc <- ggplot(data=subset(SA_data_BW_Media, !is.na(SA_mg_L)), aes(x = elapsed_hours, y = SA_mg_L, interaction(experiment_type), shape = month, linetype = study_type)) + 
          geom_line() +
          geom_point(size = 2) +
          scale_x_continuous(breaks=seq(0,55,5)) +
          scale_linetype_manual(values = c("dotted", "solid")) +
          labs(title = 'Change in Salcylic Acid (SA) Concentration Over Time', x = "Elapsed Hours", y = "SA Concentration (mg/L)", caption = '') +
          theme_classic()
        SA_conc


      #ggsave(SA_conc, filename = paste("SA_conc_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))

      SA_decrease_percent <- ggplot(data=subset(SA_data_BW_Media, !is.na(percent_decrease)), aes(x = elapsed_hours, y = percent_decrease, group = experiment_type, shape = month, linetype = study_type)) + 
          geom_line() +
          geom_point(size = 2) +
          scale_x_continuous(breaks=seq(0,55,5)) +
          scale_linetype_manual(values = c("dotted", "solid")) +
          labs(title = 'Percent Decrease in Salcylic Acid (SA) Concentration Over Time', x = "Elapsed Hours", y = "SA removal (%)", caption = '') +
          theme_classic()
        SA_decrease_percent

      #ggsave(SA_decrease_percent, filename = paste("SA_decrease_percent_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))

      pH <- ggplot(data=subset(SA_data_BW_Media, !is.na(pH)), aes(x = elapsed_hours, y = pH, group = experiment_type, shape = month, linetype = study_type)) + 
          geom_line() +
          geom_point(size = 2) +
          scale_x_continuous(breaks=seq(0,55,5)) +
          scale_linetype_manual(values = c("dotted", "solid")) +
          labs(title = 'Change in pH Over Time', x = "Elapsed Hours", y = "pH", caption = '') +
          theme_classic()
        pH

      #ggsave(pH, filename = paste("pH_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))

      DO_mg_L <- ggplot(data=subset(SA_data_BW_Media, !is.na(DO_mg_L)), aes(x = elapsed_hours, y = DO_mg_L, group = experiment_type, shape = month, linetype = study_type)) + 
          geom_line() +
          geom_point(size = 2) +
          scale_x_continuous(breaks=seq(0,55,5)) +
          scale_linetype_manual(values = c("dotted", "solid")) +
          labs(title = 'Change in DO Over Time', x = "Elapsed Hours", y = "DO (mg/L)", caption = '') +
          theme_classic()
        DO_mg_L

      #ggsave(DO_mg_L, filename = paste("DO_mg_L_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))

      Temperature <- ggplot(data=subset(SA_data_BW_Media, !is.na(T)), aes(x = elapsed_hours, y = T, group = experiment_type, shape = month, linetype = study_type)) + 
          geom_line() +
          geom_point(size = 2) +
          scale_x_continuous(breaks=seq(0,55,5)) +
          scale_linetype_manual(values = c("dotted", "solid")) +
          labs(title = 'Change in T Over Time', x = "Elapsed Hours", y = "T (\u00B0C)", caption = '') +
          theme_classic()
        Temperature

      #ggsave(Temperature, filename = paste("Temperature_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))




    # Arrange some in a grid

      # Packages
      library(ggplot2)
      library(gridExtra)
      library("cowplot")

      # Plots
      p1 <- SA_decrease_percent + theme(legend.position="none") + labs(title = 'SA removal', tag = "A")
      p2 <- DO_mg_L + theme(legend.position="none") + labs(title = 'DO', tag = "B")
      p3 <- Temperature + theme(legend.position="none") + labs(title = 'Temperature', tag = "C")
      p4 <- pH + theme(legend.position="none") + labs(title = 'pH', tag = "D")


      # Get legend
      Temperature_bottom_legend <- ggplot(data=subset(SA_data_BW_Media, !is.na(T)), aes(x = elapsed_hours, y = T, group = experiment_type, shape = month, linetype = study_type)) + 
          geom_line() +
          geom_point() +
          scale_x_continuous(breaks=seq(0,55,5)) +
          scale_linetype_manual(values = c("dotted", "solid")) +
          labs(title = 'Change in T Over Time', x = "Elapsed Hours", y = "T (\u00B0C)", caption = '') +
          theme_classic() + 
          theme(legend.position = "bottom", legend.title= element_blank())
        Temperature_bottom_legend
      legend <- get_legend(Temperature_bottom_legend)


      grid_plots <- grid.arrange(p1, p2, p3, p4, legend, ncol=2, nrow = 3, 
                 layout_matrix = rbind(c(1,2), c(3,4), c(5,5)),
                 widths = c(2.7, 2.7), heights = c(2.5, 2.5, 0.2))

      #ggsave(grid_plots, filename = paste("grid_plots_", Sys.Date(), ".jpeg", sep=""), width=8, height=8, units="in", path = paste(path, "/plots_auto_folder", sep = ""))


    # Oxygen uptake rate graph (1st 15min DO during beginning of degradation study)
      Oxygen_uptake_rate_data <- read_csv("C:/Users/nluan/Box Sync/USF PhD CEE/Summer_2022_REUs/Andrew_analysis/Oxygen_uptake_rate_data.csv", col_types = cols(date = col_number(), elapsed_hours = col_number(), pH = col_number(), DO_mg_L = col_number(), T = col_number(), UV_Abs = col_number(), SA_mg_L = col_number(), percent_decrease = col_number()))
      View(Oxygen_uptake_rate_data)

        oxygen_uptake_rate_graph <- ggplot(data=Oxygen_uptake_rate_data, aes(x = Time_min, y = DO_mg_L, group = Experiment, shape = Experiment)) + 
          geom_point(size = 3) +
          geom_smooth(method="lm", se = FALSE, color = "black") +
          stat_regline_equation(label.x= c(8, 8, 8), label.y= c(7, 6.8, 6.6)) +
              stat_cor(aes(label=..rr.label..), label.x= c(11.6, 11.6, 11.6), label.y= c(7.04, 6.84, 6.64)) +
          scale_x_continuous(breaks=seq(0,15,1)) +
          labs(title = 'Oxygen Uptake Rate', x = "Elapsed Minutes", y = "DO (mg/L)", caption = 'Oxygen uptake rate graph for the 3 trials with data') +
          theme_classic()
        oxygen_uptake_rate_graph

        #ggsave(oxygen_uptake_rate_graph, filename = paste("oxygen_uptake_rate_graph_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))


      # re-graph but just do a linear relationship for media trial 1
        oxygen_uptake_rate_graph <- ggplot(data=Oxygen_uptake_rate_data, aes(x = Time_min, y = DO_mg_L, group = Experiment, shape = Experiment)) + 
          geom_point(size = 3) +
          geom_smooth(data = subset(Oxygen_uptake_rate_data, Experiment == 'Media trial 1'), method="lm", se = FALSE, color = "black") +
          stat_regline_equation(label.x= c(8, 8, 8), label.y= c(7, 6.8, 6.6)) +
              stat_cor(aes(label=..rr.label..), label.x= c(11.6, 11.6, 11.6), label.y= c(7.04, 6.84, 6.64)) +
          scale_x_continuous(breaks=seq(0,15,1)) +
          labs(title = 'Dissolved oxygen of BOD bottle', x = "Elapsed Minutes", y = "DO (mg/L)", caption = "Oxygen uptake rate determination, Summer '22 REUs") +
          theme_classic()
        oxygen_uptake_rate_graph

        #ggsave(oxygen_uptake_rate_graph, filename = paste("oxygen_uptake_rate_graph_", Sys.Date(), ".jpeg", sep=""), width=8, height=6, units="in", path = paste(path, "/plots_auto_folder", sep = ""))

