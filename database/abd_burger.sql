-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-05-2024 a las 08:00:15
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "-06:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `abd_burger`
--
DROP DATABASE IF EXISTS `abd_burger`;
CREATE DATABASE IF NOT EXISTS `abd_burger` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `abd_burger`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_cat_burger`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cat_burger` (`p_id` INT, `p_name` VARCHAR(20), `p_desc` VARCHAR(150), `p_price` FLOAT, `p_id_user` INT)   BEGIN
	DECLARE v_operation VARCHAR(20);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
		GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
		SELECT CONCAT(@p1, ':', @p2) error, 'FAILURE' status, v_operation 'operation';
	END;

	START TRANSACTION;

	IF p_id > 0 THEN
		UPDATE cat_burger SET 
			name = upper(p_name),
            description = upper(p_desc),
            price = p_price
		WHERE
			id = p_id;
        
        UPDATE log_cat_burger
        SET id_app_user = p_id_user
        WHERE id = (SELECT max(id) FROM log_cat_burger WHERE id_cat_burger = p_id);
        
		SET v_operation = 'UPDATE';
	ELSE
		INSERT INTO cat_burger (name, description, price)
        VALUES (upper(p_name), upper(p_desc), p_price);
    
		SELECT last_insert_id() INTO p_id;
        
        UPDATE log_cat_burger
        SET id_app_user = p_id_user
        WHERE id = (SELECT max(id) FROM log_cat_burger WHERE id_cat_burger = p_id);
        
		SET v_operation = 'INSERT';
    END IF;
    
	COMMIT;
    
    SELECT p_id id, 'SUCCESS' status, v_operation operation;
END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `f_count_ingredients`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_count_ingredients` (`p_id_cat_burger` INT) RETURNS INT(11)  BEGIN
	DECLARE v_count_ingredients INT;
    
    SELECT
		count(*) INTO v_count_ingredients
	FROM
		vw_burger
	WHERE
		burger = (SELECT name FROM cat_burger WHERE id = p_id_cat_burger);
    
RETURN v_count_ingredients;
END$$

DROP FUNCTION IF EXISTS `f_get_user_pwd`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_get_user_pwd` (`p_email` VARCHAR(50), `p_user_type` INT) RETURNS VARCHAR(60) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
	DECLARE v_password VARCHAR(60);
	SELECT
		password INTO v_password
	FROM
		user
	WHERE
		email = upper(p_email)
        AND id_cat_user_type = p_user_type;
	RETURN v_password;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `burger`
--

