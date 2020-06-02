#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations
cut -d, -f4 201402-citibike-tripdata.csv | sort | head -n -1 | uniq -c | wc -l # for unique starting = 329
cut -d, -f8 201402-citibike-tripdata.csv | sort | head -n -1 | uniq -c | sort -k1 | wc -l # for unique ending = 329
cut -d, -f4,8 201402-citibike-tripdata.csv | sort | head -n -1 | uniq -c | sort -k1 | wc -l # for unique pairs = 43000

# count the number of unique bikes
cut -d, -f12 201402-citibike-tripdata.csv | sort | head -n -1 | uniq -c | wc -l # for unique bikes = 5700 - header = 5699

# count the number of trips per day
cut -d, -f2 201402-citibike-tripdata.csv | cut -d' ' -f 1 | sort | grep [0-9] | uniq -c # prints a list

# find the day with the most rides -> 13816 "2014-02-02
cut -d, -f2 201402-citibike-tripdata.csv | cut -d' ' -f 1 | sort | grep [0-9] | uniq -c | sort -nr | head -n1

# find the day with the fewest rides -> 876 "2014-02-13
cut -d, -f2 201402-citibike-tripdata.csv | cut -d' ' -f 1 | sort | grep [0-9] | uniq -c | sort -n | head -n1

# find the id of the bike with the most rides -> 130 "20837"
cut -d, -f12 201402-citibike-tripdata.csv | cut -d' ' -f 1 | sort | grep [0-9] | uniq -c | sort -nr | head -n1
    
# count the number of rides by gender and birth year
cut -d, -f14,15 201402-citibike-tripdata.csv | grep [0-9] | sort | uniq -c # prints a list sorted by year and second sorted by gender

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)
cut -d, -f5 201402-citibike-tripdata.csv | grep '.*[0-9].*&.* [0-9].*' | sort | wc -l # Answer 90549

# compute the average trip duration -> 874.52 s or 14.58 min
cut -d, -f1 201402-citibike-tripdata.csv | tail -n +2 | tr -d '"' | awk -F, '{sum += $1; count++} END {print sum/count}'