# Intro Comments ----------------------------------------------------------

# Purpose: Script to load required packages for classifying unseen particles.
# Author: Georgios Kampolis
# For: Marine Scotland Science
# Comments: As part of RGU MSc course in Data Science

# Details: This script is called by Main.R in the root folder of the project.



# Install the same versions of packages as during development -------------

if (verifyCorrectVersions) {
  pacman::p_install_version(
    c("here", "readr", "dplyr", "forcats", "tidyr", # data loading & manipulation
      "mlr", "xgboost",                             # ML pkgs
      "beepr"                                       # notify at end of lengthy procedures
    ),
    c("0.1", "1.3.1", "0.8.3", "0.4.0", "0.8.3",
      "2.14.0", "0.82.1",
      "1.3"
    )
  )
}



# Package management ------------------------------------------------------

pacman::p_load( # This is equivalent to library (+install.packages if needed)
  # File path constructor (auto root dir determination)
  here,
  # Read in data
  readr,
  # Data wrangling
  dplyr, forcats, tidyr,
  # Machine learning
  mlr,
  # Notify when done
  beepr,
  update = FALSE
)


message("Package management script complete!")
