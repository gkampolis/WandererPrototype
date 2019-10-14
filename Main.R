# Intro Comments ----------------------------------------------------------

# Purpose: This script forms the main skeleton for using a previously trained
# classifier (in this case XGBoost) to predict classes of unseen -to the
# classifier- particles.

# Author: Georgios Kampolis
# For: Marine Scotland Science
# Comments: As part of RGU MSc course in Data Science

# Details: It assumes that it is located at the root of the project folder and
# accessed after reading the .Rproj file (for the relative paths to work).
# Simplest way to do so is to launch RStudio by double-clicking the .Rproj file
# and then access this script.


# Initial packages --------------------------------------------------------

## platform-agnostic path construction & root determination:
if (!require("here")) install.packages("here"); library(here)

## package management that takes care of loading and installing if necessary:
if (!require("pacman")) install.packages("pacman"); library(pacman)


# Flags for flow control --------------------------------------------------

# Flag to install packages at the version used during development of this project.
# There is no need to keep this as TRUE after first run.
verifyCorrectVersions <- TRUE


# Load required packages --------------------------------------------------

source(here::here("Scripts","loadPackages.R"))
## returns: messages re: packages and message at end of script.


# Load classifier ---------------------------------------------------------

# Ask user for path to an existing .rds file with the model on disk
rstudioapi::showDialog(
  title = "Prompt",
  message = "In the next dialog, please select the classifier to load."
)

# Get the path
path <- rstudioapi::selectFile(
  caption = "Select classifier",
  filter = "RDS Files (*.rds)",
  existing = TRUE
)

# Load indicated classifier
classifier <- read_rds(path)


# Find folder with particle data ------------------------------------------

# Ask user for path to an existing folder with the .pid files on disk
rstudioapi::showDialog(
  title = "Prompt",
  message = "In the next dialog, please select the folder containing the .PID files."
)

# Get directory
pidDir <- rstudioapi::selectDirectory(
  caption = "Select directory with PID files.",
  label = "Select"
)

# Get names of .pid files in the directory
pidFiles <- base::list.files(pidDir, pattern = "*.pid")

# Get path separator, depending on OS, to construct paths.
fileSep <- base::.Platform$file.sep

# Classify ----------------------------------------------------------------

if (length(pidFiles) < 1) {
  message("Directory doesn't contain any .pid files or other error.")
} else {
  # Iterate over all .pid files
  for (pidCounter in 1L:length(pidFiles)) {
    # Find the "[Data]" flag in .pid and read from the next line on
    readSkip <- grep("\\[Data\\]", read_lines(paste0(pidDir,fileSep,pidFiles[pidCounter])))
    
    # Read in data
    data <- read_delim(
      file = paste0(pidDir,fileSep,pidFiles[pidCounter]),
      delim = ";",
      col_names = TRUE,
      skip = readSkip
    )
    
    # Keep subset of data for tracking particles
    result <- data %>% select(`!Item`, Label)
    
    # Clean the data
    data <- data %>% 
      # Keep features of interest only
      select(-c(`!Item`, Label, BX, BY, Width, XMg5, YMg5,
                Height, Angle, XStart, YStart,
                Compentropy, Compmean, Compslope, CompM1,
                CompM2, CompM3, Tag)
      ) %>% 
      # Add additional derived features
      mutate(Mean_exc = IntDen / Area_exc,
             ESD = 2 * sqrt(Area / pi),
             Elongation = Major / Minor,
             Range = Max - Min,
             MeanPos = (Max - Mean)/Range,
             CentroidsD = sqrt((XM - X)^2 + (YM - Y)^2),
             CV = 100 * (StdDev / Mean),
             SR = 100 * (StdDev / Range),
             PerimAreaexc = Perim. / Area_exc,
             FeretAreaexc = Feret / Area_exc,
             PerimFeret = Perim. / Feret,
             PerimMaj = Perim. / Major,
             Circexc = (4*pi*Area_exc) / Perim.^2,
             CDexc = (CentroidsD^2)/Area_exc
      ) %>% 
      # Remove unneeded features
      select(-c(X, Y, XM, YM)) %>%
      # Rename feature to conform to R's and mlr's expectations
      rename(Area_perc = `%Area`) %>% 
      # Specify dataframe rather than tibble, ensures compatibility w/ mlr
      as.data.frame()
    
    # Generate predictions
    predictions <- predict(classifier, newdata = data)
    
    # Keep only the response
    result$Predictions <- predictions$data$response
    
    # Create summary
    resultSummary <- result %>% 
      group_by(Predictions) %>% 
      summarise(sum = n()) %>% 
      arrange(desc(sum))
    
    # Save results
    write_csv(
      result,
      path = paste0(
        pidDir,fileSep,sub(".{4}$","_predictions.csv",pidFiles[pidCounter])
      )
    )
    
    write_csv(
      resultSummary,
      path = paste0(
        pidDir,fileSep,sub(".{4}$","_predictionsSummary.csv",pidFiles[pidCounter])
      )
    )
  }
}

message("Results saved in along with .pid files in orginal directory:")
message(pidDir)

rstudioapi::showDialog(
  title = "Script complete!",
  message = paste0(
    "Results saved in along with .pid files in orginal directory: \n", pidDir
  )
)

message("Script complete!")
# Play sound to notify that the end of the script has been reached.
beepr::beep(1)
