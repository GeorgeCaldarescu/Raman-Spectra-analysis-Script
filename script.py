import os
import pandas as pd
import re
import matplotlib.pyplot as plt

# Function to read all .txt files in the current directory and exclude the Readme file
def read_txt():
    txt_files = [f for f in os.listdir() if f.endswith('.txt') and f != 'Readme.txt']
    txt_data = {}
    
    for file in txt_files:
        var_name = file[:-4]  # Remove the .txt extension
        with open(file, 'rb') as f:
            # Read binary data and decode it manually
            txt_data[var_name] = [line.decode('utf-8', errors='replace') for line in f.readlines()]
    
    return txt_data

# Function to process the imported variables
def process_txt_variables(txt_data):
     processed_data = {}
    
     for var_name, data in txt_data.items():
         data_start = [i for i, line in enumerate(data) if line.startswith('[Data]')]
         if not data_start:
             continue
         data_start = data_start[0] + 1
         processed_data[var_name + '_data'] = data[data_start:]
    
     return processed_data

# Function to convert the data into dataframes
def convert_to_dataframes(processed_data):
     dfs = {}
    
     for var_name, data in processed_data.items():
         data = [line.strip() for line in data]
         df = pd.DataFrame([line.split('\t') for line in data[1:]], columns=['rel. 1/cm', 'CCD cts'])
         dfs[var_name] = df
    
     return dfs

# Function to remove the first row of each dataframe
def remove_first_row(dfs):
     for var_name, df in dfs.items():
         dfs[var_name] = df.iloc[1:].reset_index(drop=True)

# Function to convert columns to numeric
def convert_columns_to_numeric(dfs):
     for var_name, df in dfs.items():
         df['rel. 1/cm'] = pd.to_numeric(df['rel. 1/cm'])
         df['CCD cts'] = pd.to_numeric(df['CCD cts'])

# Function to create and save plots
def make_and_save_plots(dfs):
    plots = []
    
    for i, (var_name, df) in enumerate(dfs.items()):
        plt.figure(figsize=(10, 6))  # Adjust figsize as needed
        x_values = df['rel. 1/cm'].to_numpy()
        y_values = df['CCD cts'].to_numpy()
        plt.plot(x_values, y_values, linestyle='-', marker='', color='b')
        plt.axhline(0, color='black', linestyle='dotted')
        plt.xlabel('rel. 1/cm')
        plt.ylabel('CCD cts')
        plt.xticks(rotation=45, ha='right')  # Adjust rotation and horizontal alignment
        plt.subplots_adjust(bottom=0.2)  # Adjust bottom margin
        plt.grid(False)
        plt.title(var_name)
        plt.savefig(f'{var_name}{i+1}.svg', dpi=1000, format='svg')
        plots.append(plt)
        plt.close()
    
    return plots

# Main execution
txt_data = read_txt()
processed_data = process_txt_variables(txt_data)
dfs = convert_to_dataframes(processed_data)
remove_first_row(dfs)
convert_columns_to_numeric(dfs)
plots = make_and_save_plots(dfs)