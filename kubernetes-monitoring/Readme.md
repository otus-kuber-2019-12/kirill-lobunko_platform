1. Делаю ДЗ в minikube: minikube delete; minikube start --memory=4096
2. Разворачиваю prometheus-operator через helm3, предварительно скачав values.yaml и поменяв переменные из лекции. wget https://raw.githubusercontent.com/helm/charts/master/stable/prometheus-operator/values.yaml
3. helm install prometheus-operator stable/prometheus-operator --wait -f ./values.yaml
4. Доступ до графаны: Grafana: kubectl port-forward service/prometheus-operator-grafana 8080:80
5. Делаю свой контейнер с конфигом nginx: location /basic_status
6. Пишу три yaml файла: deployment.yaml, service.yaml, service-monitor.yaml
7. Разворачиваем ямлики в кубере.
8. Проверяем:
	а. http://localhost:8888/basic_status - тут доступна статистика с nginx
	b. http://127.0.0.1:9113/metrics - тут уже обработанная статистика с nginx-exporter
	c. Идем в графану http://localhost:8080/ там видим что метрики приходят, скриншот приложил.
