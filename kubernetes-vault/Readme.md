1. Устанавливаем consul:
	склонируем репозиторий consul (необходимо минимум 3 ноды)
	git clone https://github.com/hashicorp/consul-helm.git
	helm install consul consul-helm
2. склонируем репозиторий vault
	git clone https://github.com/hashicorp/vault-helm.git
	Отредактируем параметры установки в values.yaml:
	cp vault-helm/values.yaml .

standalone:
enabled: false
ha:
enabled: true
ui:
enabled: true
serviceType: "ClusterIP"

3. Установим vault:
➜  kubernetes-vault git:(kubernetes-vault) ✗ helm install vault -f ./vault_values.yaml ./vault-helm
➜  kubernetes-vault git:(kubernetes-vault) ✗ helm status vault
NAME: vault
LAST DEPLOYED: Mon Feb 10 15:57:52 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get vault

➜  kubernetes-vault git:(kubernetes-vault) ✗ k get pods
NAME                                    READY   STATUS    RESTARTS   AGE
consul-consul-bf9wm                     1/1     Running   0          21m
consul-consul-q7hvt                     1/1     Running   0          21m
consul-consul-server-0                  1/1     Running   0          21m
consul-consul-server-1                  1/1     Running   0          21m
consul-consul-server-2                  1/1     Running   0          21m
consul-consul-v5wfr                     1/1     Running   0          21m
vault-0                                 0/1     Running   0          105s
vault-1                                 0/1     Running   0          105s
vault-2                                 0/1     Running   0          105s
vault-agent-injector-776ddf9575-hx4r8   1/1     Running   0          105s

4. Инициализируем vault - инициализацию черерз любой под vault'а
	kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1
Unseal Key 1: lFZ+c2DRR3iIB2G5nHiW6C7HyhL+rYHLN8QlSy2Lbck=

Initial Root Token: s.4iIEvZ5qaAhoW1z6aV0abF3a

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.    

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       1
Threshold          1
Unseal Progress    0/1
Unseal Nonce       n/a
Version            1.3.1
HA Enabled         true
command terminated with exit code 2

➜  kubernetes-vault git:(kubernetes-vault) ✗ k logs vault-0

5. Распечатать нужно каждый под
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault operator unseal 'lFZ+c2DRR3iIB2G5nHiW6C7HyhL+rYHLN8QlSy2Lbck='
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.3.1
Cluster Name           vault-cluster-8722aab6
Cluster ID             a2b14e05-0cca-392c-5904-78c4ae869f21
HA Enabled             true
HA Cluster             n/a
HA Mode                standby
Active Node Address    <none>
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-1 -- vault operator unseal 'lFZ+c2DRR3iIB2G5nHiW6C7HyhL+rYHLN8QlSy2Lbck='
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.3.1
Cluster Name           vault-cluster-8722aab6
Cluster ID             a2b14e05-0cca-392c-5904-78c4ae869f21
HA Enabled             true
HA Cluster             https://10.52.0.5:8201
HA Mode                standby
Active Node Address    http://10.52.0.5:8200
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-2 -- vault operator unseal 'lFZ+c2DRR3iIB2G5nHiW6C7HyhL+rYHLN8QlSy2Lbck='
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.3.1
Cluster Name           vault-cluster-8722aab6
Cluster ID             a2b14e05-0cca-392c-5904-78c4ae869f21
HA Enabled             true
HA Cluster             https://10.52.0.5:8201
HA Mode                standby
Active Node Address    http://10.52.0.5:8200

6. Посмотрим список доступных авторизаций
	kubectl exec -it vault-0 -- vault auth list

7. Залогинимся в vault (у нас есть root token) Initial Root Token: s.4iIEvZ5qaAhoW1z6aV0abF3a
	kubectl exec -it vault-0 --  vault login

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 --  vault login
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.4iIEvZ5qaAhoW1z6aV0abF3a
token_accessor       NKfYa7L6ou929Ylm5aBvo8XY
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

повторно запросим список авторизаций

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 --  vault auth list
Path      Type     Accessor               Description
----      ----     --------               -----------
token/    token    auth_token_3bdbf04f    token based credentials

8. Заведем секреты
kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
kubectl exec -it vault-0 -- vault secrets list --detailed
kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'
kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'
kubectl exec -it vault-0 -- vault read otus/otus-ro/config
kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
Success! Enabled the kv secrets engine at: otus/
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault secrets list --detailed
Path          Plugin       Accessor              Default TTL    Max TTL    Force No Cache    Replication    Seal Wrap    External Entropy Access    Options    Description                                                UUID
----          ------       --------              -----------    -------    --------------    -----------    ---------    -----------------------    -------    -----------                                                ----
cubbyhole/    cubbyhole    cubbyhole_5fdf07f4    n/a            n/a        false             local          false        false                      map[]      per-token private secret storage                           a686d665-19ab-30da-67c5-a515524d1d3e
identity/     identity     identity_25f1e6e5     system         system     false             replicated     false        false                      map[]      identity store                                             0f527199-a637-5327-6e39-6121161d1a2e
otus/         kv           kv_eca412ea           system         system     false             replicated     false        false                      map[]      n/a                                                        0f16a812-f4f6-99b8-ed4a-a948edfed15e
sys/          system       system_6add6f32       n/a            n/a        false             replicated     false        false                      map[]      system endpoints used for control, policy and debugging    d588251e-be89-c4bd-6ded-8e2f4d87ca2d
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'
Success! Data written to: otus/otus-ro/config
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'
Success! Data written to: otus/otus-rw/config
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus

