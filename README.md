# Курсовая работа DevOps Нетология

### Terraform — инфраструктура

- VPC сеть `coursework-net`
- Подсети:
  - `public-a` (ru-central1-a) — для bastion и ALB
  - `private-a` (ru-central1-a) — для web1
  - `private-b` (ru-central1-b) — для web2
- Bastion host с публичным IP и открытым SSH
- Security groups:
  - `sg-bastion` — SSH из интернета (временно)
  - `sg-private` — SSH только от bastion
  - `sg-web` — HTTP от ALB + health checks от Yandex
  - `sg-alb` — HTTP из интернета + health checks для самого балансера
- Две машин:
  - `web1` (zone ru-central1-a, приватная подсеть)
  - `web2` (zone ru-central1-b, приватная подсеть)
- Application Load Balancer:
  - Target Group с web1 и web2
  - Backend Group с health check на /
  - HTTP Router и Virtual Host
  - Listener на порт 80 с публичным IP


### Ansible — конфигурация веб-серверов

- Плейбук `ansible/playbook.yml`:
  - Установка nginx
  - Развёртывание статичной HTML-страницы
  - `inventory.example.yml` — шаблон инвентаря для подключения через bastion
  - `ansible/inventory.yml` — локальный файл с реальными IP (в .gitignore)

Доступ к приватным серверам через bastion.


### Мониторинг

- Node Exporter установлен на всех ВМ (web1, web2, bastion, prometheus, grafana) — метрики системы (CPU, RAM, диск, сеть).
- Prometheus в Docker на bastion — собирает метрики с Node Exporter.
- Grafana в Docker на ВМ grafana  — дашборд Node Exporter Full (ID 1860).
- Доступ к Grafana: http://<grafana_public_ip>:3000.

Скрины прилагаются.

![1_monitoring.png](https://github.com/victorialugi/netology-devops-coursework/blob/main/1_monitoring.png)
![2_monitoring_prometheus.png](https://github.com/victorialugi/netology-devops-coursework/blob/main/2_monitoring_prometheus.png)
![3_monitoring_grafana.png](https://github.com/victorialugi/netology-devops-coursework/blob/main/3_monitoring_grafana.png)
![4_monitoring_grafana.png](https://github.com/victorialugi/netology-devops-coursework/blob/main/4_monitoring_grafana.png)
![5_monitoring_grafana.png](https://github.com/victorialugi/netology-devops-coursework/blob/main/5_monitoring_grafana.png)


### Логи

- Filebeat в Docker на web-серверах — собирает /var/log/nginx/access.log и error.log.
- Elasticsearch в Docker на ВМ kibana — хранит логи (single-node).
- Kibana в Docker на ВМ kibana (публичный IP) — просмотр логов.
- Доступ к Kibana: http://<kibana_public_ip>:5601



### Резервное копирование

- Ежедневные снапшоты дисков всех ВМ (bastion, web1, web2, prometheus, grafana, elasticsearch, kibana).
- Настройка: Terraform ресурс `yandex_compute_snapshot_schedule` в файле `terraform/snapshots.tf`.

Скрин Yandex Console Snapshot schedules прилагается.

![6_daily_snapshots.png](https://github.com/victorialugi/netology-devops-coursework/blob/main/6_daily_snapshots.png)
