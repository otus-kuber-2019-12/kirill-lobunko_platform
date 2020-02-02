# kirill-lobunko_platform
kirill-lobunko Platform repository

kubernetes-operators

Лекция 8 kubernetes-operator

Вывод комманд:

➜  kubernetes-operators git:(kubernetes-operators) ✗ kubectl get jobs
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           1s         2m23s
restore-mysql-instance-job   1/1           42s        91s

➜  kubernetes-operators git:(kubernetes-operators) ✗ sh view.sh
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+