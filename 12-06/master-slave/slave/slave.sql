CHANGE REPLICATION SOURCE TO
SOURCE_HOST='compose_mysql_master',      -- Имя хоста мастера
SOURCE_USER='repl',                      -- Имя пользователя
SOURCE_PASSWORD='pass',                  -- Пароль этого пользователя
SOURCE_SSL=1;

START REPLICA;
