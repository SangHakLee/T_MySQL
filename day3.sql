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






# 행 lock
create table my_inno_t(
	id int auto_increment primary key,
    name varchar(10)
);

insert into my_inno_t(name) values('a');
insert into my_inno_t(name) values('b');
insert into my_inno_t(name) values('c');

select * from my_inno_t;

update my_inno_t set name = sleep(200) where id = 1; # 200초 걸림



select @@autocommit;



begin;
update my_inno_t set name='abc1' where id=1;
select * from my_inno_t;
commit;


begin;
insert into my_inno_t(name) values('444444444d');
select * from my_inno_t;




#설정 정보 확인
show status;
show global status;
show session status;
show status like 'Key%';
show engine innodb status;


select @@innodb_buffer_pool_size/1024/1024;



SELECT 
	CEILING(Total_InnoDB_Bytes*1.6/POWER(1024,3)) AS RIBPS 
FROM
(
	SELECT SUM(data_length+index_length) Total_InnoDB_Bytes
	FROM information_schema.tables WHERE engine='InnoDB'
) AS T;



# 로그
select @@general_log;
set global general_log=1;
select @@general_log;



##checksum table
create table my_emp
select * from employees;

select * from my_emp;

checksum table employees, my_emp;



# range 파티션
create table my_member(
	first_name varchar(25) not null,
    last_name varchar(25) not null,
    email varchar(25) not null,
    joined_date date
)
partition by range columns(joined_date) (
	partition lessthan1990 values less than('1990-12-31'),
    partition p2000 values less than('2000-12-31'),
    partition p2020 values less than maxvalue
);

show table status where name='my_member';

select * from information_schema.PARTITIONS where table_name = 'my_member';



# 실슬
use myhr;

create table partitioned_emp_salary
select * from emp_salary; # 2844047 개

select from_date from partitioned_emp_salary order by from_date;
select DATE_FORMAT(from_date,'%Y-%m') m from partitioned_emp_salary group by m; # 월별 분류 시 212 개
select DATE_FORMAT(from_date,'%Y') y from partitioned_emp_salary group by y; # 년별 분류 시 18 개
select count(*), DATE_FORMAT(from_date,'%Y') y from partitioned_emp_salary group by y; # 년별 분류 시 각 행 수

select min(from_date) from partitioned_emp_salary; # 1985-01-01
select max(from_date) from partitioned_emp_salary; # 2002-08-01

# 1년 단위 
alter table partitioned_emp_salary partition by range(YEAR(from_date)) (
	partition p1985 values less than(1985),
    partition p1986 values less than(1986),
    partition p1987 values less than(1987),
	partition p1988 values less than(1988),
    partition p1989 values less than(1989),
    partition p1990 values less than(1990),
    partition p1991 values less than(1991),
    partition p1992 values less than(1992),
    partition p1993 values less than(1993),
    partition p1994 values less than(1994),
    partition p1995 values less than(1995),
    partition p1996 values less than(1996),
    partition p1997 values less than(1997),
    partition p1998 values less than(1998),
    partition p1999 values less than(1999),
    partition p2000 values less than(2000),
    partition p2001 values less than(2001),
    partition p2002 values less than(2002),
    partition pmax values less than maxvalue
);

select PARTITION_NAME, PARTITION_ORDINAL_POSITION, PARTITION_DESCRIPTION, TABLE_ROWS, AVG_ROW_LENGTH, DATA_LENGTH
from information_schema.PARTITIONS where table_name = 'partitioned_emp_salary'; #파티션 주요 현황

analyze table partitioned_emp_salary; # 통계 정보

checksum table emp_salary, partitioned_emp_salary; # 체크 섬




# SQL 활용 limit
use myhr;
select * from employee limit 100000, 15;


# 부서별 월별 평균 급여 출력
use hr;
select department_id, employee_id, month(hire_date)
from employees;

select department_id, 
	avg( if( month(hire_date)=1, salary, null) ) m01, 
    avg( if( month(hire_date)=2, salary, null) ) m02,
    avg( if( month(hire_date)=3, salary, null) ) m03,
    avg( if( month(hire_date)=4, salary, null) ) m04,
    avg( if( month(hire_date)=5, salary, null) ) m05,
    avg( if( month(hire_date)=6, salary, null) ) m06,
    avg( if( month(hire_date)=7, salary, null) ) m07,
    avg( if( month(hire_date)=8, salary, null) ) m08,
    avg( if( month(hire_date)=9, salary, null) ) m09,
    avg( if( month(hire_date)=10, salary, null) ) m10,
    avg( if( month(hire_date)=11, salary, null) ) m11,
    avg( if( month(hire_date)=12, salary, null) ) m12
from employees
where department_id is not null
group by department_id
order by department_id;
    


# 사원의 급여 등급별 인원 수
select 
	case 
		when salary <= 4000 then '초급'
		when salary <= 7000 then '중급'
        when salary <= 10000 then '고급'
        else '특급'
    end sal_grade,
    count(*) 인원수
from employees
group by
	case 
		when salary <= 4000 then '초급'
		when salary <= 7000 then '중급'
        when salary <= 10000 then '고급'
        else '특급'
    end
order by
	case 
		when salary <= 4000 then 1
		when salary <= 7000 then 2
        when salary <= 10000 then 3
        else 4
    end
;