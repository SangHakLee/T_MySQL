#join 

use hr;
# orcle way
select * from employees e, departments d
where e.department_id = d.department_id;

# nc join
select * from employees e
join departments d on e.department_id = e.department_id;

select * from employees e
join departments d using(department_id);


# 사원 성, 명, 급여 입사일 부서번호, 부서명 부서장명 출력
select e.last_name, e.first_name, e.salary, e.salary, d.department_id, concat(m.last_name, ', ', m.first_name) as manager_name
from employees e, departments d, employees m
where e.department_id = d.department_id
and d.manager_id = m.employee_id;


# outer 
select count(*) from employees;
select * from employees where department_id is null;
desc employees;

# 부서에 배치되지 않은 사원도 조회
select count(*) from employees e
left outer join departments d on e.department_id = e.department_id;


# 사원 성,명,급여,입사일, 관지자 사번, 관리자 입사일 출력
# 관리자 없는 경우 관리자 없음 출력
select e.last_name, e.first_name, e.salary, e.hire_date, ifnull(m.employee_id, '관리자 없음') as '관리자 사번', ifnull(m.hire_date, '관리자 없음') as '관리자 입사일'
from employees e
left outer join employees m on e.manager_id = m.employee_id;


# 자신의 관리자보다 많은 급여를 받는 사원을 조회
select * from employees e join employees m on e.manager_id = m.employee_id
where e.salary > m.salary;

# 자신의 관리자보다 입사일이 빠른 사원을 조회
select * from employees e join employees m on e.manager_id = m.employee_id
where e.hire_date < m.hire_date;


# hr.employees
# 도시명을 그 도시에 배치된 부서번호와 부서명도 함께 출력하시오.
# 단, 배치된 부서가 없는 경우도 출력
# 도시가 위치한 나라명도 함께 출력


select l.city 도시명, d.department_id 부서, d.department_name 부서명, c.country_name 나라명 
from locations l
left join departments d on l.location_id = d.location_id
join countries c on l.country_id = c.country_id;


select distinct l.city, 
	ifnull(
	(select group_concat(department_id) from departments where location_id = l.location_id),
    '배치부서없음'
    ) dept_id_list
from locations l left join departments d on l.location_id = d.location_id;



# join 알고리즘
create table my_order(
	order_id varchar(10) primary key,
    order_date varchar(8)
);
show indexes from my_order;

create table my_order_item(
	seq int auto_increment primary key,
    order_id varchar(10),
    order_item_id varchar(10),
    order_amount int
);
show indexes from my_order_item;

alter table my_order_item add foreign key(order_id) references my_order(order_id);



explain
select e.last_name, e.first_name, e.salary, d.department_id, d.department_name 
from employees e join departments d using(department_id);

explain
select straight_join e.last_name, e.first_name, e.salary, d.department_id, d.department_name 
from employees e join departments d using(department_id); # straight_join 조인 순서 변경

explain
select straight_join e.last_name, e.first_name, e.salary, d.department_id, d.department_name 
from departments d join employees e using(department_id);


SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'departments';

alter table employees drop foreign key employees_departments_department_id;

show indexes from employees;



use myhr;

#급여이력 조회 emp_no 100004
#employee, emp_salary
desc employee;
desc emp_salary;
select * from emp_salary where emp_no = 100004;
show indexes from emp_salary;

explain
select * from employee e join emp_salary es using(emp_no)
where e.emp_no = 100004;

alter table emp_salary add primary key(emp_no, from_date);
alter table emp_salary add foreign key(emp_no) references(emp_no);


/*
100004 ~ 100014 사번의 성, 이름, 입사일, 현재급여 및 현재직급을 출력
employee 테이블을 먼저 조회
관련 제약조건 생성
필요에 따라 index 생성
실행계획 
*/
use myhr;
#explain
select straight_join e.emp_no, e.last_name, e.first_name, e.hire_date, es.salary, et.title
from employee e 
left join emp_salary es using(emp_no)
left join emp_title et using(emp_no)
where e.emp_no between 100004 and 100014
and es.to_date = (select max(to_date) from emp_salary where emp_no = e.emp_no)
and et.to_date = (select max(to_date) from emp_salary where emp_no = e.emp_no);