9. Включим авторизацию черерз k8s

kubectl exec -it vault-0 -- vault auth enable kubernetes
kubectl exec -it vault-0 --  vault auth list

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 --  vault auth list
Path      Type     Accessor               Description
----      ----     --------               -----------
token/    token    auth_token_3bdbf04f    token based credentials
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 --  vault auth list
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_3c7a2f2d    n/a
token/         token         auth_token_3bdbf04f         token based credentials

10. Создадим Service Account vault-auth и применим ClusterRoleBinding
# Create a service account, 'vault-auth'
$ kubectl create serviceaccount vault-auth
# Update the 'vault-auth' service account
$ kubectl apply --filename vault-auth-service-account.yml

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl create serviceaccount vault-auth
serviceaccount/vault-auth created
➜  kubernetes-vault git:(kubernetes-vault) ✗ k apply -f ./vault_auth_service_account.yaml
clusterrolebinding.rbac.authorization.k8s.io/role-tokenreview-binding created

11. Подготовим переменные для записи в конфиг кубер авторизации

#export VAULT_SA_NAME=$( kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}" )
#export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" |base64 --decode; echo)
#export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" |base64 --decode; echo)

## this not correct -> export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')
### alternative way
Нужно вбить переменную K8S_HOST руками, иначе появляются лишние символы цвета
# export K8S_HOST=$( kubectl cluster-info|grep 'Kubernetes master' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )

12. Запишем конфиг в vault
kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
token_reviewer_jwt="$SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$SA_CA_CRT"

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT"
Success! Data written to: auth/kubernetes/config

13. Создадим файл политики
#tee otus-policy.hcl <<EOF
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}
path "otus/otus-rw/*" {
capabilities = ["read", "create", "list"]
}
EOF

14. создадим политку и роль в vault
kubectl cp otus-policy.hcl vault-0:./
kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h


➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl cp otus-policy.hcl vault-0:/tmp/
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
Success! Uploaded policy: otus-policy
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
Success! Data written to: auth/kubernetes/role/otus

15. Проверим как работает авторизация. Создадим под с привязанным сервис аккоунтом и установим туда curl и jq

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image=alpine:3.7
If you don't see a command prompt, try pressing enter.
/ #
/ #
/ # Session ended, resume using 'kubectl attach tmp -c tmp -i -t' command when the pod is running
Залогинимся и получим клиентский токен

/ # VAULT_ADDR=http://vault:8200
/ # KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
/ # curl --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login
{"request_id":"2115c6ec-687f-5d2a-d73a-9f6879f10c35","lease_id":"","renewable":false,"lease_duration":0,"data":null,"wrap_info":null,"warnings":null,"auth":{"client_token":"s.BM70JlZ4IpDXWC2tDYZS55ZA","accessor":"GhNxC9s4I7cJynkZ9ZNJuxtH","policies":["default","otus-policy"],"token_policies":["default","otus-policy"],"metadata":{"role":"otus","service_account_name":"vault-auth","service_account_namespace":"default","service_account_secret_name":"vault-auth-token-qlkz9","service_account_uid":"ef0d5dff-e70a-429f-9737-f2039dfc34d6"},"lease_duration":86400,"renewable":true,"entity_id":"9828d1f3-dacd-5e78-b140-dd9af8371255","token_type":"service","orphan":true}}
/ # curl --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
{ 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  "request_id": "2e6e78dd-dd8a-7366-633d-9a83979e5456",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth": {
    "client_token": "s.3jMOF59wAzPAzjeTpqyhI8l3",
    "accessor": "nCULYePi6mmyNpqPlhar0qv2",
    "policies": [
      "default",
      "otus-policy"
    ],
    "token_policies": [
      "default",
      "otus-policy"
    ],
    "metadata": {
      "role": "otus",
      "service_account_name": "vault-auth",
      "service_account_namespace": "default",
      "service_account_secret_name": "vault-auth-token-qlkz9",
      "service_account_uid": "ef0d5dff-e70a-429f-9737-f2039dfc34d6"
    },
    "lease_duration": 86400,
    "renewable": true,
    "entity_id": "9828d1f3-dacd-5e78-b140-dd9af8371255",
    "token_type": "service",
    "orphan": true
  }
}
100  1605  100   666  100   939  15488  21837 --:--:-- --:--:-- --:--:-- 38214
/ #

