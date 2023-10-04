# Install necessary packages and libraries 
install.packages("tidyverse") #transformation of data 
install.packages("lubridate") # useful for editing date and time formats
install.packages("skimr") # helps you summarize & skim through data 
install.packages("plotly") #for creating interactive graphs                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
install.packages("janitor") #useful for data cleaning 
install.packages("ggeasy") #useful for customization of plots 
install.packages("ggpubr") #provides functions for plots customization
#install libraries 
library(tidyverse)
library(lubridate)
library(skimr)
library(plotly)
library(janitor)
library(ggeasy)
library(ggpubr)
library(patchwork)

#Upload the data files 
daily_activity <- read_csv("/Users/damolaayoyerokun/Documents/RProjects/Rdata/Fitabase_data/dailyActivity_merged.csv")

daily_steps <- read_csv("/Users/damolaayoyerokun/Documents/RProjects/Rdata/Fitabase_data/dailySteps_merged.csv")

daily_calories <- read_csv("/Users/damolaayoyerokun/Documents/RProjects/Rdata/Fitabase_data/dailyCalories_merged.csv")

sleep_records <- read_csv("/Users/damolaayoyerokun/Documents/RProjects/Rdata/Fitabase_data/sleepDay_merged.csv")

weight_records <- read_csv("/Users/damolaayoyerokun/Documents/RProjects/Rdata/Fitabase_data/weightLogInfo_merged.csv")

#Check the summaries of dataframes to familiarize myself with the data 
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

#Initial observation of data shows date is in character format for all the dataframes. The column names also need to be reworked for consistency. 

#Clean column names 
daily_activity <- clean_names(daily_activity)
daily_steps <- clean_names(daily_steps)
daily_calories <- clean_names(daily_calories)
sleep_records <- clean_names(sleep_records)
weight_records <- clean_names(weight_records)

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

#Verify the converted type
str(daily_activity_clean$activity_date)
str(daily_steps_clean$activity_day)
str(daily_calories_clean$activity_day)
str(sleep_records_clean$sleep_day)
str(weight_records_clean$date)

#Determine sample size for each dataset
n_distinct(daily_activity_clean$id)
n_distinct(daily_calories_clean$id)
n_distinct(daily_steps_clean$id)
n_distinct(sleep_records_clean$id)
n_distinct(weight_records_clean$id)

# From the computation, activity_data returns 33 records, daily_steps returns 33 records, daily_calories returns 33 records, sleep_records returns 24 records while weight_return returns 8 records. 
#Sample size of 8 from the weight_records appears too small for any reasonable conclusions hence this will not be included in the analysis going forward. 

#To select key variables from each dataset and do a summmary calculation. 

daily_activity_clean %>%
  select(activity_date, total_steps, total_distance, sedentary_minutes, calories) %>%
  summary()

daily_steps_clean %>% 
  select(step_total) %>%
  summary()

daily_calories_clean %>%
  select(calories) %>%
  summary()

sleep_records_clean %>%
  select(total_sleep_records, total_minutes_asleep, total_time_in_bed) %>%
  summary()

#From the daily_activity_clean dataset and the sleep_records_clean dataset, we can see the following summary statistics:  


#rename date column and change type to date

sleep_records_final <- sleep_records %>%
  rename("activity_date" = "sleep_day") %>%
  mutate(activity_date = mdy_hms(activity_date))
  
#Verify format
str(sleep_records_final$activity_date)

#Select some columns from our daily_activity_clean 

daily_activity_clean <- daily_activity_clean %>%
  select(id, activity_date, total_steps, total_distance, sedentary_minutes, very_active_minutes, calories)

#Verify format
str(daily_activity_clean)

#merge daily_activity_clean and sleep_records_final dataset
merged_data <- merge(daily_activity_clean, sleep_records_final, by = c("id", "activity_date"), all.x = TRUE)

#verify merged data
head(merged_data)
glimpse(merged_data)

#Check for number of full duplicates (duplicates in every column) in our merged data 
sum(duplicated(merged_data))

#To see the duplicated rows 
filter(merged_data, duplicated(merged_data))

#Dropping full duplicates from merged dataset
merged_data_unique <- distinct(merged_data)

head(merged_data_unique)

#create weekday column from activity_date
merged_data_unique$weekday <- wday(merged_data_unique$activity_date, label=TRUE, abbr=FALSE)

head(merged_data_unique)

#checking to make sure all the duplicates were dropped. 
sum(duplicated(merged_data_unique))

