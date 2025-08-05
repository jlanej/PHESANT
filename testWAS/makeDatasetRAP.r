### create a second version of the phenotype file with
### updated fields 41, 42 and 43 to format of data provided on the RAP


x <- read.csv('data/phenotypes.csv')


##
## Field 41

x$x41_0_x <- paste(x$x41_0_0, x$x41_0_1, x$x41_0_2, sep='|')
x$x41_0_x <- gsub('\\|*$', '', x$x41_0_x)


x$x41_0_0 <- x$x41_0_x
x$x41_0_1 <- NULL           
x$x41_0_2 <- NULL
x$x41_0_x <- NULL


##
## Field 42

x$x42_0_x <- paste(x$x42_0_0, x$x42_0_1, x$x42_0_2, sep='|')
x$x42_0_x <- gsub('\\|*$', '', x$x42_0_x)

x$x42_0_0 <- x$x42_0_x
x$x42_0_1 <- NULL
x$x42_0_2 <- NULL
x$x42_0_x <- NULL



##
## Field 43

x$x43_0_x <- paste(x$x43_0_0, x$x43_0_1, x$x43_0_2, sep='|')
x$x43_0_x <- gsub('\\|*$', '', x$x43_0_x)


x$x43_0_0 <- x$x43_0_x
x$x43_0_1 <- NULL
x$x43_0_2 <- NULL                
x$x43_0_x <- NULL



write.csv(x, 'data/phenotypes-rap.csv', row.names=F)

