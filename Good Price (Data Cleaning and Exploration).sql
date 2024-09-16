-- 1. Data Cleaning and Preparation

-- Display initial table content
select * 
from `gold price prediction`;

-- Rename table to use underscores and consistent naming convention
rename table
`gold price prediction` 
to gold_price_prediction;

-- Verify the table was renamed correctly
select * 
from gold_price_prediction;

-- Calculate the average of `price today`
select
    avg(`price today`) as avg_price_today
from gold_price_prediction;

-- Fix the date format issue in the column name
select `ï»¿date` 
from gold_price_prediction;

-- Convert the string date to proper date format
select `ï»¿date`,
    str_to_date(`ï»¿date`, '%m/%d/%Y')
from gold_price_prediction;

-- Update the date column to proper format
update gold_price_prediction
set `ï»¿date` = str_to_date(`ï»¿date`, '%m/%d/%Y');

-- Rename the column `ï»¿date` to `date` for consistency
alter table gold_price_prediction
rename column `ï»¿date` to `date`;

-- Modify the column `date` to date for proper date format
alter table gold_price_prediction
modify column `date` date;

-- Verify the updates
select * 
from gold_price_prediction;

-- 2. Handling Duplicates

-- Identify duplicate rows using row_number
select *,
    row_number() over(partition by date, `price today`)
from gold_price_prediction;

-- Find and display duplicate rows
with duplicate_row as (
    select *,
        row_number() over(partition by date, `price today`) as row_num
    from gold_price_prediction
)
select *, row_num
from duplicate_row
where row_num > 1;

-- 3. Exploratory Analysis

-- Basic analysis: Get price change tomorrow and price change ten over time
select
    `date`,
    `price change tomorrow`,
    `price change ten`
from
    gold_price_prediction
order by `date`;

-- Display moving averages and `price today` over time
select 
    `date`,
    `price today`,
    `twenty moving average`,
    `fifty day moving average`,
    `200 day moving average`
from
    gold_price_prediction
order by `date`;

-- Show standard deviation of price over time
select 
    `date`,
    `std dev 10`
from 
    gold_price_prediction
order by `date`;

-- Include VIX (volatility index) in the analysis
select 
    `date`,
    `price today`,
    `std dev 10`,
    `vix`
from 
    gold_price_prediction
order by 
    `date` desc;

-- 4. Price Comparisons and Moving Averages

-- Compare recent price data with moving averages
select 
    `date`,
    `price today`,
    `price tomorrow`,
    `price 1 day prior`,
    `price 2 days prior`,
    `twenty moving average`,
    `fifty day moving average`,
    `200 day moving average`
from 
    gold_price_prediction
where 
    `price tomorrow` is not null
order by 
    `date` desc
limit 10;

-- Get basic price statistics and compare against volume and DXY
select 
    avg(`price today`) as avg_price_today,
    min(`price today`) as min_price_today,
    max(`price today`) as max_price_today,
    stddev(`price today`) as stddev_price_today,
    avg(`volume`) as avg_volume,
    avg(`dxy`) as avg_dxy
from 
    gold_price_prediction;

-- Calculate averages for moving averages
select 
    avg(`twenty moving average`) as avg_20_day,
    avg(`fifty day moving average`) as avg_50_day,
    avg(`200 day moving average`) as avg_200_day
from 
    gold_price_prediction;

-- Compare price against economic indicators (inflation, effr)
select 
    avg(`price today`) as avg_price_today,
    avg(`monthly inflation rate`) as avg_inflation,
    avg(`effr rate`) as avg_effr,
    avg(`treasury par yield curve rates (10 yr)`) as avg_treasury_yield,
    avg(`dxy`) as avg_dxy
from 
    gold_price_prediction;

-- 5. Advanced Analytics and Predictive Modeling

-- Price prediction using LEAD function and calculating prediction error
select 
    `date`,
    `price tomorrow` as actual_price,
    lead(`price today`, 1) over (order by `date`) as predicted_price,
    `price tomorrow` - lead(`price today`, 1) over (order by `date`) as prediction_error
from 
    gold_price_prediction
order by 
    `date` desc;

-- Calculate daily price changes using LAG function
with daily_changes as (
    select 
        `date`,
        `price today` - lag(`price today`, 1) over (order by `date`) as daily_change
    from 
        gold_price_prediction
)
select 
    avg(daily_change) as avg_daily_change
from 
    daily_changes
where 
    daily_change is not null;

-- Predict future price based on average daily change
with daily_changes as (
    select 
        `date`,
        `price today` - lag(`price today`, 1) over (order by `date`) as daily_change
    from 
        gold_price_prediction
),
avg_change as (
    select 
        avg(daily_change) as avg_daily_change
    from 
        daily_changes
    where 
        daily_change is not null
),
latest_price as (
    select 
        `price today`
    from 
        gold_price_prediction
    order by 
        `date` desc
    limit 1
)
select 
    '2024-08-08' as predicted_date,
    latest_price.`price today` + avg_change.avg_daily_change as predicted_price
from 
    latest_price, avg_change;

-- 6. Contextual Comparisons (Inflation-adjusted prices, high/low volume)

-- Calculate inflation-adjusted average price
select 
    avg(`price today`) as avg_price_today,
    avg(`price today` / (1 + `monthly inflation rate`)) as inflation_adjusted_avg_price
from 
    gold_price_prediction;

-- Categorize volume as high or low relative to average
select 
    `date`,
    `volume`,
    `price today`,
    `price change tomorrow`,
    case 
        when volume > (select avg(`volume`) from gold_price_prediction) then 'high volume'
        else 'low volume'
    end as volume_level
from 
    gold_price_prediction
order by 
    `date` desc;

-- 7. Key Insights and Final Summary

-- Calculate minimum price per year and month
select year(`date`) as `year`, 
    min(`price today`) min_price_year
from gold_price_prediction
group by `year`
order by `year` desc;

-- Show maximum price per year
select year(`date`) as `year`, 
    max(`price today`) max_price_year
from gold_price_prediction
group by `year`
order by `year` desc;

-- Calculate rolling average and standard deviation over 30 days
select 
    `date`,
    `price today`,
    avg(`price today`) over (order by `date` rows between 29 preceding and current row) as rolling_30_avg,
    stddev(`price today`) over (order by `date` rows between 29 preceding and current row) as rolling_30_stddev
from 
    gold_price_prediction
order by 
    `date` desc;
