# Investment Outcome Prediction using Machine Learning in R

## Description

This project analyzes a dataset of investment transactions (`investment_transactions.csv`) to understand patterns and predict investment outcomes. It performs Exploratory Data Analysis (EDA), builds classification models (Decision Tree, Logistic Regression) to predict whether an investment will be "GOOD" or "BAD", and constructs a linear regression model to predict the expected yearly return.

## Data

The script requires an input file named `investment_transactions.csv` located in the same directory. The dataset is expected to contain information about individual investment transactions, including:

* Company identifiers (`company`)
* Industry sector (`sector`)
* Investment horizon (`horizon..days.`)
* Investment amount (`amount`)
* Buy and Sell prices (`price_BUY`, `price_SELL`)
* Volatility metrics (`Volatility_Buy`, `Volatility_sell`)
* Risk/Return metrics (`Sharpe.Ratio`, `expected_return..yearly.`, `nominal_return`)
* Macroeconomic factors (`inflation`)
* Company fundamentals (ESG ranking, various financial ratios like PE, EPS, PS, PB, NetProfitMargin, current ratio, ROA, ROE)
* The investment outcome (`investment` - Categorical: "GOOD"/"BAD")

## Dependencies

The script requires the following R packages:

* `ggplot2`
* `readxl` (loaded but not used in current CSV implementation)
* `rpart`
* `rpart.plot`
* `caret`
* `pROC` (loaded but not used in current implementation)
* `dplyr`
* `corrplot`

You can install missing packages using `install.packages("package_name")`.

## Usage

1.  Ensure the required R packages are installed.
2.  Place the `investment_transactions.csv` file in the same directory as the R script.
3.  Open the R script in your R environment (like RStudio).
4.  Run the script line by line or source the entire file using `source("your_script_name.R")`.

## Methodology

1.  **Data Loading & Preprocessing:**
    * Loads the CSV data.
    * Removes rows with any missing values (`na.omit`).
    * Renames columns for easier access.
    * Removes date columns and an unnecessary 'X' column.
2.  **Exploratory Data Analysis (EDA):**
    * Calculates summary statistics.
    * Visualizes distributions of numerical variables using histograms.
    * Visualizes distributions of categorical variables using bar plots.
    * Examines relationships between variables using scatter plots and grouped bar plots (e.g., returns by sector).
    * Calculates and visualizes correlation matrices to understand relationships between numerical predictors and identify potential multicollinearity.
3.  **Data Splitting:**
    * Splits the data into a training set (`test`) and a validation set (`valid`) using a simple interleaving method (alternating rows).
4.  **Modeling:**
    * **Decision Tree (Classification):**
        * Uses `rpart` to build a tree predicting "GOOD"/"BAD" (`investment`).
        * Builds both a default tree and a deeper, potentially overfit tree.
        * Evaluates performance on training and validation sets using `confusionMatrix`.
        * Provides an example of predicting a new data point.
    * **Logistic Regression (Classification):**
        * Uses `glm` (Generalized Linear Model) with `family = "binomial"` to predict "GOOD"/"BAD".
        * Converts the target variable to 0/1 for the model.
        * Evaluates performance using `confusionMatrix`.
        * Provides an example of predicting a new data point.
    * **Linear Regression (Regression):**
        * Uses `lm` to predict the continuous `expected_return_yearly`.
        * *Note:* This model uses the entire dataset and converts categorical variables (`sector`, `company`, `investment`) to numerical factors, which may not be appropriate for nominal variables.
        * Provides an example of predicting a new data point.

## Outputs

The script generates:

* Console output including summary statistics, correlation values, model summaries, and confusion matrices (accuracy metrics).
* Various plots displayed during execution (histograms, bar plots, scatter plots, correlation matrix plot, decision tree plots).
* Example predictions for new data points for each model type.

