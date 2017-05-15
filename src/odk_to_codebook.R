###########################################
# Load/install any dependencies
###########################################

# Define function to install dependencies if
# uninstalled and load all package dependencies
loadpkg <- function(toLoad){
  for(lib in toLoad){
    if(! lib %in% installed.packages()[,1]) {
      install.packages(lib, repos='http://cran.rstudio.com/')
    }
    suppressMessages( library(lib, character.only=TRUE) )
  }
}

# Load vector of packages
loadpkg(c("dplyr", "ReporteRs", "readxl"))

##################################################################################
# Define 'odk_to_codebook' function
# Takes the following intputs:
# - excel_file: path to ODK Excel file. Must end in .xlsx or .xls
# - csv_out: path to the outputted .csv codebook file, must end in .csv
# - docx_out: path to the outputted .docx codebook file, must end in .docx
##################################################################################

odk_to_codebook <- function(excel_file, docx_out) {
  
  #################################################
  # Prepare ODK questions sheet
  #################################################
  
  # Read in ODK "survey" sheet (contains the 
  # questions) from the .xslx file
  question <- readxl::read_excel(path = excel_file, sheet = "survey")
  
  # Keep only variables needed for producing codebook,
  # rename the variables to more sensical names
  question <- question %>% select(type = type,
                                  variable = name,
                                  question = label,
                                  relevant)
  
  #################################################
  # Create variable to indicate the question type
  #################################################
  
  # Create indicator vars for the following question
  # types which may or may not be in your specific
  # ODK Excel file. You can also add other question
  # types here if your specific survey contains
  # some other types of questions. This can be done
  # by simply replacing the variable name on the left
  # hand side of the left-most equals sign and the
  # pattern value. Importantly, including the
  # character ^ indicates you want to search at the
  # start of the string and $ indicates that the end
  # of the string comes at that point. Thus
  # ^select_one searches for all strings starting with
  # "select_one" while ^end$ indicates the string must
  # be exactly "end". This was done because some of the
  # substrings you are looking for can sometimes be in the
  # variable names and you don't want to flag those variables!
  # For example, type "select_one weekend" would also flag "end" 
  # when you really just want variables of type "end".
  
  # In this iteration, I create binary indicator variables
  # for the following types of questions:
  # - select_one
  # - select_multi,
  # - date
  # - start
  # - end
  # - today
  # - text
  question <- question %>% mutate(select_one = as.numeric(grepl(pattern = "^select_one", x = type)),
                                  select_multiple = as.numeric(grepl(pattern = "^select_multiple", x = type)),
                                  date = as.numeric(grepl(pattern = "^date$", x = type)),
                                  start = as.numeric(grepl(pattern = "^start$", x = type)),
                                  end = as.numeric(grepl(pattern = "^end$", x = type)),
                                  today = as.numeric(grepl(pattern = "^today$", x = type)),
                                  text = as.numeric(grepl(pattern = "^text$", x = type)),
                                  integer = as.numeric(grepl(pattern = "^integer$", x  = type)))
  
  # Since the last word of type column in the 
  # questions sheet is the choice_list name,
  # for all select_one and select_multiple 
  # variables,  we can pull the last word in 
  # that column then look it up in the choice_list 
  # column to then extract all of the values and 
  # their value labels. This is essentially a 
  # vectorized version of Excel's VLOOKUP()
  
  # Add a column to hold the choice list value
  question$choice_list <- ""
  
  # For all rows of *select_one* type, replace the blank
  # value in choice_list with the last word in the type column.
  question$choice_list[question$select_one == 1] <- gsub("(.*? )", "", question$type[question$select_one == 1])
  
  # For all rows of *select_multiple* type, replace the
  # blank value in choice_list with the last word in the type column.
  question$choice_list[question$select_multiple == 1] <- gsub("(.*? )", "", question$type[question$select_multiple == 1])
  
  # Add a column to contain the entire concatenated
  # list of values and value labels
  question$response_choices <- ""
  
  #################################################
  # Prepare ODK choices/response options sheet
  #################################################
  
  # Read in ODK "choices" sheet from .xslx file
  choices <- readxl::read_excel(path = excel_file, sheet = "choices")
  
  # Keep only variables for producing codebook
  # note: the starts_with() function addresses an issue where
  # dplyr thinks label::English indicate we should use
  # a function named "English" in the "label" package.
  choices <- choices %>% select(choice_list = list_name,
                                val = name,
                                val_label = starts_with("label::English"))
  
  # Add another column that is the concatenated 
  # value and its corresponding label. This allows
  # users of the codebook to see the raw numeric
  # value for the response that appears in the
  # .csv file containing the survey results
  # and its corresponding label.
  choices <- choices %>% mutate(val_and_label = paste0(val, ". ", val_label))
  
  # For each value in choice_list, we want a single cell
  # containing all of the values in the val_and_label 
  # column, i.e. we want to concatenate all of the
  # possible values of val_and_label into a single cell
  # in a column that will contain all possible 
  # values and label combinations for a given choice_list
  # and then another column containing the choice_list.
  choices <- aggregate(val_and_label ~ choice_list, data = choices, toString)
  
  # The above procedure may have made choice_list a factor. 
  # Convert it back to character class for merging
  choices$choice_list <- as.character(choices$choice_list)
  
  ###############################################
  # Fill 'response_choices' in 'question' sheet
  # with values from the 'choices' sheet, 
  # conditional on question type
  ###############################################
  
  # Based upon your exact variable types you want
  # you will need to add additional code below to indicate
  # the response_choice value you want associated with that
  # variable type.
  
  #*********************************************
  # Select_one or select_multiple types
  # Merge in the response_choices based on choice_list
  #*********************************************
  
  # Add in the values and their labels
  question <- left_join(question, choices, by = "choice_list")
  
  # Move the values and their labels to response_choice column
  question$response_choices[question$select_multiple == 1 | question$select_one == 1] <- question$val_and_label[question$select_multiple == 1 | question$select_one == 1]
  
  #*********************************************
  # Date types
  #*********************************************
  question[question$date == 1, "response_choices"] <- "Date/Time"
  
  #*********************************************
  # Start types
  #*********************************************
  question[question$start == 1, "response_choices"] <- "Date/Time"
  
  #*********************************************
  # End types
  #*********************************************
  question[question$end == 1, "response_choices"] <- "Date/Time"
  
  #*********************************************
  # Today types
  #*********************************************
  question[question$today == 1, "response_choices"] <- "Date/Time"
  
  #*********************************************
  # Text types
  #*********************************************
  question[question$text == 1, "response_choices"] <- "Text"
  
  #*********************************************
  # Integer types
  #*********************************************
  question[question$integer == 1, "response_choices"] <- "Numeric value"
  
  ###########################################################
  # Clean up the final data frame for presentation
  ###########################################################
  
  # Drop any 'begin group' and 'end group', rows since
  # these do not contain any substantive information
  codebook <- question %>% filter(type != "begin group" & type != "end group")
  
  # Add a note about the question being select multiple before the 
  # response choices for **select_multiple questions**
  codebook$response_choices[codebook$select_multiple == 1] <- paste0("SELECT MULTIPLE: ",
                                                                     codebook$response_choices[codebook$select_multiple == 1])
  
  # Add a note about the question being select multiple before the 
  # response choices for **select_one questions**
  codebook$response_choices[codebook$select_one == 1] <- paste0("SELECT ONE: ",
                                                                codebook$response_choices[codebook$select_one == 1])
  
  # For all question wording that is blank, add an explanation for the reason it's blank
  codebook$question[codebook$type == "calculate" ] <- "Automatically calculated value"
  codebook$question[codebook$type == "start" ] <- "Start time of interview"
  codebook$question[codebook$type == "end" ] <- "End time of interview"
  codebook$question[codebook$type == "today" ] <- "Today's date"
  codebook$question[codebook$type == "deviceid" ] <- "Device uuid"
  
  # If the variable type is a 'note' then remove the variable name
  codebook$variable[codebook$type == "note"] <- ""
  
  # Keep only needed variables
  codebook <- codebook %>% select(variable, question, relevant, response_choices)
  
  ####################################################
  # Save output files for further manual formatting
  ###################################################
  
  # Save the codebook as a .csv file
  # commented out since .csv files rarely needed, can add 
  # this as an option to the function in the future
  # write.csv(codebook, as.character(csv_out))
  
  # Save the codebook as a Word table
  docx() %>% addFlexTable(codebook %>% FlexTable()) %>% writeDoc(file = as.character(docx_out))
  
} # this closes out the odk_to_codebook() function

############################################################
# Once this file is produced, several manual changes
# are still needed to produce a final codebook, including:
# - You can replace the "relevant" column values manually
#   to indicate the skip logic of the survey in text that
#   is readable to non-ODK users.
# - Add line breaks between options in the response_choices
#   columns to make it more aesthetically pleasing.
# - Modify the font/colors of the table headers
# - Adjust the width/height of the table cells as desired
############################################################

###########################################################
# Example of odk_to_codebook in action
############################################################

# Produces a .csv file named codebook_example.csv and a 
# .docx file named codebook_example.docx in the current
# Working directory from the file try.csv a(the 'survey' 
# sheet) nd try2.csv (the 'choices' sheet) located in the
# current working directory.

# Commented out to allow others to source this script
#odk_to_codebook(excel_file = "mydata.xlsx",
#                csv_out = "codebook_example.csv",
#                docx_out = "codebook_example.docx")
