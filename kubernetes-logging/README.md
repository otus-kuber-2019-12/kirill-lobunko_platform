1. Создал кластер в GKE.
➜  ~ k get nodes
NAME                                       STATUS   ROLES    AGE   VERSION
gke-cluster-1-default-pool-d3e6f5c0-qsf6   Ready    <none>   26m   v1.15.8-gke.3
gke-cluster-1-infra-pool-14274562-qbld     Ready    <none>   26m   v1.15.8-gke.3
gke-cluster-1-infra-pool-14274562-qs8l     Ready    <none>   26m   v1.15.8-gke.3
gke-cluster-1-infra-pool-14274562-s8vs     Ready    <none>   26m   v1.15.8-gke.3

2. 
➜  kubernetes-logging git:(kubernetes-logging) ✗ pwd
/Users/kirill_lobunko/otus/kirill-lobunko_platform/kubernetes-logging
➜  kubernetes-logging git:(kubernetes-logging) ✗ kubectl create ns microservices-demo
namespace/microservices-demo created
➜  kubernetes-logging git:(kubernetes-logging) ✗ k get ns
NAME                 STATUS   AGE
default              Active   29m
kube-node-lease      Active   29m
kube-public          Active   29m
kube-system          Active   29m
microservices-demo   Active   11s

➜  kubernetes-logging git:(kubernetes-logging) ✗ cp ~/otus/otus-platform-snippets/Module-02/Logging/microservices-demo-without-resources.yaml .
➜  kubernetes-logging git:(kubernetes-logging) ✗ ls -al
total 56
drwxr-xr-x   5 kirill_lobunko  staff    160 24 фев 19:04 .
drwxr-xr-x  14 kirill_lobunko  staff    448 24 фев 18:55 ..
-rw-r--r--   1 kirill_lobunko  staff  12288 24 фев 19:01 .README.md.swp
-rw-r--r--   1 kirill_lobunko  staff      0 24 фев 18:56 README.md
-rw-r--r--   1 kirill_lobunko  staff  13555 24 фев 19:04 microservices-demo-without-resources.yaml
➜  kubernetes-logging git:(kubernetes-logging) ✗ kubectl apply -f ./microservices-demo-without-resources.yaml -n microservices-demo
deployment.apps/emailservice created
service/emailservice created
deployment.apps/checkoutservice created
service/checkoutservice created
deployment.apps/recommendationservice created
service/recommendationservice created
deployment.apps/frontend created
service/frontend created
service/frontend-external created
deployment.apps/paymentservice created
service/paymentservice created
deployment.apps/productcatalogservice created
service/productcatalogservice created
deployment.apps/cartservice created
service/cartservice created
deployment.apps/loadgenerator created
deployment.apps/currencyservice created
service/currencyservice created
deployment.apps/shippingservice created
service/shippingservice created
deployment.apps/redis-cart created
service/redis-cart created
deployment.apps/adservice created
service/adservice created

➜  kubernetes-logging git:(kubernetes-logging) ✗ k get pods -n microservices-demo -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP          NODE                                       NOMINATED NODE   READINESS GATES
adservice-9679d5b56-cmfvn                1/1     Running   0          3m17s   10.0.1.19   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
cartservice-66b4c7d59-fv87f              1/1     Running   2          3m19s   10.0.1.14   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
checkoutservice-6cb96b65fd-lcq9s         1/1     Running   0          3m22s   10.0.1.9    gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
currencyservice-68df8c8788-n5x4s         1/1     Running   0          3m18s   10.0.1.16   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
emailservice-6fc9c98fd-sh8tf             1/1     Running   0          3m23s   10.0.1.8    gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
frontend-5559967bcd-z5dqx                1/1     Running   0          3m21s   10.0.1.11   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
loadgenerator-674846f899-tr9gm           1/1     Running   4          3m19s   10.0.1.15   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
paymentservice-6cb4db7678-bqxmn          1/1     Running   0          3m20s   10.0.1.12   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
productcatalogservice-768b67d968-gm8dg   1/1     Running   0          3m20s   10.0.1.13   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
recommendationservice-f45c4979d-z7tlf    1/1     Running   0          3m22s   10.0.1.10   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
redis-cart-cfcbcdf6c-dk97b               1/1     Running   0          3m17s   10.0.1.18   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
shippingservice-5d68c4f8d4-7tdfk         1/1     Running   0          3m18s   10.0.1.17   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>

