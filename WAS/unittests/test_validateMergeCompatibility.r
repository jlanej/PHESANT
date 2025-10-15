library("testthat")

# Set up test environment
setwd("../")
source("initFunctions.r")
loadSource()

# Mock opt variable for testing
opt <- list(
	save=FALSE,
	tab=FALSE,
	userId="userId"
)

context("Test validateMergeCompatibility function")

# Create test directory
dir.create("/tmp/phesant_test", showWarnings=FALSE)

test_that("Duplicate column names in traitofinterestfile are detected", {
	# Create test files with duplicate columns
	write.table(data.frame(userId=1:3, x21022_0_0=50:52, x31_0_0=c(1,0,1), x22000_0_0=c(0,1,0), x1_0_0=10:12), 
		"/tmp/phesant_test/test_duplicate_phenotypes.csv", sep=",", row.names=FALSE, quote=TRUE)
	write.table(data.frame(userId=1:3, exposure=c(0.5,0.6,0.7), x1_0_0=c(999,999,999)), 
		"/tmp/phesant_test/test_duplicate_trait.csv", sep=",", row.names=FALSE, quote=TRUE)
	
	opt <<- list(
		save=FALSE,
		tab=FALSE,
		userId="userId",
		phenofile="/tmp/phesant_test/test_duplicate_phenotypes.csv",
		traitofinterestfile="/tmp/phesant_test/test_duplicate_trait.csv",
		confounderfile=NULL
	)
	
	expect_error(validateMergeCompatibility(), 
		regexp="Duplicate column names found between phenofile and traitofinterestfile.*x1_0_0")
})

test_that("Duplicate column names in confounderfile are detected", {
	# Create test files with duplicate columns
	write.table(data.frame(userId=1:3, x21022_0_0=50:52, x31_0_0=c(1,0,1), x22000_0_0=c(0,1,0), x1_0_0=10:12), 
		"/tmp/phesant_test/test_duplicate_phenotypes2.csv", sep=",", row.names=FALSE, quote=TRUE)
	write.table(data.frame(userId=1:3, x21022_0_0=50:52, x31_0_0=c(1,0,1), x22000_0_0=c(0,1,0), x1_0_0=10:12), 
		"/tmp/phesant_test/test_duplicate_confounders.csv", sep=",", row.names=FALSE, quote=TRUE)
	
	opt <<- list(
		save=FALSE,
		tab=FALSE,
		userId="userId",
		phenofile="/tmp/phesant_test/test_duplicate_phenotypes2.csv",
		traitofinterestfile=NULL,
		confounderfile="/tmp/phesant_test/test_duplicate_confounders.csv"
	)
	
	expect_error(validateMergeCompatibility(), 
		regexp="Duplicate column names found between phenofile and confounderfile.*x1_0_0")
})

test_that("Subset samples in confounderfile generate a warning", {
	# Create test files with subset samples
	write.table(data.frame(userId=1:5, x21022_0_0=50:54, x31_0_0=c(1,0,1,0,1), x22000_0_0=c(0,1,0,1,0), x1_0_0=10:14), 
		"/tmp/phesant_test/test_subset_phenotypes.csv", sep=",", row.names=FALSE, quote=TRUE)
	write.table(data.frame(userId=1:5, exposure=c(0.5,0.6,0.7,0.8,0.9)), 
		"/tmp/phesant_test/test_subset_trait.csv", sep=",", row.names=FALSE, quote=TRUE)
	write.table(data.frame(userId=1:3, age=50:52, sex=c(1,0,1), batch=c(0,1,0)), 
		"/tmp/phesant_test/test_subset_confounders.csv", sep=",", row.names=FALSE, quote=TRUE)
	
	opt <<- list(
		save=FALSE,
		tab=FALSE,
		userId="userId",
		phenofile="/tmp/phesant_test/test_subset_phenotypes.csv",
		traitofinterestfile="/tmp/phesant_test/test_subset_trait.csv",
		confounderfile="/tmp/phesant_test/test_subset_confounders.csv"
	)
	
	expect_warning(validateMergeCompatibility(), 
		regexp="confounderfile has a subset of samples")
})

test_that("No errors when files have no conflicts", {
	# Create valid test files
	write.table(data.frame(userId=1:3, x21022_0_0=50:52, x31_0_0=c(1,0,1), x22000_0_0=c(0,1,0), x1_0_0=10:12), 
		"/tmp/phesant_test/test_valid_phenotypes.csv", sep=",", row.names=FALSE, quote=TRUE)
	write.table(data.frame(userId=1:3, exposure=c(0.5,0.6,0.7)), 
		"/tmp/phesant_test/test_valid_trait.csv", sep=",", row.names=FALSE, quote=TRUE)
	write.table(data.frame(userId=1:3, age=50:52, sex=c(1,0,1), batch=c(0,1,0)), 
		"/tmp/phesant_test/test_valid_confounders.csv", sep=",", row.names=FALSE, quote=TRUE)
	
	opt <<- list(
		save=FALSE,
		tab=FALSE,
		userId="userId",
		phenofile="/tmp/phesant_test/test_valid_phenotypes.csv",
		traitofinterestfile="/tmp/phesant_test/test_valid_trait.csv",
		confounderfile="/tmp/phesant_test/test_valid_confounders.csv"
	)
	
	expect_output(validateMergeCompatibility(), "Merge compatibility validation completed")
})

cat("Test completed successfully\n")
