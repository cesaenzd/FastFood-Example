-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3308
-- Tiempo de generación: 30-05-2024 a las 06:17:04
-- Versión del servidor: 10.4.32-MariaDB-log
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `stocklatte`
--
DROP DATABASE IF EXISTS `stocklatte`;
CREATE DATABASE IF NOT EXISTS `stocklatte` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `stocklatte`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `p_empleado`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_empleado` (`emple_id` INT, `emple_nombre` VARCHAR(45), `emple_apellido` VARCHAR(45), `emple_curp` VARCHAR(45), `emple_id_departamento` INT, `emple_id_puesto` INT, `emple_usuario` VARCHAR(45), `emple_password` VARCHAR(60))   BEGIN
DECLARE v_operation VARCHAR(20);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
		GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
		SELECT CONCAT(@p1, ':', @p2) error, 'FAILURE' status, v_operation 'operation';
	END;
 
	START TRANSACTION;

-- si pone un 0 inserta una nueva pelicula tanto en film y en text

IF emple_id > 0 then

UPDATE stocklatte.empleado set id = emple_id, nombre = emple_nombre , apellido = emple_apellido, curp = emple_curp, id_departamento = emple_id_departamento, id_puesto = emple_id_puesto, usuario = emple_usuario, password = emple_password  where empleado.id = emple_id;

SET v_operation = 'UPDATE';

else
INSERT INTO stocklatte.empleado (nombre, apellido, curp, id_departamento, id_puesto, usuario, password)
VALUES (upper(emple_nombre), upper(emple_apellido), upper(emple_curp), upper(emple_id_departamento), upper(emple_id_puesto), upper(emple_usuario), upper(emple_password));
SET v_operation = 'INSERT';

end if;
COMMIT;
select emple_id,'SUCCESS' status, v_operation operation;

END$$

DROP PROCEDURE IF EXISTS `p_factura_venta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_factura_venta` (`fac_id` INT, `fac_id_cliente` INT, `fac_total` DECIMAL, `fac_tipo_de_pago` VARCHAR(10), `fac_id_empleado` INT, `fac_id_producto` INT, `fac_cantidad` INT, `fac_precio` DECIMAL)   BEGIN
declare ultimo_id INT;
DECLARE v_operation VARCHAR(20);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
		GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
		SELECT CONCAT(@p1, ':', @p2) error, 'FAILURE' status, v_operation 'operation';
	END;
 
	START TRANSACTION;


-- Si es igual a 0 inserta una nueva orden y un nuevo campo en orden detalle

IF fac_id = 0 THEN
INSERT INTO stocklatte.factura_ventae (fecha, id_cliente, total, tipo_de_pago, id_empleado)
VALUES (upper(NOW()), upper(fac_id_cliente), upper(fac_total), upper(fac_tipo_de_pago), upper(fac_id_empleado));
SELECT last_insert_id() INTO fac_id;
INSERT INTO stocklatte.factura_ventad (id_factura_ventae, id_producto, cantidad, precio)
VALUES (upper(fac_id), upper(fac_id_producto), upper(fac_cantidad), upper(fac_precio));
SET v_operation = 'INSERT';

-- Si es mayor a cero elige el numero de orden para agregar un nuevo detalle en esa orden
elseif fac_id > 0 THEN
INSERT INTO stocklatte.factura_ventad (id_factura_ventae, id_producto, cantidad, precio)
VALUES (upper(fac_id), upper(fac_id_producto), upper(fac_cantidad), upper(fac_precio));
SET v_operation = 'INSERT';
-- si es un numero negativo agrega en la ultima orden ingresada un nuevo detalle a esa orden
else
select max(id) From stocklatte.factura_ventae INTO ultimo_id;
INSERT INTO stocklatte.factura_ventad (id_factura_ventae, id_producto, cantidad, precio)
VALUES (upper(fac_id), upper(fac_id_producto), upper(fac_cantidad), upper(fac_precio));
SET v_operation = 'INSERT';
END IF;
COMMIT;
SELECT fac_id, ultimo_id,'SUCCESS' status, v_operation operation;
END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `f_cantidad_producto_restante`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_cantidad_producto_restante` (`p_id_producto` INT) RETURNS INT(11)  BEGIN
    DECLARE cantidad_inicial INT;
    DECLARE cantidad_vendida INT;
    DECLARE cantidad_restante INT;

    -- Obtener la cantidad inicial del producto
    SELECT cantidad INTO cantidad_inicial
    FROM producto
    WHERE id = p_id_producto;

    -- Calcular la cantidad vendida del producto en el día de hoy
    SELECT COALESCE(SUM(d.cantidad), 0) INTO cantidad_vendida
    FROM factura_ventad d
    JOIN factura_ventae e ON d.id_factura_ventae = e.id
    WHERE d.id_producto = p_id_producto
    AND DATE(e.fecha) = CURDATE();

    -- Calcular la cantidad restante del producto
    SET cantidad_restante = cantidad_inicial - cantidad_vendida;

    RETURN cantidad_restante;
