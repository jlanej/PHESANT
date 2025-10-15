# The MIT License (MIT)
# Copyright (c) 2017 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


# Validate that files can be merged without conflicts
validateMergeCompatibility <- function() {

if (opt$save!=TRUE) {

	print("Validating merge compatibility between files ...")

	sepx=','
	if (opt$tab == TRUE) {
		sepx='\t'
	}

	###
	### Get column names from phenotype file
	phenoIn = read.table(opt$phenofile, header=1, nrows=1, sep=sepx)
	phenoCols = names(phenoIn)

	###
	### Check trait of interest file for duplicate column names
	if (!is.null(opt$traitofinterestfile)) {
		toiIn = read.table(opt$traitofinterestfile, header=1, nrows=1, sep=',')
		toiCols = names(toiIn)
		
		# Check for duplicates (excluding userID which is expected)
		duplicateCols = intersect(setdiff(phenoCols, opt$userId), setdiff(toiCols, opt$userId))
		
		if (length(duplicateCols) > 0) {
			stop(paste("ERROR: Duplicate column names found between phenofile and traitofinterestfile (excluding userID):",
				paste(duplicateCols, collapse=", "),
				"\nPlease rename columns to avoid conflicts when merging files."), call.=FALSE)
		}
	}

	###
	### Check confounder file for duplicate column names and sample coverage
	if (!is.null(opt$confounderfile)) {
		confIn = read.table(opt$confounderfile, header=1, nrows=1, sep=',')
		confCols = names(confIn)
		
		# Check for duplicates (excluding userID which is expected)
		duplicateCols = intersect(setdiff(phenoCols, opt$userId), setdiff(confCols, opt$userId))
		
		if (length(duplicateCols) > 0) {
			stop(paste("ERROR: Duplicate column names found between phenofile and confounderfile (excluding userID):",
				paste(duplicateCols, collapse=", "),
				"\nPlease rename columns to avoid conflicts when merging files."), call.=FALSE)
		}
		
		# Check sample coverage - load userIDs only
		confData = read.table(opt$confounderfile, header=TRUE, sep=',', stringsAsFactors=FALSE)
		confIDs = confData[,opt$userId]
		
		# Load trait of interest userIDs
		if (!is.null(opt$traitofinterestfile)) {
			toiData = read.table(opt$traitofinterestfile, header=TRUE, sep=',', stringsAsFactors=FALSE)
			toiIDs = toiData[,opt$userId]
		} else {
			# Load from phenotype file
			phenoData = read.table(opt$phenofile, header=TRUE, sep=sepx, stringsAsFactors=FALSE)
			toiIDs = phenoData[,opt$userId]
		}
		
		# Check if confounderfile has fewer samples than trait of interest
		missingIDs = setdiff(toiIDs, confIDs)
		
		if (length(missingIDs) > 0) {
			pctMissing = round(100 * length(missingIDs) / length(toiIDs), 2)
			warning(paste("WARNING: confounderfile has a subset of samples compared to traitofinterestfile.",
				"\n  Number of samples in trait of interest:", length(toiIDs),
				"\n  Number of samples in confounders:", length(confIDs),
				"\n  Number of missing samples:", length(missingIDs), paste0("(", pctMissing, "%)"),
				"\n  These samples will have NA values for confounders and may be excluded from analysis."))
		}
	}

	print("Merge compatibility validation completed")

}

}
