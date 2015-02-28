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

