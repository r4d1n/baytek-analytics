DROP TABLE IF EXISTS vMachine;
DROP VIEW IF EXISTS vMachine;
CREATE VIEW vMachine AS

SELECT 
 a.*,
 SUM(IF(DATEDIFF(NOW(), b.startedAt) = 0, 1,0)) as cntPlaysToday,
 SUM(IF(DATEDIFF(NOW(), b.startedAt) < 7, 1,0)) as cntPlaysWeek,
 SUM(IF(DATEDIFF(NOW(), b.startedAt) < 30, 1,0)) as cntPlaysMonth,
 SUM(IF(DATEDIFF(NOW(), b.startedAt) < 365, 1,0)) as cntPlaysYear,
 COUNT(b.id) as cntPlaysTotal,
 SUM(IF((d.jogoId = a.id) AND (d.equipaId = a.foraId), 1, IF(a.presenca_casa = 0, 8, 0))) as golos_fora,
 a.data,
 a.titulo,
 a.local,
 a.competicaoId,
 e.nome as competicao,
 b.nome as casa, 
 c.nome as fora,
 b.id as casaId,
 c.id as foraId,
 a.concluido,
 e.ano
FROM arcades AS a
INNER JOIN play AS b ON (a.id = b.arcade)
INNER JOIN equipas AS b ON (a.casaId = b.id)
INNER JOIN equipas AS c ON (a.foraId = c.id)
LEFT JOIN goloses AS d ON (d.jogoId = a.id)
GROUP BY a.id
ORDER BY a.data ASC;

DROP TABLE IF EXISTS vclass1;
DROP VIEW IF EXISTS vclass1;
CREATE VIEW vclass1 AS

SELECT 
	a.nome as nome,
	SUM(CASE WHEN b.casaId = a.id THEN b.golos_casa ELSE b.golos_fora END) as marcados,
	SUM(CASE WHEN b.casaId = a.id THEN b.golos_fora ELSE b.golos_casa END) as sofridos,
	IF(((a.id = b.casaId OR a.id = b.foraId)), COUNT(a.nome), 0) as jogos,
	SUM(IF ((b.casaId = a.id AND b.golos_casa > b.golos_fora) OR (b.foraId = a.id AND b.golos_casa < b.golos_fora), 1, 0)) as vitorias,
	SUM(IF ((b.casaId = a.id AND b.golos_casa < b.golos_fora) OR (b.foraId = a.id AND b.golos_casa > b.golos_fora), 1, 0)) as derrotas,
	a.competicaoId as competicao
	
FROM equipas AS a
LEFT JOIN vjogoses AS b ON (a.id = b.casaId OR a.id = b.foraId)
WHERE (b.concluido = 1) GROUP BY a.id, competicao;

DROP TABLE IF EXISTS vclassificacaoes;
DROP VIEW IF EXISTS vclassificacaoes;
CREATE VIEW vclassificacaoes AS

SELECT 
	a.nome,
	a.jogos,
	a.vitorias,
	a.derrotas,
	(a.jogos-(a.vitorias+a.derrotas)) as empates,
	a.marcados,
	a.sofridos,
	(a.marcados - a.sofridos) as diffP,
	((3*a.vitorias) + (a.jogos-(a.vitorias+a.derrotas))) as pontos,
	a.competicao

FROM vclass1 AS a
ORDER BY pontos DESC, diffP DESC;

DROP TABLE IF EXISTS vmarcadores;
DROP VIEW IF EXISTS vmarcadores;
CREATE VIEW vmarcadores AS
SELECT 
	b.nome,
	COUNT(b.nome) as golos,
	c.nomeCurto as equipa,
	d.jogos as jogos,
	e.competicaoId
FROM goloses AS a
INNER JOIN jogadores AS b ON (a.jogadorId = b.id)
INNER JOIN equipas AS c ON (a.equipaId = c.id)
INNER JOIN vclass1 AS d ON (d.nome = c.nome AND d.`competicao` = c.`competicaoId`)
INNER JOIN jogoses as e ON (e.id = a.jogoId)
GROUP BY b.id
ORDER BY golos DESC;

