# File Merge Validation

## Overview

PHESANT performs validation checks when merging the `traitofinterestfile`, `confounderfile`, and `phenofile` to ensure data integrity and prevent common issues.

## Validation Checks

### 1. Duplicate Column Names

**Issue**: When files contain duplicate column names (excluding `userId`), R's `merge()` function will create columns with `.x` and `.y` suffixes, which can lead to unexpected behavior and errors.

**Validation**: The system checks for duplicate column names between:
- `phenofile` and `traitofinterestfile`
- `phenofile` and `confounderfile`

**Error Message**:
```
ERROR: Duplicate column names found between phenofile and traitofinterestfile (excluding userID): <column_names>
Please rename columns to avoid conflicts when merging files.
```

**Solution**: Rename duplicate columns in your input files to ensure unique names across all files.

**Example**:
If both `phenofile` and `traitofinterestfile` contain a column named `x1_0_0`:
- Rename the column in one of the files (e.g., to `x1_0_0_trait` in the trait file)
- Or remove the duplicate column if it's not needed

### 2. Sample Coverage in Confounder File

**Issue**: When `confounderfile` contains a subset of samples compared to `traitofinterestfile`, samples missing from the confounder file will have NA values for confounders and may be excluded from analysis.

**Validation**: The system checks if `confounderfile` has fewer samples than `traitofinterestfile` and reports:
- Number of samples in trait of interest
- Number of samples in confounders
- Number of missing samples and percentage

**Warning Message**:
```
WARNING: confounderfile has a subset of samples compared to traitofinterestfile.
  Number of samples in trait of interest: <count>
  Number of samples in confounders: <count>
  Number of missing samples: <count> (<percentage>%)
  These samples will have NA values for confounders and may be excluded from analysis.
```

**Impact**: 
- Samples missing from `confounderfile` will have NA values for confounders
- These samples may be excluded during analysis if complete cases are required
- This can reduce statistical power and potentially introduce bias

**Solution**: 
- Ensure `confounderfile` includes all samples from `traitofinterestfile`
- If some samples truly lack confounder data, be aware of potential sample exclusion
- Consider imputation or other strategies if appropriate for your analysis

## How Files Are Merged

The merging process follows these steps:

1. **Trait of Interest + Phenotype** (`loadData.r`, line 52):
   ```r
   phenotype = merge(toi, phenotype, by="userID", all.y=TRUE, all.x=FALSE)
   ```
   - Keeps all rows from phenotype file
   - Adds trait of interest column
   - Samples without trait of interest are removed later

2. **Confounders Filtering** (`loadData.r`, lines 66-67):
   ```r
   confsIdx = which(conf$userID %in% phenotype$userID)
   conf = conf[confsIdx,]
   ```
   - Filters confounders to only include samples present in the phenotype file

3. **Test Data Frame Creation** (`makeTestDataFrame.r`, line 24):
   ```r
   thisdata = merge(thisdata, confounders, by="userID", all.x=TRUE, all.y=FALSE, sort=FALSE)
   ```
   - Merges confounders for each individual test
   - Keeps all rows from test data
   - Samples missing from confounders will have NA values

## When Validation Runs

Validation is performed automatically when `phenomeScan.r` is executed, after individual file validations but before data loading and merging (see `loadData.r`).

## Disabling Validation

Validation is enabled by default for all analyses (when `opt$save=FALSE`). It is skipped when using the `--save` option to generate phenotypes without running tests.

## Additional Notes

- The `userId` column is expected to be present in all files and is used as the merge key
- Validation helps identify data issues early before time-consuming analyses begin
- These checks complement the existing individual file validations for phenotype and trait of interest files