3. Установка EFK стека | Helm charts
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm repo add elastic https://helm.elastic.co
"elastic" has been added to your repositories
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm repo list
NAME    	URL
stable  	https://kubernetes-charts.storage.googleapis.com
jetstack	https://charts.jetstack.io
harbor  	https://helm.goharbor.io
elastic 	https://helm.elastic.co

➜  kubernetes-logging git:(kubernetes-logging) ✗ kubectl create ns observability
namespace/observability created
➜  kubernetes-logging git:(kubernetes-logging) ✗ k get ns
NAME                 STATUS   AGE
default              Active   40m
kube-node-lease      Active   40m
kube-public          Active   40m
kube-system          Active   40m
microservices-demo   Active   11m
observability        Active   6s

# ElasticSearch
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability
Release "elasticsearch" does not exist. Installing it now.
NAME: elasticsearch
LAST DEPLOYED: Mon Feb 24 19:14:31 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 1
NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=observability -l app=elasticsearch-master -w
2. Test cluster health using Helm test.
  $ helm test elasticsearch

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install kibana elastic/kibana --namespace observability
Release "kibana" does not exist. Installing it now.
NAME: kibana
LAST DEPLOYED: Mon Feb 24 19:20:25 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 1
TEST SUITE: None

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install fluent-bit stable/fluent-bit --namespace observability
Release "fluent-bit" does not exist. Installing it now.
NAME: fluent-bit
LAST DEPLOYED: Mon Feb 24 19:20:39 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 1
NOTES:
fluent-bit is now running.

It will forward all container logs to the svc named fluentd on port: 24284

➜  kubernetes-logging git:(kubernetes-logging) ✗ k get pods -n observability -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP          NODE                                       NOMINATED NODE   READINESS GATES
elasticsearch-master-0          0/1     Running   0          7m58s   10.0.1.20   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
elasticsearch-master-1          0/1     Pending   0          7m58s   <none>      <none>                                     <none>           <none>
elasticsearch-master-2          0/1     Pending   0          7m58s   <none>      <none>                                     <none>           <none>
fluent-bit-rqmrs                1/1     Running   0          109s    10.0.1.22   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
kibana-kibana-f58565cfb-mjw9h   0/1     Running   0          2m4s    10.0.1.21   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>

#Исправляем - все пытается запуститься в defaul-pool
➜  kubernetes-logging git:(kubernetes-logging) ✗ cat elasticsearch.values.yaml
tolerations:
  - key: node-role
    operator: Equal
    value: infra
    effect: NoSchedule
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install elasticsearch elastic/elasticsearch -n observability -f ./elasticsearch.values.yaml
Release "elasticsearch" has been upgraded. Happy Helming!
NAME: elasticsearch
LAST DEPLOYED: Mon Feb 24 19:29:39 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 2
NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=observability -l app=elasticsearch-master -w
2. Test cluster health using Helm test.
  $ helm test elasticsearch

#Все pod-ы elasticsearch-master мигрировали в infra-pool
➜  kubernetes-logging git:(kubernetes-logging) ✗ k get pods -n observability -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP          NODE                                       NOMINATED NODE   READINESS GATES
elasticsearch-master-0          1/1     Running   0          5m9s    10.0.3.2    gke-cluster-1-infra-pool-14274562-qs8l     <none>           <none>
elasticsearch-master-1          1/1     Running   0          7m15s   10.0.0.2    gke-cluster-1-infra-pool-14274562-s8vs     <none>           <none>
elasticsearch-master-2          1/1     Running   0          9m7s    10.0.2.2    gke-cluster-1-infra-pool-14274562-qbld     <none>           <none>
fluent-bit-rqmrs                1/1     Running   0          18m     10.0.1.22   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
kibana-kibana-f58565cfb-mjw9h   1/1     Running   0          18m     10.0.1.21   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>