END$$

DROP FUNCTION IF EXISTS `f_factura_ventas`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_factura_ventas` (`p_suma` VARCHAR(20), `p_fecha` DATE) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE suma_total DECIMAL(10,2);

    IF p_suma = 'suma' THEN
        SELECT SUM(d.cantidad * d.precio) INTO suma_total
        FROM factura_ventad d
        JOIN factura_ventae e ON d.id_factura_ventae = e.id
        WHERE DATE(e.fecha) = p_fecha;
    ELSE
        SET suma_total = 0;
    END IF;

    RETURN suma_total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `almacen`
--

DROP TABLE IF EXISTS `almacen`;
CREATE TABLE `almacen` (
  `id` int(11) NOT NULL,
  `id_factura_comprae` int(11) DEFAULT NULL,
  `id_material` int(11) DEFAULT NULL,
  `cantidad_material` int(11) NOT NULL,
  `id_ordene` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad_producto` int(11) NOT NULL,
  `id_factura_ventae` int(11) DEFAULT NULL,
  `tipo_de_movimiento` varchar(45) NOT NULL,
  `precio` decimal(6,2) NOT NULL,
  `fecha` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `almacen`:
--   `id_factura_comprae`
--       `factura_comprae` -> `id`
--   `id_factura_ventae`
--       `factura_ventae` -> `id`
--   `id_material`
--       `materia` -> `id`
--   `id_ordene`
--       `ordene` -> `id`
--   `id_producto`
--       `producto` -> `id`
--

--
-- Volcado de datos para la tabla `almacen`
--

INSERT INTO `almacen` (`id`, `id_factura_comprae`, `id_material`, `cantidad_material`, `id_ordene`, `id_producto`, `cantidad_producto`, `id_factura_ventae`, `tipo_de_movimiento`, `precio`, `fecha`) VALUES
(1, 1, 1, 1, 1, 1, 12, NULL, 'E', 200.00, '2024-05-29 00:00:00'),
(2, 1, 1, 2, 1, 1, 24, NULL, 'E', 400.00, '2024-05-29 00:00:00'),
(3, 1, 1, 2, 1, 1, 24, NULL, 'E', 400.00, '2024-05-29 00:00:00');

