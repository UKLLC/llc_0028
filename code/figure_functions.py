import pickle
from config import (derived_dir, 
                    figure_dir,
                    covar_order, 
                    class_dict_figures)
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
from matplotlib.colors import ListedColormap, LinearSegmentedColormap

def process_symptom_data(dta_dir, fname):

    f = pd.read_csv(dta_dir + fname)
    
    fname = fname.split('.')[0]
    
    labeldict = pickle.load(open(derived_dir + 'labeldict.pkl','rb'))
    f = f.rename(columns=labeldict)
    cols = pd.read_csv(derived_dir + 'sorted_columns_core.csv',index_col=0)
    symptoms = f[[c for c in cols['0'].values if c in f.columns and c!='rash']]
    symptoms['size'] = f['size'].values

    symptoms.T.astype(int).to_csv(derived_dir + f'{fname}_raw.csv')
    
    symptoms_ = symptoms.drop(['size'],axis=1)
    symptoms_ = symptoms_.div(symptoms['size'].values, axis='rows')*100

    symptoms_['% size'] = symptoms['size'].values/symptoms['size'].values.sum()*100
    symptoms_['size'] = symptoms['size']
    
    symptoms = symptoms_
    
    symptoms['original_index'] = f['cluster_index']
    symptoms['cluster_index'] = np.arange(symptoms.shape[0])
    
    #reorder columns
    
    if 'lca' in fname:
        
    #    continue
        
        if '_0_' in fname:
            #symptoms['cluster_index'] = [0,1,4,3,2]
            symptoms['cluster_index'] = [0,3,2,1]
        
        if '_1_' in fname:
            #symptoms['cluster_index'] = [0,5,3,1,4,2]
            symptoms['cluster_index'] = [2,1,0,3]
            
        elif '_2_' in fname:
            #symptoms['cluster_index'] = [0,1,5,2,4,3]
            symptoms['cluster_index'] = [0,2,3,1]
            
        elif '_all_' in fname:
            #symptoms['cluster_index'] = [0,1,2,5,3,4]
            symptoms['cluster_index'] = [0,1,3,2]
            
        symptoms = symptoms.sort_values(by='cluster_index', ascending=True)
        symptoms.T.to_csv(derived_dir + f'{fname}_processed.csv')
    
    symptoms=symptoms.drop(['cluster_index','size','% size','original_index'],axis=1)
    
    return symptoms


def prevplot(df,ax,i,lca=True, all_=False, max_i=3, 
             rotate=False, l0=False, symptom=True):
 
    
    if l0==False:
        newcmp = 'viridis_r'
        norm = mpl.colors.Normalize(vmin=0, vmax=100)
        
    else:
        top = mpl.cm.get_cmap('Greys_r', 10)
        bottom = mpl.cm.get_cmap('viridis_r',100)

        newcolors = np.vstack((top(np.linspace(0, 1, 20)[-4:-3]),
                           bottom(np.linspace(0, 1, 100))))
        newcmp = ListedColormap(newcolors)
        norm = mpl.colors.Normalize(vmin=0, vmax=50)

    if rotate==True:
        df=df.T
        ax.set_xticklabels(np.arange(df.shape[1]))
    else:
        ax.set_xticklabels(df.columns.values[:], rotation=90, fontsize=10)

    
    cax = ax.imshow(df.values, aspect='auto', norm=norm, cmap=newcmp)
    cbar = plt.colorbar(cax, norm=norm)
    if i==max_i:
        cbar.set_label('Prevalence (%)', fontsize=10)
        
    ax.set_yticks(np.arange(df.shape[0]))
    ax.set_yticklabels(df.index.values, fontsize=10)
    ax.set_xticks(np.arange(df.shape[1]))
    #ax.set_xticklabels(df.columns.values[:], rotation=90, fontsize=12)

    
    

def map_cluster_numbers(symptoms, df):
    
    cluster_map = dict(zip(np.array(symptoms.original_index.values),
                       symptoms.cluster_index.values))

    df['cluster'] = df.cluster.map(cluster_map)
    
    return df.sort_values(by='cluster')



def process_plot_data(df, covar_order, i, all_categories):
    
    results = df.loc[df.cluster==(i+1)]
    results = results.set_index('covar')
    
    if all_categories:
        
        results = results.reindex(list(results.index) + 
                                  ['Age: 45-55 (reference)',
                                   'Sex: Male (reference)',
                                   'Ethnicity: White (reference)', 
                                   'Functional limitation: None (reference)',
                                   'COVID-19 status: No COVID-19 (reference)'])
    
    else:
        
        results = results.reindex(list(results.index) + 
                                  ['Age: 45-55 (reference)',
                                   'Sex: Male (reference)',
                                   'Ethnicity: White (reference)', 
                                   'Functional limitation: None (reference)'])
    
    
    results = results.reindex(covar_order)
    
    return results