#Добавили nodeSelector. более гибкий способ использовать nodeAffinity
➜  kubernetes-logging git:(kubernetes-logging) ✗ cat elasticsearch.values.yaml
tolerations:
  - key: node-role
    operator: Equal
    value: infra
    effect: NoSchedule

nodeSelector:
  cloud.google.com/gke-nodepool: infra-pool

➜  kubernetes-logging git:(kubernetes-logging) ✗ k get pods -n observability -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP          NODE                                       NOMINATED NODE   READINESS GATES
elasticsearch-master-0          1/1     Running   0          7m18s   10.0.3.3    gke-cluster-1-infra-pool-14274562-qs8l     <none>           <none>
elasticsearch-master-1          1/1     Running   0          8m48s   10.0.0.3    gke-cluster-1-infra-pool-14274562-s8vs     <none>           <none>
elasticsearch-master-2          1/1     Running   0          10m     10.0.2.3    gke-cluster-1-infra-pool-14274562-qbld     <none>           <none>
fluent-bit-rqmrs                1/1     Running   0          33m     10.0.1.22   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>
kibana-kibana-f58565cfb-mjw9h   1/1     Running   0          33m     10.0.1.21   gke-cluster-1-default-pool-d3e6f5c0-qsf6   <none>           <none>

# Установите nginx-ingress. Должно быть развернуто три реплики controller, по одной, на каждую ноду из infra-pool

➜  kubernetes-logging git:(kubernetes-logging) ✗ k create ns nginx-ingress
namespace/nginx-ingress created
➜  kubernetes-logging git:(kubernetes-logging) ✗ k get ns
NAME                 STATUS   AGE
default              Active   20h
kube-node-lease      Active   20h
kube-public          Active   20h
kube-system          Active   20h
microservices-demo   Active   19h
nginx-ingress        Active   3s
observability        Active   19h

➜  kubernetes-logging git:(kubernetes-logging) ✗ cat nginx-ingress.values.yaml
controller:
  replicaCount: 3

  tolerations:
    - key: node-role
      operator: Equal
      value: infra
      effect: NoSchedule

  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - nginx-ingress
          topologyKey: kubernetes.io/hostname

  nodeSelector:
    cloud.google.com/gke-nodepool: infra-pool
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install nginx-ingress stable/nginx-ingress --wait -n nginx-ingress -f ./nginx-ingress.values.yaml
Release "nginx-ingress" does not exist. Installing it now.
NAME: nginx-ingress
LAST DEPLOYED: Tue Feb 25 19:02:40 2020
NAMESPACE: nginx-ingress
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace nginx-ingress get services -o wide -w nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls

# Обновим конфигурацию kibana - добавим доступ через ingress
➜  kubernetes-logging git:(kubernetes-logging) ✗ cat kibana.values.yaml
ingress:
  enabled: true
  annotations: {
    kubernetes.io/ingress.class: nginx
  }
  path: /
  hosts:
    - kibana.35.228.186.251.xip.io
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install kibana elastic/kibana -n observability -f ./kibana.values.yaml
Release "kibana" has been upgraded. Happy Helming!
NAME: kibana
LAST DEPLOYED: Tue Feb 25 19:18:46 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 2
TEST SUITE: None

#Обновим конфигурацию fluent
➜  kubernetes-logging git:(kubernetes-logging) ✗ cat fluent-bit.values.yaml
backend:
  type: es
  es:
    host: elasticsearch-master
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f ./fluent-bit.values.yaml
Release "fluent-bit" has been upgraded. Happy Helming!
NAME: fluent-bit
LAST DEPLOYED: Tue Feb 25 19:35:22 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 2
NOTES:
fluent-bit is now running.

It will forward all container logs to the svc named elasticsearch-master on port: 9200

# Обновим конфигурацию fluent. Часть логов пропадают Причину можно найти в логах pod с Fluent Bit, он пытается обработать JSON, отдаваемый приложением, и находит там дублирующиеся поля time и timestamp

