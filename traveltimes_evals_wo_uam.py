# -*- coding: utf-8 -*-
"""
Created on Mon Mar 30 14:24:21 2026

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import os

pd.set_option('display.max_columns', None)

output_folder_ic = 'C:/Users/chris/plots/v07/travelTimes/'

csv_files = [
    'C:/TUMdissDATA/ttimesPUT_top10000_scen1.csv',
    'C:/TUMdissDATA/ttimesPUT_top10000_scen2.csv',
    'C:/TUMdissDATA/ttimesPUT_top10000_scen3.csv', 
    'C:/TUMdissDATA/ttimesPUT_top10000_scen4.csv'
]

# Step 1: Get y-limits
cols = ['sum_ttime_put_combined', 
        'sum_ttime_put_with_uam_combined', 
        'best_sum_ttime_put_arr', 
        'best_sum_ttime_put_with_uam_arr']

y_min = float('inf')
y_max = float('-inf')

for file in csv_files:
    df = pd.read_csv(file)
    
    data = df[cols]
    
    Q1 = data.quantile(0.25)
    Q3 = data.quantile(0.75)
    IQR = Q3 - Q1
    
    lower = (Q1 - 1.5 * IQR).min()
    upper = (Q3 + 1.5 * IQR).max()
    
    y_min = min(y_min, lower)
    y_max = max(y_max, upper)
    
    real_min = data.min().min()
    y_min = max(real_min, y_min)


# Step 2: Plot files
for file in csv_files:
    
    # load CSV
    df = pd.read_csv(file)
    
    # sort again
    #df = df.sort_values(by='u_ample_scen1_common', ascending=False)
    
    df_10 = df.head(10)
    df_100 = df.head(100)
    df_10000 = df.head(10000)
    
    print(df.columns)
    
    
    # make prints for the case that the link ist evaluated for the service in both direktions
    data = [
        df_10['sum_ttime_put_combined'],
        df_10['sum_ttime_put_with_uam_combined'],
        
        df_100['sum_ttime_put_combined'],
        df_100['sum_ttime_put_with_uam_combined'],
        
        df_10000['sum_ttime_put_combined'],
        df_10000['sum_ttime_put_with_uam_combined']
    ]
    
    positions = [1, 2,   4, 5,   7, 8]
    labels = ['no UAM', 'with UAM', 'no UAM', 'with UAM', 'no UAM', 'with UAM']
    
    
    plt.figure(figsize=(12, 6))
    plt.boxplot(data, positions=positions)#, showfliers=False)
    plt.ylim(y_min, y_max)
    #plt.yscale('log')
    
    # set labels as xticks
    plt.xticks(positions, labels)
    
    # set group labels
    group_positions = [1.5, 4.5, 7.5]
    group_labels = ['Top 10', 'Top 100', 'Top 10000']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.15, label,
            ha='center',
            va='top',
            transform=plt.gca().get_xaxis_transform()
        )
    
    
    plt.ylabel('wert')
    plt.title(f'Boxplot for {file}: Sum (back and forth)')
    
    filename = 'back_and_forth_' + os.path.basename(file)
    output_name = filename.replace(".csv", ".pdf")
    
    
    
    #plt.savefig(output_folder_ic + output_name, dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + output_name, bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    plt.show()
    plt.close()
    
    
    
    # make prints for the case that the link ist evaluated only for the direction with top utility
    data = [
        df_10['best_sum_ttime_put_arr'],
        df_10['best_sum_ttime_put_with_uam_arr'],
        
        df_100['best_sum_ttime_put_arr'],
        df_100['best_sum_ttime_put_with_uam_arr'],
        
        df_10000['best_sum_ttime_put_arr'],
        df_10000['best_sum_ttime_put_with_uam_arr']
    ]
    
    positions = [1, 2,   4, 5,   7, 8]
    labels = ['no UAM', 'with UAM', 'no UAM', 'with UAM', 'no UAM', 'with UAM']
    
    
    plt.figure(figsize=(12, 6))
    plt.boxplot(data, positions=positions)#, showfliers=False)
    plt.ylim(y_min, y_max)
    #plt.yscale('log')
    
    # set labels as xticks
    plt.xticks(positions, labels)
    
    # set group labels
    group_positions = [1.5, 4.5, 7.5]
    group_labels = ['Top 10', 'Top 100', 'Top 10000']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.15, label,
            ha='center',
            va='top',
            transform=plt.gca().get_xaxis_transform()
        )
    
    
    plt.ylabel('wert')
    plt.title(f'Boxplot for {file}: Top utility direction (back and forth)')
    
    filename = 'TopWay_' + os.path.basename(file)
    output_name = filename.replace(".csv", ".pdf")
    
    
    
    #plt.savefig(output_folder_ic + output_name, dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + output_name, bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    plt.show()
    plt.close()