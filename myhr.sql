use myhr;

select count(*) from employee;

use hr;
explain
select * from employees
where department_id = 
(select department_id from employees where last_name = 'King'
and first_name = 'Steven'); # PRIMARY

explain
select * from employees; # SIMPLE

# 부서 평균 급여와 사원정보
explain
select * from employees e
join (select avg(salary), department_id from employees group by department_id) da using(department_id); # DERIVED


# 부서번호 100, 직무 IT_PROG
explain
select * from employees where department_id = 100
union
select * from employees where job_id = 'IT_PROG';

# 사원정보를 부서평균급여와 함께 상호연관
explain
select last_name, first_name, salary, hire_date, (select avg(salary) from employees where department_id = e.department_id) as 부서평균
from employees e;


create table mysample(
	id int auto_increment primary key
)engine=MEMORY;

insert into mysample() values(); # id 만 있기 때문에 
explain
select * from mysample; # system

explain
select * from employees where employee_id = 100; # const


# eq_ref
use myhr;
# 부서번호 d005 사원들의 정보를 부서정보와 함께
select * from dept_emp de 
join employee using(emp_no)
where de.dept_no = 'd005';

alter table employee add primary key(emp_no);
alter table dept_emp add primary key(dept_no, emp_no);
alter table dept_emp add foreign key(emp_no) references employee(emp_no);


use myhr;
explain
select * from emp_title
where to_date = '1985-03-01' or to_date is null; # all
alter table emp_title add primary key(emp_no, from_date);
alter table emp_title add foreign key(emp_no) references employee(emp_no);
alter table emp_title add key(to_date);


use hr;
# 성, 명 출력
explain
select last_name, first_name from employees; # index


use myhr;
#d001, d002, d003
explain
select * from department
where dept_no in (select dept_no from dept_emp where emp_no between 100004 and 101004);
#alter table department add primary key(dept_no);
alter table dept_emp add foreign key(dept_no) references department(dept_no);


#부서 번호 100 - 120
use hr;
explain
select * from employees where department_id between 100 and 120;

show indexes from employees;

# King, 부서번호 100
explain
select * from employees
where last_name = 'King' or department_id = 100; # index_merge


use myhr;
explain
select * from employee order by last_name; # Using filesort

show indexes from employee;
alter table employee add index(last_name, first_name);


use hr;
explain
select last_name from employee;


use myhr;
explain
select * from employee group by gender order by emp_no;
