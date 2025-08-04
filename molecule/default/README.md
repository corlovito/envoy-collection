# Тестирование роли envoy_roles с Molecule

Этот сценарий тестирует установку и настройку Envoy Proxy с использованием Molecule и Vagrant с libvirt.

## Структура тестирования

- `molecule.yml` - конфигурация молекулы с vagrant/libvirt
- `converge.yml` - playbook для применения роли
- `prepare.yml` - подготовка системы к установке

## Команды для тестирования

### Полный цикл тестирования
```bash
cd roles/envoy_roles/molecule/default
molecule test
```

### Пошаговое тестирование
```bash
cd roles/envoy_roles/molecule/default

# Создание VM
molecule create

# Подготовка системы
molecule prepare

# Применение роли
molecule converge

# Проверка результатов
molecule verify

# Удаление VM
molecule destroy
```

### Разработка
```bash
# Для разработки (не удаляет VM при ошибке)
molecule test --destroy=never

# Повторное применение роли
molecule converge
```

## Что тестируется

1. **Подготовка системы:**
   - Обновление пакетов
   - Установка необходимых зависимостей
   - Создание директорий для Envoy

2. **Установка Envoy:**
   - Скачивание и установка бинарного файла
   - Создание пользователя и группы envoy
   - Настройка systemd сервиса

3. **Конфигурация Envoy:**
   - Создание конфигурационного файла
   - Настройка admin интерфейса (порт 9901)
   - Настройка proxy (порт 8080)

## Переменные для тестирования

В `converge.yml` настроены следующие переменные:
- `envoy_version: "1.28.0"`
- `envoy_use_hot_restart: true`
- `envoy_admin_host: "0.0.0.0"`
- `envoy_admin_port: 9901`
- Простая конфигурация load balancer на порту 8080

## Требования

- Vagrant
- libvirt
- Molecule
- Ansible 