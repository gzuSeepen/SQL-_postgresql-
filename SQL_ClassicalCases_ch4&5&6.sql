SELECT ename from emp
WHERE ename like '[MJ]%';
-----------ch 4---------------
CREATE TABLE dept_eastas SELECT * from dept
WHERE 1=0;
CREATE TABLE dept_mid
as SELECT * from dept
WHERE 1=0;
CREATE TABLE dept_west
as SELECT * from dept
WHERE 1=0;

INSERT into dept_east 
SELECT * from dept
WHERE loc in ('NEW YORK', 'BOSTON');

SELECT * from dept_east;

------------------pg 多表插入 (?) --------------
SELECT *, case WHEN loc in ('NEW YORK', 'BOSTON') THEN
		INSERT into dept_east VALUES *
ELSE when loc in ('DALLAS') THEN
		INSERT into dept_mid
ELSE INSERT into dept_west
END x from dept;

INSERT into dept_east ;

----------------------------

SELECT deptno, ename, sal from emp
WHERE deptno = 20 ORDER BY 1,3;

UPDATE emp set sal = sal *1.1
WHERE deptno = 20;
----------------------

SELECT eb.empno, e.ename, e.sal
from "EMP_BONUS" as eb, emp as e;

UPDATE emp set sal = sal * 1.2
WHERE empno in (SELECT empno from "EMP_BONUS");
--------------------
----------------合并记录 (?) ------------
-----

---------------ch 5------------
-- # 记住一个information_schema,里面查询各种table，collumns

SELECT TABLE_NAME from information_schema.tables
WHERE table_schema = 'public';

SELECT 'SELECT count(*) from '||table_name||';' cnts
from emp;

----------ch 6----------------

-------1. 遍历字符串------------
-- 按照一个字符一行的形式输出字符串
-- substr(str, m, n): 提取str从m位置开始的n个字符
SELECT substr(e.ename, iter.pos, "length"(e.ename)-iter.pos+1) as a,
				substr(e.ename, iter.pos) as a_mdf,
				substr(e.ename, length(e.ename)-iter.pos+1, iter.pos) as b,
				substr(e.ename, length(e.ename)-iter.pos+1) as b_mdf
from(SELECT ename from emp WHERE ename = 'KING') e,
		(SELECT id pos from t10) iter
WHERE iter.pos <= "length"(ename);

-----------2. 嵌入引号-----------------
-- 当你想插入一个引号时，得在字符串里写两个引号表示字符串的这个位置有一个引号
SELECT 'g''day mate' from t1 UNION all
SELECT 'beavers'' teech' from t1 UNIon all
SELECT '''' from t1 ;

---------3. 统计逗号出现次数 ------
-- 思路：统计length，减去去掉逗号后的length，如果所统计的字符长度不为1，还要除其长度再减
-- "replace"(str, text0, text1) 把 str 中的 text0 全替换为 text1
SELECT("length"('10,clar,k,manager') - "length"("replace"('10,clark,manager', ',', '')) / "length"(',')) cnt
from t1;

-------4. 删除不想要的字符--------------
-- 为删除多个不同的字符，可使用translate将这些字符替换为同一个字符a，再全部replace掉
SELECT ename, 
				"replace"("translate"(ename, 'aeiou', 'aaaaa'), 'a', '') as ename_1,
				sal, 
				"replace"(sal, 0, '') as sal_1
from emp;

-----------5. 分离数字&字母----------------
-- 同样，利用translate & replace 将所有数字转换为一个数字，而后分离
-- 类型转换。 eg. 将sth转换为整数： cast (sth) as integer 
-- 填充字符。rpad(str1, n, str2): 用str2 将 str1 填充到 n 位


SELECT dn, 
			"replace"("translate"(dn, '0123456789', '0000000000'), '0', '') as ename,
			cast ("replace"(translate(lower(dn), 'poiuytrewqasdfghjklmnbvcxz', rpad('z', 26, 'z')), 'z', '') as INTEGER) as sal
from (
		SELECT ename || sal as dn from emp) x ;

-----------c从字符串中提取出大写字母---------------
 -- 得到姓名缩写
SELECT "replace"(
				"replace"(
				"translate"(
				"replace"('Vincent Van Gogh', '.', ''),
				'qwertyuioplkjhgfdsazxcvbnm', '0'),
				'0', ''),
				' ', '.') || '.'
from t1;

------------按照子字符串排序----------------
-- 用substr选
SELECT ename from emp
ORDER BY substr(ename, "length"(ename)-1, 2);

----------按字符串里的数字排序----------
create view V69 as
	select e.ename ||' '||
		cast(e.empno as char(4))||' '|| d.dname as data
		from emp e, dept d
		where e.deptno = d.deptno;

select data from V69
order by
	cast(
	replace(			-- 3.然后将串中所有非数字删了
	translate(data,		-- 2.再次把data引入，
	replace(		-- 1.先把所有数字删了，剩下所有 非数字字符
	translate(data,'0123456789','##########'),'#',''), rpad('#',20,'#')),'#','') as integer);
	
	-------------------将竖排表 按相同列 变成分隔列表---------------
	-- 思路是使用gruop by，但需要提前知道最大列的长度，因为要手动附加项
select deptno,
rtrim(
		max(case when pos=1 then emps else '' end)||
		max(case when pos=2 then emps else '' end)||
		max(case when pos=3 then emps else '' end)||
		max(case when pos=4 then emps else '' end)||
		max(case when pos=5 then emps else '' end)||
		max(case when pos=6 then emps else '' end),','
			) as emps
from (
	select a.deptno,
	a.ename||',' as emps,
	d.cnt,
		(select count(*) from emp b
				where a.deptno = b.deptno and b.empno <= a.empno) as pos		-- 获取每个部门有多少人
				from emp a,
			(select deptno, count(ename) as cnt
				from emp
				group by deptno) d
				where d.deptno=a.deptno
 ) x
 group by deptno
 order by 1;
 --------------------6.11 将数据转化为逗号分隔的多值IN列表-------------
 -- split_part(str, cha, n): 返回字符串str中被分隔符cha分割的第n个子串
 SELECT split_part('123 234 567 654', ' ', iter.pos) as empno
 from (SELECT id as pos from t10) iter;
 
 -----------6.12 将名字按每个字母排序--------
 -- 
 SELECT ename, substr(ename, iter.pos, 1) as Od
 from (SELECT id as pos from t1) iter, emp
 WHERE iter.pos <= "length"(ename)
 ORDER BY 1,2;
 
 ------------解析IP-------------
 
 SELECT split_part('192.168.103.97', '.', 1) as A,
 split_part('192.168.103.97', '.', 2) as B,
 split_part('192.168.103.97', '.', 3) as C,
 split_part('192.168.103.97', '.', 4) as D
from t1;


