# Example: How Field 30860 (Total Protein) Maps to outcome-info.tsv

This document provides a concrete example of how phenotype columns in your data file map to rows in outcome-info.tsv.

## Example Data Columns

Suppose your phenotype file has these columns for Total Protein measurements:
- `x30860_0_0` - Total protein, baseline assessment (instance 0), first array (0)
- `x30860_0_1` - Total protein, baseline assessment (instance 0), second array (1)  
- `x30860_1_0` - Total protein, repeat assessment (instance 1), first array (0)
- `x30860_1_1` - Total protein, repeat assessment (instance 1), second array (1)

## outcome-info.tsv Entry

All of these columns map to a **single row** in outcome-info.tsv:

```
FieldID    Path                                                                 Field           ValueType
30860      Biological samples > Assay results > Blood assays > Blood biochemistry    Total protein   Continuous
```

## How PHESANT Processes These Columns

### Step 1: Identify Field Groups

PHESANT groups columns by field ID:
- Field 30860, Instance 0: `x30860_0_0`, `x30860_0_1`
- Field 30860, Instance 1: `x30860_1_0`, `x30860_1_1`

### Step 2: Process First Instance

For instance 0 (baseline):
1. Both arrays `x30860_0_0` and `x30860_0_1` are **combined** into a multi-column phenotype
2. The field is looked up in outcome-info.tsv using FieldID=30860
3. Based on the ValueType=Continuous, PHESANT runs linear regression

### Step 3: Skip Subsequent Instances

For instance 1 (repeat assessment):
- Columns `x30860_1_0` and `x30860_1_1` are **skipped**
- They are not tested separately
- Only the first instance (baseline) is analyzed

## Why This Design?

This design allows PHESANT to:
1. Handle the complex UK Biobank data structure efficiently
2. Avoid testing the same phenotype multiple times (once per time point)
3. Use a single metadata row in outcome-info.tsv for all instances of a field

## Alternative: Analyzing All Instances

If you want to analyze different time points separately, you would need to:
1. Create separate phenotype files for each instance
2. Run PHESANT separately for each instance
3. Combine results in post-processing

Or use the `CAT_SINGLE_TO_CAT_MULT` column with `YES-INSTANCES` for fields where you want instances treated as arrays (see README.md).
