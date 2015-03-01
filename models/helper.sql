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