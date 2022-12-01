-- create opponent winrate MV
CREATE MATERIALIZED VIEW win_rates AS
WITH games_played_per_season_home as
(
	SELECT count(*) as hgames, "HomeTeamId" as team_id, season from game
	where season_type='Regular Season'
	group by "HomeTeamId", season
),
games_played_per_season_away as
(
	SELECT count(*) as agames, "AwayTeamId" as team_id, season from game
	where season_type='Regular Season'
	group by "AwayTeamId", season
),
games_won_per_season as
(
	SELECT count(*) as wgames, "winner_id" as team_id, season from game
	where season_type='Regular Season'
	group by "winner_id", season
)
SELECT w.wgames as won, w.wgames::float/(h.hgames+a.agames) as win_rate, h.team_id, h.season 
FROM  games_played_per_season_home h, games_played_per_season_away a, games_won_per_season w
where h.team_id=a.team_id and a.team_id=w.team_id and h.season=a.season and a.season=w.season

-- Get player game stats
CREATE MATERIALIZED VIEW curry_over_the_years AS 
with GSW_games_11_to_21 as (
	select g.* from game g, teams t where "HomeTeamId"=t.team_id AND t.team_name='GSW' AND season > '2010-11' and season_type='Regular Season'
	UNION ALL 
	select g.* from game g, teams t where "AwayTeamId"=t.team_id AND t.team_name='GSW' AND season > '2010-11' and season_type='Regular Season'
)
SELECT gg.*, "Name", "Minutes", "Rebounds", "Turnovers", "Points", "FtPoints", "Fouls", "FG2A", "Fg2Pct", "FG3A","Fg3Pct", "Assists", 
CASE WHEN gg.winner_id='1610612744' THEN 1 ELSE 0 END as outcome,
CASE WHEN gg."HomeTeamId" ='1610612744' THEN 1 else 0 END as is_home
FROM GSW_games_11_to_21 gg left join player_game_stats pgs on gg."GameId"=pgs."game_id"
AND "Name"='Stephen Curry' and type='FullGame'

-- join with opponent win rate 
CREATE materialized view curry_over_the_years_w_oppo as
SELECT coty.*, w.win_rate as opponent_rate 
from curry_over_the_years coty, win_rates w 
where coty."HomeTeamId" = w.team_id and coty.season=w.season 
and coty."AwayTeamId" = '1610612744'
UNION ALL 
SELECT coty.*, w.win_rate as opponent_rate 
from curry_over_the_years coty, win_rates w 
where coty."AwayTeamId" = w.team_id and coty.season=w.season 
and coty."HomeTeamId" = '1610612744'


CREATE MATERIALIZED VIEW thompson_over_the_years AS 
with GSW_games_11_to_21 as (
	select g.* from game g, teams t where "HomeTeamId"=t.team_id AND t.team_name='GSW' AND season > '2010-11' and season_type='Regular Season'
	UNION ALL 
	select g.* from game g, teams t where "AwayTeamId"=t.team_id AND t.team_name='GSW' AND season > '2010-11' and season_type='Regular Season'
)
SELECT gg.*, "Name", "Minutes", "Rebounds", "Turnovers", "Points", "FtPoints", "Fouls", "FG2A", "Fg2Pct", "FG3A","Fg3Pct", "Assists", 
CASE WHEN gg.winner_id='1610612744' THEN 1 ELSE 0 END as outcome,
CASE WHEN gg."HomeTeamId" ='1610612744' THEN 1 else 0 END as is_home
FROM GSW_games_11_to_21 gg left join player_game_stats pgs on gg."GameId"=pgs."game_id"
AND "Name"='Klay Thompson' and type='FullGame';

-- join with opponent win rate 
CREATE materialized view thompson_over_the_years_w_oppo as
SELECT coty.*, w.win_rate as opponent_rate 
from thompson_over_the_years coty, win_rates w 
where coty."HomeTeamId" = w.team_id and coty.season=w.season 
and coty."AwayTeamId" = '1610612744'
UNION ALL 
SELECT coty.*, w.win_rate as opponent_rate 
from thompson_over_the_years coty, win_rates w 
where coty."AwayTeamId" = w.team_id and coty.season=w.season 
and coty."HomeTeamId" = '1610612744';