use hr;
select * from employees e join departments d using(department_id);

explain
select e.last_name, e.first_name, e.salary, e.department_id, 
	(select avg(salary) from employees where department_id = e.department_id) dept_avg_salary
from employees e;

explain
select e.last_name, e.first_name, e.salary, e.department_id, da.avg_salary from employees e
	join (select department_id, avg(salary) avg_salary from employees group by department_id) da 
using(department_id); # inline view subquery

# p52 인라인 뷰의 사용으로 join 수 감소 

flush tables;


# 일반 join -> 1:n
explain
select d.department_id, d.department_name, avg(e.salary) dept_salary
from employees e join departments d using(department_id)
group by e.department_id;

# 인라인 뷰 -> 1:1
explain
select d.department_id, d.department_name, da.dept_salary
from departments d join (
	select department_id, avg(salary) dept_salary from employees group by department_id
) da using(department_id);


use myhr;
#부서별 평균급여를 부서명과 함께 출력

flush status;

explain
select d.dept_no, d.dept_name, avg(es.salary) dept_avg_salary 
from department d 
join dept_emp de using(dept_no)
join emp_salary es using(emp_no)
where de.to_date = '9999-01-01'
and es.to_date = '9999-01-01'
group by d.dept_no;

explain
select d.dept_no, d.dept_name, da.dept_avg_salary 
from department d 
join (
	select dept_no, avg(es.salary) dept_avg_salary from dept_emp de
    join emp_salary es using(emp_no) 
    where de.to_date = '9999-01-01'
	and es.to_date = '9999-01-01'
    group by de.dept_no
) da using(dept_no)
group by d.dept_no;



# 부서 평균보다 많은 급여 받는 사원 조회 (전체 사원은 10만)
use hr;
# 상호 연관 쿼리
explain
select * from employees e 
where salary > ( 
	# 수행 10만번. 동일 데이터 중복 접근
	select avg(salary) from employees where department_id = e.department_id
);

# 인라인 뷰
explain
select * from employees e
join (
	# 10만건을 1번 Full Scan
	select department_id, avg(salary) avg_salary from employees group by department_id
) da using(department_id)
where e.salary > da.avg_salary;




#IN & exists
use hr;
# 한번이라도 직급, 직무를 변경한 이력이 있는 사원 조회
select * from job_history;

explain
select * from employees
where employee_id in ( select employee_id from job_history);

#explain
select * from employees e
where exists (select 'x' from job_history where employee_id = e.employee_id);


# 부서장의 정보를 출력
explain
select * from employees e # exists 사용
where exists ( select 'x' from departments where manager_id = e.employee_id);

explain
select * from employees e # in 사용
where employee_id in ( select manager_id from departments);