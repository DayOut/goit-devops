# DevOps Lessons: Terraform + Jenkins + Argo CD

Цей репозиторій демонструє базовий DevOps-процес із використанням **Terraform**, **Jenkins** та **Argo CD** для розгортання та доставки Django-проєкту в Kubernetes.

---

## 1. Terraform

Terraform використовується для створення та оновлення інфраструктурних ресурсів у Kubernetes.

### Кроки виконання

1. Ініціалізація Terraform:
```bash
terraform init
```

2. Перегляд плану змін:
```bash
terraform plan
```

3. Застосування змін:
```bash
terraform apply
```

> Після виконання `terraform apply` Jenkins та всі необхідні ресурси будуть створені або оновлені в Kubernetes.

---

## 2. Jenkins

Після розгортання інфраструктури необхідно перевірити коректність роботи Jenkins job.

### Отримання доступу до Jenkins

1. Отримати пароль адміністратора Jenkins:
```bash
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```

2. Отримати URL сервісу Jenkins:
```bash
kubectl get svc -n jenkins jenkins
```

3. Відкрити Jenkins у браузері та увійти:
- Логін: `admin`
- Пароль: отриманий на попередньому кроці

### Перевірка seed-job

- Відкрити `seed-job` у Jenkins.
- Переконатися, що job створює pipeline для Django-проєкту.
- Pipeline має:
  - підключатися до GitHub;
  - збирати Docker-образ;
  - публікувати образ у Amazon ECR.

---

## 3. Argo CD

Argo CD використовується для GitOps-синхронізації застосунку в Kubernetes.

### Доступ до Argo CD UI

1. Виконати port-forward:
```bash
kubectl port-forward svc/argo-cd-server -n argocd 8080:443
```

2. Відкрити в браузері:
```
https://localhost:8080
```

### Авторизація

- Користувач: `admin`
- Отримати пароль:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Синхронізація застосунку

1. У веб-інтерфейсі Argo CD вибрати застосунок Django-проєкту.
2. Натиснути **Sync** з параметрами:
   - `Revision`: `final-project`
   - `Prune`: enabled
   - `Apply Out of Sync Only`: enabled
   - `Server-Side Apply`: enabled
   - `Prune Propagation Policy`: `foreground`
3. Натиснути **Synchronize / Apply**.

### Перевірка результату

- Статус застосунку має бути **Synced** і **Healthy**.
- У UI можна переглянути всі створені ресурси:
  - Deployment
  - Service
  - ConfigMap
  - HPA

---

## Результат

Після виконання всіх кроків:
- інфраструктура створена через Terraform;
- Jenkins автоматично будує та публікує Docker-образ;
- Argo CD синхронізує застосунок у Kubernetes згідно з GitOps-підходом.

---

### Назва модуля та короткий опис

```markdown
# Terraform RDS Module

Універсальний модуль для створення бази даних AWS:
- Підтримка Aurora та звичайної RDS (`use_aurora`).
- Створює DB Subnet Group, Security Group, Parameter Group.
- Підтримує налаштування engine, версії, класу інстансу, multi-AZ.
```

---

### Приклад використання