--
-- Disparadores `almacen`
--
DROP TRIGGER IF EXISTS `log_almacen_AFTER_INSERT`;
DELIMITER $$
CREATE TRIGGER `log_almacen_AFTER_INSERT` AFTER INSERT ON `almacen` FOR EACH ROW INSERT INTO
log_almacen(id_almacen, id_factura_comprae, id_material, cantidad_material, id_ordene, id_producto, cantidad_producto, id_factura_ventae, tipo_de_movimiento, precio, fecha, operation, id_app_user)
VALUES
(new.id, new.id_factura_comprae, new.id_material, new.cantidad_material, new.id_ordene, new.id_producto, new.cantidad_producto, new.id_factura_ventae, new.tipo_de_movimiento, new.precio ,now(), "INSERT", user())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `log_almacen_AFTER_UPDATE`;
DELIMITER $$
CREATE TRIGGER `log_almacen_AFTER_UPDATE` AFTER UPDATE ON `almacen` FOR EACH ROW INSERT INTO
log_almacen(id_almacen, id_factura_comprae, id_material, cantidad_material, id_ordene, id_producto, cantidad_producto, id_factura_ventae, tipo_de_movimiento, precio, fecha, operation, id_app_user)
VALUES
(new.id, new.id_factura_comprae, new.id_material, new.cantidad_material, new.id_ordene, new.id_producto, new.cantidad_producto, new.id_factura_ventae, new.tipo_de_movimiento, new.precio ,now(), "UPDATE", user())
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `log_almacen_DELETE_UPDATE`;
DELIMITER $$
CREATE TRIGGER `log_almacen_DELETE_UPDATE` AFTER DELETE ON `almacen` FOR EACH ROW INSERT INTO
log_almacen(id_almacen, id_factura_comprae, id_material, cantidad_material, id_ordene, id_producto, cantidad_producto, id_factura_ventae, tipo_de_movimiento, precio, fecha, operation, id_app_user)
VALUES
(old.id, old.id_factura_comprae, old.id_material, old.cantidad_material, old.id_ordene, old.id_producto, old.cantidad_producto, old.id_factura_ventae, old.tipo_de_movimiento, old.precio ,now(), "DELETE", user())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `id` int(11) NOT NULL,
  `razon_social` varchar(45) NOT NULL,
  `rfc` varchar(45) DEFAULT 'Null',
  `telefono` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `cliente`:
--

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id`, `razon_social`, `rfc`, `telefono`) VALUES
(1, 'ame', 'Null', '6141151040'),
(2, 'jesus', 'Null', '6143452017'),
(3, 'pau', 'Null', '6148723015');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamento`
--

