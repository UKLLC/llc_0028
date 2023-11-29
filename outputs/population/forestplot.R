#forest plots for LLC data

library(grid)
library(forestplot)
library(dplyr)
library(tidyverse)
library(ggplot2) 

#read in data, covid < 12 weeks ago
dta = read.csv('lr_results_0_1_core_.csv')

#convert to dataframe
data_l12<-data.frame(dta)

#read in data, covid <>12 weeks ago
dta = read.csv('lr_results_0_2_core_.csv')

#convert to dataframe
data_g12<-data.frame(dta)

################################
# plot for covid < 12 weeks ago#
################################
forest_data_l12 <- tibble::tibble(mean = data_l12$Estimate,
                              lower = data_l12$X2.5..,
                              upper = data_l12$X97.5..,
                              symptom = data_l12$X,
                              OR = round(data_l12$Estimate, digits=2))

fplot <- forest_data_l12 |> 
  forestplot(labeltext = c(symptom,OR),
             title = 'No Covid vs Covid < 12 weeks ago',
             xlog = TRUE)|>
  fp_set_style(box = "royalblue",
               line = "darkblue",
               summary = "royalblue") |> 
  fp_add_header(symptom = c("", "Symptom"),
                OR = c("", "OR"))


###############################
#plot for covid > 12 weeks ago#
###############################
forest_data_g12 <- tibble::tibble(mean = data_g12$Estimate,
                                  lower = data_g12$X2.5..,
                                  upper = data_g12$X97.5..,
                                  symptom = data_g12$X,
                                  OR = round(data_g12$Estimate, digits=2))

forest_data_g12 |> 
  forestplot(labeltext = c(symptom,OR),
             title = 'No Covid vs Covid > 12 weeks ago',
             xlog = TRUE)|>
  fp_set_style(box = "royalblue",
               line = "darkblue",
               summary = "royalblue") |> 
  fp_add_header(symptom = c("", "Symptom"),
                OR = c("", "OR"))



#################
#all on one plot#
#################

forest_data_l12 <- forest_data_l12 %>%
  add_column(Status = 'Covid < 12 weeks ago')

forest_data_g12 <- forest_data_g12 %>%
  add_column(Status = 'Covid > 12 weeks ago')

all_data <- bind_rows(forest_data_l12, forest_data_g12)


df <- all_data

#define colours for dots and bars
dotCOLS = c("#a6d8f0","#f9b282")
barCOLS = c("#008fd5","#de6b35")

p <- ggplot(df, aes(x=symptom, y=OR, ymin=lower, ymax=upper,
                    col=Status,fill=Status)) + 
  #specify position here
  geom_linerange(linewidth=1,position=position_dodge(width = 0.5)) +
  geom_hline(yintercept=1, lty=2) +
  #specify position here too
  geom_point(size=3, shape=21, colour="white", 
             stroke = 0.5,position=position_dodge(width = 0.5)) +
  scale_fill_manual(values=barCOLS)+
  scale_color_manual(values=dotCOLS)+
  scale_x_discrete(name="Symptoms") +
  scale_y_continuous(name="Odds ratio", limits = c(0.5, 14.5),  trans='log2') +
  coord_flip() +
  theme_minimal()+
  labs(title = 'Symptom ORs, (reference category: No Covid)')

print(p)

#save
ggsave('individual_symptom_ORs_combined.pdf')
