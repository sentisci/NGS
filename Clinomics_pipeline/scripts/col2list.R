## function to convert a df with two or more columns into a list using the first column name as list name and first column values as names for nested lists, which will have values from other columns than the first one


col2list <- function (df) {
	nestedN <- unique(df[,1])
	nestedL <- list()
	
	for ( Name in nestedN ) {
		Values <- unique( unlist(df[df[, 1] == Name , -1]) )
		if( Values == '' || is.na(Values) ){
			next
		}
		nestedL_1 <- list( Values )
		names(nestedL_1) <- Name
		nestedL <- c(nestedL, nestedL_1)
	}
	outList <- list(nestedL)
	names(outList) <- names(df)[1]
	return(outList)
}


