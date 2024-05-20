# Privileges for `adminvideo`@`%`

GRANT USAGE ON *.* TO `adminvideo`@`%` IDENTIFIED BY PASSWORD '*4ACFE3202A5FF5CF467898FC58AAB1D615029441';

GRANT SELECT, INSERT, UPDATE ON `mongodbvideo`.* TO `adminvideo`@`%`;
#LE DIMOS SELECT, UPDATE, INSERT Y EXECUTE, sin execute no nos deja insertar o actualizar desde la pagina hacia la base de datos con los procedimientos

# Privileges for `guess`@`localhost`

GRANT USAGE ON *.* TO `guess`@`localhost` IDENTIFIED BY PASSWORD '*852A9AD01BF1C5A598FD86F8762C2FD11A9B4B14';

GRANT SELECT ON `mongodbvideo`.* TO `guess`@`localhost`;