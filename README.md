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