def forest_plot(results, color, 
                covar_order, ax, 
                all_categories):
    
    ax.plot(np.ones(results.shape[0]), pd.Series(covar_order), 'k--', alpha=0.6)
    
    lerr = results.OR - results['[0.025']
    herr = results['0.975]'] - results.OR 
    errs = np.array(list(zip(lerr.values,
                             herr.values))).T
    
    xvals = []
    for covar in covar_order:
        if results.loc[covar].isna().all() and 'reference' not in covar:
            xvals.append(1)
        else:
            xvals.append(0)
            
    ax.scatter(xvals,pd.Series(covar_order),s = 15, marker ='o', color='orange')
            
    ax.errorbar(x=results.OR, y=results.index,
                xerr=errs, fmt = '.', 
                color = color,
                alpha=0.9,
                lw=2,
                ms=7)
    
    
    ax.set_xscale('log',base=10)
    formatter = FuncFormatter(lambda y, _: '{:.16g}'.format(y))
    ax.xaxis.set_major_formatter(formatter)
    ax.grid(alpha=0.2)
    ax.set_xlim(0.08,770)
    
    
    if all_categories:
        
        for j,t in enumerate(ax.yaxis.get_ticklabels()):
            t.set_fontsize(9)
            if j in [2,7,10,12,17]:
                t.set_weight('bold')
    else:
        
        for j,t in enumerate(ax.yaxis.get_ticklabels()):
            t.set_fontsize(9)
            if j in [4,7,9,14]:
                t.set_weight('bold')

            
def forest_plot_row(subfig, title, df, color, 
                    covar_order, letters, letter_count, 
                    class_dict, all_categories):
    
    subfig.suptitle(title,fontsize=9, 
                    fontweight='bold', x=0.62, 
                    ha = 'center')
    
    axs = subfig.subplots(nrows=1, ncols=3, sharey=True)
    
    for i,ax in enumerate(axs):

        results = process_plot_data(df, covar_order, 
                                    i, all_categories)

        forest_plot(results,color, covar_order, 
                    ax, all_categories)

        ax.set_title(f'{class_dict[i+2]}', fontsize=9)
        
        ax.text(0.05, 0.9, letters[letter_count],
                fontweight='bold', transform=ax.transAxes)
        
        letter_count+=1
        
    return letter_count




def forest_plot_grid(dfs, rowtitles, figtitle, 
                     covar_order = covar_order,
                     class_dict = class_dict_figures,
                     all_categories=None):

    fig = plt.figure(constrained_layout=True, figsize=(12,3*(len(dfs))))

    nrows = len(dfs)
    
    subfigs = fig.subfigures(nrows=nrows, ncols=1)
    
    if all_categories:
        
        covar_order = covar_order + ['COVID-19 status: No COVID-19 (reference)',
                                     'Recent COVID-19 (< 12 weeks)',
                                     'Past COVID-19 ($\geq$ 12 weeks)']
    
    covar_order.reverse()
    
    n_cols = 15
    
    cmap = mpl.colormaps['viridis_r']

    # Take colors at regular intervals spanning the colormap.
    colors = cmap(np.linspace(0, 1, n_cols))
    
    letters = list(map(chr, range(97, 123)))
    letter_count = 0
    
    if nrows>1: 
        
        for s in range(nrows):

            subfig=subfigs[s]

            title = rowtitles[s]

            letter_count = forest_plot_row(subfig, title, dfs[s], 
                                           colors[(s+1)*3], covar_order, 
                                           letters, letter_count, 
                                           class_dict, all_categories)
    
    else:
        
        subfig=subfigs

        title = rowtitles

        letter_count = forest_plot_row(subfig, title, dfs[0], 
                                       colors[-1], covar_order, 
                                       letters, letter_count, 
                                       class_dict, all_categories)
    
        
    ###### save
        
    fig.supxlabel('Odds Ratio',fontsize=10,
                  x=0.62, ha = 'center')

    plt.savefig(figure_dir + f'{figtitle}.pdf',)
    plt.savefig(figure_dir + f'{figtitle}.png',dpi=300, bbox_inches="tight",pad_inches=0.5 )