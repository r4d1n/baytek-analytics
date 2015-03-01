<<<<<<< Updated upstream
-- INSERIR NOVAS EQUIPAS TOP 5 da Masters em Masters A (id: 41)
SELECT 
	b.img,
	b.nome,
	b.nomeCurto,
	b.numero,
	b.mail,
	b.website,
	0 AS destaque,
	41 AS competicaoId
FROM vclassificacaoes AS a
INNER JOIN equipas AS b ON (a.nome = b.nome)
WHERE a.competicao = 1 AND b.competicaoId = 1
LIMIT 5;

-- INSERIR NOVAS EQUIPAS NOT TOP5 da Masters em Masters B (id: 51)
SELECT 
	b.img,
	b.nome,
	b.nomeCurto,
	b.numero,
	b.mail,
	b.website,
	0 AS destaque,
	51 AS competicaoId
FROM vclassificacaoes AS a
INNER JOIN equipas AS b ON (a.nome = b.nome)
WHERE a.competicao = 1 AND b.competicaoId = 1
LIMIT 5, 10;

-- IDs das equipas da competicao Masters A (id: 41) vs Masters (id: 1)
DROP VIEW IF EXISTS aux;
CREATE VIEW aux AS 
SELECT 
	a.id AS novo,
	b.id AS velho
FROM equipas AS a
INNER JOIN equipas AS b ON (a.nome = b.nome)
WHERE a.`competicaoId` = 41 AND b.competicaoId = 1;

-- Novos Jogadores da competicao Masters A (id:41) --> AUX
SELECT a.nome,
	b.novo AS equipaId
FROM jogadores AS a
INNER JOIN aux AS b ON (a.equipaId = b.`velho`);

-- IDs das equipas da competicao Masters B (id: 51) vs Masters (id: 1)
DROP VIEW IF EXISTS aux;
CREATE VIEW aux AS
SELECT 
	a.id AS novo,
	b.id AS velho
FROM equipas AS a
INNER JOIN equipas AS b ON (a.nome = b.nome)
WHERE a.`competicaoId` = 51 AND b.competicaoId = 1;

-- Novos Jogadores da competicao Masters B (id:51) --> AUX
SELECT a.nome,
	b.novo AS equipaId
FROM jogadores AS a
INNER JOIN aux AS b ON (a.equipaId = b.`velho`);

-- Jogos para a competicao Masters A (id: 41) copiados da Masters só com competicoes das equipas TOP 5 --> aux
SELECT 
	a.data,
	a.titulo,
	a.local,
	a.concluido,
	41 as competicaoId,
	c.novo AS casaId,
	d.novo AS foraId
FROM jogoses AS a
INNER JOIN aux AS c ON (c.velho = a.casaId)
INNER JOIN aux AS d ON (d.velho = a.foraId)
WHERE a.`competicaoId` = 1;

-- Jogos para a competicao Masters B (id: 51) copiados da Masters só com competicoes das equipas TOP 5 --> aux
SELECT 
	a.data,
	a.titulo,
	a.local,
	a.concluido,
	51 as competicaoId,
	c.novo AS casaId,
	d.novo AS foraId
FROM jogoses AS a
INNER JOIN aux AS c ON (c.velho = a.casaId)
INNER JOIN aux AS d ON (d.velho = a.foraId)
WHERE a.`competicaoId` = 1;

-- IDs dos jogos da competicao Masters A (id: 41) vs as do Masters (id: 1)
DROP VIEW if EXISTS aux1;
CREATE VIEW aux1 AS
SELECT 
	a.id AS velho,
	b.id AS novo
FROM jogoses AS a
INNER JOIN aux AS c ON (a.casaId = c.velho)
INNER JOIN aux AS d ON (a.foraId = d.velho)
INNER JOIN jogoses AS b ON (a.data = b.data AND a.local = b.local AND c.novo = b.casaId AND d.novo = b.foraId)
WHERE a.`competicaoId` = 1 AND b.competicaoId = 41;

-- IDs dos jogadores das equipas da Masters A (id: 41) vs as do Masters (id: 1)
DROP VIEW IF EXISTS aux2;
CREATE VIEW aux2 AS
SELECT 
	a.id AS velho,
	c.id AS novo
FROM jogadores AS a
INNER JOIN aux AS b ON (a.`equipaId` = b.velho)
INNER JOIN jogadores AS c ON (b.novo = c.`equipaId` AND a.nome = c.nome);

-- Golos para a Competicao MASTERS A (id: 41)
SELECT 
	a.data,
	d.novo AS jogadorId,
	c.novo AS jogoId,
	b.novo AS `equipaId`
FROM goloses AS a
INNER JOIN aux AS b ON (b.velho = a.`equipaId`)
INNER JOIN aux1 AS c ON (c.velho = a.jogoId)
LEFT JOIN aux2 AS d ON (d.velho = a.jogadorId);

=======
DROP TABLE IF EXISTS vTicketsLeft;
DROP VIEW IF EXISTS vTicketsLeft;
CREATE VIEW vTicketsGiven AS
    SUM(p.ticketsOut) as numTicketsGiven
    FROM arcades AS a
    INNER JOIN plays AS p ON (a.id = p.arcadeId)
    INNER JOIN maintenances AS m ON ((a.id = m.arcadeId) AND (m.action = 'Tickets'))
    WHERE TIMEDIFF(p.startedAt, m.date)>0
    ORDER BY p.startedAt ASC;

