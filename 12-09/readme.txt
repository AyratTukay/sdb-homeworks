## 2. Подключение к master и проверка роли

### 2.1. Установка клиента psql (локально или на VM)
На Ubuntu:

```
sudo apt update
sudo apt install -y postgresql-client
```
2.2. Скачивание SSL-сертификата (root.crt)
Для подключения к Managed Service for PostgreSQL требуется доверенный сертификат CA. 

```
mkdir -p ~/.postgresql
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ~/.postgresql/root.crt
chmod 0600 ~/.postgresql/root.crt
(Путь ~/.postgresql/root.crt — стандартный для psql на Linux.) 
```

2.3. Подключение к кластеру именно к master (read-write)
В команде подключения указываем:

host = список FQDN всех узлов кластера (через запятую)

target_session_attrs=read-write — чтобы psql выбрал узел, который принимает запись (master). 

Пример:

```
psql "host=<FQDN_MASTER>,<FQDN_REPLICA> \
port=6432 \
sslmode=verify-full \
dbname=<DB_NAME> \
user=<DB_USER> \
target_session_attrs=read-write"
```
Проверка, что подключились к master:

```
select case when pg_is_in_recovery() then 'REPLICA' else 'MASTER' end;
```
Проверка количества подключённых реплик (на master):

```
select count(*) from pg_stat_replication;
```

Подключение выполнено, запрос вернул MASTER

pg_stat_replication показывает наличие реплики (count >= 1)

3. Проверка работоспособности репликации
3.1. Создание таблицы и данных на master
В той же сессии psql (на master):
```
CREATE TABLE test_table(text varchar);
insert into test_table values('Строка 1');
insert into test_table values('Строка 2');
```

4. Подключение к replica и проверка данных
4.1. Подключение к узлу-реплике
Теперь подключаемся только к FQDN реплики (в host указываем один хост),
и убираем target_session_attrs. 


```
psql "host=<FQDN_REPLICA> \
port=6432 \
sslmode=verify-full \
dbname=<DB_NAME> \
user=<DB_USER>"
Проверка роли:
```
```
select case when pg_is_in_recovery() then 'REPLICA' else 'MASTER' end;
```

```
select status from pg_stat_wal_receiver;
```
```
select * from test_table;
```
На реплике выполнен select * from test_table; и видны строки (Строка 1, Строка 2)
