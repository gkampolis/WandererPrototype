# ZooplanktonClassifierPrototype
A simple prototype to feed in .PID files to a pre-trained classifier.
In its current incarnation, a pre-trained XGBoost model is used.

## Usage
1. Open RStudio by double-clicking the .Rproj file (or any other R IDE that supports root dir determination via .Rproj).
2. Source/run the `Main.R` and follow the on-screen prompts:
   1. Point to an `.RDS` file containing the pre-trained classifier (an XGBoost model is supplied in the `Classifier` folder).
   2. Point to a folder containing the `.pid` files (example files are provided in teh `SamplePID` folder).
3. At the script's end, the results will be save on the same folder as the `.pid` files but in `.csv` format, keeping the same name. This allows for easy separation of results and input. For each `xyz.pid` file the following are generated:
   1. A `xyz_predictions.csv` containing the `!Item` and `Label` identifiers along with the generated predictions.
   2. A `xyz_predictionsSummary.csv` containing the predicted classes along with the number of predictions corresponding to each predicted class, i.e. how many observations are (estimated to be) of each class.

## Overview
 The key functionality is the automatic detection of the `[Data]` flag inside `.pid` files via regular expressions. The user does not have to provide the line number of where that flag is located, especially useful given that it is not the same in all `.pid` files.

 Furthermore, the script is able to distinguish between `.pid` and other files, targeting the `.pid` exclusively.

 Otherwise, the script simply formats the data as expected by the classifier (removal of features unrelated to the classification, adding derived features etc.). The original `.pid` files are left unchanged on disk, all changes are taking place in memory.

 The classifier used in this incarnation has been created by George Kampolis with a process fully documented as part of his MSc. project in collaboration with Marine Scotland:

 Kampolis Georgios, 2019. Automated Zooplankton Classification, Aberdeen: Robert Gordon University.
