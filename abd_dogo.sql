-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 29-04-2024 a las 02:52:50
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `abd_dogo`
--
-- DROP DATABASE IF EXISTS abd_dogo;
CREATE DATABASE IF NOT EXISTS `abd_dogo` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `abd_dogo`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_order_operation`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_order_operation` (`p_id_order` INT, `p_id_order_detail` INT, `p_id_dogo` INT, `p_quantity` INT)   BEGIN
DECLARE v_operation VARCHAR(20);

IF p_id_order > 0 THEN
	SET v_operation = 'UPDATE ORDER';
	IF p_id_order_detail > 0 THEN
		UPDATE order_detail SET
			id_dogo = p_id_dogo,
            quantity = p_quantity
		WHERE
			id = p_id_order_detail;
	ELSE
		INSERT INTO order_detail (id_order, id_dogo, quantity)
        VALUES (p_id_order, p_id_dogo, p_quantity);
	END IF;
	
    UPDATE abd_dogo.order SET
		total = f_order_total(p_id_order)
	WHERE
		id = p_id_order;
ELSE
	SET v_operation = 'NEW ORDER';
    
	INSERT INTO abd_dogo.order (order_date, total)
	VALUES (now(), (SELECT price * p_quantity FROM cat_dogo WHERE id = p_id_dogo));
    
    SET p_id_order = last_insert_id();
    INSERT INTO order_detail (id_order, id_dogo, quantity)
	VALUES (p_id_order, p_id_dogo, p_quantity);
END IF;

SELECT p_id_order 'order id', v_operation 'order type';
END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `f_get_dogo`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_get_dogo` (`p_id` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
RETURN (SELECT
			name
		FROM
			cat_dogo
		WHERE
			id = p_id);
END$$

DROP FUNCTION IF EXISTS `f_order_total`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_order_total` (`p_id_order` INT) RETURNS FLOAT  BEGIN
DECLARE v_total FLOAT;

SELECT
	sum(cd.price * od.quantity) INTO v_total
FROM cat_dogo cd
	JOIN order_detail od ON od.id_dogo = cd.id
WHERE
	od.id_order = p_id_order;

RETURN v_total;
END$$

DROP FUNCTION IF EXISTS `get_dogo_name`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_dogo_name` (`p_id` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
RETURN (SELECT
			name
		FROM
			cat_dogo
		WHERE
			id = p_id);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cat_dogo`
--

DROP TABLE IF EXISTS `cat_dogo`;
CREATE TABLE `cat_dogo` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `price` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cat_dogo`
--

INSERT INTO `cat_dogo` (`id`, `name`, `description`, `price`) VALUES
(1, 'CLASICO', 'DOGO SENCILLO CON WINI', 39.99),
(2, 'SALCHICHON', 'DOGO CON SALCHICHA PARA ASAR Y QUESO', 49.99),
(3, 'TOCINEITOR', 'DOGO CON WINI, TOCINO Y QUESO', 49.99),
(4, 'SUPER', 'DOGO CON SALCHICHA PARA ASAR, WINI, TOCINO Y QUESO', 59.99);

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
(6, 'ADEREZO'),
(7, 'AGUACATE'),
(4, 'PAN'),
(8, 'QUESO'),
(2, 'SALCHICHA PARA ASAR'),
(3, 'TOCINO'),
(5, 'TOMATE'),
(1, 'WINI');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dogo`
--

