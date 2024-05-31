# Raman Spectra analysis Script
The scripts are designed to efficiently import and plot Raman spectra data stored in multiple '.txt' files. It automates the following tasks:
- **Reading Data:** imports all '.txt' files containing Raman spectra data, excluding the 'Readme.txt' file.
- **Data Processing:** process the imported text data to remove undesired text and extract relevant information (keep only the CCD cts and rel. 1/cm data usable for the plots)
- **Data Conversion:** Converts the processed data into structured DataFrames for easy manipulation and analysis
- **Data Preparation:** Remove the firs row from each DataFrame to eliminate header information. Converts DataFrame columns to numeric data types for mathematica analysis
- **Visualisation:** Generates plots from the processed data and save them as high-quality SVG files.

## Usage
To Use the script (both R and Python verion):
- Place all files ('.txt' format) in the same directory as the script.
- Run the script, which automatically execute all the necessary steps outlined above.
- Retrive the processed data and plots for further analysis or visualisation

## Dependencies
### For Python
- 'os' for file operations
- 'pandas' for data manipulation
- 'matplotlib' for ploting

### For R
- 'tidyverse' for data manipulation and plotting (contain ggplot2)
- 'readr' to import the files

## Notes
- Make sure to exclude the 'Readme.txt' file or other informative file from your data directory to prevent unnecessary processing and errors (especially during the graph creation)
- Customise the script as needed to fit specific data formats or analysis requirements.
