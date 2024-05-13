/* DBA Sr. Systems Engineer (Master)
Es el rol de DBA máximo, lo que le permite tener todos los privilegios globales,
lo cual conllevaría a que a su vez acceda a toda la base de datos.
*/

GRANT ALL PRIVILEGES ON *.* TO `dba_master`@`%` IDENTIFIED BY PASSWORD '*C6D380A7121816A4E7E1DA263633AF4A1F8A3602' WITH GRANT OPTION;

/* DBA Jr. Systems Engineer (Standard)
Este rol tiene casi todos los privilegios globales, únicamente tiene restringido el hacer “deletes” en los datos,
tampoco puede hacer “drops” en la estructura, ni crear o garantizar permisos a los usuarios. Adicional a esto no puede
desconectar el servidor. Básicamente este usuario puede realizar todo lo que un rango Senior puede, a excepción de
operaciones que involucren la depuración de datos y comprometer el acceso de intrusos al servidor.
*/

GRANT SELECT, INSERT, UPDATE, CREATE, RELOAD, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON *.* TO `dba_standard`@`%` IDENTIFIED BY PASSWORD '*C206F4C6E3016AFCBA2AFA1BD682C78253646C0A';

/* DBA Practicante (Novice)
La diferencia de este usuario con el anterior es que puede realizar lo mismo a excepción de operaciones que involucren
la edición de datos y estructura de las bases de datos. Este usuario debe ser supervisado por usuarios avanzados para
evitar que pueda comprometer la información.
*/

GRANT SELECT, INSERT, CREATE, RELOAD, PROCESS, FILE, REFERENCES, INDEX, SHOW DATABASES, CREATE TEMPORARY TABLES, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE ON *.* TO `dba_novice`@`%` IDENTIFIED BY PASSWORD '*91D6688152D95FBDC342743BC4AF7BD219FD1C5F';

-- ***********************************************************************************************************************

-- NOTA: Los usuarios de desarrollo nol tienen acceso a privilegios globales, pues estos solo tienen asignado un
-- proyecto (el acceso a una base de datos o varias según sea el caso).

/*  DEV Sr. Systems Engineer (Master)
Este usuario tiene acceso total a la manipulación de datos del proyecto asignado. Adicional a ello, este puede crear y
actualizar procedimientos almacenados que puedan tener relación directa con el funcionamiento de la aplicación.
Este usuario puede ser el “tech lead” del proyecto, por lo tanto facilita el acceso total a las operaciones que involucren
la manipulación de datos.
*/

GRANT USAGE ON *.* TO `dev_master`@`%` IDENTIFIED BY PASSWORD '*5D9E0D22D3DED51E2EFD56D59D9E042476A1D734';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, TRIGGER ON `abd\_burger`.* TO `dev_master`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, TRIGGER ON `abd\_dogo`.* TO `dev_master`@`%`;

/* DEV Jr. Systems Engineer (Standard)
Este usuario puede hacer lo mismo que el usuario senior, con la diferencia de que no puede eliminar datos ni realizar
disparadores sin supervisión, ya que estos últimos no están a la vista y pueden generar acciones indeseadas si no hay supervisión.
*/

GRANT USAGE ON *.* TO `dev_standard`@`%` IDENTIFIED BY PASSWORD '*B847D4EFCB7458AA443C93290D91A3AA8C6E0FC1';
GRANT SELECT, INSERT, UPDATE, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE ON `abd\_burger`.* TO `dev_standard`@`%`;
GRANT SELECT, INSERT, UPDATE, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE ON `abd\_dogo`.* TO `dev_standard`@`%`;

/* DEV Practicante (Novice)
Por último, este rol a diferencia del tipo de usuario anterior, solo tiene restringido adicionalmente la actualización de
rutinas (edición de funciones y procedimientos almacenados), para evitar que lo que actualmente funcione se pueda romper.
*/

GRANT USAGE ON *.* TO `dev_novice`@`%` IDENTIFIED BY PASSWORD '*D1BAF12B40A1EE539CABCD12FBAA29078209F36A';
GRANT SELECT, INSERT, UPDATE, CREATE VIEW, CREATE ROUTINE ON `abd\_dogo`.* TO `dev_novice`@`%`;
GRANT SELECT, INSERT, UPDATE, CREATE VIEW, CREATE ROUTINE ON `abd\_burger`.* TO `dev_novice`@`%`;
