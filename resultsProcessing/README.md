


## Understanding the Sample "n" Column

The combined results file includes an "n" column that represents the number of participants with complete, non-missing data used in each statistical test. The format varies by test type:

- **Linear regression:** Simple count (e.g., `1000`)
- **Binary logistic:** Cases/controls(total) format (e.g., `300/600(900)`)
- **Ordered logistic:** Simple count (e.g., `889`)
- **Multinomial logistic:** Reference/total or reference#category formats (e.g., `300/1000` or `300#150`)

**Important:** The "n" value represents only participants with complete data after all quality control filters, not the total sample size. 

For comprehensive documentation on the provenance and interpretation of the "n" column, see [PHESANT-sample-n-column-documentation.md](../PHESANT-sample-n-column-documentation.md).

## Updating Category Information

Update the catbrowse.txt file with the most recent UKBiobank category hierarchy:

This only needs to be run when updating the outcome-info.tsv file, because new fields might belong to new categories

```bash
wget -nd -O catbrowse.txt "biobank.ndph.ox.ac.uk/showcase/scdown.cgi?fmt=txt&id=13"
```
