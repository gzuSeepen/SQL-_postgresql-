
---某列的累计求和--------------
SELECT e.ename, e.sal, 
		(SELECT sum(d.sal) from emp d
			WHERE d.empno <= e.empno) as running_total  -- 每次都从头求和
	from emp e
	ORDER BY 3;
	
	--------计算众数----------------
	-- 聚合函数不能在where里, 不能嵌套
	
		SELECT sal, "count"(*) as freq
		from emp
		WHERE deptno = 20
		GROUP BY sal 
		having "count"(*) >= all(		-- 用max一直报错 只能重复一遍计数代码
				SELECT "count"(*)
				from emp
				WHERE deptno = 20
				GROUP BY sal );

-------------- 计算中位数-------------
SELECT sal, id, "count"(sal) as num
from emp, t100
WHERE deptno=20 and id = num/2
ORDER BY sal;

-- within gruop(col) fillter ()
-- "percentile_cont"(n) 
SELECT "percentile_cont"(0.5) WITHIN GROUP(ORDER BY sal)
as var_median
from emp;

--------提取字符串中数字---------
-- cast用法：cast(sth as integer);  as及类型是在cast()中
SELECT cast(
replace(
"translate"('asdf123gjs456sd', 'qwertyuioplkjhgfdsazxcvbnm', rpad('#', 26, '#')
), '#', '') as INTEGER) num
from t1;

------------修改累计值-----------
CREATE or replace view V715 (id,amt,trx) as
select 1, 100, 'PR' from t1 union all
select 2, 100, 'PR' from t1 union all
select 3, 50, 'PY' from t1 union all
select 4, 100, 'PR' from t1 union all
select 5, 200, 'PY' from t1 union all
select 6, 50, 'PY' from t1;
-- trx - 交易类型，amt - 金额
-- PR - 存钱， PY - 花钱
select * from V715;

-- 一般如果要用到累计，要能想到在同一个表的自联结操作
-- case when 的用法
SELECT case when v1.trx = 'PY' 
						then 'Payment' else 'Purchase'
						end as trx_type,
				v1.amt,
				(SELECT sum(case when v2.trx = 'PY'
										then -v2.amt else v2.amt end)  -- 控制加减
					from V715 as v2
					WHERE v2.id <= v1.id) as balance -- 在此操作时累计计算
from V715 v1;

--------ch 8-日期---------------
-------为某一日期加减n个单位日期------------
-- 使用关键字 interval 后面指定时间单位 
SELECT hiredate - interval '5 day' as hd_minus_5d,
				hiredate + interval '5 day' as hd_plus_5d,
				hiredate - interval '5 month' as hd_minus_5m,
				hiredate + interval '5 month' as hd_plus_5m,
				hiredate - interval '5 year' as hd_minus_5y,
				hiredate + interval '5 year' as hd_plus_5y
from emp
WHERE deptno = 10;

---- 两个日期相减，算天数---
-- 找出这两个日期，直接减 - 就好
select (ward_hd - allen_hd) as diff_days
from (
		select hiredate as ward_hd 
		from emp
		where ename = 'WARD' 
) x,
		(select hiredate as allen_hd 
			from emp
			where ename = 'ALLEN' 
			
) y;

---------计算两天间的工作日-----
--思想：使用数据透视表（其实就是一个只有单列1-n为id的表），
-- 使之间每一天单独一行，计算有多少个非周末日期
-- 如果需要排除节假日，搞一个holiday表，用not in再筛
-- 函数 to_char(str, 'DAY'): 返回这天是周几

SELECT sum(CASE WHEN trim(to_char(jones_hd+t100.id-1, 'DAY')) in ('Saturday', 'Sunday') 
						THEN 0 ELSE 1		-- 计数
				END) as days
from(
		select max(case when ename = 'BLAKE'
							then hiredate 
							end) as blake_hd,
					max(case when ename = 'JONES' 
							then hiredate
							end) as jones_hd 
			from emp
			where ename in ( 'BLAKE','JONES' )
		) x, t100
where t100.id <= blake_hd-jones_hd + 1;

SELECT jones_hd+t100.id-1  --jones是日期起点，累加id 
from(
		select max(case when ename = 'BLAKE'
							then hiredate
							end) as blake_hd,
					max(case when ename = 'JONES' 
							then hiredate
							end) as jones_hd 
			from emp
			where ename in ( 'BLAKE','JONES' )
		) x, t100
where t100.id <= blake_hd-jones_hd + 1;	--一直到日起终点 black
--------提取年月日-------------------
-- extract(year/month/day from x_date): 从x_date中提取年月日
SELECT max_hd, EXTRACT(day from max_hd)
from (SELECT max(hiredate) max_hd from emp) x;

-------计算相差的时分秒----
-- 思想：算出差几天dy，然后。。时：24*dy, min: 24*60*dy, sec: 24*60*60*dy

----------ch 9-----------
---------检查闰年-----------
-- 判断二月最后一天是不是29号
-- generate_series(a, b): 生成从 a+1 到 b 的29行数字
-- date_trunc(text, timestamptz): 找到当前年份第一天
select tmp2.dy + x.id as dy, tmp2.mth 
from (
		select dy, to_char(dy,'MM') as mth 
		from (
				select cast(cast(
									date_trunc('year',current_date) as date) + interval '1 month' as date) as dy
				from t1 ) tmp1
			) tmp2, generate_series (0,29) x(id)	-- 为2月生成1-29号
where to_char(tmp2.dy+x.id,'MM') = tmp2.mth;
	
-------------从一个日期值提取各种时间单位-------------
select 
	to_number(to_char(current_timestamp,'hh24'),'99') as hr, 
	to_number(to_char(current_timestamp,'mi'),'99') as min,
	to_number(to_char(current_timestamp,'ss'),'99') as sec,
	to_number(to_char(current_timestamp,'dd'),'99') as day,
	to_number(to_char(current_timestamp,'mm'),'99') as mth,
	to_number(to_char(current_timestamp,'yyyy'),'9999') as yr
from t1;

---------------

	
	