-- For all venues that have hosted Athletics discipline competitions, 
-- list all athletes who have competed at these venues, 
-- and sort them by the distance from their nationality country to the country they represented in descending order, 
-- then by name alphabetically.
-- Details: The athletes can have any discipline and can compete as a team member or an individual in these venues. 
-- The distance between two countries is calculated as the sum square of the difference between their latitudes and longitudes. 
-- Only output athletes who have valid information. 
-- (i.e., the athletes appear in the athletes table and have non-null latitudes and longitudes for both countries.) 
-- Assume that if a team participates in a competition, all team members are competing.
-- Output Format: ATHLETE_NAME|REPRESENTED_COUNTRY_CODE|NATIONALITY_COUNTRY_CODE

with person_code as (
    select participant_code
    from results left join venues on results.venue = venues.venue
    where venues.disciplines like '%Athletics%' and participant_type = 'Person'
),
team_code as (
    select athletes_code as participant_code 
    from teams
    where code in (
        select participant_code
        from results left join venues on results.venue = venues.venue
        where venues.disciplines like '%Athletics%' and participant_type = 'Team'
    )
    
),
athletes_info1 as (
    select * 
    from athletes
    where code in (
        select distinct participant_code
        from (select * from person_code) union (select * from team_code)
    )
),
athletes_info2 as (
    select athletes_info1.*,countries.Latitude as country_latitude, countries.Longitude as country_longitude
    from athletes_info1 left join countries on athletes_info1.country_code = countries.code
),
athletes_info3 as (
    select athletes_info2.*,countries.Latitude as nationality_latitude,countries.Longitude as nationality_longitude
    from athletes_info2 left join countries on athletes_info2.nationality_code = countries.code
    where nationality_latitude is not null 
        and nationality_longitude is not null
        and country_latitude is not null
        and country_longitude is not null
)
select name as athlete_name,country_code as represented_country_code,nationality_code as nationality_country_code
from athletes_info3
order by (country_latitude - nationality_latitude)^2 + (country_longitude - nationality_longitude)^2 desc,athlete_name;


