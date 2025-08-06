#!/bin/bash
# Wrapper для molecule с автоматическим определением путей Python

# Определяем Python версию
if [ -n "$VIRTUAL_ENV" ]; then
    PYTHON_VERSION=$(python -c 'import sys; print(f"python{sys.version_info[0]}.{sys.version_info[1]}")')
    SITE_PACKAGES="$VIRTUAL_ENV/lib/$PYTHON_VERSION/site-packages"
else
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"python{sys.version_info[0]}.{sys.version_info[1]}")')
    SITE_PACKAGES="$PWD/.venv/lib/$PYTHON_VERSION/site-packages"
fi

# Экспортируем переменные окружения для Molecule
export ANSIBLE_STRATEGY_PLUGINS="$SITE_PACKAGES/ansible_mitogen/plugins/strategy"
export ANSIBLE_LIBRARY="$SITE_PACKAGES/molecule_vagrant/modules"

# Дополнительные переменные
export ANSIBLE_COLLECTIONS_PATH="${HOME}/.ansible/collections:/usr/share/ansible/collections"
export ANSIBLE_ROLES_PATH="${PWD}/roles:${HOME}/.ansible/roles"
export ANSIBLE_STRATEGY="mitogen_linear"
export ANSIBLE_CALLBACKS_ENABLED="ansible.posix.profile_tasks"

echo "Используется Python: $PYTHON_VERSION"
echo "Site-packages: $SITE_PACKAGES"

# Запускаем molecule с переданными аргументами
exec molecule "$@"