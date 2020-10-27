----------------ch12-------------
-- 把若干行直接合成一行（列转行）
select  
				sum(case when deptno=10 then 1 else 0 end) as deptno_10,	-- 直接统计出现的次数
				sum(case when deptno=20 then 1 else 0 end) as deptno_20,
				sum(case when deptno=30 then 1 else 0 end) as deptno_30
from emp;
group by deptno;
-------把结果集转化为多行

select max(case when job='CLERK' then ename else null end) as clerk,
				max(case when job='ANALYST' then ename else null end) as analyst,
				max(case when job='MANAGER' then ename else null end) as manager,
				max(case when job='PRESIDENT' then ename else null end) as president,
				max(case when job='SALESMAN'then ename else null end) as salesman
from (
			select e.job,e.name,
			(SELECT count(*) from d		-- 每个部门内部，给各自员工编号
				WHERE e.job = d.job and e.empo < d. empo)
			from emp e ) x
group by rnk;

-----------  行变列------------


--- 窗口函数---------
-- over() 标识聚合函数为窗口操作 括号内为空表示执行对象为全体记录
-- 会直接返回结果到一个新列中
SELECT ename, deptno, count(*) over() as cnt
from emp
ORDER BY 2;

----partition by----------
--partition by 用在括号内，表示over所覆盖的范围分区
SELECT ename, deptno, count(*) over(partition by deptno) as cnt
from emp
ORDER BY 2;

----- 同一个select中也能用partition按不同的列分区
SELECT ename, deptno, count(*) over(partition by deptno) as dept_cnt,
			job, "count"(*) over(partition by job) as job_cnt
from emp
ORDER BY 2;

------------over中排序----------
select deptno, ename, hiredate, sal,
				sum(sal)over(partition by deptno) as total1,
				sum(sal)over() as total2, 
				sum(sal)over(order by hiredate
										range between unbounded preceding and current row)		-- framing子句
											as running_total
from emp
where deptno = 10 or deptno = 20;

---综合使用
-- 为数据增添一个索引列，按sal排序，从1开始
SELECT deptno, ename, sal, "row_number"() over(ORDER BY sal asc) as idx
from emp;

-- 分部门为数据增添一个索引列，每个部门内按sal排序，从1开始
SELECT deptno, ename, sal, "row_number"() over(partition by deptno ORDER BY sal desc) as idx
from emp;

-- sal相同的要idx需要并列第几
-- rank()
SELECT deptno, ename, sal, rank() over(partition by deptno ORDER BY sal desc) as idx
from emp;
-- 需要两个并列第一下，第三个idx为2而不是3
-- 用dense_rank()

-- 如果select中窗口函数太多太乱 窗口函数的定义还可写在where后面, orderby前面
select deptno, ename, hiredate, sal,
				sum(sal)over w1 as total1,
				sum(sal)over() as total2, 
				sum(sal)over w2 as running_total
from emp
where deptno = 10 or deptno = 20
WINDOW
	w1 as (partition by deptno),
	w2 as (order by hiredate range between unbounded preceding and current row);

