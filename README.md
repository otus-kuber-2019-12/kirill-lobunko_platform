# kirill-lobunko_platform
kirill-lobunko Platform repository
## Вопрос 1:
Разберитесь почему все pod в namespace kube-system восстановились после удаления.
## Ответ:

## Вопрос 2:
Выясните причину, по которой pod frontend находится в статусе Error

## Ответ:
$ kubectl logs frontend 
panic: environment variable "PRODUCT_CATALOG_SERVICE_ADDR" not set

 Выполнено ДЗ №1

 - [*] Основное ДЗ
 - [ ] Задание со *

## В процессе сделано:
 - Написал Docerfile и создал образ по указанным требованиям.
    1. Запускающий web-сервер на порту 8000
    2. Отдающий содержимое директории /app внутри контейнера
    3. Работающий с UID 1001
 - Написал манифест web-pod.yaml для создания pod web. Добавил запуск init контейнера.

## Как запустить проект:
$ kubectl apply -f ./web-pod.yaml 
pod/web created
$ kubectl port-forward --address 0.0.0.0 pod/web 8000:8000 
Forwarding from 0.0.0.0:8000 -> 8000
Handling connection for 8000

## Как проверить работоспособность:
 - http://localhost:8000

## PR checklist:
 - [ ] Выставлен label с номером домашнего задания