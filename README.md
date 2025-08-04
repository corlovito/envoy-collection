# Ansible Roles for Envoy Proxy

Этот репозиторий содержит Ansible роли для установки и настройки Envoy Proxy с автоматической установкой BIRD BGP.

**Требования:** Vagrant и libvirt должны быть установлены системно.

## Структура проекта

```
project/
├── roles/
│   ├── envoy-install/     # Роль для установки Envoy
│   └── envoy-config/      # Роль для конфигурации Envoy
├── playbooks/
│   ├── deploy-envoy.yml           # Полная установка и настройка
│   ├── configure-envoy.yml        # Только настройка конфигурации
│   ├── install-envoy-only.yml     # Только установка
│   ├── cleanup-envoy.yml          # Очистка установки
│   └── inventory.yml              # Инвентарь хостов
├── molecule/                      # Тесты Molecule
├── requirements.yml               # Зависимости ролей
└── README.md
```

## Структура ролей

### 1. `roles/envoy-install` - Установка Envoy
**Назначение:** Устанавливает Envoy Proxy на систему

**Функции:**
- Создание пользователя и группы envoy
- Скачивание и установка бинарного файла Envoy
- Создание systemd сервиса
- Настройка директорий для логов
- **Автоматическая установка BIRD BGP** через dependencies
- **Поддержка Hot Restart** для zero-downtime обновлений

**Переменные:**
- `envoy_version` - версия Envoy (по умолчанию: "1.28.0")
- `envoy_bin_path` - путь к бинарному файлу (по умолчанию: "/usr/local/bin")
- `envoy_user` - пользователь для запуска (по умолчанию: "envoy")
- `envoy_group` - группа пользователя (по умолчанию: "envoy")
- `envoy_use_hot_restart` - включить hot restart (по умолчанию: true)

### 2. `roles/envoy-config` - Конфигурация Envoy
**Назначение:** Настраивает конфигурацию Envoy Proxy

**Функции:**
- Создание конфигурационного файла из шаблона
- Настройка admin интерфейса
- Настройка listeners и clusters
- Поддержка health checks
- **Автоматический hot reload** при изменении конфигурации

**Переменные:**
- `envoy_config_template` - выбор шаблона конфигурации (по умолчанию: "envoy-loadbalancer.yaml.j2")
- `envoy_admin_host` - адрес admin интерфейса (по умолчанию: "0.0.0.0")
- `envoy_admin_port` - порт admin интерфейса (по умолчанию: 9901)
- `envoy_listeners` - список listeners с расширенными настройками
- `envoy_clusters` - список clusters с health checks

## Использование

### Базовое использование:
```yaml
---
- name: Install and configure Envoy
  hosts: all
  become: true
  
  roles:
    - role: envoy-install
    - role: envoy-config
```

### Расширенная конфигурация:
```yaml
---
- name: Install and configure Envoy with advanced settings
  hosts: all
  become: true
  
  vars:
    envoy_version: "1.28.0"
    envoy_admin_host: "{{ ansible_default_ipv4.address }}"
    
    # Множественные listeners
    envoy_listeners:
      - name: web_listener
        address: "0.0.0.0"
        port: 80
        cluster: web_cluster
      - name: api_listener
        address: "0.0.0.0"
        port: 8080
        route_prefix: "/api"
        cluster: api_cluster
    
    # Кластеры с health checks
    envoy_clusters:
      - name: web_cluster
        lb_policy: ROUND_ROBIN
        health_checks:
          - timeout: "1s"
            interval: "10s"
            path: "/health"
        endpoints:
          - address: "10.0.1.10"
            port: 8080
          - address: "10.0.1.11"
            port: 8080
      
      - name: api_cluster
        lb_policy: LEAST_REQUEST
        health_checks:
          - timeout: "2s"
            interval: "15s"
            path: "/api/health"
        endpoints:
          - address: "10.0.1.20"
            port: 3000
          - address: "10.0.1.21"
            port: 3000

  roles:
    - role: envoy-install
    - role: envoy-config
```

### Запуск playbooks:
```bash
# Полная установка и настройка
ansible-playbook -i playbooks/inventory.yml playbooks/deploy-envoy.yml

# Только установка
ansible-playbook -i playbooks/inventory.yml playbooks/install-envoy-only.yml

# Только настройка конфигурации
ansible-playbook -i playbooks/inventory.yml playbooks/configure-envoy.yml

# Очистка
ansible-playbook -i playbooks/inventory.yml playbooks/cleanup-envoy.yml
```

## Тестирование

### Настройка окружения для Molecule:

```bash
# Создать виртуальное окружение
python -m venv .venv
source .venv/bin/activate

# Установить Python зависимости
pip install -r requirements.txt

# Установить Ansible роли (вариант 1: с переменной окружения)
export GITLAB_TOKEN=your_token_here
envsubst < requirements.tmpl > requirements.yml

ansible-galaxy install -r requirements.yml
```

### Запуск тестов Molecule:
```bash
molecule test # Полный тест - шаги dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
molecule converge  # Установка и настройка
molecule verify    # Проверки
molecule destroy   # Очистка