# Это не работает
TOKEN=$(curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')
# так как ошибка {"errors":["invalid role name \"test\""]}
curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "test"}' $VAULT_ADDR/v1/auth/kubernetes/login
{"errors":["invalid role name \"test\""]}

#Правим "test" на otus.
TOKEN=$(curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')

# curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token'
"s.Pwp5DqD9hSiloYyiG4l2ZgLw"

16. Прочитаем записанные ранее секреты и попробуем их обновить.
	используйте свой клиентский токен
	проверим чтение:
/ # curl --header "X-Vault-Token:s.Pwp5DqD9hSiloYyiG4l2ZgLw" $VAULT_ADDR/v1/otus/otus-ro/config
{"request_id":"e746ea8d-c13b-72f5-0863-7a9fb3c312ad","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}
/ # curl --header "X-Vault-Token:s.Pwp5DqD9hSiloYyiG4l2ZgLw" $VAULT_ADDR/v1/otus/otus-rw/config
{"request_id":"8d149c1f-d031-788c-964c-03468e377c45","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}

	проверим запись:
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.Pwp5DqD9hSiloYyiG4l2ZgLw" $VAULT_ADDR/v1/otus/otus-ro/config
{"errors":["1 error occurred:\n\t* permission denied\n\n"]}
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.Pwp5DqD9hSiloYyiG4l2ZgLw" $VAULT_ADDR/v1/otus/otus-rw/config
{"errors":["1 error occurred:\n\t* permission denied\n\n"]}
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.Pwp5DqD9hSiloYyiG4l2ZgLw" $VAULT_ADDR/v1/otus/otus-rw/config1
/ #

Почему мы смогли записать otus-rw/config1 но не смогли otus- rw/config?
>> Так как в политике есть возможность создания, но нет модификации. capabilities = ["read", "create", "list"]
Измените политику так, чтобы можно было менять otus-rw/config.
>> capabilities = ["read", "create", "list", "update"]

➜  kubernetes-vault git:(kubernetes-vault) ✗ cat otus-policy-update.hcl
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}
path "otus/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}
➜  kubernetes-vault git:(kubernetes-vault) ✗ k cp otus-policy-update.hcl vault-0:/tmp
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- sh
/ $ ls -l /tmp
total 12
-rw-r--r--    1 vault    vault          136 Feb 12 04:59 otus-policy-update.hcl
-rw-r--r--    1 vault    vault          126 Feb 11 03:46 otus-policy.hcl
-rw-r--r--    1 vault    vault          557 Feb 10 08:58 storageconfig.hcl
/ $ vault policy write otus-policy /tmp/otus-policy-update.hcl
Success! Uploaded policy: otus-policy

Убедимся что теперь можно модифицировать:
# curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.Pwp5DqD9hSiloYyiG4l2ZgLw" $VAULT_ADDR/v1/otus/otus-rw/config

17. Use case использования авторизации через кубер.
	1. Правим файл configs-k8s/consul-template-config.hcl: {{- with secret "otus/otus-ro/config" }}
	2. File configs-k8s/vault-agent-config.hcl: role = "otus"
	3. Пришлось поправить файл otus-policy.hcl:
➜  kubernetes-vault git:(kubernetes-vault) ✗ cat otus-policy-update.hcl
#if working with K/V v1
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}
path "otus/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}

#if working with K/V v2
path "otus/data/otus-ro/*" {
capabilities = ["read", "list"]
}
path "otus/data/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}
	4. В описании пода example-k8s-spec.yml поправил только переменные VAULT_ADDR:
      env:
        - name: VAULT_ADDR
          value: http://vault:8200
	5. Дальше:
	kubectl create configmap example-vault-agent-config --from-file=configs-k8s
	kubectl get configmaps example-vault-agent-config -o yaml
	kubectl apply -f example-k8s-spec.yml --record
➜  kubernetes-vault git:(kubernetes-vault) ✗ k port-forward vault-agent-example 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
	6. Результат - страница с nginx:
  <html>
  <body>
  <p>Some secrets:</p>
  <ul>
  <li><pre>username: otus</pre></li>
  <li><pre>password: asajkjkahs</pre></li>
  </ul>

  </body>
  </html>

18. создадим CA на базе vault. 
	Включим pki секретс
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- sh
/ $ vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
/ $ vault secrets tune -max-lease-ttl=87600h pki
Success! Tuned the secrets engine at: pki/
/ $ vault write -field=certificate pki/root/generate/internal common_name="exmaple.ru"  ttl=87600h > /tmp/CA_cert.crt
/ $ cat /tmp/CA_cert.crt
-----BEGIN CERTIFICATE-----
MIIDMjCCAhqgAwIBAgIUMpIhvShV2LV7RQNOclM/TQ6ozgQwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAyMTQwNDU2MDBaFw0zMDAy
MTEwNDU2MzBaMBUxEzARBgNVBAMTCmV4bWFwbGUucnUwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCrwYcbSsGNcH1kdYNrKjkfD/GMW1fzNhybDE+LBw/x
AFeNXuS3LaDNeKlI8FUoy7ycG3BJfzKVmC8gPx6nIeR3B2Y5va9nrqTib5S37F5n
t0xZqq8PvJS9Up7fvzMTjA3JjESwcHifBM4IbGQKGpE9WS715eVKzoAvr289gMs/
P6LBi9o0HZ5OFLZkb4m9YCssUYiz0WBTvfAjIf0lk2xM8dQhAzLZODJ5K2+owK9M
JsX2vgyuK3LXWsqcpFZI0paR5fV3uZDRP9xwRjs584l8abCcqExNVGvQK9Z61E/e
FTmU+yezKIbT8oHgLm0buTJu7Uk29MmWNe46PGKr1WbfAgMBAAGjejB4MA4GA1Ud
DwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTlAAEwezcd7+bn
DAvJ9SjN/dxiIjAfBgNVHSMEGDAWgBTlAAEwezcd7+bnDAvJ9SjN/dxiIjAVBgNV
HREEDjAMggpleG1hcGxlLnJ1MA0GCSqGSIb3DQEBCwUAA4IBAQAGOi/f7TbNiTdx
Ak1HNRmE7/HJX09isSpvXVHZUAOjJgNDAPjccR0G73+BUJ3uu3G2YpSXD41jb+Mb
AuqisXutLQCLk7Hu319CF4+9xJzVsCm7ja20Wozw47ZNj/1tJVW5xokGydJGXfL8
/BQWI1KMIxbne/DlQ//iiR52OEfHAGRr95SLVsU7AaO6W1k1jZ4mCOWiKw4fE45G
x/tLphM4pDhuHU/PMUr0QiAGJ8CJOsQKWQy73ndOvkwblKaclw9cvhhtkkVeWwUl
ZGo+QOJK0caahAywBjkZEVtMDXxufBobvs/2ek0sXPJ8flL0g3fT38IAtVVHTZcH
3aqIbxnE
-----END CERTIFICATE-----

	пропишем урлы для ca и отозванных сертификатов:
/ $ vault write pki/config/urls issuing_certificates="http://vault:8200/v1/pki/ca" crl_distribution_points="http://vault:8200/v1/pki/crl"
Success! Data written to: pki/config/urls

	создадим промежуточный сертификат:
/ $ vault secrets enable --path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/

/ $ vault secrets tune -max-lease-ttl=87600h pki_int
Success! Tuned the secrets engine at: pki_int/

➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl exec -it vault-0 -- vault write -format=json pki_int/intermediate/generate/internal common_name="example.ru Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr

	пропишем промежуточный сертификат в vault:
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl cp pki_intermediate.csr vault-0:/tmp
/tmp $ vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" > 1.crt
➜  kubernetes-vault git:(kubernetes-vault) ✗ k cp vault-0:/tmp/1.crt 1.crt
tar: removing leading '/' from member names
➜  kubernetes-vault git:(kubernetes-vault) ✗ cat 1.crt| jq -r '.data.certificate' > intermediate.cert.pem
➜  kubernetes-vault git:(kubernetes-vault) ✗ kubectl cp intermediate.cert.pem vault-0:/tmp/
/tmp $ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed

Создадим и отзовем новые сертификаты:
	Создадим роль для выдачи с ертификатов
/tmp $ vault write pki_int/roles/example-dot-ru allowed_domains="example.ru" allow_subdomains=true   max_ttl="720h"
Success! Data written to: pki_int/roles/example-dot-ru
	Создадим и отзовем сертификат

/ $ vault write pki_int/issue/example-dot-ru common_name="tst.example.ru" ttl="24h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUbKOSpJBX4E73HJVR0XzPeZFRAKQwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAyMTQwNTE3MDZaFw0yNTAy
MTIwNTE3MzZaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOrl/6UBGcW8
qEsq53v9hnF3AY3L0Ptb4URpQo8R09g+QgwUt0F21AwwYrv8WqhlPw+O0NFvqFUD
lt1plxiMxhEi3whhhy8BbOczvgSvfzR3kpVSoXlBV9zc6w8WaDRpZLp+vbml5nm0
M1pmIMnlFsU3N/LJjHowGk4fYFmTvr44Zs0SI4EgD9e4o3pd776g9dn/FMj2LCzO
P+ich249qsyxJXNezxm89r87kdyqUwetAwjfBy0/HAdfmpG2gFD/pjAjjTZSe7tw
m6pZZvDryUhFxQ2JEZHNwoncOFySbix9wv8TYq/LJNk4IwNrwQa25Ch7LJseM4uJ
sk9DQ70K/R8CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUqol44o4EdXih8deISmZ3yj/O0ocwHwYDVR0jBBgwFoAU
5QABMHs3He/m5wwLyfUozf3cYiIwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
Y3NF/Yhow1L4iCjqUjADz7iUbC481m7x6eimwfbOZU7WIUtdN1yisq3c54AwIeH9
gp0flxxJusK4QXtSx23ORRKV0Bdd8sZGFK07+IXTe+JprOgFRlOtHvHOIkTNTXRN
PTixe363fc1VVuBQ18JXwIR6mRUDsmklm4VfjXtQ0V0Gg+tL9hGNBzOLui/CeBVZ
R5Ok+gtAVmNFxQmo2/YZ5wViODkteXmzLRKSgC8/FmhV6WbPPyG7FczzeXnUSBa/
+SZ6NBHrVMhNeN4HYpKhSSF7Wnv4fKIkLS7+1J3d3xk+bb5XmyhLPp+dfTvrw5cT
azYsgCQlRSJgyORSirmpRQ==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDYTCCAkmgAwIBAgIUHOALIQj8nU54G5f0HUaXG32QG+YwDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIwMDIxNDA3MjQxMloXDTIwMDIxNTA3MjQ0MVowGTEXMBUGA1UEAxMOdHN0
LmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC8rU3H
vmm+q5GwziAYJgR2pH5319RY9F8+ZOSdCCmbLeVF9a/MmZeaoiQubzt332j61+5d
zXmASFHhy6HI/L8vDuupwqQDZm/B64UAbUfAX7lu4wVXfEx7UjUZzuE4E1jOiV/Z
0ewB65laooXUbM+GwT00wYMN7xAS5OcRO6XNML3XDf/bwrammRX1feiZdUJBd3bs
heJQTniyq8Ue5szsbg3kPZ5DT2b0t6O8bm5lPiUgyu+MfBlnzL46C2/Zyk1j+pXh
7NNR20qtDcJpRqg6QGdLhL0PJOWZJ7X1WYCeoYsXAOjc+nDCpHwx9oUbzMFFC5Jv
h5qs6PXSU7KZLhk3AgMBAAGjgY0wgYowDgYDVR0PAQH/BAQDAgOoMB0GA1UdJQQW
MBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQU/qafSQTlBcDqgGVN4qGp
VxjDO+kwHwYDVR0jBBgwFoAUqol44o4EdXih8deISmZ3yj/O0ocwGQYDVR0RBBIw
EIIOdHN0LmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBAIbL9ZnUSKuTEYwf
eCiJsPdrTq+PHWc9rFvm9ArkAJO29kftCXX7TPZHfuSH3bRXv95JCj22SrqzwDWU
XVnK0Pl91LbBg54fEkBq3mCwf1YemmGv8fzZLncIEwLNgqJT8sAuJ7SCYTyfemW5
NoXvbDqWrrPTPbKAjpGWB6eJ+IF+jTwWpIAzeZaaI6lzNmkidT1jaba0yD2n/UD8
26JjDshi5zjeTB1LzWE0F5sPp6nEDi28FaygqKvgWI77H0F2UCHgP+il+WBWKUPw
IzBgZ6eYjCY8VIq536NOT345c4bwcFGbdm7FYByNDYKiPtJVpgc88lKFrI0LS4M6
H7dyiUU=
-----END CERTIFICATE-----
expiration          1581751481
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUbKOSpJBX4E73HJVR0XzPeZFRAKQwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAyMTQwNTE3MDZaFw0yNTAy
MTIwNTE3MzZaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOrl/6UBGcW8
qEsq53v9hnF3AY3L0Ptb4URpQo8R09g+QgwUt0F21AwwYrv8WqhlPw+O0NFvqFUD
lt1plxiMxhEi3whhhy8BbOczvgSvfzR3kpVSoXlBV9zc6w8WaDRpZLp+vbml5nm0
M1pmIMnlFsU3N/LJjHowGk4fYFmTvr44Zs0SI4EgD9e4o3pd776g9dn/FMj2LCzO
P+ich249qsyxJXNezxm89r87kdyqUwetAwjfBy0/HAdfmpG2gFD/pjAjjTZSe7tw
m6pZZvDryUhFxQ2JEZHNwoncOFySbix9wv8TYq/LJNk4IwNrwQa25Ch7LJseM4uJ
sk9DQ70K/R8CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUqol44o4EdXih8deISmZ3yj/O0ocwHwYDVR0jBBgwFoAU
5QABMHs3He/m5wwLyfUozf3cYiIwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
Y3NF/Yhow1L4iCjqUjADz7iUbC481m7x6eimwfbOZU7WIUtdN1yisq3c54AwIeH9
gp0flxxJusK4QXtSx23ORRKV0Bdd8sZGFK07+IXTe+JprOgFRlOtHvHOIkTNTXRN
PTixe363fc1VVuBQ18JXwIR6mRUDsmklm4VfjXtQ0V0Gg+tL9hGNBzOLui/CeBVZ
R5Ok+gtAVmNFxQmo2/YZ5wViODkteXmzLRKSgC8/FmhV6WbPPyG7FczzeXnUSBa/
+SZ6NBHrVMhNeN4HYpKhSSF7Wnv4fKIkLS7+1J3d3xk+bb5XmyhLPp+dfTvrw5cT
azYsgCQlRSJgyORSirmpRQ==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvK1Nx75pvquRsM4gGCYEdqR+d9fUWPRfPmTknQgpmy3lRfWv
zJmXmqIkLm87d99o+tfuXc15gEhR4cuhyPy/Lw7rqcKkA2ZvweuFAG1HwF+5buMF
V3xMe1I1Gc7hOBNYzolf2dHsAeuZWqKF1GzPhsE9NMGDDe8QEuTnETulzTC91w3/
28K2ppkV9X3omXVCQXd27IXiUE54sqvFHubM7G4N5D2eQ09m9LejvG5uZT4lIMrv
jHwZZ8y+Ogtv2cpNY/qV4ezTUdtKrQ3CaUaoOkBnS4S9DyTlmSe19VmAnqGLFwDo
3PpwwqR8MfaFG8zBRQuSb4earOj10lOymS4ZNwIDAQABAoIBAAT9PDJM+bTeCpM3
UCfzUWjlvqZioa3cgGxA9L6mSZtd4lMwRP7PDPA822IS9OqdkMQZU6dNWKoov2mO
HfAXpuKSrW6mw/mHCuuA09qICT6wCVJCVJDUq50TNm5BRzlZYZ7MiSlUYL5IQZzg
8VMFsZMppvmvKE0FBlLJlMai4iaD2L/EwCkM34ydb3b0MxoF30EZJOx7Lg96joWW
Okter7J3cfoQvxzWgS/YsFlMq6O43DZ4cUAATC00Z7+1mbo7p66l5DutMg7wTXjA
1kBVt7/WPdTjAumeMj2FHuo1tW15WwwEr7j9HD+xcutvbk/PAoNp79+n4pSveqTk
PuldQAkCgYEAxOuIvjlJmTXNX1/uNG7wgr0TTnP7xCP/qyKCOQmp+VHocPijCbNx
/zN1viJiRGwYAw3UZFRSPomdLx7BqcDzwIO2rnBG2asV/q0xcSLjNI1t8sCv9fGG
wT1m/JS4avIWmNpoedF+9HGNd2c7BcRghfLIkGU5UpWhCbzZJsjZXuUCgYEA9Uio
knehDwoh0pf5dq5v4OgLOhreiLrqNIDWGj/uhlK1aLMRUkv4SWuZBfRNUVtPNYY8
dP7qKTvBN+83PoOVawDTp2WeoNn5+PjfRW6StcWj+OGRAO3jS9d9TJsup5hWR9wG
hiMkcWoZcH9X0sSwSI26B0VIMKqyhyLKMlpHOesCgYBFFBL+F/6XfmYzBOX9AsXg
Nw+kv88b+Tzg/dQMyjUUPwV5S991sbtVuOme71Tlh73MpHdTUrkfMwsu0m1BbWyU
ph/ZhY11Ii0vD/Z+J6zobIybUbjoX/fTpgSQqmMfMRl4OXXY9gLBIWxs7Iup9D+f
/ZEaBkhbjh3V2qeakW6feQKBgC5LDU2/eE1PWzzU5AdLOuBWyy+nPJLPvD42hrIj
mNAPMh/VlBJVNkIdJZ9jEWimdBelAyoNpoIrvfbhliqdSQkN+eRhIIQ5P52G0xTW
nqfh6mWhpO1o+Hoq7IIV08Nb1ATx+OU+IrWpEa4Syq+D4cV/wjl3EP3maZVpsoG4
WjMLAoGAXnjVoC/jzwaat9cbj09amL+FuWHe5MDFl6yMSd2j3RMIc2ZrLNcvFy0D
AmObgpRCnwfZZhjLH5KtX0p28Bum+hL/wq5ijrz9LJxt5ZkrPId1YH37Sbmms6ur
nU4f5kgSYwCPcihOvGY1UQrJdwNLX2RUo2Da+41Fq3az3glnzSk=
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       1c:e0:0b:21:08:fc:9d:4e:78:1b:97:f4:1d:46:97:1b:7d:90:1b:e6

/ $ vault write pki_int/revoke serial_number="1c:e0:0b:21:08:fc:9d:4e:78:1b:97:f4:1d:46:97:1b:7d:90:1b:e6"
Key                        Value
---                        -----
revocation_time            1581665285
revocation_time_rfc3339    2020-02-14T07:28:05.696216677Z

19. включить TLS
	1. Генерация серфтификата 
tls git:(kubernetes-vault) ✗ openssl genrsa -out vault_gke.key 4096
Generating RSA private key, 4096 bit long modulus
........................................++
................++
e is 65537 (0x10001)
	2.  Делаем запрос на сертификат
➜  tls git:(kubernetes-vault) ✗ openssl req -config vault_gke_csr.cnf -new -key vault_gke.key -nodes -out vault.csr
	3. Создаем csr.yaml  и получем сертификат

➜  tls git:(kubernetes-vault) ✗ k apply -f ./csr.yaml
certificatesigningrequest.certificates.k8s.io/vaultcsr created
➜  tls git:(kubernetes-vault) ✗ k get csr
NAME       AGE   REQUESTOR                  CONDITION
vaultcsr   11s   k.lobunko2otus@gmail.com   Pending
➜  tls git:(kubernetes-vault) ✗ k describe csr
Name:         vaultcsr
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"certificates.k8s.io/v1beta1","kind":"CertificateSigningRequest","metadata":{"annotations":{},"name":"vaultcsr"},"spec":{"groups":["system:authenticated"],"request":"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJRkpEQ0NBd3dDQVFBd2dZTXhFakFRQmdOVkJBTU1DV3h2WTJGc2FHOXpkREVVTUJJR0ExVUVDQXdMVG05MgpiM05wWW1seWMyc3hDekFKQmdOVkJBWVRBbEpWTVNJd0lBWUpLb1pJaHZjTkFRa0JGaE5yTG14dlluVnVhMjlBCloyMWhhV3d1WTI5dE1SQXdEZ1lEVlFRS0RBZEliMjFsVEdGaU1SUXdFZ1lEVlFRTERBdEVaWFpsYkc5d2JXVnUKZERDQ0FpSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnSVBBRENDQWdvQ2dnSUJBTDFpc1pyREJWTkNNcm93dWl5YQoyYmx1ODlSck9MS2RMMjJ4Y0xBRFgzcHpUUTczQnQxOVV1cC9QQmlDOEY4WUFsZFN6ZzJENUpuWCswMGI1VnFRCkF1YU9MV0NLREg4TU5nL1RaSkwwOFNLeDlUVDFyQ2pBQzdKTkp5MllTai9TSDZhY1YyY0ZyblgreFUzYjlzbkMKL2J0aDc2cG1RYVBxNGtCM3JDU3gzalJ6WFFsUXhGZFV6bEcyQ0tXcEdWVTBLVFVENzhVUXM2NGE4ejYrQ205TgorWm1RYjhtdVU4bVEwQ3V6MUpBTjgvQXEyczNRSjczNkx6QkhwQ0hGVDJpMFJldXpkOFhKak5xK09IbGRRVFNZCjRYYlltTDBIbytYelBaMXVBOXB1d05ZMnJzNXgvaUs5NVVQQWZLNjI0SEpkQlJJMWpWeU4wYVBCdXZXSWViWTcKQmpYazdkSk93ZGZWTUh5RmVzWDhpOVFyUlVmTjBETjkzVEwxWjdKY1VvU08yeEJIN3pxSDRUZk1HWG1jNFgycwp2U0VyeTNURHlnYjlOL2phdk93cnNzMnFQb0ZxUGFSVk5wR09JYkEvblplQzlFTFRBK0lGSTc2WU9WbTRJcFB4ClBYRkVxT2hTR0FZdi84NjNycmNPbTQ2MVhDRzVMcmJ5SkMrUG1yM1paR3AvZitCd1o2S21CZkZIc0prUlJmR2wKRjczOHRiQllzN3RDdHFjdVpUckU2MDVEeVcwMk5GREpKQmdjUjhaR0k4MTlpNnBBL0JoM1NVR1M2SnAxeEUrdAplMEdObUU0akUvWSt4ejhHQmNhaktNVDNXMWxkWUhGYVNtVGV5WkNGZHNmRlI0c3VTZWZWYkU4Ykx6Vkdmcy9oCkJpdUtvVm9scnUvZWpFUC9aQ2crUGJndEFnTUJBQUdnV3pCWkJna3Foa2lHOXcwQkNRNHhUREJLTUFrR0ExVWQKRXdRQ01BQXdDd1lEVlIwUEJBUURBZ1F3TUJNR0ExVWRKUVFNTUFvR0NDc0dBUVVGQndNQk1Cc0dBMVVkRVFRVQpNQktDQ1d4dlkyRnNhRzl6ZElJRmRtRjFiSFF3RFFZSktvWklodmNOQVFFTEJRQURnZ0lCQUhGN1dkUWJKV0h2CmpSUkU1K0pkV3lid1k1T3dGTWFEcVFoQXFDRTBhalpVZUpxd2F3RzhQQlkzamw2MzRYMHlQRGZob0hFWm0yVnEKQXllN201QW5TWHFjSm92aCtXOHF6WFA1S0NzOHUvbE9KekZKL25DVGRpa0RoaVZUSGRQQzNaZUhZVG9XaDFuMworWDdEZWF3LytUUk1BVFVvZmxKZG1QUnFBeGhsa3FNdlJPY00xVTVpMDBqdkNmaitLY0pGc0hDNHlDR2pTVzNuCkJ0Nnp2KzZrZEFKM3BodjdCSTEyOVNtU24rdVU1T1p1R1loV1FML3l3QWNmYXNZd3lkbUlhZ0JyZVMvMmpCb1gKOTRjUVJiWVBDNVZqVEcrMkpvb0tIakozV0k4MCtPUzVVbnJMYlphc0RkbERrTzgyVFN5WnpnZVV0dVRDZGYxbgpmUlFuTEQvQnphUzV6QlZ3NTZVeldQcnRoWmc0TzhpUFVka0NCdzZTZnY4cEF3MFRHTm5nNUFPSEFQWHZkOEY2Cm1SZG1FOGhBeGVKNlYyM2VFRVd6T1kvQWVwT3RVcVJzT0F1K0MyMmtLN09WY243a1NaK0dESGlrM25WQ2dlQ0UKekJRbCt2cHBpMnFSVzRFNUswYmJYVUNMTUoreHc3TlhnRjg2ZnJDbE1hbm5EUEE1YTcwWDYwcDM1dVpLa0VCLwp4RU52bXhtOGd4QkM0UnBUbW11RkN2YWNrcmIydFVWSFA5SDB5QUFIcWdBYUhFRW9LU1hFTmNuYjZLeFI5dzgxCkdNMC9Mb2RtckJoendKbEp6c0l2REFGQ3k0V3BVU0xIaHhPc1RuNms0SUtwRThBQ3dJbXhPOTF5TG5mRENNZU8KeUFuTjQyOGxpYlFmUy8vd1hjeEt2RUZaTTdnekhCZGQKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==","usages":["digital signature","key encipherment","server auth"]}}

