# -*- coding: utf-8 -*-
"""
Created on Mon Mar 30 14:24:21 2026

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import os

output_folder_ic = 'C:/Users/chris/plots/v07/travelTimes/'


file = 'C:/TUMdissDATA/ttimesPUT_top10000_scen1.csv'

# load CSV
df = pd.read_csv(file)


# sort again
#df = df.sort_values(by='u_ample_scen1_common', ascending=False)

df_10 = df.head(10)
df_100 = df.head(100)
df_10000 = df.head(10000)


print(df_10)

data = [
    df_10['sum_ttime_put_combined'],
    df_10['sum_ttime_put_with_uam_combined'],
    
    df_100['sum_ttime_put_combined'],
    df_100['sum_ttime_put_with_uam_combined'],
    
    df_10000['sum_ttime_put_combined'],
    df_10000['sum_ttime_put_with_uam_combined']
]


plt.figure(figsize=(12, 6))
plt.boxplot(data, showfliers=False)



#plt.yscale('log')  # falls Werte stark streuen

plt.xticks(
    [1, 2, 3, 4, 5, 6],
    [
        '10 mit', '10 ohne',
        '100 mit', '100 ohne',
        '10k mit', '10k ohne'
    ]
)

plt.ylabel('wert')
plt.title(f'Boxplot for {file}')

filename = os.path.basename(file)
output_name = filename.replace(".csv", ".pdf")



#plt.savefig(output_folder_ic + output_name, dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig(output_folder_ic + output_name, bbox_inches='tight', transparent=True) ## pdf for LaTeX

plt.show()
plt.clf()