#using skimr to get a data summary of our merged data to ensure cleanliness
skim(merged_data_unique)

# ANALYSIS AND VISUALIZATION 

#PLOT_1  To observe the distribution of time spent sleeping by participants.
ggplot(data = merged_data_unique, mapping = aes(total_minutes_asleep)) + 
  geom_histogram(bins = 10, na.rm = TRUE, color = "#ffa600") + 
  labs(title="Distribution of Total Time Asleep", x="Total Time Asleep (minutes)")


#PLOT_2 Burnt calories vs total steps - To check the relationship between steps_taken and calories_burnt
ggplot(data = merged_data_unique, mapping = aes(x = total_steps, y = calories)) +
  geom_point(alpha = 0.5, shape = 8, color = "#003f5c", size = 3) + 
  geom_smooth(method = "lm", se = FALSE) +
  theme_bw() +
  labs(title = "Burnt Calories vs Total Steps")

#Comparing how time asleep is impacted by time_in_bed and sedentary_time


#PLOT_3 total time_in_bed vs total_time_asleep 
plot_3 <- ggplot(data = merged_data_unique, mapping= aes(x = total_time_in_bed , y = total_minutes_asleep)) + 
    geom_point(mapping = aes(color = calories), alpha = 0.3, shape = 7) + 
    geom_smooth() + 
    labs(title = "Sleep duration vs Time in Bed") +
    theme_classic()

#PLOT_4 Sleep duration vs Sedentary Time 
plot_4 <-  ggplot(data = merged_data_unique, mapping = aes(x = sedentary_minutes, y = total_minutes_asleep)) + 
    geom_point(alpha = 0.6, shape = 1, mapping = aes(color = calories)) + 
    geom_smooth() + 
    labs(title = "Sleep duration vs Sedentary Time") + 
    theme_classic()


plot_3 + plot_4
#To compare how steps_taken, burnt_calories and total_sleep varies on each days of the week

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

# plots of days of the week against average steps and average calories
ggarrange( 
#PLOT_5 Day of the week vs average steps
  ggplot(data = total_steps_by_weekday, mapping = aes(x = reorder(weekday, -Mean), y = Mean)) +
    geom_col(fill = "#fa9169") + 
    geom_hline(yintercept = 10000) +
    ggeasy::easy_rotate_labels(which = "x", angle = 90) +
    labs(title = "Average Steps by days_of_week", y = "average_steps", x = "Day of the Week"),
  
#PLOT_6 Day of the week vs average calories burnt
  ggplot(data = total_calories_by_weekday, mapping = aes(x = reorder(weekday, -Mean_calories), y= Mean_calories)) + 
    geom_col(fill="#d45087") + 
    labs(title = "Calories Burnt by days_of_week", y = "Avearge Calories Burnt", x = "Day of the Week") +
    ggeasy::easy_rotate_labels(which = "x", angle = 90)
)

#PLOT_7 Day of the week vs Sleep  - To check the average sleep on each day of the week 

ggplot(data = sleep_by_weekday, mapping = aes(x = reorder(weekday, -average_sleep), y = average_sleep)) + 
  geom_col(fill="#ff7c43" ) + 
  geom_hline(yintercept = 480) +
  ggeasy::easy_rotate_labels(which = "x", angle = 90) +
  labs(title = "Average sleep in minutes by day_of_week", y = "Average Sleep (minutes)", x = "Day of the Week")

#PLOT_8 Average Steps by Date - To check how date impacts activity level. No observable relationship between dates and average steps taken by participants 
#total steps by date
total_steps_by_day <- merged_data_unique %>% group_by(activity_date) %>%
  summarise(steps= sum(total_steps, na.rm = TRUE), 
            average_steps = mean(total_steps, na.rm = TRUE))

ggplot(data = total_steps_by_day, mapping = aes(x = activity_date, y = average_steps)) + 
  geom_point(alpha = 0.6, shape = 4, color = "#a05195") + 
  geom_smooth() + 
  labs(title = "Average Steps by Date")

# I'd like to categorize the respondents based on their level of activity. The classification will be based on whether participants are sedentary, lightly active, fairly active and very active.         e

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

#Getting the fraction of active categories
usertype_data <- daily_activity_average %>%
  group_by(user_categories) %>%
  summarise(total = n()) %>%
  mutate(category_fraction = (total/sum(total)))

#verify usertype data 
usertype_data

# PLOT 9: Doughnut chart of participants on activity levels - The very active category represents the smallest group of the entire sample accounting for only 21.21%. 
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

