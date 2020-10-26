-------------------------------------------------------
SELECT * FROM "emp";

CREATE VIEW V
as
SELECT ename || ' ' || deptno as data
from emp;

SELECT * FROM V;

-- 按照deptno 排序
SELECT data from V
ORDER BY "replace"(data, "r   eplace"(
"translate"("data",'0123456789', '##########'), '#', ''), '');

SELECT data, 
		"replace"(data, 
		"replace"(
		"translate"("data", '0123456789', '##########'), '#', ''), '') nums,
		"replace"(
		"translate"("data", '0123456789', '##########'), '#', '') chars
	FROM V

----------------------------------------------------------------------

SELECT ename, sal, comm from emp
ORDER BY 3 DESC;

SELECT ename, sal, comm, x
FROM(
	SELECT ename, sal, comm,
	CASE WHEN comm is null THEN 0
	ELSE 1 
END is_null from emp
)x
ORDER BY is_null, comm DESC;

SELECT ename, sal, job, comm
from emp
order by CASE WHEN job = 'SALESMAN' THEN
		comm
	ELSE
		sal
END;
--------------------------------------------------------

SELECT ename as ename_and_dname, dept.deptno
from emp, dept
WHERE dept.deptno  =10
UNIon all
SELECT '--------------', null
from t1
UNION all
SELECT dname, deptno
from dept;
 19198
-------------------------------
SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno = d.deptno and e.deptno = 10;

------------------------
CREATE view V_33 as
SELECT ename, job, sal from emp
WHERE job = 'CLERK';

SELECT * from V_33;

---------------------------

SELECT * from "EMP_BONUS";

SELECT e.empno, e.ename, e.sal, (eb."TYPE"  * e.sal / 10) as bonus
from emp e, "EMP_BONUS" eb
WHERE e.empno = eb."EMPNO" and e.deptno = 10;
------
CREATE view v_39_bonus as
SELECT e.empno, e.ename, e.sal, (eb."TYPE"  * e.sal / 10) as bonus
from emp e, "EMP_BONUS" eb
WHERE e.empno = eb."EMPNO" and e.deptno = 10;

SELECT sum(v_39_bonus.bonus) as total_bonus, sum(distinct v_39_bonus.sal) as total_sal
from v_39_bonus;
-------------------
SELECT sum(DISTINCT sal) as tt_sal, sum(bonus) as tt_bs from(
SELECT e.empno, e.ename, e.sal, (eb."TYPE"  * e.sal / 10) as bonus
from emp e left outer join "EMP_BONUS" eb
on e.empno = eb."EMPNO" where e.deptno = 10
)x;

------------------------------
SELECT * from dept d join emp e on d.deptno = e.deptno;