DROP TABLE IF EXISTS `burger`;
CREATE TABLE `burger` (
  `id` int(11) NOT NULL,
  `id_burger` int(11) DEFAULT NULL,
  `id_ingredient` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `burger`
--

INSERT INTO `burger` (`id`, `id_burger`, `id_ingredient`) VALUES
(1, 1, 1),
(5, 1, 4),
(12, 1, 5),
(13, 1, 6),
(6, 1, 8),
(2, 2, 1),
(7, 2, 2),
(8, 2, 4),
(10, 2, 5),
(11, 2, 6),
(9, 2, 8),
(3, 3, 1),
(14, 3, 3),
(15, 3, 4),
(17, 3, 5),
(18, 3, 6),
(16, 3, 8),
(4, 4, 1),
(19, 4, 2),
(20, 4, 3),
(21, 4, 4),
(22, 4, 5),
(23, 4, 6),
(24, 4, 7),
(25, 4, 8);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cat_burger`
--

DROP TABLE IF EXISTS `cat_burger`;
CREATE TABLE `cat_burger` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `price` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cat_burger`
--

INSERT INTO `cat_burger` (`id`, `name`, `description`, `price`) VALUES
(1, 'QUESOBADON', 'HAMBURGUESA SENCILLA CON CARNE Y QUESO', 39.99),
(2, 'JAMONCILLA', 'HAMBURGUESA CON CARNE, JAMON Y QUESO', 49.99),
(3, 'TOCINEITOR', 'HAMBURGUESA CON CARNE, TOCINO Y QUESO', 49.99),
(4, 'SUPER', 'HAMBURGUESA CON CARNE, JAMON, TOCINO Y QUESO', 59.99),
(5, 'AGUACATOSA', 'HAMBURGUESA SUPER CON DOBLE AGUACATE', 79.79),
(7, 'CAPRICHOSA', 'HAMBURGUESA CON HUEVO, TOCINO, JAMON Y QUESO', 39.99),
(8, 'DIABLA', 'HAMBURGUESA SUPER CON JALAPEÑO', 73.73),
(9, 'DIABLILLA', 'HAMBURGUESA SUPER CON JALAPEÑO', 10.99),
(10, 'BIG CANGREBURGER', 'BURGER CON CARNE DE CANGREJO', 107.99),
(11, 'FAMOUS STAR', 'CARLS JN MAMLONA', 129.99);

--
-- Disparadores `cat_burger`
--
DROP TRIGGER IF EXISTS `cat_burger_AFTER_DELETE`;
DELIMITER $$
CREATE TRIGGER `cat_burger_AFTER_DELETE` AFTER DELETE ON `cat_burger` FOR EACH ROW BEGIN
	INSERT INTO
		log_cat_burger (id_cat_burger, name, description, price, operation, db_user, date) 
    VALUES
		(old.id, old.name, old.description, old.price, 'DELETE', user(), now());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `cat_burger_AFTER_INSERT`;
DELIMITER $$
CREATE TRIGGER `cat_burger_AFTER_INSERT` AFTER INSERT ON `cat_burger` FOR EACH ROW BEGIN
	INSERT INTO
		log_cat_burger (id_cat_burger, name, description, price, operation, db_user, date) 
    VALUES
		(new.id, new.name, new.description, new.price, 'INSERT', user(), now());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `cat_burger_AFTER_UPDATE`;
DELIMITER $$
CREATE TRIGGER `cat_burger_AFTER_UPDATE` AFTER UPDATE ON `cat_burger` FOR EACH ROW BEGIN
	INSERT INTO
		log_cat_burger (id_cat_burger, name, description, price, operation, db_user, date) 
    VALUES
		(new.id, new.name, new.description, new.price, 'UPDATE', user(), now());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cat_ingredient`
--

DROP TABLE IF EXISTS `cat_ingredient`;
CREATE TABLE `cat_ingredient` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cat_ingredient`
--

INSERT INTO `cat_ingredient` (`id`, `name`) VALUES
(7, 'AGUACATE'),
(1, 'CARNE'),
(2, 'JAMON'),
(6, 'LECHUGA'),
(4, 'PAN'),
(8, 'QUESO'),
(3, 'TOCINO'),
(5, 'TOMATE');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cat_user_type`
--

DROP TABLE IF EXISTS `cat_user_type`;
CREATE TABLE `cat_user_type` (
  `id` int(11) NOT NULL,
  `name` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cat_user_type`
--

INSERT INTO `cat_user_type` (`id`, `name`) VALUES
(1, 'MASTER'),
(2, 'ADMIN'),
(3, 'GUESS');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_cat_burger`
--

DROP TABLE IF EXISTS `log_cat_burger`;
CREATE TABLE `log_cat_burger` (
  `id` int(11) NOT NULL,
  `id_cat_burger` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `price` float NOT NULL,
  `operation` varchar(10) NOT NULL,
  `db_user` varchar(50) NOT NULL,
  `id_app_user` varchar(20) DEFAULT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `log_cat_burger`
--

INSERT INTO `log_cat_burger` (`id`, `id_cat_burger`, `name`, `description`, `price`, `operation`, `db_user`, `id_app_user`, `date`) VALUES
(1, 5, 'AGUACATOSA', 'HAMBURGUESA SUPER CON DOBLE AGUACATE', 79.49, 'INSERT', 'root@localhost', NULL, '2024-04-17 12:04:11'),
(2, 6, 'CAPRICHOSA', 'HAMBURGUESA SUPER CON AGUACATE Y HUEVO', 86.89, 'INSERT', 'root@localhost', NULL, '2024-04-17 12:15:30'),
(3, 7, 'TEST', 'HAMBURGUESA CON HUEVO, TOCINO, JAMON Y QUESO', 39.99, 'INSERT', 'root@localhost', NULL, '2024-04-17 12:17:50'),
(4, 7, 'BREAKFAST', 'HAMBURGUESA CON HUEVO, TOCINO, JAMON Y QUESO', 39.99, 'UPDATE', 'root@localhost', NULL, '2024-04-17 12:19:57'),
(5, 5, 'AGUACATOSA', 'HAMBURGUESA SUPER CON DOBLE AGUACATE', 79.79, 'UPDATE', 'root@localhost', NULL, '2024-04-17 12:19:57'),
(6, 6, 'CAPRICHOSA', 'HAMBURGUESA SUPER CON AGUACATE Y 2 HUEVOS', 89.89, 'UPDATE', 'root@localhost', NULL, '2024-04-17 12:19:57'),
(7, 6, 'CAPRICHOSA', 'HAMBURGUESA SUPER CON AGUACATE Y 2 HUEVOS', 89.89, 'DELETE', 'root@localhost', NULL, '2024-04-17 12:32:35'),
(8, 7, 'CAPRICHOSA', 'HAMBURGUESA CON HUEVO, TOCINO, JAMON Y QUESO', 39.99, 'UPDATE', 'root@localhost', NULL, '2024-04-17 12:33:05'),
(9, 8, 'DIABLE', 'HAMBURGUESA SUPER CON JALAPEÑO', 10.99, 'INSERT', 'root@localhost', NULL, '2024-04-22 19:44:16'),
(10, 9, 'DIABLILLA', 'HAMBURGUESA SUPER CON JALAPEÑO', 10.99, 'INSERT', 'root@localhost', NULL, '2024-04-22 19:44:59'),
(11, 8, 'DIABLA', 'HAMBURGUESA SUPER CON JALAPEÑO', 73.73, 'UPDATE', 'root@localhost', NULL, '2024-04-22 19:45:51'),
(12, 10, 'BIG CANGREBURGER', 'BURGER CON CARNE DE CANGREJO', 1.99, 'INSERT', 'root@localhost', NULL, '2024-04-23 14:33:43'),
(13, 10, 'BIG CANGREBURGER', 'BURGER CON CARNE DE CANGREJO', 107.99, 'UPDATE', 'root@localhost', NULL, '2024-04-23 14:35:38'),
(14, 11, 'FAMOUS STAR', 'CARLS JN MAMLONA', 129.99, 'INSERT', 'root@localhost', '2', '2024-05-11 23:52:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `order`
--

DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
  `id` int(11) NOT NULL,
  `order_date` datetime NOT NULL,
  `total` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `order`
--

INSERT INTO `order` (`id`, `order_date`, `total`) VALUES
(1, '2024-03-17 15:47:27', 99.98),
(2, '2024-03-17 15:47:27', 39.99),
(3, '2024-03-17 15:47:27', 199.96),
(4, '2024-03-17 15:47:27', 99.98),
(5, '2024-03-17 15:47:27', 79.98);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `order_detail`
--

DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
  `id` int(11) NOT NULL,
  `id_order` int(11) DEFAULT NULL,
  `id_burger` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `order_detail`
--

INSERT INTO `order_detail` (`id`, `id_order`, `id_burger`, `quantity`) VALUES
(1, 1, 1, 1),
(2, 1, 4, 1),
(3, 2, 1, 1),
(4, 3, 1, 1),
(5, 3, 2, 1),
(6, 3, 3, 1),
(7, 3, 4, 1),
(8, 4, 2, 1),
(9, 4, 3, 1),
(10, 5, 1, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `id_cat_user_type` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `id_cat_user_type`, `email`, `password`) VALUES
(1, 1, 'CESAR.SS@TEC2.COM', 'master'),
(2, 2, 'CESAR.SS@TEC2.COM', '$2y$10$XIkbibPlmh2DfJhR4ZMmKuVo8fYFQTU0tN04TQX/sTH93Cpk5Tw06'),
(3, 3, 'CESAR.SS@TEC2.COM', 'guess');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_burger`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_burger`;
CREATE TABLE `vw_burger` (
`ID` int(11)
,`Burger` varchar(20)
,`Ingredient` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_users`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_users`;
CREATE TABLE `vw_users` (
`id` int(11)
,`id_user_type` int(11)
,`user_type` varchar(10)
,`email` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_burger`
--
DROP TABLE IF EXISTS `vw_burger`;

DROP VIEW IF EXISTS `vw_burger`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_burger`  AS SELECT `b`.`id` AS `ID`, `cb`.`name` AS `Burger`, `ci`.`name` AS `Ingredient` FROM ((`burger` `b` join `cat_burger` `cb` on(`cb`.`id` = `b`.`id_burger`)) join `cat_ingredient` `ci` on(`ci`.`id` = `b`.`id_ingredient`)) ORDER BY `cb`.`id` ASC, `ci`.`id` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_users`
--
DROP TABLE IF EXISTS `vw_users`;

DROP VIEW IF EXISTS `vw_users`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_users`  AS SELECT `u`.`id` AS `id`, `cut`.`id` AS `id_user_type`, `cut`.`name` AS `user_type`, `u`.`email` AS `email` FROM (`user` `u` join `cat_user_type` `cut` on(`cut`.`id` = `u`.`id_cat_user_type`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `burger`
--
ALTER TABLE `burger`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_burger` (`id_burger`,`id_ingredient`),
  ADD KEY `id_ingredient` (`id_ingredient`);

--
-- Indices de la tabla `cat_burger`
--
ALTER TABLE `cat_burger`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_cat_burger` (`name`);

--
-- Indices de la tabla `cat_ingredient`
--
ALTER TABLE `cat_ingredient`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_cat_ingredient` (`name`);

--
-- Indices de la tabla `cat_user_type`
--
ALTER TABLE `cat_user_type`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `log_cat_burger`
--
ALTER TABLE `log_cat_burger`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `order`
--
ALTER TABLE `order`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `order_detail`
--
ALTER TABLE `order_detail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_order` (`id_order`),
  ADD KEY `id_burger` (`id_burger`);

--
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_user` (`id_cat_user_type`,`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `burger`
--
ALTER TABLE `burger`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `cat_burger`
--
ALTER TABLE `cat_burger`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `cat_ingredient`
--
ALTER TABLE `cat_ingredient`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `cat_user_type`
--
ALTER TABLE `cat_user_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `log_cat_burger`
--
ALTER TABLE `log_cat_burger`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `order`
--
ALTER TABLE `order`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `order_detail`
--
ALTER TABLE `order_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `burger`
--
ALTER TABLE `burger`
  ADD CONSTRAINT `burger_ibfk_1` FOREIGN KEY (`id_burger`) REFERENCES `cat_burger` (`id`),
  ADD CONSTRAINT `burger_ibfk_2` FOREIGN KEY (`id_ingredient`) REFERENCES `cat_ingredient` (`id`);

--
-- Filtros para la tabla `order_detail`
--
ALTER TABLE `order_detail`
  ADD CONSTRAINT `order_detail_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `order` (`id`),
  ADD CONSTRAINT `order_detail_ibfk_2` FOREIGN KEY (`id_burger`) REFERENCES `burger` (`id`);

--
-- Filtros para la tabla `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`id_cat_user_type`) REFERENCES `cat_user_type` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
