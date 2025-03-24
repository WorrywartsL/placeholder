-- List the five countries with the greatest improvement in the number of gold medals compared to the Tokyo Olympics. 
-- For each of these five countries, list all their all-female teams. 
-- Sort the output first by the increased number of gold medals in descending order, then by country code alphabetically, and last by team code alphabetically.
-- Details: When calculating all-female teams, if the athletes_code in a record from the teams table is not found in the athletes table, please ignore this record as if it doesn't exist.
-- Hints: You might find Lateral Joins in DuckDB useful: find out the 5 countries with largest progress first, and then use lateral join to find their all-female reams.
-- Output Format: COUNTRY_CODE|INCREASED_GOLD_MEDAL_NUMBER|TEAM_CODE

-- refer official solve below.  i can't solve it without reference. :(

with ccode as (
    select code, country_code
    from teams group by code, country_code
),
mcode as (
    select *
    from medals left join ccode on medals.winner_code = ccode.code
),
amcode as (
    select mcode.medal_code,
           case when mcode.country_code is not null then mcode.country_code 
           else athletes.country_code end as country_code
    from   mcode left join athletes on athletes.code = mcode.winner_code
),
paris_medals as (
    select amcode.country_code as country_code,count(amcode.country_code) as medal_number
    from amcode,medal_info 
    where amcode.medal_code = medal_info.code and medal_info.name = 'Gold Medal'
    group by amcode.country_code
    order by medal_number desc
)
select country as country_code, progress as increased_gold_medal_number,code as team_code 
from (
    select
        paris_medals.country_code as country,
        paris_medals.medal_number - tokyo_medals.gold_medal as progress
    from tokyo_medals,paris_medals
    where paris_medals.country_code = tokyo_medals.country_code
    order by progress desc 
    limit 5
) as countries, lateral (
    select teams.code as code 
    from teams, athletes
    where teams.athletes_code = athletes.code and teams.country_code = countries.country
    group by teams.code 
    having sum(1 - gender) = 0
    )
order by progress desc,country,code;