CreationTimestamp:  Mon, 17 Feb 2020 11:34:09 +0700
Requesting User:    k.lobunko2otus@gmail.com
Status:             Pending
Subject:
  Common Name:          localhost
  Serial Number:
  Organization:         HomeLab
  Organizational Unit:  Development
  Country:              RU
  Province:             Novosibirsk
Subject Alternative Names:
         DNS Names:  localhost
                     vault
Events:  <none>
➜  tls git:(kubernetes-vault) ✗ k certificate approve vaultcsr
certificatesigningrequest.certificates.k8s.io/vaultcsr approved
➜  tls git:(kubernetes-vault) ✗ k get csr
NAME       AGE    REQUESTOR                  CONDITION
vaultcsr   109s   k.lobunko2otus@gmail.com   Approved,Issued

➜  tls git:(kubernetes-vault) ✗ kubectl get csr vaultcsr -o jsonpath='{.status.certificate}' | base64 --decode > vault.crt
	4. создаем секрет из сертификата и ключа
➜  tls git:(kubernetes-vault) ✗ kubectl create secret tls vault-certs --cert=vault.crt --key=vault_gke.key
secret/vault-certs created
	5. Удаляем предыдущую установку vault и ставим заново c https

➜  tls git:(kubernetes-vault) ✗ helm delete vault
release "vault" uninstalled
➜  kubernetes-vault git:(kubernetes-vault) ✗ helm install vault -f ./tls/vault_values_tls.yaml ./vault-helm
NAME: vault
LAST DEPLOYED: Mon Feb 17 12:24:57 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get vault

