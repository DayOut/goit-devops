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
   - `Revision`: `lesson-9`
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

