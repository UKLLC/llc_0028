import os

output_dir = '../outputs/'
dta_dir = output_dir + '/raw/'
derived_dir = output_dir + '/derived/'
figure_dir = output_dir + '/figures/'

for dir_ in [output_dir, dta_dir, derived_dir, 
             figure_dir]:
    
    os.makedirs(dir_, exist_ok = True)

core_symp2label = {'fever': 'Fever',
                 'cough': 'Cough',
                 'throat': 'Sore throat',
                 'chest_tight': 'Tight chest',
                 'breath': 'Difficulty breathing',
                 'nose': 'Runny/blocked nose',
                 'aches': 'Body/muscle aches',
                 'fatigue': 'Fatigue',
                 'diarrhoea': 'Diarrhoea',
                 'smell_taste': 'Loss of smell or taste',
                 'nausea_vomit': 'Nausea or vomiting',
                 'sneezing': 'Sneezing',
                 'headache': 'Headache',
                 'concentrating': 'Difficulty concentrating',
                 'memory': 'Memory loss'
                  }

covar_order = ['Age (years): 45-54 (reference)','18-44','55-64','$\geq$65',' Unknown',]\
            + ['Sex: Male (reference)','Female']\
            + ['Ethnicity: White (reference)','Non-white','Unknown']\
            + ['Functional limitation: None (reference)', '$\leq$2 weeks','>2-4 weeks',\
               '>4-12 weeks','>12 weeks',]

covar_dict = {'llc_ethnic3_7.0':'Non-white',
                  'llc_ethnic3_99.0': 'Unknown',
                  'functional_limitation_cat_1.0':'$\leq$2 weeks',
                  'functional_limitation_cat_2.0':'>2-4 weeks',
                  'functional_limitation_cat_3.0':'>4-12 weeks',
                  'functional_limitation_cat_4.0':'$\geq$12 weeks',
                  'llc_age': 'Age (years)',
                  'llc_sex_1.0': 'Female',
                  'age_cat_numeric_1.0': '18-44',
                  'age_cat_numeric_2.0': '55-64',
                  'age_cat_numeric_3.0' : '$\geq$65',
                  'age_cat_numeric_99.0' : ' Unknown',
                  'covid_status_1.0': 'Recent COVID-19 (< 12 weeks)',
                  'covid_status_2.0': 'Past COVID-19 ($\geq$ 12 weeks)'
              }

class_dict_tables = {1: 'Low symptom burden',
                     2: 'Aches and fatigue with upper respiratory symptoms',
                     3: 'Aches and fatigue with cognitive symptoms',
                     4: 'High symptom burden'}

class_dict_figures = {1: 'Low symptom burden',
                      2: 'Aches and fatigue with\nupper respiratory symptoms',
                      3: 'Aches and fatigue with\ncognitive symptoms',
                      4: 'High symptom burden'}
