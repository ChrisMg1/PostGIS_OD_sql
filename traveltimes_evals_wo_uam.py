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

cm_showfliers=False
cm_use_log = False
cm_common_limits = False
plt.yscale('log')


csv_files = [
    'C:/TUMdissDATA/ttimesPUT_top10000_scen1.csv',
    'C:/TUMdissDATA/ttimesPUT_top10000_scen2.csv',
    'C:/TUMdissDATA/ttimesPUT_top10000_scen3.csv', 
    'C:/TUMdissDATA/ttimesPUT_top10000_scen4.csv'
]

# Step 1: Get y-limits (optional)
if cm_common_limits:
    cols = ['total_ttime_put_combined',
            'total_ttime_put_with_uam090_combined',
            'total_ttime_put_with_uam260_combined',
            'total_ttime_put_with_uam320_combined',
            'best_total_ttime_put_arr',
            'best_total_ttime_put_with_uam090_arr',
            'best_total_ttime_put_with_uam260_arr',
            'best_total_ttime_put_with_uam320_arr']
    
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
        df_10['total_ttime_put_combined'],
        df_10['total_ttime_put_with_uam090_combined'],
        df_10['total_ttime_put_with_uam260_combined'],
        df_10['total_ttime_put_with_uam320_combined'],
        
        df_100['total_ttime_put_combined'],
        df_100['total_ttime_put_with_uam090_combined'],
        df_100['total_ttime_put_with_uam260_combined'],
        df_100['total_ttime_put_with_uam320_combined'],
        
        df_10000['total_ttime_put_combined'],
        df_10000['total_ttime_put_with_uam090_combined'],
        df_10000['total_ttime_put_with_uam260_combined'],
        df_10000['total_ttime_put_with_uam320_combined']
    ]
    
    positions = [1, 2, 3, 4,   6, 7, 8, 9,   11, 12, 13, 14]
    labels = ['no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h', 'no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h', 'no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h']
    
    
    plt.figure(figsize=(12, 6))
    plt.boxplot(data, positions=positions, showfliers=cm_showfliers)
        
    if cm_use_log:
        plt.yscale('log')
    if cm_common_limits:
        plt.ylim(y_min, y_max)
    
    # set labels as xticks
    plt.xticks(positions, labels, rotation=25, ha='right')
    
    # set group labels
    group_positions = [2.5, 7.5, 12.5]
    group_labels = ['Top 10', 'Top 100', 'Top 10000']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.25, label,
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
        df_10['best_total_ttime_put_arr'],
        df_10['best_total_ttime_put_with_uam090_arr'],
        df_10['best_total_ttime_put_with_uam260_arr'],
        df_10['best_total_ttime_put_with_uam320_arr'],
        
        df_100['best_total_ttime_put_arr'],
        df_100['best_total_ttime_put_with_uam090_arr'],
        df_100['best_total_ttime_put_with_uam260_arr'],
        df_100['best_total_ttime_put_with_uam320_arr'],
        
        df_10000['best_total_ttime_put_arr'],
        df_10000['best_total_ttime_put_with_uam090_arr'],
        df_10000['best_total_ttime_put_with_uam260_arr'],
        df_10000['best_total_ttime_put_with_uam320_arr']
    ]
    
    positions = [1, 2, 3, 4,   6, 7, 8, 9,   11, 12, 13, 14]
    labels = ['no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h', 'no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h', 'no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h']
    
    
    plt.figure(figsize=(12, 6))
    plt.boxplot(data, positions=positions, showfliers=cm_showfliers)
    
    if cm_use_log:
        plt.yscale('log')
    if cm_common_limits:
        plt.ylim(y_min, y_max)
    
    # set labels as xticks
    plt.xticks(positions, labels, rotation=25, ha='right')
    
    # set group labels
    group_positions = [2.5, 7.5, 12.5]
    group_labels = ['Top 10', 'Top 100', 'Top 10000']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.25, label,
            ha='center',
            va='top',
            transform=plt.gca().get_xaxis_transform()
        )
    
    
    plt.ylabel('wert')
    plt.title(f'Boxplot for {file}: Top (utility) direction')
    
    filename = 'TopWay_' + os.path.basename(file)
    output_name = filename.replace(".csv", ".pdf")
    
    
    
    #plt.savefig(output_folder_ic + output_name, dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + output_name, bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    plt.show()
    plt.close()