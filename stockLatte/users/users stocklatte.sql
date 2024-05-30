# Privileges for `adminLatte`@`%`

GRANT USAGE ON *.* TO `adminLatte`@`%` IDENTIFIED BY PASSWORD '*4ACFE3202A5FF5CF467898FC58AAB1D615029441';

GRANT SELECT, INSERT, UPDATE, EXECUTE ON `stocklatte`.* TO `adminLatte`@`%`;


# Privileges for `guessLatte`@`%`

GRANT USAGE ON *.* TO `guessLatte`@`%` IDENTIFIED BY PASSWORD '*852A9AD01BF1C5A598FD86F8762C2FD11A9B4B14';

GRANT SELECT ON `stocklatte`.* TO `guessLatte`@`%`;