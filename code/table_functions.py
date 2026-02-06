##import libraries

import pandas as pd
import numpy as np
from config import covar_dict, covar_order, class_dict_tables

## OR tables

def mnlogit_results_table(df, symptoms, status, all_categories=None,
                         covar_dict = covar_dict, covar_order = covar_order,
                         class_dict = class_dict_tables):
    
    t4 = df
            
    t4['[0.025'] = [float(v.split(' ')[0][1:])for v in t4.CI.values]
    t4['0.975]'] = [float(v.split(' ')[-1][:-1]) for v in t4.CI.values]
    t4['covar'] = [v + '_' + str(t4.index.values[i]) for i,v in enumerate(t4.variable.values)]
            
    cluster_map = dict(zip(np.array(symptoms.original_index.values),
                       symptoms.cluster_index.values))
    t4['cluster'] = t4.cluster.map(cluster_map)

    t4 = t4.sort_values(by='cluster')
    
    #rename covariates



    t4['covar'] = t4.covar.map(covar_dict)
    t4 = t4.rename(columns = {'coef':'OR',
                              })

    
    if all_categories:
        covar_order = covar_order + ['COVID-19 status: No COVID-19 (reference)',
                                     'Recent COVID-19 (< 12 weeks)',
                                     'Past COVID-19 ($\geq$ 12 weeks)']
            
    new_or = []

    for i,v in enumerate(t4.OR.values):

        string = str(round(v,3)) + ' [' + \
                str(t4['[0.025'].values[i]) + \
                ', ' + str(t4['0.975]'].values[i]) + ']'
        
        new_or.append(string)

    t4['OR'] = new_or
    t4['p-value'] = t4['p-value'].round(3)
    
    t4 = t4[['covar','OR','p-value','cluster']]
    processed = pd.DataFrame()


    for i in range(int(max(t4.cluster.values))):

        df2 = process_plot_data(t4,covar_order,i)
        df2 = df2.drop(['cluster'],axis=1)
        df2.columns =  pd.MultiIndex.from_product([[f'{class_dict[i+2]}'],['OR','p-value']])
        processed = pd.concat([processed, df2],axis=1)
        
    
    processed = processed.replace(0.000,'<0.001')
    processed = processed.fillna('-')
    
    return processed

# process plot data

def process_plot_data(df, covar_order, i):
    
    results = df.loc[df.cluster==(i+1)]
    results = results.set_index('covar')
    results = results.reindex(list(results.index) + 
                              ['Age (years): 45-54 (reference)','Sex: Male (reference)',
                               'Ethnicity: White (reference)', 
                                'Functional limitation: None (reference)',
                              'COVID-19 status: No COVID-19 (reference)'])
    results = results.reindex(covar_order)
    
    return results

# table1

def table1(df):
    
    t1 = df
    
    t1 = t1.rename(columns = {'Unnamed: 0':'Covariate'})

    t1 = t1[['Covariate','All participants',
             'No covid','Covid < 12 weeks ago',
             'Covid > 12 weeks ago']]

    t1 = t1.set_index('Covariate')

    row_order = [t1.index.values[-1]] + [t1.index.values[-2]]\
                + list(t1.index.values[1:-2])

    t1 = t1.reindex(row_order)

    t1 = t1.reset_index()

    ssize = [int(v.split(' ')[0]) for v in t1.iloc[0][1:]]
    asymptomatic = [int(v.split(' ')[0]) for v in t1.iloc[1][1:]]

    symptomatic = np.array(ssize) - np.array(asymptomatic)

    symptomatic = pd.DataFrame.from_dict({'Covariate': 'Symptomatic, N(%)',
                  'All participants': [f'{symptomatic[0]} ({float(int(symptomatic[0]*100/ssize[0]))})'],
                  'No covid': [f'{symptomatic[1]} ({float(int(symptomatic[1]*100/ssize[1]))})'],
                  'Covid < 12 weeks ago': [f'{symptomatic[2]} ({float(int(symptomatic[2]*100/ssize[2]))})'],
                  'Covid > 12 weeks ago': [f'{symptomatic[3]} ({float(int(symptomatic[3]*100/ssize[3]))})']})

    t1 = pd.concat([symptomatic, t1], ignore_index=True)

    t1 = t1.loc[~(t1.Covariate == 'Asymptomatic, N(%)')]

    t1['Covariate group'] = ['' if ':' not in v else v.split(':')[0] \
                             for v in t1.Covariate.values]

    t1['Covariate group'] = [v if i <17 else 'Study' 
                             for i,v in enumerate(t1['Covariate group'].values)]

    t1['Covariate'] = [v.title() if ':' not in v \
                       else (v.split(':')[1]).title() \
                             for v in t1.Covariate.values]

    t1= t1[['Covariate group','Covariate','All participants',
             'No covid','Covid < 12 weeks ago',
             'Covid > 12 weeks ago']]
    
    return t1
