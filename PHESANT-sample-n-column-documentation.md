# Sample "n" Column Documentation

## Overview

This document provides comprehensive documentation on the provenance and meaning of the sample "n" column present in the output of `mainCombineResults.r`. The "n" column represents the **number of participants with non-missing data** used in the statistical model for each phenotype test, but its format and exact meaning vary depending on the type of regression test performed.

## Purpose

The "n" column serves to:
1. Report the effective sample size used in each statistical test
2. Help researchers understand data completeness for each phenotype
3. Enable assessment of statistical power for each association test
4. Support interpretation of results by showing how many participants contributed to each analysis

## Important Note on Sample Representation

The "n" value represents **participants with complete, non-missing data** for the specific test after all quality control steps. This count:
- **Does NOT** represent the total number of participants in the dataset
- **Does NOT** include participants with missing values (NA) for the phenotype
- **Does NOT** include participants removed due to quality control filters
- **MAY** be misleading if interpreted as the total available sample, as it reflects only those used in the final model

## Format by Regression Type

The "n" column uses different formats depending on the type of statistical test performed:

### 1. Linear Regression (Continuous Variables)

**Format:** `numNotNA`

**Example:** `1000`

**Calculation:**
```r
numNotNA = length(which(!is.na(phenoIRNT)))
```

**Source Code:** `WAS/testContinuous.r` (line 220)

**Description:**
- Simple count of participants with non-missing values for the phenotype
- Calculated after inverse rank normal transformation (IRNT)
- Requires minimum of 500 participants (hard-coded threshold in line 167)
- Represents participants with complete data for:
  - The transformed phenotype variable
  - The trait of interest (e.g., genetic variant)
  - All confounders (age, sex, assessment centre, etc.)

**Quality Control Filters:**
- Missing values (NA) are excluded
- Values initially coded as NaN are converted to NA
- For multi-instance fields, uses row means across arrays
- Minimum threshold: 500 participants

### 2. Binary Logistic Regression

**Format:** `idxTrue/idxFalse(numNotNA)`

**Example:** `300/600(900)` means 300 cases, 600 controls, 900 total

**Calculation:**
```r
idxTrue = length(which(phenoFactor==facLevels[1]))
idxFalse = length(which(phenoFactor==facLevels[2]))
numNotNA = length(na.omit(phenoFactor))
```

**Source Code:** `WAS/binaryLogisticRegression.r` (lines 37-39, 101, 104)

**Description:**
- Shows distribution of cases and controls
- `idxTrue`: Count of participants with the first factor level (typically cases or presence of trait)
- `idxFalse`: Count of participants with the second factor level (typically controls or absence)
- `numNotNA`: Total participants with either value (should equal idxTrue + idxFalse)

**Quality Control Filters:**
- Both groups must have at least 10 participants (opt$mincase, default=10, line 41)
- Total sample must be at least 500 participants (line 45)
- Missing values are excluded
- For categorical multiple fields, negative values (<0) indicating missingness are handled specially

**Special Case - Categorical Multiple Fields:**
For categorical multiple fields (e.g., disease diagnoses where multiple can be selected), the sample restriction varies based on the `CAT_MULT_INDICATOR_FIELDS` setting:
- **NO_NAN**: Only includes participants who answered the question (have at least one value)
- **ALL**: Includes all participants in the dataset
- **fieldID**: Only includes participants with a value in the specified indicator field

### 3. Ordered Logistic Regression (Ordinal Categorical)

**Format:** `numNotNA`

**Example:** `889`

**Calculation:**
```r
numNotNA = length(which(!is.na(pheno)))
```

**Source Code:** `WAS/testCategoricalOrdered.r` (line 39, 106)

**Description:**
- Count of participants with non-missing values for the ordinal phenotype
- Does not show distribution across categories (unlike binary logistic)
- Represents all participants with valid category values

**Quality Control Filters:**
- Minimum 500 participants required (line 40)
- Each category must have at least 10 participants (checked in doCatOrdAssertions, line 155)
- Must have at least 3 categories (checked in assertions, lines 147-148)
- Missing values (NA) are excluded
- Values <0 are considered missing and excluded

### 4. Multinomial Logistic Regression (Unordered Categorical)

