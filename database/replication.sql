/* On MASTER server go to replicaction tab and do the following:
1. Select wich database is going to be replicated.
2. Copy server info like this:
    log_bin=mysql-bin
    log_error=mysql-bin.err
    binlog_do_db=abd_burger
3. Open configuration file and after line 'server-id=1' paste the last 3 lines above.
4. Restart services.
5. Create user from server 1 with slave IP address.
*/

GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO `mirror_slave`@`192.168.100.2` IDENTIFIED BY PASSWORD '*1B6FCA07A1546E311BC69163257644D8DE2DC05C';

/* On SLAVE server do the following:
1. Open configuration file, comment 'server-id=1' and uncomment 'server-id-2'.
2. Restart services.
3. Execute the following SQL lines:
*/

STOP SLAVE;
CHANGE MASTER TO
	master_host = '192.168.100.1',
    master_user = 'mirror_master',
    master_password = 'mirror',
    master_log_file = 'mysql-bin.000002', -- Depends on master server information.
    master_log_pos = 342; -- Depends on master server information.

/* Continuing with SLAVE config:
1. Go to replication tab.
2. Select control slave and then Full start option.
3. Confirm information selecting slave status table.
*/