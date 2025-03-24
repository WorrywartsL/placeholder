-- Find all athletes in Judo discipline, and also list the number of medals they have won. 
-- Sort output in descending order by medal number first, then by name alphabetically.

-- Details: The medals counted do not have to be from the Judo discipline, 
-- and also be sure to include any medals won as part of a team. 
-- If an athlete doesn't appear in the athletes table, please ignore him/her. 
-- Assume that if a team participates in a competition, all team members are competing.
-- Output Format: ATHLETE_NAME|MEDAL_NUMBER

with person_medals as (
    select athletes.code as athletes_code, count(*) as num
    from athletes,medals
    where medals.winner_code = athletes_code
    group by athletes.code
),
team_medals as (
    select athletes_code,count(*) as num
    from medals, teams 
    where medals.winner_code = teams.code 
    group by athletes_code
),
athletes_teams as (
    select *
    from (athletes left join team_medals on athletes.code = team_medals.athletes_code)
),
target_table as (
    select code, name,
    case when athletes_teams.num is not null then athletes_teams.num else 0  end as team_num,
    case when person_medals.num is not null then person_medals.num else 0 end as person_num
    from athletes_teams left join person_medals on athletes_teams.code = person_medals.athletes_code
    where athletes_teams.disciplines like '%Judo%'
)
select name as athlete_name,team_num + person_num as medals_number
from target_table
order by medals_number desc, athlete_name;
