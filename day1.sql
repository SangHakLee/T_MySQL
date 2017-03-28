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

# 프로파일링 
select @@profiling;
set profiling=1;

# 부서번호 80, 이름이 k로 시작되는
select * from employees e 
join departments d using(department_id) 
where d.department_id = 80 and e.last_name like 'K%' ;
ssssss
show profile;

show profiles;

# 특정 쿼리에 대한 프로파일
show profile for query 4;