# kirill-lobunko_platform
kirill-lobunko Platform repository
## Вопрос 1:
Найти ошибку в манифесте ReplicaSet.
## Ответ:
Нехватает секции selector:

## Вопрос 2:
Обновление ReplicaSet. Почему обновление ReplicaSet не повлекло обновление запущенных Pod?
## Ответ:
Поиск подов происходит по метке app: frontend. Поскольку находятся все три требуемых пода, то ничего не происходит.
Если убить под, то новый будет создан уже по новому описанию, из новой версии образа.

 Выполнено ДЗ №2

 - [*] Основное ДЗ
 - [ ] Задание со *

## В процессе сделано:
 - Изучал различные контроллеры ReplicaSet, Deployment, DaemonSet
 - Создавал манифесты для развертывания подов под управлением контроллеров:
 новый файл:    kubernetes-controllers/frontend-deployment.yaml
	изменено:      kubernetes-controllers/frontend-replicaset.yaml
	новый файл:    kubernetes-controllers/node-exporter-daemonset.yaml
	новый файл:    kubernetes-controllers/paymentservice-deployment-bg.yaml
	новый файл:    kubernetes-controllers/paymentservice-deployment-reverse.yaml
	новый файл:    kubernetes-controllers/paymentservice-deployment.yaml
	новый файл:    kubernetes-controllers/paymentservice-replicaset.yaml

## Как запустить проект:

## Как проверить работоспособность:

## PR checklist:
 - [ ] Выставлен label с номером домашнего задания