INSERT INTO `openhours` (`id`, `openAt`, `closeAt`)
VALUES
	(1, '0:00', '0:00'),
	(2, '10:00', '19:00'),
	(3, '10:00', '19:00'),
	(4, '10:00', '19:00'),
	(5, '10:00', '19:00'),
	(6, '10:00', '22:00'),
	(7, '9:30', '9:33');
#
INSERT INTO `arcades` (`id`, `gameTitle`, `physicalId`, `ticketCapacity`, `coinCapacity`, `firmwareVer`, `createdAt`, `updatedAt`)
VALUES
	(1, 'Flappy Bird', '1234', 200, 10, '1.2.1', '0000-00-00 00:00:00', '0000-00-00 00:00:00');
#
INSERT INTO `players` (`id`, `name`, `device`, `createdAt`, `updatedAt`)
VALUES
	(1, 'JayDee', 'Android', '0000-00-00 00:00:00', '0000-00-00 00:00:00');
#
INSERT INTO `plays` (`id`, `startedAt`, `finishedAt`, `gameVersion`, `coinsIn`, `ticketsOut`, `score`, `createdAt`, `updatedAt`, `arcadeId`, `playerId`)
VALUES
<<<<<<< Updated upstream
	(1, '2015-03-01 00:26:30', '2015-03-01 00:26:41', '1.2.1', 1, 5, 245, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1);
=======
	(1, '2015-03-01 00:26:30', '2015-03-01 00:26:41', '1.2.1', 1, 5, 245, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1),
	(2, '2015-03-01 00:31:20', '2015-03-01 00:32:00', '1.2.1', 1, 5, 300, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, 1);
>>>>>>> Stashed changes