DROP TABLE IF EXISTS `departamento`;
CREATE TABLE `departamento` (
  `id` int(11) NOT NULL,
  `departamento` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `departamento`:
--

--
-- Volcado de datos para la tabla `departamento`
--

INSERT INTO `departamento` (`id`, `departamento`) VALUES
(1, 'Ventas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

DROP TABLE IF EXISTS `empleado`;
CREATE TABLE `empleado` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `curp` varchar(45) NOT NULL,
  `id_departamento` int(11) NOT NULL,
  `id_puesto` int(11) NOT NULL,
  `usuario` varchar(45) NOT NULL,
  `password` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `empleado`:
--

--
-- Volcado de datos para la tabla `empleado`
--

INSERT INTO `empleado` (`id`, `nombre`, `apellido`, `curp`, `id_departamento`, `id_puesto`, `usuario`, `password`) VALUES
(1, 'AMERICA', 'CHAVARRIA', 'HDHDHDH', 1, 1, '2', '2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_comprad`
--

DROP TABLE IF EXISTS `factura_comprad`;
CREATE TABLE `factura_comprad` (
  `id` int(11) NOT NULL,
  `id_factura_comprae` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `factura_comprad`:
--

--
-- Volcado de datos para la tabla `factura_comprad`
--

INSERT INTO `factura_comprad` (`id`, `id_factura_comprae`, `id_materia`, `cantidad`, `precio`) VALUES
(1, 1, 1, 1, 200.00),
(2, 1, 2, 2, 400.00),
(3, 1, 2, 2, 400.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_comprae`
--

DROP TABLE IF EXISTS `factura_comprae`;
CREATE TABLE `factura_comprae` (
  `id` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `total` decimal(6,2) NOT NULL,
  `tipo_de_pago` varchar(45) NOT NULL,
  `id_proveedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `factura_comprae`:
--

--
-- Volcado de datos para la tabla `factura_comprae`
--

INSERT INTO `factura_comprae` (`id`, `fecha`, `total`, `tipo_de_pago`, `id_proveedor`) VALUES
(1, '2024-05-29 00:00:00', 1000.00, 'EF', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_ventad`
--

DROP TABLE IF EXISTS `factura_ventad`;
CREATE TABLE `factura_ventad` (
  `id` int(11) NOT NULL,
  `id_factura_ventae` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(6,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `factura_ventad`:
--

--
-- Volcado de datos para la tabla `factura_ventad`
--

INSERT INTO `factura_ventad` (`id`, `id_factura_ventae`, `id_producto`, `cantidad`, `precio`) VALUES
(1, 1, 1, 20, 19.99),
(2, 2, 1, 2, 50.00),
(3, 3, 1, 2, 50.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_ventae`
--

DROP TABLE IF EXISTS `factura_ventae`;
CREATE TABLE `factura_ventae` (
  `id` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `total` decimal(6,2) NOT NULL,
  `tipo_de_pago` varchar(45) NOT NULL,
  `id_empleado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `factura_ventae`:
--

--
-- Volcado de datos para la tabla `factura_ventae`
--

INSERT INTO `factura_ventae` (`id`, `fecha`, `id_cliente`, `total`, `tipo_de_pago`, `id_empleado`) VALUES
(1, '2024-05-28 00:00:00', 1, 12.99, 'EF', 1),
(2, '2024-05-29 18:50:16', 2, 99.99, 'EF', 1),
(3, '2024-05-29 18:50:57', 2, 99.99, 'EF', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_almacen`
--

DROP TABLE IF EXISTS `log_almacen`;
CREATE TABLE `log_almacen` (
  `id` int(11) NOT NULL,
  `id_almacen` int(11) DEFAULT NULL,
  `id_factura_comprae` int(11) DEFAULT NULL,
  `id_material` int(11) DEFAULT NULL,
  `cantidad_material` int(11) NOT NULL,
  `id_ordene` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad_producto` int(11) NOT NULL,
  `id_factura_ventae` int(11) DEFAULT NULL,
  `tipo_de_movimiento` varchar(45) NOT NULL,
  `precio` decimal(6,2) NOT NULL,
  `fecha` datetime NOT NULL,
  `operation` varchar(50) NOT NULL,
  `db_user` varchar(50) NOT NULL,
  `id_app_user` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `log_almacen`:
--

--
-- Volcado de datos para la tabla `log_almacen`
--

INSERT INTO `log_almacen` (`id`, `id_almacen`, `id_factura_comprae`, `id_material`, `cantidad_material`, `id_ordene`, `id_producto`, `cantidad_producto`, `id_factura_ventae`, `tipo_de_movimiento`, `precio`, `fecha`, `operation`, `db_user`, `id_app_user`) VALUES
(1, 1, 1, 1, 1, 1, 1, 12, NULL, 'E', 10.00, '2024-05-29 21:37:32', 'INSERT', '', 'root@localhost'),
(2, 2, 1, 1, 2, 1, 1, 24, NULL, 'E', 99.99, '2024-05-29 21:38:49', 'INSERT', '', 'root@localhost'),
(3, 1, 1, 1, 1, 1, 1, 12, NULL, 'E', 99.99, '2024-05-29 21:38:49', 'UPDATE', '', 'root@localhost'),
(4, 3, 1, 1, 2, 1, 1, 24, NULL, 'E', 99.99, '2024-05-29 21:42:23', 'INSERT', '', 'root@localhost'),
(5, 1, 1, 1, 1, 1, 1, 12, NULL, 'E', 99.99, '2024-05-29 21:42:23', 'UPDATE', '', 'root@localhost'),
(6, 2, 1, 1, 2, 1, 1, 24, NULL, 'E', 99.99, '2024-05-29 21:42:23', 'UPDATE', '', 'root@localhost');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materia`
--

DROP TABLE IF EXISTS `materia`;
CREATE TABLE `materia` (
  `id` int(11) NOT NULL,
  `materia` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `materia`:
--

--
-- Volcado de datos para la tabla `materia`
--

INSERT INTO `materia` (`id`, `materia`) VALUES
(1, 'pastel de chocolate');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ordend`
--

DROP TABLE IF EXISTS `ordend`;
CREATE TABLE `ordend` (
  `id` int(11) NOT NULL,
  `id_ordene` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio` decimal(6,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `ordend`:
--

--
-- Volcado de datos para la tabla `ordend`
--

INSERT INTO `ordend` (`id`, `id_ordene`, `id_producto`, `cantidad`, `precio`) VALUES
(1, 1, 1, 12, 60.00),
(2, 1, 1, 24, 60.00),
(3, 1, 1, 24, 60.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ordene`
--

DROP TABLE IF EXISTS `ordene`;
CREATE TABLE `ordene` (
  `id` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `tipo_de_pago` varchar(10) NOT NULL,
  `total_materia` int(11) NOT NULL,
  `total_ganancia_producto` decimal(6,2) NOT NULL,
  `id_factura_comprae` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `ordene`:
--

--
-- Volcado de datos para la tabla `ordene`
--

INSERT INTO `ordene` (`id`, `fecha`, `tipo_de_pago`, `total_materia`, `total_ganancia_producto`, `id_factura_comprae`) VALUES
(1, '2024-05-29 00:00:00', 'EF', 1000, 3600.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

DROP TABLE IF EXISTS `producto`;
CREATE TABLE `producto` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(45) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `costo` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `producto`:
--

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`id`, `descripcion`, `cantidad`, `costo`) VALUES
(1, 'Rebanada de pastel de chocolate', 60, 60.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

DROP TABLE IF EXISTS `proveedor`;
CREATE TABLE `proveedor` (
  `id` int(11) NOT NULL,
  `razon_social` varchar(45) NOT NULL,
  `direcion` varchar(45) NOT NULL,
  `cp` varchar(45) NOT NULL,
  `correo` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `proveedor`:
--

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`id`, `razon_social`, `direcion`, `cp`, `correo`) VALUES
(1, 'costo', 'americas', '31510', 'cosco@cosco.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puesto`
--

DROP TABLE IF EXISTS `puesto`;
CREATE TABLE `puesto` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(45) NOT NULL,
  `id_departamento` int(11) NOT NULL,
  `actividad` varchar(45) NOT NULL,
  `sueldo` decimal(4,2) NOT NULL,
  `tipo_de_pago` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `puesto`:
--

--
-- Volcado de datos para la tabla `puesto`
--

INSERT INTO `puesto` (`id`, `descripcion`, `id_departamento`, `actividad`, `sueldo`, `tipo_de_pago`) VALUES
(1, 'mesero', 1, 'mesero', 99.99, 'EF');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `id_user_type` varchar(45) DEFAULT NULL,
  `email` varchar(45) NOT NULL,
  `password` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `user`:
--

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `id_user_type`, `email`, `password`) VALUES
(1, '1', 'adminLatte', '$2y$10$XIkbibPlmh2DfJhR4ZMmKuVo8fYFQTU0tN04TQX/sTH93Cpk5Tw06'),
(2, '2', 'guessLatte', '$2y$10$S81i8n64DFa7tiNYXla.weDdzkL6zOUA6xf5AUeJeNJTpm6Xo.f0q');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_type`
--

DROP TABLE IF EXISTS `user_type`;
CREATE TABLE `user_type` (
  `id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELACIONES PARA LA TABLA `user_type`:
--

--
-- Volcado de datos para la tabla `user_type`
--

INSERT INTO `user_type` (`id`, `name`) VALUES
(1, 'ADMIN'),
(2, 'GUESS');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_almacen`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_almacen`;
CREATE TABLE `vw_almacen` (
`id` int(11)
,`id_factura_comprae` int(11)
,`id_material` int(11)
,`cantidad_material` int(11)
,`id_ordene` int(11)
,`id_producto` int(11)
,`cantidad_producto` int(11)
,`id_factura_ventae` int(11)
,`tipo_de_movimiento` varchar(45)
,`precio` decimal(6,2)
,`fecha` datetime
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_almacen`
--
DROP TABLE IF EXISTS `vw_almacen`;

DROP VIEW IF EXISTS `vw_almacen`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_almacen`  AS SELECT `almacen`.`id` AS `id`, `almacen`.`id_factura_comprae` AS `id_factura_comprae`, `almacen`.`id_material` AS `id_material`, `almacen`.`cantidad_material` AS `cantidad_material`, `almacen`.`id_ordene` AS `id_ordene`, `almacen`.`id_producto` AS `id_producto`, `almacen`.`cantidad_producto` AS `cantidad_producto`, `almacen`.`id_factura_ventae` AS `id_factura_ventae`, `almacen`.`tipo_de_movimiento` AS `tipo_de_movimiento`, `almacen`.`precio` AS `precio`, `almacen`.`fecha` AS `fecha` FROM `almacen` ORDER BY `almacen`.`id` DESC LIMIT 0, 20 ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `almacen`
--
ALTER TABLE `almacen`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idfacturacomprae` (`id_factura_comprae`),
  ADD KEY `idfacturaventae` (`id_factura_ventae`),
  ADD KEY `idmateria` (`id_material`),
  ADD KEY `idordene` (`id_ordene`),
  ADD KEY `idproducto` (`id_producto`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `departamento`
--
ALTER TABLE `departamento`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `factura_comprad`
--
ALTER TABLE `factura_comprad`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `factura_comprae`
--
ALTER TABLE `factura_comprae`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `factura_ventad`
--
ALTER TABLE `factura_ventad`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `factura_ventae`
--
ALTER TABLE `factura_ventae`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `log_almacen`
--
ALTER TABLE `log_almacen`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `materia`
--
ALTER TABLE `materia`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ordend`
--
ALTER TABLE `ordend`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ordene`
--
ALTER TABLE `ordene`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `puesto`
--
ALTER TABLE `puesto`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `user_type`
--
ALTER TABLE `user_type`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `almacen`
--
ALTER TABLE `almacen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `departamento`
--
ALTER TABLE `departamento`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `empleado`
--
ALTER TABLE `empleado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `factura_comprad`
--
ALTER TABLE `factura_comprad`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `factura_comprae`
--
ALTER TABLE `factura_comprae`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `factura_ventad`
--
ALTER TABLE `factura_ventad`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `factura_ventae`
--
ALTER TABLE `factura_ventae`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `log_almacen`
--
ALTER TABLE `log_almacen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `materia`
--
ALTER TABLE `materia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `ordend`
--
ALTER TABLE `ordend`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `ordene`
--
ALTER TABLE `ordene`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `puesto`
--
ALTER TABLE `puesto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `user_type`
--
ALTER TABLE `user_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `almacen`
--
ALTER TABLE `almacen`
  ADD CONSTRAINT `idfacturacomprae` FOREIGN KEY (`id_factura_comprae`) REFERENCES `factura_comprae` (`id`),
  ADD CONSTRAINT `idfacturaventae` FOREIGN KEY (`id_factura_ventae`) REFERENCES `factura_ventae` (`id`),
  ADD CONSTRAINT `idmateria` FOREIGN KEY (`id_material`) REFERENCES `materia` (`id`),
  ADD CONSTRAINT `idordene` FOREIGN KEY (`id_ordene`) REFERENCES `ordene` (`id`),
  ADD CONSTRAINT `idproducto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
