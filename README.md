Execute em bancos separados o script de cada pasta e execute a função de teste => SELECT public.teste_performance_insert_row() ;

Teste inicial com 30.000 Execuções cada.

rules : Query OK (execution time: 1.093 sec; total time: 1.156 sec)

Trigger : Query OK (execution time: 1.265 sec; total time: 1.360 sec)


Diferença 17.6%

Referencias :
https://www.cybertec-postgresql.com/en/rules-or-triggers-to-log-bulk-updates/
![image](https://user-images.githubusercontent.com/91134093/194581135-f694dda5-eb08-4075-ba4f-d55cbe30c143.png)


https://www.postgresql.org/docs/current/rules-triggers.html
A documentação do postgres degrada a utilização de triggers para operações onde as rules poder realizar a mesma operação. 

"For the things that can be implemented by both, which is best depends on the usage of the database. A trigger is fired once for each affected row. A rule modifies the query or generates an additional query. So if many rows are affected in one statement, a rule issuing one extra command is likely to be faster than a trigger that is called for every single row and must re-determine what to do many times. However, the trigger approach is conceptually far simpler than the rule approach, and is easier for novices to get right."