➜  tls git:(kubernetes-vault) ✗ k get pods
NAME                                    READY   STATUS    RESTARTS   AGE
consul-consul-bf9wm                     1/1     Running   0          6d20h
consul-consul-q7hvt                     1/1     Running   0          6d20h
consul-consul-server-0                  1/1     Running   0          6d20h
consul-consul-server-1                  1/1     Running   0          6d20h
consul-consul-server-2                  1/1     Running   0          6d20h
consul-consul-v5wfr                     1/1     Running   0          6d20h
tmp                                     1/1     Running   1          5d20h
vault-0                                 0/1     Running   0          4m14s
vault-1                                 0/1     Running   0          4m14s
vault-2                                 0/1     Running   0          4m13s

➜  tls git:(kubernetes-vault) ✗ k get service
NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                                                   AGE
consul-consul-dns          ClusterIP      10.56.15.105   <none>           53/TCP,53/UDP                                                             6d20h
consul-consul-server       ClusterIP      None           <none>           8500/TCP,8301/TCP,8301/UDP,8302/TCP,8302/UDP,8300/TCP,8600/TCP,8600/UDP   6d20h
consul-consul-ui           ClusterIP      10.56.5.201    <none>           80/TCP                                                                    6d20h
kubernetes                 ClusterIP      10.56.0.1      <none>           443/TCP                                                                   6d21h
vault                      ClusterIP      10.56.5.210    <none>           8200/TCP,8201/TCP                                                         2m45s
vault-agent-injector-svc   ClusterIP      10.56.8.129    <none>           443/TCP                                                                   2m44s
vault-ui                   LoadBalancer   10.56.0.247    35.228.175.177   8200:32138/TCP                                                            2m45s

Идем браузером по адресу: https://35.228.175.177:8200/, все успешно зашли по https, srceenshot приложил 

➜  kubernetes-vault git:(kubernetes-vault) ✗ ls -l tls/https_vault_screen.png
-rw-r--r--@ 1 kirill_lobunko  staff  2626242 17 фев 12:37 tls/https_vault_screen.png