DROP TABLE IF EXISTS `dogo`;
CREATE TABLE `dogo` (
  `id` int(11) NOT NULL,
  `id_dogo` int(11) DEFAULT NULL,
  `id_ingredient` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dogo`
--

INSERT INTO `dogo` (`id`, `id_dogo`, `id_ingredient`) VALUES
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
-- Estructura de tabla para la tabla `log_order`
--

DROP TABLE IF EXISTS `log_order`;
CREATE TABLE `log_order` (
  `id` int(11) NOT NULL,
  `id_order` int(11) NOT NULL,
  `order_date` datetime NOT NULL,
  `total` float NOT NULL,
  `operation` varchar(10) NOT NULL,
  `db_user` varchar(30) NOT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `log_order`
--

INSERT INTO `log_order` (`id`, `id_order`, `order_date`, `total`, `operation`, `db_user`, `date`) VALUES
(1, 6, '2024-04-29 00:37:32', 419.93, 'INSERT', 'root@localhost', '2024-04-29 00:37:32'),
(2, 7, '2024-04-29 00:39:47', 249.95, 'INSERT', 'root@localhost', '2024-04-29 00:39:47'),
(3, 6, '2024-04-29 00:37:32', 239.96, 'UPDATE', 'root@localhost', '2024-04-29 00:43:37'),
(4, 6, '2024-04-29 00:37:32', 339.94, 'UPDATE', 'root@localhost', '2024-04-29 00:44:48'),
(5, 7, '2024-04-29 00:39:47', 669.88, 'UPDATE', 'root@localhost', '2024-04-29 00:45:26'),
(6, 7, '2024-04-29 00:39:47', 709.87, 'UPDATE', 'root@localhost', '2024-04-29 00:45:36'),
(7, 8, '0000-00-00 00:00:00', 10, 'INSERT', 'root@localhost', '2024-04-29 00:46:35'),
(8, 8, '0000-00-00 00:00:00', 10, 'DELETE', 'root@localhost', '2024-04-29 00:46:51');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_order_detail`
--

DROP TABLE IF EXISTS `log_order_detail`;
CREATE TABLE `log_order_detail` (
  `id` int(11) NOT NULL,
  `id_order_detail` int(11) NOT NULL,
  `id_order` int(11) NOT NULL,
  `id_dogo` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `operation` varchar(10) NOT NULL,
  `db_user` varchar(30) NOT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `log_order_detail`
--

INSERT INTO `log_order_detail` (`id`, `id_order_detail`, `id_order`, `id_dogo`, `quantity`, `operation`, `db_user`, `date`) VALUES
(1, 2, 1, 4, 4, 'UPDATE', 'root@localhost', '2024-04-28 23:38:34'),
(2, 11, 6, 4, 7, 'INSERT', 'root@localhost', '2024-04-29 00:37:32'),
(3, 12, 7, 3, 5, 'INSERT', 'root@localhost', '2024-04-29 00:39:47'),
(4, 11, 6, 2, 6, 'UPDATE', 'root@localhost', '2024-04-29 00:42:48'),
(5, 11, 6, 4, 4, 'UPDATE', 'root@localhost', '2024-04-29 00:43:37'),
(6, 14, 6, 3, 2, 'INSERT', 'root@localhost', '2024-04-29 00:44:48'),
(7, 15, 7, 4, 7, 'INSERT', 'root@localhost', '2024-04-29 00:45:26'),
(8, 16, 7, 1, 1, 'INSERT', 'root@localhost', '2024-04-29 00:45:36');

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
(5, '2024-03-17 15:47:27', 79.98),
(6, '2024-04-29 00:37:32', 339.94),
(7, '2024-04-29 00:39:47', 709.87);

--
-- Disparadores `order`
--
DROP TRIGGER IF EXISTS `order_AFTER_DELETE`;
DELIMITER $$
CREATE TRIGGER `order_AFTER_DELETE` AFTER DELETE ON `order` FOR EACH ROW BEGIN
	INSERT INTO
		log_order (id_order, order_date, total, operation, db_user, date) 
    VALUES
		(old.id, old.order_date, old.total, 'DELETE', user(), now());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `order_AFTER_INSERT`;
DELIMITER $$
CREATE TRIGGER `order_AFTER_INSERT` AFTER INSERT ON `order` FOR EACH ROW BEGIN
	INSERT INTO
		log_order (id_order, order_date, total, operation, db_user, date) 
    VALUES
		(new.id, new.order_date, new.total, 'INSERT', user(), now());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `order_AFTER_UPDATE`;
DELIMITER $$
CREATE TRIGGER `order_AFTER_UPDATE` AFTER UPDATE ON `order` FOR EACH ROW BEGIN
	INSERT INTO
		log_order (id_order, order_date, total, operation, db_user, date) 
    VALUES
		(new.id, new.order_date, new.total, 'UPDATE', user(), now());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `order_detail`
--

DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
  `id` int(11) NOT NULL,
  `id_order` int(11) DEFAULT NULL,
  `id_dogo` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `order_detail`
--

INSERT INTO `order_detail` (`id`, `id_order`, `id_dogo`, `quantity`) VALUES
(1, 1, 1, 1),
(2, 1, 4, 4),
(3, 2, 1, 1),
(4, 3, 1, 1),
(5, 3, 2, 1),
(6, 3, 3, 1),
(7, 3, 4, 1),
(8, 4, 2, 1),
(9, 4, 3, 1),
(10, 5, 1, 2),
(11, 6, 4, 4),
(12, 7, 3, 5),
(14, 6, 3, 2),
(15, 7, 4, 7),
(16, 7, 1, 1);

--
-- Disparadores `order_detail`
--
DROP TRIGGER IF EXISTS `order_detail_AFTER_DELETE`;
DELIMITER $$
CREATE TRIGGER `order_detail_AFTER_DELETE` AFTER DELETE ON `order_detail` FOR EACH ROW BEGIN
	INSERT INTO
		log_order_detail (id_order_detail, id_order, id_dogo, quantity, operation, db_user, date) 
    VALUES
		(old.id, old.id_order, old.id_dogo, old.quantity, 'DELETE', user(), now());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `order_detail_AFTER_INSERT`;
DELIMITER $$
CREATE TRIGGER `order_detail_AFTER_INSERT` AFTER INSERT ON `order_detail` FOR EACH ROW BEGIN
	INSERT INTO
		log_order_detail (id_order_detail, id_order, id_dogo, quantity, operation, db_user, date) 
    VALUES
		(new.id, new.id_order, new.id_dogo, new.quantity, 'INSERT', user(), now());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `order_detail_AFTER_UPDATE`;
DELIMITER $$
CREATE TRIGGER `order_detail_AFTER_UPDATE` AFTER UPDATE ON `order_detail` FOR EACH ROW BEGIN
	INSERT INTO
		log_order_detail (id_order_detail, id_order, id_dogo, quantity, operation, db_user, date) 
    VALUES
		(new.id, new.id_order, new.id_dogo, new.quantity, 'UPDATE', user(), now());
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cat_dogo`
--
ALTER TABLE `cat_dogo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_cat_dogo` (`name`);

--
-- Indices de la tabla `cat_ingredient`
--
ALTER TABLE `cat_ingredient`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_cat_ingredient` (`name`);

--
-- Indices de la tabla `dogo`
--
ALTER TABLE `dogo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uc_dogo` (`id_dogo`,`id_ingredient`),
  ADD KEY `id_ingredient` (`id_ingredient`);

--
-- Indices de la tabla `log_order`
--
ALTER TABLE `log_order`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `log_order_detail`
--
ALTER TABLE `log_order_detail`
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
  ADD KEY `id_dogo` (`id_dogo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cat_dogo`
--
ALTER TABLE `cat_dogo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `cat_ingredient`
--
ALTER TABLE `cat_ingredient`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `dogo`
--
ALTER TABLE `dogo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `log_order`
--
ALTER TABLE `log_order`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `log_order_detail`
--
ALTER TABLE `log_order_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `order`
--
ALTER TABLE `order`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `order_detail`
--
ALTER TABLE `order_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `dogo`
--
ALTER TABLE `dogo`
  ADD CONSTRAINT `dogo_ibfk_1` FOREIGN KEY (`id_dogo`) REFERENCES `cat_dogo` (`id`),
  ADD CONSTRAINT `dogo_ibfk_2` FOREIGN KEY (`id_ingredient`) REFERENCES `cat_ingredient` (`id`);

--
-- Filtros para la tabla `order_detail`
--
ALTER TABLE `order_detail`
  ADD CONSTRAINT `order_detail_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `order` (`id`),
  ADD CONSTRAINT `order_detail_ibfk_2` FOREIGN KEY (`id_dogo`) REFERENCES `dogo` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
