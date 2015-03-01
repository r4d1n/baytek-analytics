INSERT INTO `arcades` (`id`, `gameTitle`, `physicalId`, `ticketCapacity`, `coinCapacity`, `firmwareVer`, `createdAt`, `updatedAt`)
VALUES
	(1, 'Flappy Bird', '1234', 200, 10, '1.2.1', '0000-00-00 00:00:00', '0000-00-00 00:00:00');

INSERT INTO `players` (`id`, `name`, `device`, `createdAt`, `updatedAt`)
VALUES
	(1, 'JayDee', 'Android', '0000-00-00 00:00:00', '0000-00-00 00:00:00');

INSERT INTO `plays` (`id`, `startedAt`, `finishedAt`, `gameVersion`, `coinsIn`, `ticketsOut`, `score`, `createdAt`, `updatedAt`, `arcadeId`, `playerId`)
VALUES
	(1, '2015-03-01 00:26:30', '2015-03-01 00:26:41', '1.2.1', 1, 5, 245, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1);