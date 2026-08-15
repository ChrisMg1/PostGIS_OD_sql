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


def calculate_mean_median_stats(in_labels, in_data, n_boxes):
    rows = []

    for label, series in zip(in_labels, in_data):
        s = series.dropna()

        rows.append({
            "Dataset": label,
            "Median": s.median(),
            "Mean": s.mean(),
            "Min": s.min()
        })

    df_stats = pd.DataFrame(rows)

    # Neue Spalten vorbereiten
    df_stats["Median_Change_%"] = 0.0
    df_stats["Mean_Change_%"] = 0.0
    df_stats["Min_Change_%"] = 0.0

    # Blockweise Referenzen setzen
    for start_idx in range(0, len(df_stats), n_boxes):

        # Referenz = erste Zeile des aktuellen Blocks
        ref_median = df_stats.loc[start_idx, "Median"]
        ref_mean = df_stats.loc[start_idx, "Mean"]
        ref_min = df_stats.loc[start_idx, "Min"]

        # Ende des Blocks
        end_idx = min(start_idx + n_boxes, len(df_stats))

        # Prozentänderungen innerhalb des Blocks berechnen
        df_stats.loc[start_idx:end_idx-1, "Median_Change_%"] = (
            (df_stats.loc[start_idx:end_idx-1, "Median"] - ref_median) / ref_median * 100
        )
        
        df_stats.loc[start_idx:end_idx-1, "Mean_Change_%"] = (
            (df_stats.loc[start_idx:end_idx-1, "Mean"] - ref_mean) / ref_mean * 100
        )
        
        df_stats.loc[start_idx:end_idx-1, "Min_Change_%"] = (
            (df_stats.loc[start_idx:end_idx-1, "Min"] - ref_min) / ref_min * 100
        )        

    return df_stats.round(2)

def boxplot_vals(in_labels, in_data):
    rows = []
    for label, series in zip(in_labels, in_data):
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

    return pd.DataFrame(rows)

def format_LaTeX(in_stats, in_sizes, in_labels, in_regex):
    # 'in_sizes': group the rows in buckets; 
    # ! CM important: this is 'hard coded' and makes the groups from the dataset
        
    # create group names from the names in the plot; crop after top 10 etc.        
    latex_group_labels = [latex_label[:latex_label.rfind("0") + 1] for latex_label in in_labels]
    
    # create the groups from the names above
    latex_groups = [latex_label for latex_size, latex_label in zip(in_sizes, latex_group_labels) for _ in range(latex_size) ]
    
    # some index stuff
    latex_subindex = [""] * len(in_stats)
    in_stats.index = pd.MultiIndex.from_arrays( [latex_groups, latex_subindex])
    
    # export to latex table with pandas
    latex_table = in_stats.to_latex(multirow=True, index=True, index_names=False, escape=True, float_format="%.2f")
    
    if in_regex:
        # remove clines
        latex_table = re.sub(r"\\cline\{1-\d+\}", "", latex_table)
        
        # remove empty columns
        latex_table = re.sub(r'&\s*&', '&', latex_table)
        latex_table = re.sub(r'\\begin\{tabular\}\{lll', r'\\begin{tabular}{ll', latex_table, count=1)
    
    return latex_table

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
    labels = ['PuT no AAM', 'with AAM 90 km/h', 'with AAM 260 km/h', 'with AAM 320 km/h', 'with AAM 320 km/h D2D'] * 3
    
    
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
    group_labels = ['Top 10 edges', 'Top 100 edges', 'Top 10000 edges']
    
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
    df_stats = boxplot_vals(labels, data)
    print(f'Stats for {file}: Top (utility) edges')
    # ... and format as latex
    if cm_show_LaTeX:
        print(format_LaTeX(df_stats, [5, 5, 5], group_labels, True))
    else:        
        print(df_stats)
        
    # Finally medians, means, differences:
    print(calculate_mean_median_stats(labels, data, 5))
        
        
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
    labels = ['PuT no AAM', 'with AAM 90 km/h', 'with AAM 260 km/h', 'with AAM 320 km/h', 'with AAM 320 km/h D2D'] * 3
        
    
    
    
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
    group_labels = ['Top 10 connections', 'Top 100 connections', 'Top 10000 connections']
    
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
    df_stats = boxplot_vals(labels, data)
    print(f'Stats for {file}: Sum (back and forth)')
    # ... and format as latex
    if cm_show_LaTeX:
        print(format_LaTeX(df_stats, [5, 5, 5], group_labels, True))
    else:        
        print(df_stats)
        
    # Finally medians, means, differences:
    print(calculate_mean_median_stats(labels, data, 5))
    
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
    labels = ['back and forth\n(average)', 'top edges'] * 3
        
    
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
    group_labels = ['Top 10 connections', 'Top 100 connections', 'Top 10000 connections']
    
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
    plt.ylabel('OD demand / max. AAM capacity [%]', fontsize=18)
    if cm_print_title:
        plt.title(f'Boxplot for {file}: Occupancy')
    
    filename = 'eval_OccupOneAndBothWay_' + os.path.basename(file)
    plt.savefig(output_folder_ic + filename.replace(".csv", ".png"), dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
    plt.savefig(output_folder_ic + filename.replace(".csv", ".pdf"), bbox_inches='tight', transparent=True) ## pdf for LaTeX
    
    
    # get stats... 
    df_stats = boxplot_vals(labels, data)
    print(f'Stats for {file}: Occupancy')
    # ... and format as latex
    if cm_show_LaTeX:
        print(format_LaTeX(df_stats, [2, 2, 2], group_labels, True))    # [2, 2, 2] wegen jeweils zwei boxplots pro gruppe (one-way und both)
    else:        
        print(df_stats)
        
    # Finally medians, means, differences:
    print(calculate_mean_median_stats(labels, data, 2))
        
    plt.show()
    plt.close()