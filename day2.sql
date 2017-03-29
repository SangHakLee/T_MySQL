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



alter table employees add index(last_name, first_name, salary);

explain
select employee_id, last_name, first_name, salary from employees ignore index(last_name_2);

show indexes from employees;