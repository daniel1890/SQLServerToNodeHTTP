-- CREATE Match, Team, Player tables
CREATE TABLE [Match](
	team_1	VARCHAR(255)	NOT NULL,
	team_2	VARCHAR(255)	NOT NULL,
	[date]	DATE			NOT NULL,
	score	VARCHAR(255)	NOT NULL,

	PRIMARY KEY(team_1, team_2, [date])
)

CREATE TABLE Team(
	name	VARCHAR(255)	NOT NULL

	PRIMARY KEY(name)
)

CREATE TABLE Player(
	first_name	VARCHAR(255)	NOT NULL,
	last_name	VARCHAR(255)	NOT NULL,
	birthdate	DATE			NOT NULL,
	team		VARCHAR(255)	NOT NULL

	PRIMARY KEY(first_name, last_name, birthdate)
)

-- ADD FOREIGN KEYS
ALTER TABLE [Match] ADD FOREIGN KEY (team_1) REFERENCES Team([name]);
ALTER TABLE [Match] ADD FOREIGN KEY (team_2) REFERENCES Team([name]);
ALTER TABLE Player ADD FOREIGN KEY (team) REFERENCES Team([name]);

-- INSERT TESTDATA
INSERT INTO Team (name)
VALUES
	('FC Barcelona'),
	('Beuningse Boys')

INSERT INTO Player (first_name, last_name, birthdate, team)
VALUES
    ('John', 'Doe', '1990-01-01', 'FC Barcelona'),
    ('Jane', 'Doe', '1992-02-02', 'FC Barcelona'),
    ('Bob', 'Smith', '1995-03-03', 'FC Barcelona'),
    ('Sarah', 'Johnson', '1997-04-04', 'FC Barcelona'),
    ('Mike', 'Miller', '1993-05-05', 'FC Barcelona'),
    ('Emily', 'Davis', '1991-06-06', 'FC Barcelona'),
    ('Tom', 'Wilson', '1994-07-07', 'FC Barcelona'),
    ('Amy', 'Clark', '1996-08-08', 'FC Barcelona'),
    ('David', 'Brown', '1998-09-09', 'FC Barcelona'),
    ('Lisa', 'Taylor', '1999-10-10', 'Beuningse Boys'),
    ('Chris', 'Anderson', '1991-11-11', 'Beuningse Boys'),
    ('Katie', 'Thomas', '1992-12-12', 'Beuningse Boys'),
    ('Steve', 'Lee', '1993-01-13', 'Beuningse Boys'),
    ('Amanda', 'Garcia', '1995-02-14', 'Beuningse Boys'),
    ('Alex', 'Jackson', '1996-03-15', 'Beuningse Boys'),
    ('Catherine', 'Harris', '1998-04-16', 'Beuningse Boys'),
    ('Eric', 'Martin', '1999-05-17', 'Beuningse Boys'),
    ('Jessica', 'White', '1997-06-18', 'Beuningse Boys'),
    ('Peter', 'Anderson', '1995-07-19', 'Beuningse Boys'),
    ('Rachel', 'Hall', '1994-08-20', 'FC Barcelona'),
    ('Ryan', 'Wright', '1996-09-21', 'FC Barcelona'),
    ('Julie', 'Green', '1998-10-22', 'FC Barcelona');

DELETE FROM Match
INSERT INTO [Match] (team_1, team_2, [date], score)
VALUES
    ('Beuningse Boys', 'FC Barcelona', '2001-01-01', '6-40'),
	('Beuningse Boys', 'FC Barcelona', '2019-01-01', '6-40'),
	('Beuningse Boys', 'FC Barcelona', '2017-01-01', '6-40'),
	('Beuningse Boys', 'FC Barcelona', '2010-01-01', '6-40')

-- CREATE VIEW TO SEE FULL NAMES OF PLAYERS
CREATE OR ALTER VIEW VW_TFullNamePlayers AS(
SELECT P.first_name + ' ' + P.last_name AS full_name
FROM Player P
)

-- CREATE VIEW TO SEE ALL PLAYERS WHO ARE PART OF A TEAM
CREATE OR ALTER VIEW VW_TeamWithPlayernames AS(
SELECT T.name, STRING_AGG( FN.full_name, ',') WITHIN GROUP (ORDER BY T.name ASC) AS names_players_team
FROM Team T
	INNER JOIN Player P ON P.team = T.name
	INNER JOIN VW_TFullNamePlayers FN ON FN.full_name LIKE P.first_name + ' ' + P.last_name
GROUP BY name
)

-- TRIGGER FOR GENERATING JSON AND SENDING AS HTTP REQUEST TO local node API
CREATE OR ALTER TRIGGER tr_SendMatchToMongoDB
ON Match
AFTER INSERT
AS
BEGIN
	DECLARE @URL NVARCHAR(MAX) = 'http://localhost:3000/match/';
	DECLARE @Object AS INT;
	DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @team_1 VARCHAR(255), @team_2 VARCHAR(255), @date DATE, @score VARCHAR(255), @names_players_team_1 VARCHAR(255), @names_players_team_2 VARCHAR(255)
	
	SELECT @team_1 = inserted.team_1, @team_2 = inserted.team_2, @date = inserted.date, @score = inserted.score
	FROM inserted
	
	SELECT @names_players_team_1 = names_players_team FROM VW_TeamWithPlayernames T1 WHERE T1.name = @team_1
	SELECT @names_players_team_2 = names_players_team FROM VW_TeamWithPlayernames T2 WHERE T2.name = @team_2
	
	DECLARE @Body AS VARCHAR(8000) =
	(
	SELECT team_1, team_2, [date], score, JSON_ARRAY(@names_players_team_1) AS names_players_team_1, JSON_ARRAY(@names_players_team_2) AS names_players_team_2
	FROM inserted
	FOR JSON PATH
	);
	EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
	EXEC sp_OAMethod @Object, 'open', NULL, 'post',
	                 @URL,
	                 'false'
	EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
	EXEC sp_OAMethod @Object, 'send', null, @body
	EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT

	EXEC sp_OADestroy @Object
END