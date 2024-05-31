# loading libraries\
library(tidyverse)
library(readr)

# create a function to read all the .txt files in the folder and remove the Readme one
read_txt <- function() {
  # List all .txt files in the current working directory
  txt_files <- list.files(pattern = "\\.txt$")
  
  # Iterate over each .txt file
  for (file in txt_files) {
    # Extract the base name of the file (without .txt extension)
    var_name <- sub("\\.txt$", "", file)
    
    # Read the contents of the file
    file_contents <- readLines(file)
    
    # Assign the contents to a variable with the name derived from the file
    assign(var_name, file_contents, envir = .GlobalEnv)
  }
  
  # Remove the ReadMe variable file if it exists
  if (exists("ReadMe")) {
    rm(ReadMe, envir = .GlobalEnv)
  }
}


# Create a function that remove the undesired text from the imported variables.
process_txt_variables <- function() {
  # Get all variable names in the global environment
  var_names <- ls(envir = .GlobalEnv)
  
  # Filter out any non-character variables and any specific variable names you don't want to process (e.g., "ReadMe")
  var_names <- var_names[sapply(var_names, function(x) is.character(get(x, envir = .GlobalEnv))) & !var_names %in% c("ReadMe")]
  
  # Function to process the data in each variable
  process_data <- function(data) {
    data_start <- grep("^\\[Data\\]", data) + 1
    if (length(data_start) == 0 || data_start > length(data)) {
      return(character(0))  # Return an empty character vector if the pattern is not found
    }
    return(data[data_start:length(data)])
  }
  
  # Iterate over each variable name
  for (var_name in var_names) {
    # Get the data from the variable
    data <- get(var_name, envir = .GlobalEnv)
    
    # Process the data
    processed_data <- process_data(data)
    
    # Create the new variable name
    new_var_name <- paste0(var_name, "_data")
    
    # Assign the processed data to the new variable in the global environment
    assign(new_var_name, processed_data, envir = .GlobalEnv)
  }
}


# function to convert the data into dataframe to be used for the plot
convert_to_dataframes <- function() {
  # Get all variable names in the global environment
  var_names <- ls(envir = .GlobalEnv)
  
  # Filter variable names to include only those with the "_data" suffix
  data_var_names <- var_names[grep("_data$", var_names)]
  
  # Function to convert tab-separated values to a data frame
  convert_to_df <- function(data) {
    # Skip the first row and read the remaining data into a data frame using textConnection
    df <- read.table(text = paste(data[-1], collapse = "\n"), sep = "\t", header = FALSE, stringsAsFactors = FALSE)
    
    # Set the column names
    colnames(df) <- c("rel. 1/cm", "CCD cts")
    
    return(df)
  }
  
  # Iterate over each data variable name
  for (var_name in data_var_names) {
    # Get the data from the variable
    data <- get(var_name, envir = .GlobalEnv)
    
    # Convert the data to a data frame
    df <- convert_to_df(data)
    
    # Assign the data frame to the same variable name in the global environment
    assign(var_name, df, envir = .GlobalEnv)
  }
  
}

# remove the first row function
remove_first_row <- function() {
  # Get all data frame names in the global environment
  df_names <- ls(pattern = ".*_data$", envir = .GlobalEnv)
  
  # Iterate over each data frame
  for (df_name in df_names) {
    # Remove the first row from the data frame
    df <- get(df_name, envir = .GlobalEnv)[-1, , drop = FALSE]
    
    # Assign the modified data frame back to the same variable name
    assign(df_name, df, envir = .GlobalEnv)
  }
}

# convert the columns to numeric
convert_columns_to_numeric <- function() {
  # Get all data frame names in the global environment
  df_names <- ls(pattern = ".*_data$", envir = .GlobalEnv)
  
  # Iterate over each data frame
  for (df_name in df_names) {
    # Get the data frame
    df <- get(df_name, envir = .GlobalEnv)
    
    # Convert all columns to numeric
    df[] <- lapply(df, as.numeric)
    
    # Assign the modified data frame back to the same variable name
    assign(df_name, df, envir = .GlobalEnv)
  }
}

# create and save the plots

make_and_save_plots <- function() {
  # Get all data frame names in the global environment
  df_names <- ls(pattern = ".*_data$", envir = .GlobalEnv)
  
  plots <- list()  # Initialize a list to store plots
  
  # Iterate over each data frame
  for (i in seq_along(df_names)) {
    # Get the data frame
    df <- get(df_names[i], envir = .GlobalEnv)
    
    # Make the plot
    plot <- ggplot(df, aes(x = `rel. 1/cm`, y = `CCD cts`)) +
      geom_line() +
      geom_hline(yintercept = 0, linetype = "dotted", color = "black") +
      theme_light()+
      theme(rect = element_rect(fill = "transparent"),
            plot.background = element_rect(fill = "transparent"),
            panel.grid = element_blank(), 
            panel.border = element_blank(),
            panel.background = element_rect(fill = "transparent"),
            axis.text.x = element_text(angle = 90, hjust = 0.7, vjust = 0.7, size = 12, 
                                       color = "black"),
            axis.text.y = element_text(color = "black", size = 12),
            axis.title.x = element_text(vjust = -1),
            axis.title.y = element_text(vjust = 1),
            axis.line = element_line(color = "black",lineend = "round",
                                     linetype = "solid", size = 0.7),
            axis.ticks = element_line(color = "black", size = 0.5,
                                      lineend = "round"),
            legend.background = element_rect(fill = "white"),
            legend.key = element_rect(fill = "white"),
            legend.title = element_text(color = "black"),
            legend.text = element_text(color = "black")) +
      labs(x = "rel. 1/cm", y = "CCD cts") +
      scale_x_continuous(breaks = seq(100, 4000, by = 200))
    
    # Add the plot to the list
    plots[[i]] <- plot
    
    # Save the plot
    ggsave(filename = paste0(df_names[i], i, ".svg"), plot = plot, dpi = 1000)
  }
  
  # Return the list of plots
  return(plots)
}


# Run and wait for the resuls
read_txt()

process_txt_variables()

convert_to_dataframes()

remove_first_row()

convert_columns_to_numeric()
make_and_save_plots()


