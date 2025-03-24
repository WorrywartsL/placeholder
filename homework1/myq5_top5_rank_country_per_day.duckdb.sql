-- For each day, find the country with the highest number of appearances in the top 5 ranks (inclusive) of that day. 
-- For these countries, also list their population rank and GDP rank. Sort the output by date in ascending order.
-- Hints: Use the result table, and use the participant_code to get the corresponding country. 
-- If you cannot get the country information for a record in the result table, ignore that record.
-- Details: When counting appearances, only consider records from the results table where rank is not null. 
-- Exclude days where all rank values are null from the output. In case of a tie in the number of appearances, select the country that comes first alphabetically. 
-- Keep the original format of the date. Also, DON'T remove duplications from results table when counting appearances. (see Important Clarifications section).
-- Output Format: DATE|COUNTRY_CODE|TOP5_APPEARANCES|GDP_RANK|POPULATION_RANK

-- refer official solve below.

with ccode as (
    select code, country_code 
    from teams group by code, country_code
),
country_rank as (
    select code,
           rank() over (order by "GDP ($ per capita)" desc) as gdp_rank,
           rank() over(order by "Population" desc) as population_rank
    from countries
),
result_ccode as (
    select *
    from results left join ccode on results.participant_code = ccode.code
),
result_ccode_athlete as (
    select date, 
    case when result_ccode.country_code is not null then result_ccode.country_code else athletes.country_code end as country,
    count(*) as num 
    from  result_ccode left join athletes on result_ccode.participant_code = athletes.code 
    where rank <= 5
    group by date, country
),
target_table as (
    select *,row_number() over (partition by date order by num desc, country) as row_number
    from result_ccode_athlete
)
select date,
       country as country_code, 
       num as top5_appearances, 
       country_rank.gdp_rank as gdp_rank,
       country_rank.population_rank as population_rank
from target_table, country_rank
where row_number = 1 and country_rank.code = target_table.country order by date


