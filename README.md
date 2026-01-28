## ДЗ5 – Розгортання інфраструктури в AWS за допомогою Terraform

## Опис модульної структури

### Backend: S3 + DynamoDB (modules/s3-backend)
- Налаштовує S3-бакет для зберігання стану Terraform
- Створює таблицю DynamoDB, яка використовується для блокування state та запобігання конкурентним змінам

### Модуль VPC (modules/vpc)
- Ініціалізує Virtual Private Cloud з заданим CIDR-блоком
- Створює три публічні та три приватні підмережі
- Підключає Internet Gateway для доступу публічних підмереж до інтернету
- Налаштовує NAT Gateway для вихідного трафіку з приватних підмереж
- Конфігурує таблиці маршрутизації та зв’язує їх із підмережами

### Модуль ECR (modules/ecr)
- Створює Amazon ECR репозиторій для зберігання Docker-образів
- Вмикає автоматичне сканування образів на наявність вразливостей

## Команди

```bash
kubectl get nodes
```


### 2. Створення секрету з даними бази даних

Рекомендовано зберігати чутливі дані у Kubernetes Secret, а не в ConfigMap.

kubectl create secret generic django-db-secret \
  --from-literal=POSTGRES_DB=db_name \
  --from-literal=POSTGRES_USER=db_user \
  --from-literal=POSTGRES_PASSWORD=db_pass \
  --from-literal=DB_HOST=db \
  --from-literal=DB_PORT=5432


Після цього у Deployment можна підключити секрет через envFrom.secretRef.


### Перевірка Helm chart перед деплоєм
```bash
helm lint charts/app-name/
helm template app-name charts/app-name/ --values charts/app-name/values.yaml
```