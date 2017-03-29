# MySQL 쿼리 튜닝 최적화

**Day 1**

## MySQL 개요

### MySQL 개요
- 오픈소스 DBMS, 1995.03 첫 버전 발표
- [LAMP](https://ko.wikipedia.org/wiki/LAMP) 의 중심 요소
<br>

### MySQL 특징
- 대용량 DB에 사용가능(테이블 기본 값은 `256TB`)
- 하나의 테이블에 `64`개의 index 설정 가능. 
- 하나의 index에 `16`개의 칼럼 지정가능
<br>

### MySQL Architecture
![@MySQL Architecture | 500x0](http://cfs10.tistory.com/image/20/tistory/2009/02/18/18/21/499bd3254afb6)
<br>

#### 서버 엔진
- SQL interface, Parser, Optimizer, Cache & Buffer 로 구성
- 쿼리 재구성, 데이터 처리
- 스토리지 엔진에 데이터 요청
- Join, Group by, Order by 처리
- 함수, 트리거, 프로시저 처리
<br>

#### 스토리지 엔진
```sql
show engines;
```

| Engine | Support | Comment | Transactions | XA | Savepoints |
|--------------------|---------|----------------------------------------------------------------|--------------|------|------------|
| InnoDB | DEFAULT | Supports transactions, row-level locking, and foreign keys | YES | YES | YES |
| MRG_MYISAM | YES | Collection of identical MyISAM tables | NO | NO | NO |
| MEMORY | YES | Hash based, stored in memory, useful for temporary tables | NO | NO | NO |
| BLACKHOLE | YES | /dev/null storage engine (anything you write to it disappears) | NO | NO | NO |
| MyISAM | YES | MyISAM storage engine | NO | NO | NO |
| CSV | YES | CSV storage engine | NO | NO | NO |
| ARCHIVE | YES | Archive storage engine | NO | NO | NO |
| PERFORMANCE_SCHEMA | YES | Performance Schema | NO | NO | NO |
| FEDERATED | NO | Federated MySQL storage engine | NULL | NULL | NULL |
<br>

##### 스토리지 엔진별 특징
- **MyISAM** 
	- File 기반
	- 디스크에 직접 접근, 메모리에 저장하지 않는다.
	- 트랜잭션 X, 테이블 단위 Lock
- **InnoDB**
	- 트랜잭션 O
	- 행단위 Lock
	- 데이터와 인덱스를 메모리에 저장
		- InnoDB_buffer_pool_size 크기가 성능에 영향
- **archive**
	- index X
	- 데이터 압축 저장
<br>

### 강의 내용 

#### 스키마 생성
`hr-schema-mysql.sql` 의 내용을 실행해서 새로운 `hr` 스키마 생성 (복사 후 쿼리 실행)
<br>

#### ERD 만들기
Menu - Database - Reverse Enginner(Ctrl + R) - `hr` 선택
<br>

## MySQL 성능 향상, 쿼리 최적화, 실행 계획

### 성능 향상

#### DB 성능은 I/O 작업에 가장 영향을 많이 받는다.

#### DB 성능
- 애플리케이션 로직
- 테이터 모델링, 테이블 구조
- **쿼리 튜닝**
- 하드웨어 성능 튜닝
- 서버 환경 튜닝
<br>

### SW 레벨
- 테이블의 구조
	- 칼럼의 타입이 적절한지 살펴봐야 한다.
- 인덱스
	- 적절한 칼럼에 인덱스가 정해져 있는지 확인
- 스토리지 엔진 선택
- Lock 전략
- 메모리 캐시량
	- 캐시 메모리의 사이즈가 적절한지 확인 
<br>

### HW 레벨
- 디스크 검색 시간
- 디스크 I/O 속도
- CPU 사이클
<br>

### 쿼리 최적화
- DBMS에서 쿼리가 실행되는 구조를 알아야 함
- 로그 분석을 통해 `느린 쿼리를 찾는 방법`을 알아야 함
- 프로파일링
- **쿼리문 최적화 방법**
	- 실제 쿼리문 실행 후 결과 확인
	- 프로파일링
		- ```select @@profilinig;```
	- 실행 계획 분석 explain
<br>

### 프로파일링
- 현재  세션에서 퀴리가 실행될 때 리소스 사용량 확인
- 프로파일 환경 변수 설정
	- ```set profiling = 1;```
	- 디폴트 `0`, `1`로 설정하면 쿼리 실행 로그가 기록 됨
- 프로파일 목록 보기
	- ```show profile;```
	- ```show profiles;```
	- ```show profile for query 4;```
<br>

### 실행 계획
- 쿼리 실행 과정에서 어떠한 작업의 조합으로 쿼리가 실행되는 지 알려줌
- 반드시 실행 계획에 따라 수행되지는 않는다.
- 쿼리문 앞에 ```explain```을 붙인다
- 5.7 버전부터 `SELECT` 이외 쿼리도 가능

#### 실행 계획 상세 p25

<br>

### 강의 내용 
./day1.sql

<br>

```powershell
# 현재 폴더의 sql 파일을 모두 합쳐 all.sql로 만듬
copy *.sql all.sql
```
```powershell
# all.sql 을 myhr 스키마에 넣으면서 DB 접속
# 사전에 myhr 이라는 스키마가 있어야 함
# worckbench Navigator 에서 오른쪽 클릭으로 생성
mysql -u root -p myhr < all.sql
```
./myhr.sql

### 실습
#### 문제
hr 스키마를 이용하여 `Seattle` 에 근무하는 사원들의 성, 이름, 부서명, 급여, 입사일을 출력하고 실행계획을 설명.
<br>

#### 결과 SQL
```sql
select e.last_name, e.first_name, d.department_name, e.salary, e.hire_date
from departments d
join locations l using(location_id)
join employees e using(department_id)
where l.city = 'Seattle';
```
#### 실행 계획
![@기존 실행 계획 | day1-work1-explain](https://cloud.githubusercontent.com/assets/9030565/24394715/0779e696-13d8-11e7-9857-7354d9099750.PNG)

- table `l`에 type 이 `ALL` 인 이유는 ```where l.city = 'Seattle'``` 쿼리에 `city` 칼럼이 PK, index 모두 아니기 때문에 Full scan 했기 때문이다.
- table `d`, `e` 는 type 이 `ref` 인 이유는 join 의 칼럼이 PK, index, unique 중 하나였기 때문이다.
- Full scan을 방지하려면 locations `city` 칼럼을 index에 추가한다.
<br>

#### locations 에 index 생성
```sql
create index location_city_idx on locations(city);
```
<br>

#### index 생성 후 실행 계획
![@수정 실행 계획 | day1-work1-explain index](https://cloud.githubusercontent.com/assets/9030565/24394734/194622ea-13d8-11e7-8250-0bc27e700dda.PNG)
<br>

## Index 이해와 적용 

### Index 개요
#### 기본 개념
- SELECT 성능 향상을 위해 생성된 별도 데이터
- Table 과는 별도로 존재
- CUD 시 index도 변경
#### 장점
- SELECT 빠름
- 정렬 빠름
#### 단점
- Table 이외의 저장공간 필요
- 데이터 변경시 index 도 변경되서 overhead 
<br>

### Index 종류
#### 알고리즘 분류
- **B-Tree**
- R-Tree
- Hash Index
- Full-Text Index
#### 칼럼 분류
- 단일 컬럼 Index
- 복합 컬럼 Index
- 부분 Index
- 커버링 Index
<br>

### B-Tree
- Root, Branch, Leaf 로 구성
- 어떠한 데이터도 일정한 시간이 소요
- 데이터 변경 시 재구성 필요
<br>

### MySQL Index
- `PK`, `Unique`, `Key` 로 구분
- `InnoDB` 에선 PK 에 따라 클러스터화 됨
- 보조 Index 는 내부적으로 PK 를 포함하여 생성
	- index(email) 은 index(email, id) 와 같다.
	- **PK 로 지정되는 칼럼의 길이가 길어지는 것을 지양할 것**
<br>

**Day 2**

### MySQL Index - InnoDB 스토리지 Index
- InnoDB는 `Clustered Index` 와 `Secondary Index` 가 있다.
- **Clustered Index**
	- PK 시 자동으로 Clustered 생성
	- 데이터가 순서대로 정렬
	- 테이블 당 하나의 Clustered Index
	- Unique, Not null 조건 부여시 Clustered Index 생성, PK가 있으면 Clustered Index는 생성되지 않는다. (테이블 다 하나이기 때문)
	- 검색 속도 빠름. 입력, 수정, 삭제 느림
- **Secondary Index**
	- 입력, 수정, 삭제 빠름 
	- 검색은 Clustered 에 비해 느림
	- 테이블에 여러개 생성 가능
< br>

### Index 명령어
#### 생성
- PK 지정시 index 자동 생성
- FK 지정시 index 자동 생성
```sql
CREAE [UNIQUE | FULLTEXT | SPATIAL] INDEX index_name
[index_type]
ON table_name(column_names)
[index_option]
[algorithm_option | lock_option]
```
<br>

#### 조희
```sql
show indexes from table_name;

# 통계 정보
select * from information_schema.STATISTICS where table_name = 'employees';
```
<br>

#### 삭제
- index는 **수정 불가**
- 수정하려면 삭제 후 다시 생성
- **Index를 삭제해야 하는 경우**
	- 대용량 데이터를 넣는 경우
		- 데이터 insert 마다 index를 update 해야하기 때문에 일단 지우고 데이터 넣고 index를 다시 생성한다.
	- 사용하지 않는 index 있는 경우
```sql
drop index index_name on table_name;
# or
alter table table_name drop index index_name;
```
<br>

### Index 종류
#### 단일 컬럼 Index
- Unique Index, = 검색
```sql
explain
select last_name, first_name, salary, hire_date 
from employees where employee_id = 100;
```

- Unique Index, 범위
```sql
explain
select last_name, first_name, salary, hire_date 
from employees where employee_id >= 100;
```

- Non-Unique Index, = 검색
```sql
explain
select last_name, first_name, salary, hire_date 
from employees where salary = 8000;
```

- Non-Unique Index, 범위
```sql
explain
select last_name, first_name, salary, hire_date 
from employees where salary between 8000 and 9000;
```

- OR & IN 조건
```sql
explain
select last_name, first_name, salary, hire_date 
from employees where employee_id in (100, 200);
```
<br>

#### 복합 컬럼 Index
```sql
alter table employees add index(last_name, first_name);

explain
select last_name, first_name, salary, hire_date 
from employees where last_name like 'K%';
```
<br>

#### 커버링 Index
- Index 만으로 데이터를 조회. 테이블에 저장된 데이터를 조회하지 않는다.
- 실행 계획  type 이 `index`
<br>

#### Prefix Index
- 컬럼의 일부분으로 index 생성

##### 특징
- index크기 줄임
- 커버링 index 사용 불가
- BLOB / TEXT 타입 컬럼 적용
- **적절한 길이 필요**
	- `Selectivity`(선택도) 로 길이 판단
```sql
alter table emp add index(last_name(4));
```

##### 자동 생성 칼럼 (v5.7 이상)
MySQL에는 Oracle의 Function based index 는 없으나, **자동 생성 칼럼**을 이용해 이와 비슷한 효과를 낼 수 있다.
``` sql
create table some_table(
	id varchar(10),
	sub_id varchar(8) as (substring(id, 1, 8)),
	index(sub_id)
);

insert some_table(id) values('sub_id_001');

select * from some_table;
```
<br>

### Index 힌트
- **use index**
	- Index 사용
	- ```... from employee use index(name_idx) ...```
- **ignore index**
	- Index 사용 X
	- - ```... from employee ignore index(name_idx) ...```
- **force index**
	- index 강제 사용
	- - ```... from employee force index(name_idx) ...```
<br>

### Index 사용불가 Case
1. `not` 연산자
2. `is not null` 연산자
3. 컬럼을 변형하여 비교
```sql
# salary 에는 index가 있지만, * 12 때문에 컬럼 변형됨
explain
select * from employees where salary*12 >= 120000;

# 해결책 - 컬럼 변형 X, 조건식을 변형!
explain
select * from employees where salary >= (120000/12);
```
4. 칼럼 타입이 자동 변형되는 경우
```sql
create table my_internal(
	t_no varchar(10) primary key, # PK를 varchar로 
    t_name varchar(20)
);

insert into my_internal(t_no, t_name) values(1234, 'hong'); # 자동 형변환

explain select * from my_internal where t_no = 1234; # type: All, index 사용 X, 성능 이슈 야기

explain select * from my_internal where t_no = '1234'; # type: const
```
5. 복합 칼럼에서 AND, OR 에 따라
```sql
# index 사용 O
explain
select * from employees where last_name = 'King' and first_name = 'Steven'; 
explain

# index 사용 X
select * from employees where last_name = 'King' or first_name = 'Steven'; 
```
<br>

### 실습
#### 문제
`t_emp` 테이블 생성 **id: int, name: varchar(200), hire_date: varchar(8)**
`employees` 테이블의 데이터를 `t_emp` 에 삽입
`t_emp` hire_date index 생성
`t_emp` 에서 hire_date 가 `19930113`, `'1993013'` 으로 각각 조회하고 실행계획 확인
#### 결과
- t_emp 테이블 생성
```sql
create table t_emp(
	id int,
    name varchar(200),
    hire_date varchar(8)
);
```

- t_emp 에 employees 데이터 삽입
```sql
insert into t_emp(id, name, hire_date) 
select employee_id as id, concat(first_name, ', ', last_name) as name, replace(hire_date,'-','')  from employees;
```

- hire_date index 생성
```sql
create index hire_date_idx on t_emp(hire_date);
```

- 실행계획
```sql
explain
select id, name, hire_date from t_emp where hire_date = 19930113;
```
![@19930113 으로 조회시 type ALL | day2-work1-explain int](https://cloud.githubusercontent.com/assets/9030565/24438270/253c59bc-1481-11e7-9b03-77ea5f4065c0.PNG)

---

```sql
explain
select id, name, hire_date from t_emp where hire_date = '19930113';
```
![@'19930113' 으로 조회시 type ref | day2-work1-explain varchar](https://cloud.githubusercontent.com/assets/9030565/24438294/570b3652-1481-11e7-886c-9ad68f53cd03.PNG)
<br>

### Index 설계
#### Index 생성 적절한 경우
- 전체 테이블의 10 ~15% 조회되는 경우
- Index로만 조회시. 커버링 index
- Join 시 연결되는 칼럼인 경우
	- MySQL은 nested join 이기 때문에 연결 칼럼의 index 는 필수적

#### Index 생성 적절하지 않은 경우
- 단순 저장용 table
- Full scan 경우
- CUD 의 비율이 R 보다 현저히 높은 경우
- 

#### Selectivity(선택도)
컬럼 내부의 저장되 데이터 값들의 종류와 전체 값의 비율

#### 고려사항
- select 시 where, group by, order by 에 쓰는 컬럼 위주로 선택
- 선택도
- 길이가 짧은 컬럼

#### 통계 정보
- Index의 통계정보를 update할 필요가 있다.
- optimize table_name 명령어 사용
	- 테이블 데이터와 index 를 재구조화
	- 저장 공간 줄이고 I / O 효율 증가
```sql
optimize table employee;
```
- optimize 하는 경우
	- 대용량 데이터를 CUD 한 경우
	- FULLTEXT index를 CUD 한 경우
