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