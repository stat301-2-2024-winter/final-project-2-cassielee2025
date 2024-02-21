## Overview

This folder contains all the .R scripts associated with the project.

## Files
- `1_read_in_data.R`: reading in original data, subsetting data, checking data quality
- `2_target_variable_analysis.R`: splitting subsetted data into EDA data and modeling data, univariate analysis of birth weight (`dbwt`)
- `3_eda.R`: EDA of 20,000 variables
- `4_data_split_fold.R`: split model data into training and testing sets and create resampled dataset using vfold cross validation
- `5_recipes.R`: creating two recipes, one for linear/elastic net models, one for tree based models
- `6_fit_boosted_tree.R`: fit boosted tree model/workflow with resamples
- `6_fit_elastic.R`: fit elastic net model/workflow with resamples
- `6_fit_lm.R`: fit linear model/workflow with resamples
- `6_fit_random_forest.R`: fit random forest model/workflow with resamples
- `6_fit_null.R`: fit null model/workflow with resamples