```hcl
module "rds" {
  source      = "./modules/rds"
  
  use_aurora       = false       # true для Aurora, false для RDS
  engine           = "postgres"
  engine_version   = "17.2"
  instance_class   = "db.t3.medium"
  multi_az         = true
  db_name          = "myapp"
  password         = "secure_password"
  subnet_ids       = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
  vpc_id           = "vpc-xxxx"
  tags             = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

---

### Опис змінних

- **`use_aurora`**
  - Тип: `bool`
  - Значення за замовчуванням: `false`
  - Опис:
    - Визначає, чи буде використовуватися Amazon Aurora.
    - Якщо `false` — створюється звичайна RDS-інстанція.

- **`engine`**
  - Тип: `string`
  - Значення за замовчуванням: `"postgres"`
  - Опис:
    - Тип рушія бази даних.
    - Підтримувані значення: `postgres`, `mysql` тощо.

- **`engine_version`**
  - Тип: `string`
  - Значення за замовчуванням: `"17.2"`
  - Опис:
    - Версія обраного рушія бази даних.
    - Повинна відповідати підтримуваним версіям у провайдері.

- **`instance_class`**
  - Тип: `string`
  - Значення за замовчуванням: `"db.t3.medium"`
  - Опис:
    - Клас інстансу для RDS.
    - Визначає ресурси (CPU, RAM) бази даних.

- **`multi_az`**
  - Тип: `bool`
  - Значення за замовчуванням: `true`
  - Опис:
    - Увімкнення Multi-AZ розгортання.
    - Забезпечує підвищену відмовостійкість.

- **`db_name`**
  - Тип: `string`
  - Значення за замовчуванням: `"myapp"`
  - Опис:
    - Ім’я бази даних, що буде створена.

- **`password`**
  - Тип: `string`
  - Значення за замовчуванням: не задано
  - Опис:
    - Пароль користувача `postgres`.
    - Рекомендується передавати через змінні середовища або secrets.

- **`subnet_ids`**
  - Тип: `list(string)`
  - Значення за замовчуванням: `[]`
  - Опис:
    - Список ID підмереж.
    - Використовується для створення DB Subnet Group.

- **`vpc_id`**
  - Тип: `string`
  - Значення за замовчуванням: не задано
  - Опис:
    - Ідентифікатор VPC.
    - В межах цієї VPC буде створено ресурси.

- **`tags`**
  - Тип: `map(string)`
  - Значення за замовчуванням: `{}`
  - Опис:
    - Набір тегів для створюваних ресурсів.
    - Дозволяє групувати та ідентифікувати інфраструктуру.

---

### Як змінити конфігурацію

* **Тип БД та engine:** змінюємо `use_aurora` і `engine`.
* **Версія engine:** `engine_version`.
* **Клас інстансу:** `instance_class`.
* **Multi-AZ:** `multi_az = true/false`.
* **Subnet group та VPC:** передаємо `subnet_ids` і `vpc_id`.

-----

## 4 Налаштування Grafana та Prometheus
```
kubectl create namespace monitoring
```

### 4.1. Встановлення Prometheus та Grafana

Додайте репозиторій Prometheus Community:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

-----

### 4.2. Доступ до Grafana UI

Отримайте URL Grafana Service:

```bash
kubectl get svc -n monitoring
```

Знайдіть Service типу **`LoadBalancer`** (або `NodePort`) для Grafana, щоб отримати зовнішню URL-адресу.

Виконайте порт-форвардинг (якщо не використовуєте Load Balancer):

```bash
kubectl port-forward svc/<GRAFANA_SVC_NAME> 8080:80 -n monitoring
# Далі відкрийте http://localhost:8080
```

Отримайте пароль Grafana (якщо встановлено через Helm):

```bash
kubectl get secret --namespace monitoring <GRAFANA_SECRET_NAME> -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# Логін за замовчуванням: admin
```

-----

### 4.3. Налаштування Джерела Даних (Data Source)

1.  Увійдіть у Grafana (зазвичай пароль `admin`).

2.  Перейдіть до **Configuration → Data Sources**.

3.  Натисніть **Add data source** та виберіть **Prometheus**.

4.  **Введіть Prometheus Server URL:**
    Оскільки Prometheus і Grafana знаходяться в одному кластері (EKS), використовуйте внутрішній Service DNS:

    ```
    http://<PROMETHEUS_SVC_NAME>.monitoring.svc.cluster.local:9090
    ```

    > Якщо Prometheus встановлений як `prometheus-server`, URL буде:
    > `http://prometheus-server.monitoring.svc.cluster.local:9090`

5.  Натисніть **Save & test**. Має з'явитися повідомлення: `Data source is working`.


-----

### 4.4. Імпорт Дашборда Моніторингу

1.  У Grafana натисніть **`+` (Create) → Import**.
2.  Використовуйте стандартний ID для моніторингу наприклад Kubernetes/Kube-State-Metrics:
      * **ID:** `13337`
3.  Натисніть **Load**.
4.  На екрані конфігурації виберіть ваше щойно створене джерело даних **Prometheus**.
5.  Натисніть **Import** і перегляньте метрики кластера.