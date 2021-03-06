# Дипломный практикум в Yandex.Cloud

- [Дипломный практикум в Yandex.Cloud](#дипломный-практикум-в-yandexcloud)
  - [Цели](#цели)
  - [Этапы выполнения](#этапы-выполнения)
    - [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
    - [Создание Kubernetes кластера](#создание-kubernetes-кластера)
    - [Создание тестового приложения](#создание-тестового-приложения)
    - [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
    - [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  - [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  - [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)
  - [Решение](#решение)
    - [Ссылки](#ссылки)

---

## Цели

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Этапы выполнения

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:

1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:

1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---

## Как правильно задавать вопросы дипломному руководителю?

Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в
  материалах курса и ДЗ и только после этого спрашивать у дипломного
  руководителя. Скилл поиска ответов пригодится вам в профессиональной
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного
  списка. Так дипломному руководителю будет проще отвечать на каждый из
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой
  покажите, где не получается.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось».
  Дипломный руководитель не сможет ответить на такой вопрос без
  дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания,
  своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

---

## Решение

Все действия будут производиться на домашней машине с ArchLinux.  
Для начала подготовим системные переменные для Yandex Cloud и Gitlab:  

```bash
export YC_STORAGE_ACCESS_KEY="XXXXXXXXXXXXXX-XXXXXXXXXX"
export YC_STORAGE_SECRET_KEY="XXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export YC_SERVICE_ACCOUNT_KEY_FILE="/home/wizard/.yckey.json"
export GITLAB_PRIVATE_TOKEN="xxxxx-XXXXXXXXXXXXXXXXXXXX"
export GITLAB_AGENT_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```  

Создадим руками через web-интерфейс YC s3 backet и проинициализируем terraform backend:  

```bash
terraform init -backend-config "access_key=$YC_STORAGE_ACCESS_KEY" -backend-config "secret_key=$YC_STORAGE_SECRET_KEY"
```  

![YC s3 backet](./img/1.png)  
![YC s3 backet](./img/1.1.png)  

Напишем **[манифесты для terraform](/terraform)**  
Подключимся к `app.terraform.io` через анонимный прокси, настроим там наш репозиторий с терраформом и проверим как всё само работает:  

![YC s3 backet](./img/2.png)  
![YC s3 backet](./img/3.png)  
![YC s3 backet](./img/4.png)  
![YC s3 backet](./img/5.png)  

Установим kubespray и **[напишем скрипт](/terraform/generate_inventory.sh)**, который будет генерировать **[hosts.yaml (инвентори для kubespray)](/kubespray/hosts.yaml)** из развернутой terraform-ом инфраструктуры.  
Напишем скрипты (**[1](./setup_k8s.sh), [2](./terraform/get_k8s_config.sh)**), которые будут:

- подготавливать инвентори для kubespray из шаблона,
- копировать сгенерированный `hosts.yaml` в созданный инвентори,
- включать поддержку ingress-controller,
- менять имя кластера,
- создавать кластер K8S с помощью kubespray,
- копировать `.kube/config` с control plane созданного kubespray кластера в локальный каталог для использования с kubectl,
- копировать `.kube/config` с control plane созданного kubespray кластера в переменную в gitlab для использования в pipeline с qbec и kubectl,
- подключаться к кластеру K8S, смотреть, что всё работает, поды есть,
- устанавливать `kube-prometheus`,
- устанавливать `gitlab agent` в кластер,
- создавать qbec манифест тестового приложения из шаблона,
- создавать namespace в K8S с тем же именем что и `terraform workspace`,
- применять манифест `qbec` в кластер K8S в соответствующее `namespace`,
- смотреть, что `pod` с тестовым приложением задеплоился,
- выводить в финале адреса ресурсов кластера.

Запустим стартовый скрипт **[setup_k8s.sh](./setup_k8s.sh)**, будем ждать и любоваться как поднимается инфраструктура, кластер, деплоятся приложения и т.д.:  

![YC s3 backet](./img/6.1.png)  
![YC s3 backet](./img/6.2.png)  
![YC s3 backet](./img/6.3.png)  
![YC s3 backet](./img/6.4.png)  
![YC s3 backet](./img/6.5.png)  
![YC s3 backet](./img/6.6.png)  
![YC s3 backet](./img/6.7.png)  
![YC s3 backet](./img/6.8.png)  
![YC s3 backet](./img/6.9.png)  

Сходим на Yandex Cloud, посмотрим на поднявшуюся инфраструктуру:  

![YC s3 backet](./img/7.1.png)  
![YC s3 backet](./img/7.2.png)  
![YC s3 backet](./img/7.3.png)  
![YC s3 backet](./img/7.4.png)  
![YC s3 backet](./img/7.5.png)  
![YC s3 backet](./img/7.6.png)  
![YC s3 backet](./img/7.7.png)  

Подключимся к свежеподнятому K8S кластеру (с которого скрипт любезно достал `.kube/config` и указал его как `KUBECONFIG` чтобы у нас подключение происходило куда нужно) и посмотрим на него:  

![YC s3 backet](./img/8.1.png)  
![YC s3 backet](./img/8.2.png)  
![YC s3 backet](./img/8.3.png)  
![YC s3 backet](./img/8.4.png)  
![YC s3 backet](./img/8.5.png)  

У нас в кластер и наше тестовое приложение задеплоилось:  

![YC s3 backet](./img/9.1.png)  

И `kube-prometheus` уже работает:  

![YC s3 backet](./img/10.1.png)  
![YC s3 backet](./img/10.2.png)  

Поменяем что-нибудь в репозитории с нашим тестовым приложением и посмотрим, как на `gitlab` отработает `pipeline`, соберет новый `docker image` и задеплоит приложение в кластер:  

![YC s3 backet](./img/11.1.png)  
![YC s3 backet](./img/11.2.png)  
![YC s3 backet](./img/11.3.png)  
![YC s3 backet](./img/11.5.png)  
![YC s3 backet](./img/11.4.png)  

### Ссылки

Тестовое приложение доступно по адресу: **[http://pirozhkov-aa.ru](http://pirozhkov-aa.ru)**  
К `Grafana` можно подключиться по ссылке: **[http://k8s.pirozhkov-aa.ru](http://k8s.pirozhkov-aa.ru)**  с логином: `admin` и паролем: `ADMIN123456!`  
Репозиторий тестового приложения: **[https://gitlab.com/tabwizard/nginxn](https://gitlab.com/tabwizard/nginxn)**  
**[Docker image](https://hub.docker.com/repository/docker/tabwizard/nginxn)** для тестового приложения  
**[Репозиторий](https://gitlab.com/tabwizard/k8s-tools)** и **[Docker image](https://hub.docker.com/repository/docker/tabwizard/k8s-tools)** для деплоя тестового приложения в `gitlab pipeline`  
Репозиторий `qbec` с настройками для кластера: **[webtestapp](https://gitlab.com/tabwizard/nginxn/-/tree/main/webtestapp)**  
Репозиторий **[Terraform](https://gitlab.com/tabwizard/netology_graduation_project/-/tree/main/terraform)**  
Репозиторий `kubespray` полностью дефолтный за исключением **[нескольких файлов инвентори для kubespray](https://gitlab.com/tabwizard/netology_graduation_project/-/tree/main/kubespray)**  