**Format:** 
- Overall model result: `maxFreq/numNotNA`
- Category-specific results: `maxFreq#numThisValue`

**Examples:** 
- `300/1000` (overall): 300 in reference category, 1000 total
- `300#150` (category-specific): 300 in reference, 150 in this category

**Calculation:**
```r
maxFreq = length(which(phenoFactor==reference))  # reference category count
numNotNA = length(which(!is.na(pheno)))          # total participants
numThisValue = length(which(phenoFactor==u))     # specific category count
```

**Source Code:** `WAS/testCategoricalUnordered.r` (lines 90-92, 126, 129)

**Description:**
- **Overall model result** (beta=-999, one row per phenotype): Shows reference category size and total sample
  - `maxFreq`: Count in the reference category (category with most participants)
  - `numNotNA`: Total participants with valid values across all categories
- **Category-specific results** (one row per non-reference category): Shows reference category and specific category sizes
  - `maxFreq`: Count in the reference category (same for all categories)
  - `numThisValue`: Count in this specific category being tested
  
The reference category is automatically selected as the category with the largest number of participants.

**Quality Control Filters:**
- Minimum 500 participants required (line 28)
- Model complexity check: (num_categories-1) × (num_predictors+1) must be ≤1000 (lines 38-42)
- Missing values are excluded
- Values <0 are considered missing (for numeric fields)

## Data Processing Flow

The "n" values are calculated at different points in the data processing pipeline:

1. **Data Loading**: Raw phenotype data is loaded from CSV files
2. **Value Reassignment**: Values are reassigned based on data coding file specifications
3. **Missing Value Handling**: 
   - NA values are identified
   - NaN values (from row means of all-NA rows) are converted to NA
   - Negative values (<0) are treated as missing for numeric fields
4. **Quality Control Filters Applied**:
   - Minimum case requirements (default 10 per group)
   - Minimum total sample requirements (500 for most tests)
   - Category-specific filters for ordered/unordered categorical
5. **Sample Counting**: The "n" value is calculated on the final dataset after all filters
6. **Model Fitting**: Statistical models are fit using the filtered dataset
7. **Results Writing**: The "n" value is written to results files alongside beta, CI, p-value

## Key Code References

| Regression Type | Source File | Line(s) | Function |
|----------------|-------------|---------|----------|
| Linear | `WAS/testContinuous.r` | 220, 223 | `testContinuous2` |
| Binary Logistic | `WAS/binaryLogisticRegression.r` | 37-39, 101, 104 | `binaryLogisticRegression` |
| Ordered Logistic | `WAS/testCategoricalOrdered.r` | 39, 106 | `testCategoricalOrdered` |
| Multinomial Logistic | `WAS/testCategoricalUnordered.r` | 90-92, 126, 129 | `testCategoricalUnordered` |

## Results File Generation

1. **Individual Results Files**: Created by `WAS/initFunctions.r` (lines 60-78) with headers including "n"
2. **Combined Results**: Combined by `resultsProcessing/combineResults.r` (lines 20-59)
3. **Final Output**: Written by `resultsProcessing/mainCombineResults.r` (line 72)

The final output file `results-combined.txt` contains:
- All regression types combined
- Sorted by p-value
- Variable descriptions added from variable info file
- Column order: varName, varType, n, beta, lower, upper, pvalue, resType, [additional columns]

## Interpretation Guidelines

### What the "n" Column Tells You

✓ **Valid Interpretations:**
- The exact number of participants used in this specific statistical test
- The effective sample size after quality control
- Whether the test had adequate statistical power
- Relative data completeness across phenotypes

✗ **Invalid Interpretations:**
- Total number of participants in the study
- Number of participants who were assessed for this phenotype
- Number of participants in the original dataset
- Sample size before any exclusions

### Practical Examples

**Example 1: Linear Regression**
```
varName: BMI
varType: CONTINUOUS  
n: 487237
```
**Interpretation**: 487,237 participants had complete data (non-missing BMI, trait of interest, and confounders) and were used in the linear regression model.