DROP TABLE IF EXISTS vduplocartao;
DROP VIEW IF EXISTS vduplocartao;
CREATE VIEW vduplocartao AS
SELECT
	*,
	IF(a.cor = 'A', FLOOR(COUNT(a.cor)/2), 0) as amarelos2,
	IF(a.cor = 'A', COUNT(a.cor), 0) AS amarelos,
	IF(a.cor = 'V', COUNT(a.cor), 0) AS vermelhos
FROM cartoes AS a
GROUP BY jogoId, jogadorId, cor;

DROP TABLE IF EXISTS vdisciplinas;
DROP VIEW IF EXISTS vdisciplinas;
CREATE VIEW vdisciplinas AS
SELECT 
	b.nome,
	SUM(a.amarelos-(2*a.amarelos2)) as amarelo,
	SUM(a.amarelos2) as amarelo2,
	SUM(a.vermelhos) as vermelho,
	c.nomeCurto as equipa,
	e.competicaoId
FROM vduplocartao AS a
INNER JOIN jogadores AS b ON (a.jogadorId = b.id)
INNER JOIN equipas AS c ON (b.equipaId = c.id)
INNER JOIN jogoses as e ON (e.id = a.jogoId)
GROUP BY b.id, e.competicaoId
ORDER BY b.nome ASC;

DROP TABLE IF EXISTS vgoloses;
DROP VIEW IF EXISTS vgoloses;
CREATE VIEW vgoloses AS
SELECT 
	a.*,
	b.nome AS jogador,
	c.nome AS equipa
FROM goloses AS a
LEFT JOIN jogadores AS b ON (a.jogadorId = b.id)
INNER JOIN equipas AS c ON (a.equipaId = c.id);
	
DROP TABLE IF EXISTS vcartoes;
DROP VIEW IF EXISTS vcartoes;
CREATE VIEW vcartoes AS
SELECT 
	a.*,
	b.nome AS jogador
FROM cartoes AS a
LEFT JOIN jogadores AS b ON (a.jogadorId = b.id);

DROP VIEW IF EXISTS vjogadores;
DROP TABLE IF EXISTS vjogadores;
CREATE VIEW vjogadores AS
SELECT 
	a.id,
	a.nome,
	a.equipaId,
	b.nome AS equipa,
	b.competicaoId,
	c.nome AS competicao,
	c.ano
FROM jogadores AS a
INNER JOIN equipas AS b ON (a.equipaId = b.id)
INNER JOIN competicoes AS c ON (b.competicaoId = c.id);

DROP TABLE IF EXISTS vequipas;
DROP VIEW IF EXISTS vequipas;
CREATE VIEW vequipas AS
SELECT 
	a.id,
	a.nome,
	a.nomeCurto,
	a.numero,
	a.mail,
	a.destaque,
	b.nome AS competicao,
	b.ano
FROM equipas AS a
INNER JOIN competicoes AS b ON (a.competicaoId = b.id);

DROP TABLE IF EXISTS vestatisticas;
DROP VIEW IF EXISTS vestatisticas;
CREATE VIEW vestatisticas AS
SELECT 
	CAST(COUNT(id) as CHAR(20)) as numberTitle,
	'Users Totais' as title,
	'icon-user' as icon,
	'#ddd' as bgColor,
	'#4CC5CD' as fgColor,
	'turquoise-color' as color,
	COUNT(id) as value
FROM users UNION ALL
SELECT 
	'2' as numberTitle,
	'CPUsuy' as title,
	'icon-cogs' as icon,
	'#ddd' as bgColor,
	'#e17f90' as fgColor,
	'red-color' as color,
	40 as value
UNION ALL
SELECT 
	'0€' as numberTitle,
	'Pagamentos' as title,
	'icon-money' as icon,
	'#ddd' as bgColor,
	'#a8c77b' as fgColor,
	'green-color' as color,
	0 as value
UNION ALL
SELECT 
	'+71' as numberTitle,
	'Emails' as title,
	'icon-envelope-alt' as icon,
	'#ddd' as bgColor,
	'#b9baba' as fgColor,
	'gray-color' as color,
	1 as value;
