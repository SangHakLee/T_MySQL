show engines;

#K 시작되는 이름의 사원정보
explain
select * from employees where substr(last_name, 1, 1) = 'K';
# id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
# '1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '107', '100.00', 'Using where'

explain
select * from employees where last_name like'K%';

show indexes from employees;

# index 생성 후 쿼리 결과
create index emp_last_first_idx on employees(last_name, first_name);
# id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
# '1', 'SIMPLE', 'employees', NULL, 'range', 'emp_last_first_idx', 'emp_last_first_idx', '77', NULL, '6', '100.00', 'Using index condition'
