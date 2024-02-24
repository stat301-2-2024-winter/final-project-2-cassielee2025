## Original dataset

The original dataset, `US_births(2018).csv`, was downloaded from the ["US births (2018)"](https://www.kaggle.com/datasets/des137/us-births-2018/data) dataset created by Amol Deshmukh on Kaggle. Deshmukh created this dataset from the raw 2018 natality file available from the [Vital Statistics Online Data Portal](https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm#Tools). 

The original dataset has been added to the `.gitignore` file in the main project directory because the file is 507.9 MB and cannot be uploaded to the Github repository.

## Subsampled dataset: `birth_data.rda`

37 variables (including target variable) were selected from the original dataset according to the variables selected for the [Kaggle Prediction interval competition I: Birth weight competition](https://www.kaggle.com/competitions/prediction-interval-competition-i-birth-weight/data). These variables were selected to match the Kaggle competition to simplify the processes of identifying predictors to be used in the models. 

Missing values (ex: 3, 9, 99, 99.9, 9999, "U") from the original dataset were converted to `NA` values, and incomplete observations were removed from the dataset. 

30,000 observations were then randomly sampled form the original dataset for use in exploratory data analysis, training models, and testing models. 

The target variable is birth weight, `dbwt`.

Two variables, `plural_del` and `any_precare` are logical variables created from the variables `illb_r`, `ilp_r`, and `precare` because these variables contained multiple types of information (i.e. whether or not there was prenatal care and what month the care began). `plural_del` refers to whether or not the pregnancy resulted in a plural delivery. `any_precare` refers to whether or not there was any prenatal care.

## Data splits (`data_split/`)
The subsetted observations with split into two datasets. These datasets are mutually exclusive. This also contains the training, testing, and resampled datasets.

## Data codebook
`UserGuide2018-508.pdf` is the full data codebook with all variables from the 2018 Natality
Public Use File.

`natality_codebook.txt` is the condensed codebook with only variables appearing in `US_births(2018).csv`.