DROP TABLE IF EXISTS vAllArcades;
DROP VIEW IF EXISTS vAllArcades;
SET @numRunning = (SELECT SUM(TIME_TO_SEC(TIMEDIFF(NOW(), a.updatedAt)) < 10*60) FROM arcades AS a);
SET @numTicketsLow = (SELECT p.ticketsOut FROM plays as p WHERE ((a.id = p.arcadeId) AND (TIMEDIFF(startedAt, (SELECT date FROM maintenances WHERE a.id = maintenances.arcadeId))>0)));
CREATE VIEW vAllArcades AS SELECT
    a.*,
    (TIME_TO_SEC(TIMEDIFF(NOW(), a.updatedAt)) < 10*60) as isRunning,
    t.numTicketsGiven,
    t.numTicketsRemaining,
    #
    SUM(IF(DATEDIFF(NOW(), p.startedAt) = 0, 1,0)) as cntPlaysToday,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 7, 1,0)) as cntPlaysWeek,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 30, 1,0)) as cntPlaysMonth,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 365, 1,0)) as cntPlaysYear,
    COUNT(p.id) as cntPlaysTotal,
    #
    SUM(IF(DATEDIFF(NOW(), p.startedAt) = 0, p.coinsIn,0)) as cntCoinsInToday,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 7, p.coinsIn,0)) as cntCoinsInWeek,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 30, p.coinsIn,0)) as cntCoinsInMonth,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 365, p.coinsIn,0)) as cntCoinsInYear,
    SUM(p.coinsIn) as cntCoinsInTotal,
    #
    SUM(IF(DATEDIFF(NOW(), p.startedAt) = 0, p.ticketsOut,0)) as cntTicketsOutToday,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 7, p.ticketsOut,0)) as cntTicketsOutWeek,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 30, p.ticketsOut,0)) as cntTicketsOutMonth,
    SUM(IF(DATEDIFF(NOW(), p.startedAt) < 365, p.ticketsOut,0)) as cntTicketsOutYear,
    SUM(p.ticketsOut) as cntTicketsOutTotal,
    #
    (SELECT score FROM plays WHERE (a.id = p.arcadeId) ORDER BY startedAt DESC LIMIT 1) as latestScore,
    MAX(IF(DATEDIFF(NOW(), p.startedAt) = 0, p.score,0)) as highestScoreToday,
    MAX(IF(DATEDIFF(NOW(), p.startedAt) < 7, p.score,0)) as highestScoreWeek,
    MAX(IF(DATEDIFF(NOW(), p.startedAt) < 30, p.score,0)) as highestScoreMonth,
    MAX(IF(DATEDIFF(NOW(), p.startedAt) < 365, p.score,0)) as highestScoreYear,
    MAX(p.score) as highestScoreTotal,
    #
    100*SUM(IF(DATEDIFF(NOW(), p.startedAt) = 0, TIME_TO_SEC(TIMEDIFF(p.finishedAt,p.startedAt)),0))/(SELECT TIME_TO_SEC(TIMEDIFF(closeAt,openAt)) FROM openhours WHERE id=DAYOFWEEK(NOW())) as timeUsedToday,
    100*SUM(IF(DATEDIFF(NOW(), p.startedAt) < 7, TIME_TO_SEC(TIMEDIFF(p.finishedAt,p.startedAt)),0))/(SELECT SUM(TIME_TO_SEC(TIMEDIFF(closeAt,openAt))) FROM openhours) as timeUsedWeek,
    100*SUM(IF(DATEDIFF(NOW(), p.startedAt) < 30, TIME_TO_SEC(TIMEDIFF(p.finishedAt,p.startedAt)),0))/(4*(SELECT SUM(TIME_TO_SEC(TIMEDIFF(closeAt,openAt))) FROM openhours)) as timeUsedMonth,
    100*SUM(IF(DATEDIFF(NOW(), p.startedAt) < 365, TIME_TO_SEC(TIMEDIFF(p.finishedAt,p.startedAt)),0))/(52*(SELECT SUM(TIME_TO_SEC(TIMEDIFF(closeAt,openAt))) FROM openhours)) as timeUsedYear
    #
    FROM arcades AS a
    INNER JOIN plays AS p ON (a.id = p.arcadeId)
    INNER JOIN (SELECT
        a.id as id,
        SUM(p.ticketsOut) as numTicketsGiven,
        a.ticketCapacity - SUM(p.ticketsOut) as numTicketsRemaining
        #
        FROM arcades AS a
        INNER JOIN plays AS p ON (a.id = p.arcadeId)
        INNER JOIN maintenances AS m ON ((a.id = m.arcadeId) AND (m.action = 'Tickets') AND (m.date = (SELECT MAX(m.date) FROM maintenances as m)))
        WHERE TIMEDIFF(p.startedAt, m.date)>0
        ORDER BY p.startedAt ASC
    ) AS t ON (a.id = t.id)
    ORDER BY p.startedAt ASC;
>>>>>>> Stashed changes
