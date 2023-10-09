## Introduction 

The following analysis is a capstone project requirement for the **Google Data Analytics Certification**. In this analysis, I'll be focussing on Bellabeat, a wellness technology company focussed on health-related products for women.   

## STEP 1 - Company Background 

The technology company with the name Bellabeat is focussed on health products for women and interested in identifying opportunities for growth based on insights from analysis of smart device fitness data. 

Although Bellabeat offers 5 different products, the focus of this analysis will be the Bellabeat app which measures health related data such as sleep, stress, activity etc. 

## STEP 2 - Ask Phase  

Here, we identify the problems to solve whilst keeping stakeholders in mind. 

**2.1 Business Task**
    
My focus as a member of Bellabeat analytic team will be on the analysis of the data from the Bellabeat app. From this analysis, I will identify highlight insights from the analysis and make high-level recommendations to marketing and management based on findings. 

**2.2 Key Deliverables** 

a.	A clear summary of the business task.

b.	A description of all data sources used. 

c.	Documentation of any cleaning or manipulation of data.

d.	A summary of your analysis.

e.	Supporting visualizations and key findings.

f.	Your top high-level content recommendations based on your analysis.

## STEP 3 - Preparation Phase

The dataset used is the FitBit Fitness Tracker Data available *[here](https://www.kaggle.com/datasets/arashnic/fitbit)*. Please note that this data is in the Public Domain and available through Mobius.  

Things to note about dataset used: 

* Dataset was generated in 2016 and more than 6 years old from the time of this analysis. This means that findings from this analysis may need to be complemented/compared with more recent data. 

* Although Bellabeat is a tech company focussed only on women, the datasets used in this analysis gives no information about the gender of study participants. 

* Although a total of 18 CSV files were included in the dataset at the time of this analysis, most of them are either replicates or redundant. For this reason, we started by importing 5 datasets but ended up using both the dailyAcvity_merged.csv and sleepDay_merged.csv for our analysis. 

* The highest sample size of 33 distinct correspondents in dataset confers significant limitation and may not be an accurate representation of user’s population. The other datasets are either too small or too inconsistent and have been excluded from being used in our analysis. 

**3.1 Loading Packages and libraries** 

The R codes used in this analysis are shown [here]( https://github.com/damolasimon/PortfolioProjects/blob/main/BellabeatAnalysis.R).

```
#Upload the data files 
daily_activity <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
daily_steps <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/dailySteps_merged.csv")
daily_calories <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/dailyCalories_merged.csv")
sleep_records <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
weight_records <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")
```

```
glimpse(daily_activity)
glimpse(daily_steps)
glimpse(daily_calories)
glimpse(sleep_records)
glimpse(weight_records)

head(daily_activity)
head(daily_steps)
head(daily_calories)
head(sleep_records)
head(weight_records)
```

## STEP 4 - Processing Phase
From the earlier preview of our datasets, we observed the following:
•	The column names need to be reworked for consistency.
•	Date is in character format and need to be changed to appropriate type.
In this phase, we’ll be cleaning, formatting, and merging our datasets to make sure they are ready for analysis.
```
#Clean column names
daily_activity <- clean_names(daily_activity)
daily_steps <- clean_names(daily_steps)
daily_calories <- clean_names(daily_calories)
sleep_records <- clean_names(sleep_records)
weight_records <- clean_names(weight_records)

```

```

#Convert data type of date from char to date format

daily_activity_clean <- daily_activity %>%
  mutate(activity_date = mdy(activity_date))

daily_steps_clean <- daily_steps %>% 
  mutate(activity_day = mdy(activity_day))

daily_calories_clean <- daily_calories %>% 
  mutate(activity_day = mdy(activity_day))

sleep_records_clean <- sleep_records %>%
  mutate(sleep_day = mdy_hms(sleep_day))

weight_records_clean <- weight_records %>%
  mutate(date = mdy_hms(date))

```

```
#Determine sample size for each dataset
n_distinct(daily_activity_clean$id)
## [1] 33
n_distinct(daily_calories_clean$id)
## [1] 33
n_distinct(daily_steps_clean$id)
## [1] 33
n_distinct(sleep_records_clean$id)
## [1] 24
n_distinct(weight_records_clean$id)
## [1] 8
```
From the above cleaning, we observed that the weight_records dataset returned 8 records which is too small a sample size for this analysis. Therefore, we’ll not be including this dataset in further analysis.

 ### STEP 4.1 Compare Summaries and Remove Redundancy
Here, we’ll be removing redundancy by comparing summaries of our datasets and eliminating non-useful data.

```
#To select key variables from each dataset and do a summmary calculation. 
daily_activity_clean %>%
  select(activity_date, total_steps, total_distance, sedentary_minutes, calories) %>%
  summary()
```


```
daily_steps_clean %>% 
  select(step_total) %>%
  summary(
```

```
daily_calories_clean %>%
  select(calories) %>%
  summary()
```

```
sleep_records_clean %>%
  select(total_sleep_records, total_minutes_asleep, total_time_in_bed) %>%
  summary()
```

Taking a look at the summary of our datasets, we observed that both daily_steps and daily_calories datasets are not giving us additional insights and we’ll not be including them in further analysis.

 ## STEP 4.2 Merging Datasets and Removing Duplicates
At this stage, we’ll be looking at combining both our sleep_records dataset and daily_activity_clean dataset. We’ll then remove duplicates and check our merged data to make sure it is ready for further analysis.
```
#rename date column and change type to date

sleep_records_final <- sleep_records %>%
  rename("activity_date" = "sleep_day") %>%
  mutate(activity_date = mdy_hms(activity_date))
  ```
```
#Verify format
str(sleep_records_final$activity_date)
```


```
#Select some columns from our daily_activity_clean 
daily_activity_clean <- daily_activity_clean %>%
  select(id, activity_date, total_steps, total_distance, sedentary_minutes, very_active_minutes, calories)
```

```
#Verify format
str(daily_activity_clean)

#merge daily_activity_clean and sleep_records_final dataset
merged_data <- merge(daily_activity_clean, sleep_records_final, by = c("id", "activity_date"), all.x = TRUE)

```

```
#verify merged data
head(merged_data)
##           id activity_date total_steps total_distance sedentary_minutes
## 1 1503960366    2016-04-12       13162           8.50               728
## 2 1503960366    2016-04-13       10735           6.97               776
## 3 1503960366    2016-04-14       10460           6.74              1218
## 4 1503960366    2016-04-15        9762           6.28               726
## 5 1503960366    2016-04-16       12669           8.16               773
## 6 1503960366    2016-04-17        9705           6.48               539
##   very_active_minutes calories total_sleep_records total_minutes_asleep
## 1                  25     1985                   1                  327
## 2                  21     1797                   2                  384
## 3                  30     1776                  NA                   NA
## 4                  29     1745                   1                  412
## 5                  36     1863                   2                  340
## 6                  38     1728                   1                  700
##   total_time_in_bed
## 1               346
## 2               407
## 3                NA
## 4               442
## 5               367
## 6               712
```
```
glimpse(merged_data)
## Rows: 943
## Columns: 10
## $ id                   <dbl> 1503960366, 1503960366, 1503960366, 1503960366, 1…
## $ activity_date        <date> 2016-04-12, 2016-04-13, 2016-04-14, 2016-04-15, …
## $ total_steps          <dbl> 13162, 10735, 10460, 9762, 12669, 9705, 13019, 15…
## $ total_distance       <dbl> 8.50, 6.97, 6.74, 6.28, 8.16, 6.48, 8.59, 9.88, 6…
## $ sedentary_minutes    <dbl> 728, 776, 1218, 726, 773, 539, 1149, 775, 818, 83…
## $ very_active_minutes  <dbl> 25, 21, 30, 29, 36, 38, 42, 50, 28, 19, 66, 41, 3…
## $ calories             <dbl> 1985, 1797, 1776, 1745, 1863, 1728, 1921, 2035, 1…
## $ total_sleep_records  <dbl> 1, 2, NA, 1, 2, 1, NA, 1, 1, 1, NA, 1, 1, 1, 1, N…
## $ total_minutes_asleep <dbl> 327, 384, NA, 412, 340, 700, NA, 304, 360, 325, N…
## $ total_time_in_bed    <dbl> 346, 407, NA, 442, 367, 712, NA, 320, 377, 364, N…
#Check for number of full duplicates (duplicates in every column) in our merged data 
sum(duplicated(merged_data))
## [1] 3

#To see the duplicated rows 
filter(merged_data, duplicated(merged_data))
##           id activity_date total_steps total_distance sedentary_minutes
## 1 4388161847    2016-05-05        9603           7.38               896
## 2 4702921684    2016-05-07       14370          11.65               577
## 3 8378563200    2016-04-25       12405           9.84               692
##   very_active_minutes calories total_sleep_records total_minutes_asleep
## 1                  12     2899                   1                  471
## 2                   5     3683                   1                  520
## 3                 117     4005                   1                  388
##   total_time_in_bed
## 1               495
## 2               543
## 3               402

#Drop full duplicates from merged dataset and verify 
merged_data_unique <- distinct(merged_data)

head(merged_data_unique)
##           id activity_date total_steps total_distance sedentary_minutes
## 1 1503960366    2016-04-12       13162           8.50               728
## 2 1503960366    2016-04-13       10735           6.97               776
## 3 1503960366    2016-04-14       10460           6.74              1218
## 4 1503960366    2016-04-15        9762           6.28               726
## 5 1503960366    2016-04-16       12669           8.16               773
## 6 1503960366    2016-04-17        9705           6.48               539
##   very_active_minutes calories total_sleep_records total_minutes_asleep
## 1                  25     1985                   1                  327
## 2                  21     1797                   2                  384
## 3                  30     1776                  NA                   NA
## 4                  29     1745                   1                  412
## 5                  36     1863                   2                  340
## 6                  38     1728                   1                  700
##   total_time_in_bed
## 1               346
## 2               407
## 3                NA
## 4               442
## 5               367
## 6               712

```
```
#create weekday column from activity_date
merged_data_unique$weekday <- wday(merged_data_unique$activity_date, label=TRUE, abbr=FALSE)

head(merged_data_unique)

##           id activity_date total_steps total_distance sedentary_minutes
## 1 1503960366    2016-04-12       13162           8.50               728
## 2 1503960366    2016-04-13       10735           6.97               776
## 3 1503960366    2016-04-14       10460           6.74              1218
## 4 1503960366    2016-04-15        9762           6.28               726
## 5 1503960366    2016-04-16       12669           8.16               773
## 6 1503960366    2016-04-17        9705           6.48               539
##   very_active_minutes calories total_sleep_records total_minutes_asleep
## 1                  25     1985                   1                  327
## 2                  21     1797                   2                  384
## 3                  30     1776                  NA                   NA
## 4                  29     1745                   1                  412
## 5                  36     1863                   2                  340
## 6                  38     1728                   1                  700
##   total_time_in_bed   weekday
## 1               346   Tuesday
## 2               407 Wednesday
## 3                NA  Thursday
## 4               442    Friday
## 5               367  Saturday
## 6               712    Sunday

```

```
#checking to make sure all the duplicates were dropped.
sum(duplicated(merged_data_unique))
```

Getting a summary of our merged data to ensure cleanliness
```
skim(merged_data_unique)

Data summary
Name	merged_data_unique
Number of rows	940
Number of columns	11
_______________________	
Column type frequency:	
Date	1
factor	1
numeric	9
________________________	
Group variables	None
Variable type: Date
skim_variable	n_missing	complete_rate	min	max	median	n_unique
activity_date	0	1	2016-04-12	2016-05-12	2016-04-26	31
Variable type: factor
skim_variable	n_missing	complete_rate	ordered	n_unique	top_counts
weekday	0	1	TRUE	7	Tue: 152, Wed: 150, Thu: 147, Fri: 126
Variable type: numeric
skim_variable	n_missing	complete_rate	mean	sd	p0	p25	p50	p75	p100	hist
id	0	1.00	4.855407e+09	2.424805e+09	1503960366	2.320127e+09	4.445115e+09	6.962181e+09	8.877689e+09	▇▅▃▅▅
total_steps	0	1.00	7.637910e+03	5.087150e+03	0	3.789750e+03	7.405500e+03	1.072700e+04	3.601900e+04	▇▇▁▁▁
total_distance	0	1.00	5.490000e+00	3.920000e+00	0	2.620000e+00	5.240000e+00	7.710000e+00	2.803000e+01	▇▆▁▁▁
sedentary_minutes	0	1.00	9.912100e+02	3.012700e+02	0	7.297500e+02	1.057500e+03	1.229500e+03	1.440000e+03	▁▁▇▅▇
very_active_minutes	0	1.00	2.116000e+01	3.284000e+01	0	0.000000e+00	4.000000e+00	3.200000e+01	2.100000e+02	▇▁▁▁▁
calories	0	1.00	2.303610e+03	7.181700e+02	0	1.828500e+03	2.134000e+03	2.793250e+03	4.900000e+03	▁▆▇▃▁
total_sleep_records	530	0.44	1.120000e+00	3.500000e-01	1	1.000000e+00	1.000000e+00	1.000000e+00	3.000000e+00	▇▁▁▁▁
total_minutes_asleep	530	0.44	4.191700e+02	1.186400e+02	58	3.610000e+02	4.325000e+02	4.900000e+02	7.960000e+02	▁▂▇▃▁
total_time_in_bed	530	0.44	4.584800e+02	1.274600e+02	61	4.037500e+02	4.630000e+02	5.260000e+02	9.610000e+02	▁▃▇▁▁

```
##  STEP 5 – Analysis & Visualisation Phase
To get interesting insights from our merged datasets, we’ll be comparing different variables from our datasets and viewing relationships via plots.


5.1 # Measuring Relationships between Variables
```
#PLOT_1 To observe the distribution of time spent sleeping by participants.
ggplot(data = merged_data_unique, mapping = aes(total_minutes_asleep)) + 
  geom_histogram(bins = 10, na.rm = TRUE, color = "#ffa600") + 
  labs(title="Distribution of Total Time Asleep", x="Total Time Asleep (minutes)") + 
  theme_classic()
```
![Distribution]

```
#PLOT_2 Burnt calories vs total steps - To check the relationship between steps_taken and calories_burnt
ggplot(data = merged_data_unique, mapping = aes(x = total_steps, y = calories)) +
  geom_point(alpha = 0.5, shape = 8, color = "#003f5c", size = 3) + 
  geom_smooth(method = "lm", se = FALSE) +
  theme_bw() +
  labs(title = "Burnt Calories vs Total Steps")
```

```
#PLOT_3 total time_in_bed vs total_time_asleep 
plot_3 <- ggplot(data = merged_data_unique, mapping= aes(x = total_time_in_bed , y = total_minutes_asleep)) + 
    geom_point(mapping = aes(color = calories), alpha = 0.3, shape = 7) + 
    geom_smooth() + 
    labs(title = "Sleep duration vs Time in Bed") +
    theme_classic()
```

```
#PLOT_4 Sleep duration vs Sedentary Time 
plot_4 <-  ggplot(data = merged_data_unique, mapping = aes(x = sedentary_minutes, y = total_minutes_asleep)) + 
    geom_point(alpha = 0.6, shape = 1, mapping = aes(color = calories)) + 
    geom_smooth() + 
    labs(title = "Sleep duration vs Sedentary Time") + 
    theme_classic()

(plot_3 + plot_4) + 
    plot_annotation(title = 'Sleep duration compared to Time in Bed and Sedentary Time') + 
    plot_layout(ncol = 2, widths = c(2,2))

Key findings based on our analysis and plots include:
•	The sleep distribution of our participants shows that majority sleep less than the the daily recommendation of 8 hours per day.
•	It seems the less active our participants become, the less actual sleep they get.
•	All participants records less than the CDC recommended 10,000 daily steps for an active adult.
•	It appears that a positive relationship exists between total steps and calories burnt.
5.2 ## Measuring Daily Data In the next plots, it will be good to see how the steps_taken by participants, burnt_calories and total_sleep varies on each day of the week. To do this, we need to carry out some data aggregation and summary as shown below:
#computing total steps by weekday
total_steps_by_weekday <- merged_data_unique %>% group_by(weekday) %>%
  summarise(steps= sum(total_steps, na.rm = TRUE), 
            Mean = mean(total_steps, na.rm = TRUE))

#computing total calories by weekday
total_calories_by_weekday <- merged_data_unique %>% group_by(weekday)%>%
  summarise(total_calories = sum(calories, na.rm = TRUE), 
            Mean_calories = mean(calories, na.rm = TRUE))

#computing total sleep by days of the week  
sleep_by_weekday <- merged_data_unique %>% group_by(weekday) %>%
  summarise(total_sleep = sum(total_minutes_asleep, na.rm = TRUE), 
            average_sleep = mean(total_minutes_asleep, na.rm = TRUE))
 
#PLOT_5 Day of the week vs average steps
plot_5 <- ggplot(data = total_steps_by_weekday, mapping = aes(x = reorder(weekday, -Mean), y = Mean)) +
    geom_col(fill = "#fa9169") + 
    geom_hline(yintercept = 10000) +
    ggeasy::easy_rotate_labels(which = "x", angle = 90) +
    labs(title = "Average Steps by days_of_week", y = "average_steps", x = "Days of the Week") 
   
  
#PLOT_6 Day of the week vs average calories burnt
plot_6 <- ggplot(data = total_calories_by_weekday, mapping = aes(x = reorder(weekday, -Mean_calories), y= Mean_calories)) + 
    geom_col(fill="#d45087") + 
    labs(title = "Calories Burnt by days_of_week", y = "Avearge Calories Burnt", x = "Days of the Week") +
    ggeasy::easy_rotate_labels(which = "x", angle = 90) 
    

(plot_5 + plot_6) +
    plot_annotation(title = 'Average Steps and Average Calories burnt on different Days of the Weeek') + 
    plot_layout(ncol = 2, widths = c(1,1))
 
#PLOT_7 Day of the week vs Sleep 
ggplot(data = sleep_by_weekday, mapping = aes(x = reorder(weekday, -average_sleep), y = average_sleep)) + 
  geom_col(fill="#ff7c43" ) + 
  geom_hline(yintercept = 480) +
  labs(title = "Average sleep in minutes by day_of_week", y = "Average Sleep (minutes)", x = "Days of the Week") + 
  theme_classic()
 
Further important findings based day of the week include the following: * Highest number of average steps taken was recored on Saturday while the least was recorded on Sunday. * Maximum amount of average calories burnt was recorded on Saturday while the least was recorded on Sunday. This agrees with our earlier findings about the average stpes and calories burnt. * The least amount of sleep was recorded on Thursday, and highest was recorded on Sunday.
5.3 # Grouping Participants
Finally, I think it will be interesting to categorize participants on the level of their activity. This classification will be based on whether participants are sedentary, lightly active, fairly active or very active. The source used for the categorisation can be found by clicking on this link.
#Group participants into different categories
daily_activity_average <- merged_data_unique %>%
  group_by(id) %>%
  summarise(daily_calories_average = mean(calories),
            daily_steps_average = mean(total_steps),
            daily_sleep_average = mean(total_minutes_asleep, na.rm = TRUE)) %>%
  mutate(user_categories = case_when(
    daily_steps_average < 5000 ~ "sedentary",
    daily_steps_average >= 5000 & daily_steps_average < 7499 ~ "lightly_active",
    daily_steps_average >= 7499 & daily_steps_average < 9999 ~ "fairly_active",
    daily_steps_average >= 10000 ~ "very_active"
  ))

#verify the daily_activity_average
head(daily_activity_average)
## # A tibble: 6 × 5
##           id daily_calories_average daily_steps_average daily_sleep_average
##        <dbl>                  <dbl>               <dbl>               <dbl>
## 1 1503960366                  1816.              12117.                360.
## 2 1624580081                  1483.               5744.                NaN 
## 3 1644430081                  2811.               7283.                294 
## 4 1844505072                  1573.               2580.                652 
## 5 1927972279                  2173.                916.                417 
## 6 2022484408                  2510.              11371.                NaN 
## # ℹ 1 more variable: user_categories <chr>
#Getting the fraction of active categories
usertype_data <- daily_activity_average %>%
  group_by(user_categories) %>%
  summarise(total = n()) %>%
  mutate(category_fraction = (total/sum(total)))

#verify usertype data 
usertype_data
## # A tibble: 4 × 3
##   user_categories total category_fraction
##   <chr>           <int>             <dbl>
## 1 fairly_active       9             0.273
## 2 lightly_active      9             0.273
## 3 sedentary           8             0.242
## 4 very_active         7             0.212
# PLOT 8: Doughnut chart of participants on activity levels - The very active category represents the smallest group of the entire sample accounting for only 21.21%. 
usertype_distribution <- usertype_data %>%
  mutate(ymax = cumsum(category_fraction)) %>%
  mutate(ymin = c(0, head(ymax, n=-1))) %>%
  mutate(label_position = (ymax + ymin)/2) %>%
  mutate(label = paste0(user_categories, "\n", round(category_fraction*100, digits = 2), "%"))

ggplot(usertype_distribution, aes(
  ymax = ymax, ymin = ymin, xmax = 7, xmin = 4, fill = user_categories)) + 
  geom_rect() + 
  geom_label( x = 6, aes(y = label_position, label = label), fill = "#bfcbdb", inherit.aes = FALSE, alpha = 0.6, size = 4, label.size = 0) +
  ggtitle("Categorisation of participants based on activity levels") + 
  scale_color_brewer(palette = 2) + 
  coord_polar(theta = "y") + 
  theme_void() + 
  annotate("text", x = 0, y = 0, label = "Sample size\n= 33", size = 6) + 
  theme(legend.position = "none", plot.title = element_text(size = 19, hjust = 0.5))
 
Final observation based on grouping participants based on their activity levels reveals the following:
•	The very active group accounts for only 21.21% of the total participants and represents the smallest group.
•	The lightly active and failry active group accounts for 27.27% and represents the largest group.
## STEP 6 Act - Recommendation
Looking at the key findings from our analysis phase, we can make the following recommendations based on those:
•	It will be an interesting and potential selling point for customers if the Bellabeat app could be designed to measure the relationship between suboptimal sleeping habits and stress levels.
•	The app could be modified to include push notifications or reminders that encourage more activities on days with high sedentary levels like Sundays.
•	The app could be designed to show health benefits associated with keeping an active lifestyle. This will encourage users to engage the app more often in achieving their exercise goals.
•	The app could be designed to encourage the development of healthy communities through the formation of work-out groups and clubs. This will help customers to attain their health goals whilst fostering social interaction and integration.

![image](https://github.com/damolasimon/PortfolioProjects/assets/35555470/e0ecc14f-266c-430e-93a7-8c1c9ecda8d6)
