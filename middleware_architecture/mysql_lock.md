
# 联合索引不能触发行锁也是表锁  
https://www.cnblogs.com/Marydon20170307/p/14105005.html  
select...for update/insert/update/delete操作都会触发锁  
当where条件中含有至少一个字段添加了索引，才会触发行锁，否则就是表锁  
当表中只有联合索引，而且是根据查询条件所创建的索引，触发的将是表锁而不是行锁  

# 查看索引  
SHOW INDEX FROM subnet;  
ALTER table tableName ADD INDEX indexName(columnName);  
ALTER table mytable ADD UNIQUE [indexName] (username(length));  

SELECT @@session.tx_isolation; // 查询会话隔离级别  
SELECT @@tx_isolation; //查询系统隔离级别  
SELECT @@global.tx_isolation; //查看系统隔离级别  
# 事务操作的背后  
如果会话是auto_commit=1，每次执行update语句后都要执行commit操作。commit操作耗费时间久，会产生两次磁盘同步（写binlog和写redo日志）  

# 查看造成死锁占用时间长的sql语句  
show processlist;  
show status like '%lock%';  
# 正在锁的事务  
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;  
# 等待锁的事务  
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS;  
# 表锁  
show OPEN TABLES where In_use > 0;  
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;  
# 行锁  
select r.trx_isolation_level, r.trx_id waiting_trx_id,r.trx_mysql_thread_id waiting_trx_thread,
r.trx_state waiting_trx_state,lr.lock_mode waiting_trx_lock_mode,lr.lock_type waiting_trx_lock_type,
lr.lock_table waiting_trx_lock_table,lr.lock_index waiting_trx_lock_index,r.trx_query waiting_trx_query,
b.trx_id blocking_trx_id,b.trx_mysql_thread_id blocking_trx_thread,b.trx_state blocking_trx_state,
lb.lock_mode blocking_trx_lock_mode,lb.lock_type blocking_trx_lock_type,lb.lock_table blocking_trx_lock_table,
lb.lock_index blocking_trx_lock_index,b.trx_query blocking_query
from information_schema.innodb_lock_waits w inner join information_schema.innodb_trx b on b.trx_id=w.blocking_trx_id
inner join information_schema.innodb_trx r on r.trx_id=w.requesting_trx_id
inner join information_schema.innodb_locks lb on lb.lock_trx_id=w.blocking_trx_id
inner join information_schema.innodb_locks lr on lr.lock_trx_id=w.requesting_trx_id;  
