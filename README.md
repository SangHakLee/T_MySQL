# MySQL 쿼리 튜닝 최적화

# Day 1

## MySQL 개요
### MySQL 개요
- 오픈소스 DBMS, 1995.03 첫 버전 발표
- [LAMP](https://ko.wikipedia.org/wiki/LAMP) 의 중심 요소

### MySQL 특징
- 대용량 DB에 사용가능(테이블 기본 값은 `256TB`)
- 하나의 테이블에 `64`개의 index 설정 가능. 
- 하나의 index에 `16`개의 칼럼 지정가능

### MySQL Architecture
![@MySQL Architecture | 500x0](http://cfs10.tistory.com/image/20/tistory/2009/02/18/18/21/499bd3254afb6)

#### 서버 엔진
- SQL interface, Parser, Optimizer, Cache & Buffer 로 구성
- 쿼리 재구성, 데이터 처리
- 스토리지 엔진에 데이터 요청
- Join, Group by, Order by 처리
- 함수, 트리거, 프로시저 처리

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

#### SW 레벨
- 테이블의 구조
	- 칼럼의 타입이 적절한지 살펴봐야 한다.
- 인덱스
	- 적절한 칼럼에 인덱스가 정해져 있는지 확인
- 스토리지 엔진 선택
- Lock 전략
- 메모리 캐시량
	- 캐시 메모리의 사이즈가 적절한지 확인 

#### HW 레벨
- 디스크 검색 시간
- 디스크 I/O 속도
- CPU 사이클

#### 쿼리 최적화
- DBMS에서 쿼리가 실행되는 구조를 알아야 함
- 로그 분석을 통해 `느린 쿼리를 찾는 방법`을 알아야 함
- 프로파일링
- **쿼리문 최적화 방법**
	- 실제 쿼리문 실행 후 결과 확인
	- 프로파일링
		- ```select @@profilinig;```
	- 실행 계획 분석 explain

#### 프로파일링
- 현재  세션에서 퀴리가 실행될 때 리소스 사용량 확인
- 프로파일 환경 변수 설정
	- ```set profiling = 1;```
	- 디폴트 `0`, `1`로 설정하면 쿼리 실행 로그가 기록 됨
- 프로파일 목록 보기
	- ```show profile;```
	- ```show profiles;```
	- ```show profile for query 4;```

#### 실행 계획
- 쿼리 실행 과정에서 어떠한 작업의 조합으로 쿼리가 실행되는 지 알려줌
- 반드시 실행 계획에 따라 수행되지는 않는다.
- 쿼리문 앞에 ```explain```을 붙인다
- 5.7 버전부터 `SELECT` 이외 쿼리도 가능

##### 실행 계획 상세 p25

### 강의 내용 
./day1.sql


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