➜  kubernetes-logging git:(kubernetes-logging) ✗ cat fluent-bit.values_v2.yaml
backend:
  type: es
  es:
    host: elasticsearch-master
rawConfig: |
  @INCLUDE fluent-bit-service.conf
  @INCLUDE fluent-bit-input.conf
  @INCLUDE fluent-bit-filter.conf
  @INCLUDE fluent-bit-output.conf
  [FILTER]
      Name    modify
      Match   *
      Remove  time
      Remove  @timestamp

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f ./fluent-bit.values_v2.yaml
Release "fluent-bit" has been upgraded. Happy Helming!
NAME: fluent-bit
LAST DEPLOYED: Tue Feb 25 20:52:24 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 3
NOTES:
fluent-bit is now running.

It will forward all container logs to the svc named elasticsearch-master on port: 9200

#Для мониторинга ElasticSearch будем использовать следующий Prometheus exporter. Установите prometheus-operator в namespace observability.

➜  kubernetes-logging git:(kubernetes-logging) ✗ cat prometheus-operator.values.yaml
commonLabels:
  prometheus: default

prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
  serviceMonitorSelector: []
  ## Example which selects ServiceMonitors with label "prometheus" set to "somelabel"
  # serviceMonitorSelector:
    # matchLabels:
    #   prometheus: default

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install prometheus stable/prometheus-operator --namespace observability -f ./prometheus-operator.values.yaml
Release "prometheus" does not exist. Installing it now.
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
NAME: prometheus
LAST DEPLOYED: Thu Feb 27 17:10:44 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 1
NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace observability get pods -l "release=prometheus"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install elasticsearch-exporter stable/elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true --namespace=observability
Release "elasticsearch-exporter" does not exist. Installing it now.
NAME: elasticsearch-exporter
LAST DEPLOYED: Tue Feb 25 21:27:45 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace observability -l "app=elasticsearch-exporter" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9108/metrics to use your application"
  kubectl port-forward $POD_NAME 9108:9108 --namespace observability

#Импортируйте в Grafana один из популярных dashboard

➜  kubernetes-logging git:(kubernetes-logging) ✗ k port-forward -n observability prometheus-grafana-5d9994bc86-xssk9 3000:3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000

#получаем пароль для grafana
➜  kubernetes-logging git:(kubernetes-logging) ✗ kubectl get secret prometheus-grafana -n observability -o jsonpath='{.data.admin-password}' -n observability | base64 --decode
prom-operator

#Проверим, что метрики действительно собираются корректно.Сделайте drain одной из нод infra-pool

➜  kubernetes-logging git:(kubernetes-logging) ✗ k drain gke-cluster-1-infra-pool-14274562-s8vs --ignore-daemonsets
node/gke-cluster-1-infra-pool-14274562-s8vs cordoned
evicting pod "nginx-ingress-controller-7d6c4cdff-5wghd"
evicting pod "elasticsearch-master-1"
pod/elasticsearch-master-1 evicted
pod/nginx-ingress-controller-7d6c4cdff-5wghd evicted
node/gke-cluster-1-infra-pool-14274562-s8vs evicted

# Попробуем сделать drain второй ноды из infra-pool, и увидим что PDB не дает этого сделать.

➜  kubernetes-logging git:(kubernetes-logging) ✗ k drain gke-cluster-1-infra-pool-14274562-qs8l --ignore-daemonsets
node/gke-cluster-1-infra-pool-14274562-qs8l cordoned
evicting pod "nginx-ingress-controller-7d6c4cdff-b4pnr"
evicting pod "elasticsearch-master-0"
error when evicting pod "elasticsearch-master-0" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
evicting pod "elasticsearch-master-0"
error when evicting pod "elasticsearch-master-0" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
evicting pod "elasticsearch-master-0"
error when evicting pod "elasticsearch-master-0" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.

#Попробуем найти в Kibana логи nginx-ingress. Добейтесь того, чтобы эти логи появились

