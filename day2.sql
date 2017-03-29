use hr;
create table my_prim(
	id varchar(10),
    name varchar(10)
);

insert into my_prim(id, name) values('3333', 'haha');
insert into my_prim(id, name) values('1111', 'susu');
#alter table my_prim add primary key(id);
alter table my_prim add primary key(name);
alter table my_prim drop primary key;
select * from my_prim;

show indexes from employees;
select * from information_schema.STATISTICS where table_name = 'employees';

drop index emp_last_first_idx on employees;

create index emp_salary_idx on employees(salary);
create index emp_salary_idx2 on employees(salary);

explain
select last_name, first_name, salary, hire_date from employees where employee_id = 100;

explain
select last_name, first_name, salary, hire_date from employees where employee_id >= 100;

explain
select last_name, first_name, salary, hire_date from employees where salary = 8000;

explain
select last_name, first_name, salary, hire_date from employees where salary between 8000 and 9000;

explain
select last_name, first_name, salary, hire_date from employees where employee_id in (100, 200);



alter table employees add index(last_name, first_name);
show indexes from employees;

explain
select last_name, first_name, salary, hire_date from employees where last_name like 'K%';

explain
select last_name, first_name, salary, hire_date from employees where last_name = 'King' and first_name like 'K%';

explain
select last_name, first_name, salary, hire_date from employees where last_name like 'K%' and first_name like 'K%';


# index 힌트
alter table employees add index(last_name, first_name, salary);

explain
select employee_id, last_name, first_name, salary from employees ignore index(last_name_2);

show indexes from employees;


# prefix index
use myhr;
show indexes from employee;
alter table employee add primary key(emp_no);
alter table employee add index(last_name);
alter table employee add index(last_name(4));

explain
select * from employee force index(last_name_2) where last_name like 'Straney';

show indexes from emp_title;

#explain
select title, count(*) from emp_title group by title order by 2 desc limit 4;

select substring(title, 1, 4), count(*) from emp_title group by substring(title, 1, 4) order by 2 desc limit 4;


create table some_table(
	id varchar(10),
	sub_id varchar(8) as (substring(id, 1, 8)),
	index(sub_id)
);
insert some_table(id) values('sub_id_001');

select * from some_table;


use hr;
explain
select * from employees where commission_pct not in (0.2, 0.25);
create index emp_commission_pct_idx on employees(commission_pct);

show indexes from employees;
alter table employees drop index emp_salary_idx2;

# 연봉 10만 이상 직원 조회
explain
select * from employees where salary*12 >= 120000;

explain
select * from employees where salary >= 120000/12;

explain
select * from employees where substring(last_name, 1, 1) = 'K';

explain
select * from employees where last_name like 'K%';


# index 사용 불가 - 컬럼 타입 자동 변환
create table my_internal(
	t_no varchar(10) primary key, # PK를 varchar로 
    t_name varchar(20)
);
insert into my_internal(t_no, t_name) values(1234, 'hong'); # 자동 형변환
select * from my_internal;
show indexes from my_internal;
explain select * from my_internal where t_no = 1234; # type: All, index 사용 X, 성능 이슈 야기
explain select * from my_internal where t_no = '1234'; # type: const



use hr;
explain
select * from employees where last_name = 'King' and first_name = 'Steven'; # index 사용 O
explain
select * from employees where last_name = 'King' or first_name = 'Steven'; # index 사용 X


