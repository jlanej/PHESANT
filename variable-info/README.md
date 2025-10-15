# Variable Information Files

This directory contains the variable information files used by PHESANT to process phenotypes.

## Files

### outcome-info.tsv

This file contains metadata about each UK Biobank field that PHESANT uses to determine how to process and analyze phenotypes. Each row represents a unique **field** (not individual instances or arrays).

#### Understanding Field IDs and Instances

UK Biobank data has a hierarchical structure:
- **Field**: A measurement or variable (e.g., Total protein, field 30860)
- **Instance**: Multiple assessments over time (e.g., instance 0 = baseline, instance 1 = first repeat assessment)
- **Array**: Multiple values within an instance (e.g., multiple readings)

In your phenotype data file, columns follow the naming convention `x[FieldID]_[Instance]_[Array]`:
- `x30860_0_0` = Total protein, baseline assessment (instance 0), first value (array 0)
- `x30860_1_0` = Total protein, first repeat assessment (instance 1), first value (array 0)
- `x30860_0_1` = Total protein, baseline assessment (instance 0), second value (array 1)

#### How Instances Map to outcome-info.tsv

The `outcome-info.tsv` file uses only the **FieldID** (without instance or array indices) to define phenotypes. For example:

```
FieldID    Path                                                             Field           ValueType
30860      Biological samples > Assay results > Blood assays > Blood biochemistry    Total protein   Continuous
```

**All instances and arrays of a field (e.g., x30860_0_0, x30860_1_0, x30860_0_1) map to the same row in outcome-info.tsv** based on the FieldID (30860).

#### How PHESANT Processes Multiple Instances

When PHESANT encounters multiple instances of the same field:

1. **Arrays within the same instance** (e.g., x30860_0_0, x30860_0_1) are **combined** and processed together as a multi-column phenotype
2. **Different instances** (e.g., x30860_0_0, x30860_1_0) are **only tested once** - PHESANT tests only the first instance encountered and skips subsequent instances

This behavior means:
- If your data has both `x30860_0_0` (baseline) and `x30860_1_0` (repeat), only the baseline instance will be tested
- The metadata in outcome-info.tsv (ValueType, Path, Field name, etc.) applies to all instances of the field

#### Special Case: Converting Instances to Arrays

For some fields, you may want to treat different instances as if they were arrays (to combine data across time points). Use the `CAT_SINGLE_TO_CAT_MULT` column with value `YES-INSTANCES` to enable this behavior. See the main README.md for details.

### data-coding-ordinal-info.txt

This file contains information about data codings used by categorical fields. See the main README.md for details about this file's structure and usage.

## Updating outcome-info.tsv

When UK Biobank releases new fields, you can update outcome-info.tsv using the scripts in the `update-outcome-info/` directory. See the README in that directory for instructions.

## Column Descriptions

For detailed descriptions of all columns in outcome-info.tsv, see the "Variable information file" section in the main README.md file.