➜  kubernetes-logging git:(kubernetes-logging) ✗ cat nginx-ingress.values_v2.yaml
controller:
  replicaCount: 3
  config:
    log-format-escape-json: "true"
    log-format-upstream: '{"proxy_protocol_addr": "$proxy_protocol_addr","remote_addr": "$remote_addr", "proxy_add_x_forwarded_for": "$proxy_add_x_forwarded_for", "remote_user": "$remote_user", "time_local": "$time_local", "request" : "$request", "status": "$status", "body_bytes_sent": "$body_bytes_sent", "http_referer":  "$http_referer", "http_user_agent": "$http_user_agent", "request_length" : "$request_length", "request_time" : "$request_time", "proxy_upstream_name": "$proxy_upstream_name", "upstream_addr": "$upstream_addr",  "upstream_response_length": "$upstream_response_length", "upstream_response_time": "$upstream_response_time", "upstream_status": "$upstream_status"}'

  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      scrapeInterval: 30s

  tolerations:
    - key: node-role
      operator: Equal
      value: infra
      effect: NoSchedule

  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - nginx-ingress
          topologyKey: kubernetes.io/hostname

  nodeSelector:
    cloud.google.com/gke-nodepool: infra-pool

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install nginx-ingress stable/nginx-ingress --wait -n nginx-ingress -f ./nginx-ingress.values_v2.yaml
Release "nginx-ingress" has been upgraded. Happy Helming!
NAME: nginx-ingress
LAST DEPLOYED: Thu Feb 27 20:25:45 2020
NAMESPACE: nginx-ingress
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace nginx-ingress get services -o wide -w nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls


#Установка Loki + Promtail
➜  kubernetes-logging git:(kubernetes-logging) ✗ helm repo add loki https://grafana.github.io/loki/charts
"loki" has been added to your repositories

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "harbor" chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "loki" chart repository
...Successfully got an update from the "elastic" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install loki loki/loki -n observability
Release "loki" does not exist. Installing it now.
NAME: loki
LAST DEPLOYED: Mon Mar  9 21:49:17 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Verify the application is working by running these commands:
  kubectl --namespace observability port-forward service/loki 3100
  curl http://127.0.0.1:3100/api/prom/label

➜  kubernetes-logging git:(kubernetes-logging) ✗ cat loki.values.yaml
tolerations:
- operator: Exists

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install promtail loki/promtail --set "loki.serviceName=loki" --namespace=observability -f ./loki.values.yaml
Release "promtail" has been upgraded. Happy Helming!
NAME: promtail
LAST DEPLOYED: Mon Mar  9 22:10:20 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
Verify the application is working by running these commands:
  kubectl --namespace observability port-forward daemonset/promtail 3101
  curl http://127.0.0.1:3101/metrics

#Модифицируйте конфигурацию prometheus-operator таким образом, чтобы datasource Loki создавался сразу после установки оператора.
➜  kubernetes-logging git:(kubernetes-logging) ✗ cat prometheus-operator.values_v2.yaml
commonLabels:
  prometheus: default

prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
  serviceMonitorSelector: []
  ## Example which selects ServiceMonitors with label "prometheus" set to "somelabel"
  # serviceMonitorSelector:
    # matchLabels:
    #   prometheus: default

grafana:
    additionalDataSources:
      - name: Loki
        type: loki
        access: proxy
        url: http://loki:3100
        jsonData:
          maxLines: 1000

➜  kubernetes-logging git:(kubernetes-logging) ✗ helm upgrade --install prometheus stable/prometheus-operator --namespace observability -f ./prometheus-operator.values_v2.yaml
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
Release "prometheus" has been upgraded. Happy Helming!
NAME: prometheus
LAST DEPLOYED: Tue Mar 10 19:03:31 2020
NAMESPACE: observability
STATUS: deployed
REVISION: 2
NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace observability get pods -l "release=prometheus"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.

➜  kubernetes-logging git:(kubernetes-logging) ✗ k port-forward -n observability prometheus-grafana-84c8fdd4d-zfz4t 3000:3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
