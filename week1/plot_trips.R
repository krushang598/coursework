########################################
# load libraries
########################################

# load some packages that we'll need
library(tidyverse)
library(scales)

# be picky about white backgrounds on our plots
theme_set(theme_bw())

# load RData file output by load_trips.R
load('trips.RData')


########################################
# plot trip data
########################################

# plot the distribution of trip times across all rides (compare a histogram vs. a density plot)
trips %>%
  filter(tripduration/60 < 1000) %>%
  ggplot() + 
  geom_density(aes(x = tripduration/60), fill = "red") + 
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma)

# plot the distribution of trip times by rider type indicated using color and fill (compare a histogram vs. a density plot)
filter(trips, tripduration < quantile(tripduration, .99)) %>%
  ggplot() +
  geom_histogram(aes(x = tripduration/60), bins = 50) + 
  scale_x_log10(label = comma) + 
  scale_y_continuous(label = comma) +
  facet_wrap(~ usertype, ncol = 1, scale = "free_y")

# plot the total number of trips on each day in the dataset
trips %>% 
  mutate(ymd = as.Date(starttime)) %>%
  group_by(ymd) %>%
  summarize(count = n()) %>%
  ggplot() + 
  geom_histogram(aes(x = y = count),bins=30) +
  scale_y_continuous(label = comma)

# plot the total number of trips (on the y axis) by age (on the x axis) and gender (indicated with color)
trips %>%
  mutate(age = (2014-birth_year)) %>%
  group_by(age, gender) %>%
  summarize(count = n()) %>%
  ggplot(mapping = aes(x = age, y = count, color = gender)) +
  scale_y_continuous(lim = c(0, 250000)) + 
  geom_point() +
  scale_color_brewer()

# plot the ratio of male to female trips (on the y axis) by age (on the x axis)
# hint: use the spread() function to reshape things to make it easier to compute this ratio
# (you can skip this and come back to it tomorrow if we haven't covered spread() yet)
trips %>%
  mutate(age = 2014-birth_year) %>%
  group_by(age, gender) %>%
  summarize(count = n()) %>%
  pivot_wider(names_from = gender, values_from = count) %>%
  mutate(ratio = Male/Female) %>%
  ggplot(mapping = aes(x = age, y = ratio)) +
  geom_point()

########################################
# plot weather data
########################################
# plot the minimum temperature (on the y axis) over each day (on the x axis)
weather %>%
  ggplot(mapping = aes(x = ymd, y = tmin)) +
  geom_line()

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)
# hint: try using the gather() function for this to reshape things before plotting
# (you can skip this and come back to it tomorrow if we haven't covered gather() yet)
weather %>% select(ymd,tmax,tmin) %>% 
  pivot_longer(names_to = "temp", values_to = "temperature", 2:3) %>% 
  ggplot() + geom_point(mapping = aes(x=ymd, y=temperature,color=temp))

########################################
# plot trip and weather data
########################################

# join trips and weather
trips_with_weather <- inner_join(trips, weather, by="ymd")

# plot the number of trips as a function of the minimum temperature, where each point represents a day
# you'll need to summarize the trips and join to the weather data to do this
trips_with_weather %>%
  group_by(ymd, tmin) %>%
  summarize(num_rides = n()) %>%
  ggplot(mapping = aes(x = tmin, y = num_rides)) +
  geom_point()

# repeat this, splitting results by whether there was substantial precipitation or not
# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this
trips_with_weather %>%
  group_by(ymd) %>%
  summarize(num_rides = n(), prcp = mean(prcp), tmin = mean(tmin)) %>%
  mutate(rainy = prcp >= mean(prcp) + 2*sd(prcp)) %>%
  ggplot(mapping = aes(x = tmin, y = num_rides, color = rainy)) + 
  geom_point()

# add a smoothed fit on top of the previous plot, using geom_smooth
trips_with_weather %>%
  group_by(ymd) %>%
  summarize(num_rides = n(), prcp = mean(prcp), tmin = mean(tmin)) %>%
  mutate(rainy = prcp >= mean(prcp) + 2*sd(prcp)) %>%
  ggplot(mapping = aes(x = tmin, y = num_rides, color = rainy)) + 
  geom_point() +
  geom_smooth()

# compute the average number of trips and standard deviation in number of trips by hour of the day
# hint: use the hour() function from the lubridate package
trips_with_weather %>%
  mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), sd = sd(count))


# plot the above
trips %>%
  mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), sd = sd(count)) %>%
  ggplot(mapping = aes(x = hour, y = avg)) +
  geom_pointrange(aes(ymin = avg - sd, ymax = avg + sd))

# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days
# hint: use the wday() function from the lubridate package
trips %>%
  mutate(wkdy = wday(starttime, label = TRUE)) %>%
  group_by(ymd, wkdy) %>%
  summarize(count = n()) %>%
  group_by(wkdy) %>%
  summarize(avg = mean(count), sd = sd(count)) %>%
  ggplot(mapping = aes(x = wkdy, y = avg)) +
  geom_pointrange(aes(ymin = avg - sd, ymax = avg + sd))
