###########################################
# Some useful functions for cleaning ODK
# data.
###########################################


# 'new_name'
# Variables names found in original file currently have the names of 
# groups in which they are nested appended to the variable names with
# a colon ":" after each level of group nesting. Retain the "correct"
# variable name by keeping anything to the right of the last colon
# in the variable name.
new_name <- function(data_frame){
  stringr::str_extract(colnames(data_frame), '\\b[^:]+$')
  }

# 'drop_empty'
# Drop all variables where every observation is NA
drop_empty <- function(data_frame) {
  all_na <-  sapply(data_frame, function(x) all(is.na(x))) # identify vars w/ all NAs
  data_frame[ , !all_na]  # removes vars with all NAs
}

# 'drop_timestamp'
# Drop any variable starting with "timestamp"
drop_timestamp <- function(data_frame){
  dplyr::select(data_frame, -dplyr::starts_with("timestamp"))
}

# 'duration'
# Calculates duration of interview, rounded to the nearest minute
duration <- function(start, end){
  temp_end <- strptime(end, format = "%a %b %d %H:%M:%S", tz = "UTC")
  temp_start <- strptime(start, format = "%a %b %d %H:%M:%S",tz = "UTC")
  diff <- difftime(temp_end, temp_start, unit = "mins")
  dur <- round(as.numeric(diff), 0)
  return(dur)
}

# 'end_date'
# Extract the end date of the ODK interview from the server output
# This is probably redundant and slow, could be re-written
end_date <- function(end_var){
  temp <- strptime(end_var, format = "%a %b %d %H:%M:%S", tz = "UTC")
  temp <- format(temp, format = "%m_%d")
  end_date <- as.character(as.POSIXct(temp, format = "%m_%d"))
  
  return(end_date)
}

# 'add_labels'
# Adds values labels to values
#add_labels <- function(my_df){
#  return(dplyr::mutate(my_df,
#                int_name = rename_int(int_name),  # use interviewer labels
#                superv = rename_sup(superv),  # use supervisor labels
#                region = rename_region(region)))} # use region labels

# 'add_meta'
# Add population of survey, form version, end date, and duration of interview
add_meta <- function(my_df, pop, version, source = "server") {
  
  return(dplyr::mutate(my_df,
                duration = duration(start, end),  # add duration
                end_date = end_date(end), # add interview end date
                population = as.character(pop), # add variable identifying population
                form_version = as.character(version), # add form version
                source = as.character(source)))  # add data source
} 