**Example 2: Binary Logistic**
```
varName: Diabetes
varType: CAT-SIN
n: 30000/457237(487237)
```
**Interpretation**: 30,000 participants had diabetes (cases), 457,237 did not (controls), for a total of 487,237 participants used in the logistic regression.

**Example 3: Categorical Multiple**
```
varName: Cancer_type#1001  
varType: CAT-MUL
n: 495/505(1000)
```
**Interpretation**: For this specific cancer type (code 1001), 495 participants did NOT have it, 505 did have it, among 1,000 total participants who completed the cancer questionnaire (based on NO_NAN or indicator field restriction).

**Example 4: Multinomial Logistic (Overall)**
```
varName: Ethnicity-1
varType: CAT-SIN
n: 450000/487237
beta: -999
```
**Interpretation**: This is the overall model result. Category 1 is the reference with 450,000 participants. Total of 487,237 participants across all ethnicity categories. The beta=-999 indicates this is the overall model p-value row, not a category comparison.

## Common Pitfalls and Clarifications

### 1. Missing Values Are Excluded
The "n" represents only participants with **complete data**. If a phenotype has substantial missingness, the "n" will be much smaller than your total sample size.

### 2. Quality Control Affects "n"
Multiple QC steps affect the final count:
- Minimum case requirements (≥10 per group for binary/categorical)
- Minimum total requirements (≥500 for most tests)
- Removal of categories with <10 examples
- Exclusion of negative values (<0) treated as missing

### 3. Different "n" for Same Field
The same field may have different "n" values if:
- Tested with different regression types
- Different instances or arrays are combined differently
- Different quality control filters apply
- Used in different parts of a categorical multiple field

### 4. Categorical Multiple Complexity
For categorical multiple fields, understanding the "n" requires knowing:
- Which restriction method was used (NO_NAN, ALL, or indicator field)
- Whether negative examples are well-defined
- Which participants actually answered the questionnaire

### 5. Reference Category in Multinomial
The reference category is automatically chosen as the most frequent category. This affects interpretation of the "n" format and category comparisons.

## Technical Details

### Calculating Effective Sample Size

For linear regression:
```r
# After IRNT transformation
numNotNA = length(which(!is.na(phenoIRNT)))
```

For binary logistic regression:
```r
phenoFactor = factor(thisdata[,phenoStartIdx])
facLevels = levels(phenoFactor)
idxTrue = length(which(phenoFactor==facLevels[1]))
idxFalse = length(which(phenoFactor==facLevels[2]))
numNotNA = length(which(!is.na(phenoFactor)))
```

### Quality Control Thresholds

| Parameter | Default Value | Configurable | Location |
|-----------|--------------|--------------|----------|
| mincase | 10 | Yes (--mincase) | Binary/categorical groups |
| Minimum total | 500 | No (hard-coded) | Most tests |
| Continuous threshold | 500 | No (hard-coded) | Linear regression |
| Model complexity | 1000 weights | No (hard-coded) | Multinomial logistic |

## Validation

To validate your understanding of the "n" column:

1. **Check Log Files**: `results-log-all.txt` shows the processing flow and sample sizes at each step
2. **Compare Formats**: Verify the format matches the expected regression type
3. **Cross-Reference**: For binary logistic, verify that idxTrue + idxFalse = numNotNA
4. **Review QC**: Check that n ≥ minimum thresholds (500 total, 10 per group)

## Updates and Maintenance

This documentation reflects the PHESANT codebase as of the time of writing. Key files to monitor for changes:
- `WAS/testContinuous.r`
- `WAS/binaryLogisticRegression.r`
- `WAS/testCategoricalOrdered.r`
- `WAS/testCategoricalUnordered.r`
- `WAS/initFunctions.r`
- `resultsProcessing/combineResults.r`

## References

- Main README: `README.md`
- Logging information: `PHESANT-logging-information.md`
- Counter codes: `PHESANT-counter-codes.pdf`
- Variable information: `variable-info/README.md`

## Summary

The sample "n" column provides the **effective sample size** used in each statistical test, calculated after:
1. Removing missing values (NA)
2. Applying quality control filters
3. Restricting to appropriate comparison groups

The format varies by test type but always represents **participants with complete data** used in the model, not the total available sample. Understanding these nuances is critical for proper interpretation of phenome scan results.
