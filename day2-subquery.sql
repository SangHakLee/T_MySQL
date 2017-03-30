# steven king 이 근무하는 부서원 정보 출력alter
use hr;
select department_id from employees where last_name = 'King' and first_name = 'Steven';
select * from employees where department_id = 90;

explain
select * from employees where department_id = (
	select department_id from employees where last_name = 'King' and first_name = 'Steven'
)