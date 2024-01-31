## Original Dataset

The original dataset, `US_births(2018).csv`, was downloaded from the ["US births (2018): 2018 Natality Public Use File"](https://www.kaggle.com/datasets/des137/us-births-2018/data) dataset created by Amol Deshmukh on Kaggle. Deshmukh created this dataset from the raw natality file available from the [Vital Statistics Online Data Portal](https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm#Tools). 

## Subsampled Dataset: `birth_data.rda`

37 variables (including target variable) were selected from the original dataset according to the variables selected for the [Kaggle Prediction interval competition I: Birth weight competition](https://www.kaggle.com/competitions/prediction-interval-competition-i-birth-weight/data). These variables were selected to match the Kaggle competition to simplify the processes of identifying predictors to be used in the models. 

Missing and not applicable values (ex: 3, 9, 99, 99.9, 9999, "U") from the original dataset were converted to `NA` values, and incomplete observations were removed from the dataset. 

60,000 observations were then randomly sampled form the original dataset for use in exploratory data analysis, training models, and testing models. 

## Data codebook
`UserGuide2018-508.pdf` is the full data codebook with all variables from the 2018 Natality
Public Use File.

`natality_codebook.txt` is the condensed codebook with only variables appearing in `US_births(2018).csv`.