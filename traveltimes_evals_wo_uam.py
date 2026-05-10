# -*- coding: utf-8 -*-
"""
Created on Mon Mar 30 14:24:21 2026

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import os
import re


cm_print_title = False
cm_show_LaTeX = True

pd.set_option('display.max_columns', None)

output_folder_ic = 'C:/Users/chris/plots/v07/travelTimes/'


csv_files = [
    'C:/TUMdissDATA/ttimesPUT_top10000_scen1.csv',
    'C:/TUMdissDATA/ttimesPUT_top10000_scen2.csv',
    'C:/TUMdissDATA/ttimesPUT_top10000_scen3.csv', 
    'C:/TUMdissDATA/ttimesPUT_top10000_scen4.csv'
]


# Plot files
for file in csv_files:
    
    # load CSV
    df = pd.read_csv(file)
    
    # sort again
    #df = df.sort_values(by='u_ample_scen1_common', ascending=False)
    
    df_10 = df.head(10)
    df_100 = df.head(100)
    df_10000 = df.head(10000)
    
    # print(df.columns)
    
    
    
    # make prints for the case that the link ist evaluated only for the direction with top utility
    data = [
        df_10['best_total_ttime_put_arr'],
        df_10['best_total_ttime_put_with_uam090_arr'],
        df_10['best_total_ttime_put_with_uam260_arr'],
        df_10['best_total_ttime_put_with_uam320_arr'],
        df_10['best_total_ttime_put_with_uam320noae_arr'],
        
        df_100['best_total_ttime_put_arr'],
        df_100['best_total_ttime_put_with_uam090_arr'],
        df_100['best_total_ttime_put_with_uam260_arr'],
        df_100['best_total_ttime_put_with_uam320_arr'],
        df_100['best_total_ttime_put_with_uam320noae_arr'],
        
        df_10000['best_total_ttime_put_arr'],
        df_10000['best_total_ttime_put_with_uam090_arr'],
        df_10000['best_total_ttime_put_with_uam260_arr'],
        df_10000['best_total_ttime_put_with_uam320_arr'],
        df_10000['best_total_ttime_put_with_uam320noae_arr']
    ]
    
    positions = [1, 2, 3, 4, 5,   7, 8, 9, 10, 11,   13, 14, 15, 16, 17]
    labels = ['PuT no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h', 'with UAM 320 km/h d2d'] * 3
    
    
    plt.figure(figsize=(12, 6))
    box = plt.boxplot(data, positions=positions, patch_artist=True, showfliers=False)
    
    # Optional: Nicer colors
    colors = ['#aec7e8', '#ffbb78', '#98df8a', '#ff9896', '#c5b0d5'] * 3
    for patch, color in zip(box['boxes'], colors):
        patch.set_facecolor(color)
        

    
   
    # set labels as ticks
    plt.xticks(positions, labels, rotation=25, ha='right', fontsize=14)
    plt.yticks(fontsize=14)
    
    # set group labels
    group_positions = [3, 9, 15]
    group_labels = ['Top 10 UAM connections', 'Top 100 UAM connections', 'Top 10000 UAM connections']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.3, label,
            ha='center',
            va='top',
            fontsize=16,
            transform=plt.gca().get_xaxis_transform()
        )
    
    
    # Optional: Borders and grid
    for x in [6, 12]:
        plt.axvline(x, color='grey', linestyle='--', linewidth=0.7)
    plt.grid(color='grey', linestyle='dotted', linewidth=0.5, axis='y')
    plt.ylabel(r'Person-minutes traveled [persons $\times$ min]', fontsize=16)
    if cm_print_title:
        plt.title(f'Boxplot for {file}: Top (utility) direction')
    
    filename = 'eval_PAXt_TopWay_' + os.path.basename(file)
    plt.savefig(output_folder_ic + filename.replace(".csv", ".png"), dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + filename.replace(".csv", ".pdf"), bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    
    
    
    # get stats...
    rows = []
    for label, series in zip(labels, data):
        s = series.dropna()
        
        q1 = s.quantile(0.25)
        median = s.quantile(0.5)
        q3 = s.quantile(0.75)
        iqr = q3 - q1
        
        rows.append({
            "Dataset": label,
            "Min": s.min(),
            "Q1": q1,
            "Median": median,
            "Q3": q3,
            "Max": s.max(),
            "IQR": iqr
        })

    df_stats = pd.DataFrame(rows)
    print(f'Stats for {file}: Top (utility) direction')
    # ... and format as latex
    if cm_show_LaTeX:
        # group the roes in buckets; 
        # !CM important: this is 'hard coded' and makes the groups from the dataset
        latex_group_sizes = [5, 5, 5]
        
        # create group names from the names in the plot; crop after top 10 etc.        
        latex_group_labels = [latex_label[:latex_label.rfind("0") + 1] for latex_label in group_labels]
        
        # create the groups from the names above
        latex_groups = [latex_label for latex_size, latex_label in zip(latex_group_sizes, latex_group_labels) for _ in range(latex_size) ]
        
        # some index stuff
        latex_subindex = [""] * len(df_stats)
        df_stats.index = pd.MultiIndex.from_arrays( [latex_groups, latex_subindex])
        
        # export to latex table with pandas
        latex_table = df_stats.to_latex(multirow=True, index=True, index_names=False, escape=True, float_format="%.2f")
    
        # remove clines
        latex_table = re.sub(r"\\cline\{1-\d+\}", "", latex_table)
        
        # print latex table
        print(latex_table)
    else:        
        print(df_stats)
        
        
    plt.show()
    plt.close()
    
    # make prints for the case that the link ist evaluated for the service in both direktions
    data = [
        df_10['total_ttime_put_combined'],
        df_10['total_ttime_put_with_uam090_combined'],
        df_10['total_ttime_put_with_uam260_combined'],
        df_10['total_ttime_put_with_uam320_combined'],
        df_10['total_ttime_put_with_uam320noae_combined'],
        
        df_100['total_ttime_put_combined'],
        df_100['total_ttime_put_with_uam090_combined'],
        df_100['total_ttime_put_with_uam260_combined'],
        df_100['total_ttime_put_with_uam320_combined'],
        df_100['total_ttime_put_with_uam320noae_combined'],
        
        df_10000['total_ttime_put_combined'],
        df_10000['total_ttime_put_with_uam090_combined'],
        df_10000['total_ttime_put_with_uam260_combined'],
        df_10000['total_ttime_put_with_uam320_combined'],
        df_10000['total_ttime_put_with_uam320noae_combined']
    ]
    
    positions = [1, 2, 3, 4, 5,   7, 8, 9, 10, 11,   13, 14, 15, 16, 17]
    labels = ['PuT no UAM', 'with UAM 90 km/h', 'with UAM 260 km/h', 'with UAM 320 km/h', 'with UAM 320 km/h d2d'] * 3
        
    
    
    
    plt.figure(figsize=(12, 6))
    box = plt.boxplot(data, positions=positions, patch_artist=True, showfliers=False)
    
    # Optional: Nicer colors
    colors = ['#aec7e8', '#ffbb78', '#98df8a', '#ff9896', '#c5b0d5'] * 3
    for patch, color in zip(box['boxes'], colors):
        patch.set_facecolor(color)
        

    
    # set labels as ticks
    plt.xticks(positions, labels, rotation=25, ha='right', fontsize=14)
    plt.yticks(fontsize=14)
    
    # set group labels
    group_positions = [3, 9, 15]
    group_labels = ['Top 10 UAM connections', 'Top 100 UAM connections', 'Top 10000 UAM connections']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.3, label,
            ha='center',
            va='top',
            fontsize=16,
            transform=plt.gca().get_xaxis_transform()
        )
    
    # Optional: Borders and grid
    for x in [6, 12]:
        plt.axvline(x, color='grey', linestyle='--', linewidth=0.7)
    plt.grid(color='grey', linestyle='dotted', linewidth=0.5, axis='y')
    plt.ylabel(r'Person-minutes traveled [persons $\times$ min]', fontsize=16)
    if cm_print_title:
        plt.title(f'Boxplot for {file}: Sum (back and forth)')
    
    filename = 'eval_PAXt_back_and_forth_' + os.path.basename(file)
    plt.savefig(output_folder_ic + filename.replace(".csv", ".png"), dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + filename.replace(".csv", ".pdf"), bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    
    # get stats...
    rows = []
    for label, series in zip(labels, data):
        s = series.dropna()
        
        q1 = s.quantile(0.25)
        median = s.quantile(0.5)
        q3 = s.quantile(0.75)
        iqr = q3 - q1
        
        rows.append({
            "Dataset": label,
            "Min": s.min(),
            "Q1": q1,
            "Median": median,
            "Q3": q3,
            "Max": s.max(),
            "IQR": iqr
        })

    df_stats = pd.DataFrame(rows)
    print(f'Stats for {file}: Sum (back and forth)')
    # ... and format as latex
    if cm_show_LaTeX:
        # group the roes in buckets; 
        # !CM important: this is 'hard coded' and makes the groups from the dataset
        latex_group_sizes = [5, 5, 5]
        
        # create group names from the names in the plot; crop after top 10 etc.        
        latex_group_labels = [latex_label[:latex_label.rfind("0") + 1] for latex_label in group_labels]
        
        # create the groups from the names above
        latex_groups = [latex_label for latex_size, latex_label in zip(latex_group_sizes, latex_group_labels) for _ in range(latex_size) ]
        
        # some index stuff
        latex_subindex = [""] * len(df_stats)
        df_stats.index = pd.MultiIndex.from_arrays( [latex_groups, latex_subindex])
        
        # export to latex table with pandas
        latex_table = df_stats.to_latex(multirow=True, index=True, index_names=False, escape=True, float_format="%.2f")
    
        # remove clines
        latex_table = re.sub(r"\\cline\{1-\d+\}", "", latex_table)
        
        # print latex table
        print(latex_table)
    else:        
        print(df_stats)
        
        
    plt.show()
    plt.close()
    
    
    
       
    
    ### Plots for occupance
    # Select column
    data = [
        df_10['uam_occupancy_combined'],
        df_10['best_uam_occupancy_arr'],
        
        df_100['uam_occupancy_combined'],
        df_100['best_uam_occupancy_arr'],
        
        df_10000['uam_occupancy_combined'],
        df_10000['best_uam_occupancy_arr']
    ]
    
    positions = [1, 2,  4, 5,  7, 8]
    labels = ['back and forth\n(average)', 'top direction'] * 3
        
    
    plt.figure(figsize=(12, 6))
    box = plt.boxplot(data, positions=positions, patch_artist=True, showfliers=True)
    
    # Optional: Nicer colors
    colors = ['#2f5597', '#f7b6d2'] * 3
    for patch, color in zip(box['boxes'], colors):
        patch.set_facecolor(color)
    
    # Optional: Borders
    for x in [3, 6]:
        plt.axvline(x, color='grey', linestyle='--', linewidth=0.7)
    
   
    # set labels as ticks
    plt.xticks(positions, labels, rotation=25, ha='right', fontsize=16)
    plt.yticks(fontsize=16)
    
    # set group labels
    group_positions = [1.5, 4.5, 7.5]
    group_labels = ['Top 10 UAM connections', 'Top 100 UAM connections', 'Top 10000 UAM connections']
    
    for x, label in zip(group_positions, group_labels):
        plt.text(
            x, -0.25, label,
            ha='center',
            va='top',
            fontsize=18,
            transform=plt.gca().get_xaxis_transform()
        )
    
    # Format y-axis as percent
    ax = plt.gca()
    ax.yaxis.set_major_formatter(mtick.StrMethodFormatter("{x:.0%}"))
    ax.set_ylim([-0.05,1.4])
    
    # Highlight 100% line
    ax.axhline(1, color='#c44e52', linestyle='--', linewidth=2, alpha=0.8)

    plt.grid(color='grey', linestyle='dotted', linewidth=0.5, axis='y')
    plt.ylabel('OD demand / max. UAM capacity [%]', fontsize=18)
    if cm_print_title:
        plt.title(f'Boxplot for {file}: Occupancy')
    
    filename = 'eval_OccupOneAndBothWay_' + os.path.basename(file)
    plt.savefig(output_folder_ic + filename.replace(".csv", ".png"), dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + filename.replace(".csv", ".pdf"), bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    
    # get stats...
    rows = []
    for label, series in zip(labels, data):
        s = series.dropna()
        
        q1 = s.quantile(0.25)
        median = s.quantile(0.5)
        q3 = s.quantile(0.75)
        iqr = q3 - q1
        
        rows.append({
            "Dataset": label,
            "Min": s.min(),
            "Q1": q1,
            "Median": median,
            "Q3": q3,
            "Max": s.max(),
            "IQR": iqr
        })
    df_stats = pd.DataFrame(rows)
    print(f'Stats for {file}: Occupancy')
    # ... and format as latex
    if cm_show_LaTeX:
        # group the roes in buckets; 
        # !CM important: this is 'hard coded' and makes the groups from the dataset
        latex_group_sizes = [2, 2, 2]
        
        # create group names from the names in the plot; crop after top 10 etc.        
        latex_group_labels = [latex_label[:latex_label.rfind("0") + 1] for latex_label in group_labels]
        
        # create the groups from the names above
        latex_groups = [latex_label for latex_size, latex_label in zip(latex_group_sizes, latex_group_labels) for _ in range(latex_size) ]
        
        # some index stuff
        latex_subindex = [""] * len(df_stats)
        df_stats.index = pd.MultiIndex.from_arrays( [latex_groups, latex_subindex])
        
        # export to latex table with pandas
        latex_table = df_stats.to_latex(multirow=True, index=True, index_names=False, escape=True, float_format="%.2f")
    
        # remove clines
        latex_table = re.sub(r"\\cline\{1-\d+\}", "", latex_table)
        
        # print latex table
        print(latex_table)
    else:        
        print(df_stats)
        
        
        
    plt.show()
    plt.close()