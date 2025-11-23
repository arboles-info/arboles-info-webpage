# Makefile para comandos de desarrollo y seguridad
# Facilita la ejecución de scripts de seguridad y desarrollo

.PHONY: help install-security-tools security-quick security-full security-install clean-security-reports test-local docker-build docker-build-ci docker-test docker-run docker-clean docker-logs docker-stop docker-stop-all compose-up compose-down compose-down-volumes compose-logs compose-ps compose-restart compose-db-shell compose-db-create-extensions compose-migrate compose-makemigrations compose-run compose-shell

# Variables
PYTHON := python3
PIP := python3 -m pip
VENV := venv-security
VENV_DEV := venv
VENV_BIN := $(VENV_DEV)/bin
PIP_DEV := $(VENV_BIN)/pip
PYTHON_VENV := $(VENV_BIN)/python
MANAGE := manage.py
HOST := 0.0.0.0
PORT := 8000
DJANGO_SETTINGS := arboles_info_project.settings

# Colores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Ayuda por defecto
help: ## Mostrar esta ayuda
	@echo "$(GREEN)Comandos disponibles:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Comandos de seguridad
install-security-tools: ## Instalar herramientas de seguridad
	@echo "🔧 Instalando herramientas de seguridad..."
	@./scripts/install-security-tools.sh

security-quick: ## Ejecutar verificación rápida de seguridad (equivalente a security-quick.yml)
	@echo "🚀 Ejecutando verificación rápida de seguridad..."
	@bash -c "source $(VENV)/bin/activate && ./scripts/quick-security-check.sh"

security-full: ## Ejecutar verificación completa de seguridad (equivalente a security.yml)
	@echo "🔒 Ejecutando verificación completa de seguridad..."
	@bash -c "source $(VENV)/bin/activate && ./scripts/run-security-checks.sh"

security-install: ## Crear entorno virtual y instalar herramientas de seguridad
	@echo "📦 Creando entorno virtual para seguridad..."
	@$(PYTHON) -m venv $(VENV)
	@echo "🔧 Activando entorno virtual e instalando herramientas..."
	@bash -c "source $(VENV)/bin/activate && ./scripts/install-security-tools.sh"
	@echo "✅ Entorno de seguridad configurado. Para activar: source $(VENV)/bin/activate"

# Verificar dependencias del sistema
check-deps: ## Verificar dependencias del sistema
	@echo "$(YELLOW)🔍 Verificando dependencias del sistema...$(NC)"
	@echo ""
	@echo "$(BLUE)Python:$(NC)"
	@if command -v $(PYTHON) >/dev/null 2>&1; then \
		echo "  ✅ $(PYTHON) disponible: $$($(PYTHON) --version)"; \
	else \
		echo "  ❌ $(PYTHON) no encontrado"; \
	fi
	@echo ""
	@echo "$(BLUE)Pip:$(NC)"
	@if $(PYTHON) -m pip --version >/dev/null 2>&1; then \
		echo "  ✅ pip disponible: $$($(PYTHON) -m pip --version)"; \
	else \
		echo "  ❌ pip no encontrado"; \
	fi
	@echo ""
	@echo "$(BLUE)Virtualenv:$(NC)"
	@if $(PYTHON) -m venv --help >/dev/null 2>&1; then \
		echo "  ✅ python3-venv disponible"; \
	else \
		echo "  ❌ python3-venv no encontrado"; \
	fi
	@echo ""
	@echo "$(BLUE)Dependencias de Python:$(NC)"
	@if $(PYTHON) -c "import django" 2>/dev/null; then \
		echo "  ✅ Django disponible"; \
	else \
		echo "  ❌ Django no encontrado"; \
	fi
	@if $(PYTHON) -c "import httpx" 2>/dev/null; then \
		echo "  ✅ HTTPX disponible"; \
	else \
		echo "  ❌ HTTPX no encontrado"; \
	fi
	@if $(PYTHON) -c "import pydantic" 2>/dev/null; then \
		echo "  ✅ Pydantic disponible"; \
	else \
		echo "  ❌ Pydantic no encontrado"; \
	fi
	@echo ""
	@echo "$(BLUE)Recomendaciones:$(NC)"
	@if ! $(PYTHON) -m pip --version >/dev/null 2>&1; then \
		echo "  📦 Instalar pip: sudo apt install python3-pip"; \
	fi
	@if ! $(PYTHON) -m venv --help >/dev/null 2>&1; then \
		echo "  📦 Instalar venv: sudo apt install python3-venv"; \
	fi
	@if ! $(PYTHON) -c "import django" 2>/dev/null; then \
		echo "  📦 Instalar dependencias: make install-system"; \
	fi

# Crear virtualenv e instalar dependencias
setup: check-deps ## Crear virtualenv e instalar dependencias
	@echo "$(YELLOW)🔧 Configurando entorno...$(NC)"
	@if $(PYTHON) -m venv --help >/dev/null 2>&1; then \
		echo "$(YELLOW)Creando virtualenv...$(NC)"; \
		if $(PYTHON) -m venv $(VENV_DEV) 2>/dev/null; then \
			echo "$(GREEN)✅ Virtualenv creado$(NC)"; \
			echo "$(YELLOW)📦 Instalando dependencias...$(NC)"; \
			bash -c "source $(VENV_DEV)/bin/activate && pip install --upgrade pip && pip install -r requirements.txt"; \
			echo "$(GREEN)✅ Dependencias instaladas$(NC)"; \
			echo "$(YELLOW)Para activar el virtualenv ejecuta: source $(VENV_DEV)/bin/activate$(NC)"; \
		else \
			echo "$(RED)❌ Error creando virtualenv$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(RED)❌ python3-venv no disponible$(NC)"; \
		echo "$(YELLOW)Instalando dependencias del sistema...$(NC)"; \
		$(MAKE) install-system; \
	fi

# Verificar que pip está disponible
check-pip: ## Verificar que pip está disponible
	@if ! $(PYTHON) -m pip --version >/dev/null 2>&1; then \
		echo "$(RED)❌ pip no encontrado. Instala python3-pip:$(NC)"; \
		echo "$(YELLOW)sudo apt install python3-pip$(NC)"; \
		exit 1; \
	fi

# Verificar que el virtualenv existe y es válido
check-venv: ## Verificar que el virtualenv existe y es válido
	@if [ ! -d "$(VENV_DEV)" ]; then \
		echo "$(RED)❌ Virtualenv no encontrado. Ejecuta 'make setup' primero$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(VENV_BIN)/pip" ]; then \
		echo "$(RED)❌ Virtualenv corrupto. Ejecuta 'make clean-venv' y luego 'make setup'$(NC)"; \
		exit 1; \
	fi

# Verificar que las dependencias están disponibles
check-app-deps: ## Verificar que las dependencias están disponibles
	@if [ -f "$(VENV_BIN)/python" ]; then \
		PYTHON_CMD="$(PYTHON_VENV)"; \
	else \
		PYTHON_CMD="$(PYTHON)"; \
	fi; \
	if ! $$PYTHON_CMD -c "import django, httpx, pydantic" 2>/dev/null; then \
		echo "$(RED)❌ Faltan dependencias. Ejecuta 'make setup' o 'make install-system' primero$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(MANAGE)" ]; then \
		echo "$(RED)❌ manage.py no encontrado$(NC)"; \
		exit 1; \
	fi

# Instalar dependencias del sistema (sin virtualenv)
install-system: check-pip ## Instalar dependencias del sistema (sin virtualenv)
	@echo "$(YELLOW)📦 Instalando dependencias del sistema...$(NC)"
	$(PYTHON) -m pip install --user -r requirements.txt
	@echo "$(GREEN)✅ Dependencias instaladas del sistema$(NC)"
	@echo "$(YELLOW)Nota: Las dependencias se instalaron globalmente$(NC)"

# Comandos de desarrollo
install: check-venv ## Instalar dependencias en el virtualenv existente
	@echo "$(YELLOW)📦 Actualizando dependencias en virtualenv...$(NC)"
	@bash -c "source $(VENV_DEV)/bin/activate && pip install --upgrade pip && pip install -r requirements.txt"
	@echo "$(GREEN)✅ Dependencias actualizadas$(NC)"

run: check-app-deps ## Ejecutar la aplicación Django
	@echo "$(GREEN)🚀 Levantando Árboles Info Maps...$(NC)"
	@echo "$(YELLOW)📱 Aplicación disponible en:$(NC)"
	@echo "$(BLUE)   - http://localhost:$(PORT)$(NC)"
	@echo "$(BLUE)   - http://127.0.0.1:$(PORT)$(NC)"
	@echo "$(YELLOW)⏹️  Presiona Ctrl+C para detener$(NC)"
	@echo "$(YELLOW)💡 Variables de entorno: DEBUG=True (por defecto), ALLOWED_HOSTS=localhost,127.0.0.1 (por defecto)$(NC)"
	@echo ""
	@if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) runserver $(HOST):$(PORT); \
	else \
		$(PYTHON) $(MANAGE) runserver $(HOST):$(PORT); \
	fi

# Levantar en modo desarrollo (con recarga automática)
dev: check-app-deps ## Levantar la aplicación Django en modo desarrollo
	@echo "$(GREEN)🚀 Levantando Árboles Info Maps en modo desarrollo...$(NC)"
	@echo "$(YELLOW)📱 Aplicación disponible en:$(NC)"
	@echo "$(BLUE)   - http://localhost:$(PORT)$(NC)"
	@echo "$(BLUE)   - http://127.0.0.1:$(PORT)$(NC)"
	@echo "$(YELLOW)🔄 Recarga automática habilitada$(NC)"
	@echo "$(YELLOW)⏹️  Presiona Ctrl+C para detener$(NC)"
	@echo "$(YELLOW)💡 Variables de entorno: DEBUG=True (por defecto), ALLOWED_HOSTS=localhost,127.0.0.1 (por defecto)$(NC)"
	@echo ""
	@if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) runserver $(HOST):$(PORT); \
	else \
		$(PYTHON) $(MANAGE) runserver $(HOST):$(PORT); \
	fi

test: check-app-deps ## Ejecutar tests Django (si existen)
	@echo "$(YELLOW)🧪 Ejecutando tests...$(NC)"
	@if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) test; \
	else \
		$(PYTHON) $(MANAGE) test; \
	fi

migrate: check-app-deps ## Ejecutar migraciones de Django
	@echo "$(YELLOW)🔄 Ejecutando migraciones...$(NC)"
	@if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) migrate; \
	else \
		$(PYTHON) $(MANAGE) migrate; \
	fi

makemigrations: check-app-deps ## Crear migraciones de Django
	@echo "$(YELLOW)📝 Creando migraciones...$(NC)"
	@if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) makemigrations; \
	else \
		$(PYTHON) $(MANAGE) makemigrations; \
	fi

collectstatic: check-app-deps ## Recopilar archivos estáticos
	@echo "$(YELLOW)📦 Recopilando archivos estáticos...$(NC)"
	@if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) collectstatic --noinput; \
	else \
		$(PYTHON) $(MANAGE) collectstatic --noinput; \
	fi

# Verificar código con linters
lint: check-app-deps ## Verificar código con linters
	@echo "$(YELLOW)🔍 Verificando código...$(NC)"
	@$(PYTHON) -m pip install --user flake8 black isort 2>/dev/null || true
	@echo "$(YELLOW)📝 Verificando con flake8...$(NC)"
	@$(PYTHON) -m flake8 maps/ arboles_info_project/ --max-line-length=100 --ignore=E203,W503 || true
	@echo "$(YELLOW)📝 Verificando imports con isort...$(NC)"
	@$(PYTHON) -m isort maps/ arboles_info_project/ --check-only --diff || true
	@echo "$(GREEN)✅ Verificación completada$(NC)"

# Formatear código
format: check-app-deps ## Formatear código
	@echo "$(YELLOW)�� Formateando código...$(NC)"
	@$(PYTHON) -m pip install --user black isort 2>/dev/null || true
	@$(PYTHON) -m black maps/ arboles_info_project/ --line-length=100
	@$(PYTHON) -m isort maps/ arboles_info_project/
	@echo "$(GREEN)✅ Código formateado$(NC)"

# Comandos de limpieza
clean: ## Limpiar archivos temporales
	@echo "$(YELLOW)🧹 Limpiando archivos temporales...$(NC)"
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name "__pycache__" -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.log" -delete 2>/dev/null || true
	rm -rf .pytest_cache 2>/dev/null || true
	rm -rf .coverage 2>/dev/null || true
	rm -rf htmlcov 2>/dev/null || true
	rm -rf db.sqlite3 2>/dev/null || true
	rm -rf staticfiles 2>/dev/null || true
	@echo "$(GREEN)✅ Archivos temporales eliminados$(NC)"

# Limpiar virtualenv
clean-venv: ## Eliminar virtualenv
	@echo "$(YELLOW)🧹 Eliminando virtualenv...$(NC)"
	rm -rf $(VENV_DEV)
	@echo "$(GREEN)✅ Virtualenv eliminado$(NC)"

clean-security-reports: ## Limpiar reportes de seguridad
	@echo "🧹 Limpiando reportes de seguridad..."
	@rm -f *-report.json
	@rm -f security-summary.md

clean-all: clean clean-venv clean-security-reports ## Limpiar todos los archivos temporales y reportes
	@echo "$(GREEN)✅ Limpieza completa realizada$(NC)"

# Comandos de verificación
check-format: ## Verificar formato del código
	@echo "🎨 Verificando formato del código..."
	@if command -v black >/dev/null 2>&1; then \
		black --check .; \
	else \
		echo "⚠️  Black no está instalado. Instala con: pip install black"; \
	fi

check-lint: ## Verificar linting del código
	@echo "🔍 Verificando linting del código..."
	@if command -v flake8 >/dev/null 2>&1; then \
		flake8 .; \
	else \
		echo "⚠️  Flake8 no está instalado. Instala con: pip install flake8"; \
	fi

check-types: ## Verificar tipos del código
	@echo "🔍 Verificando tipos del código..."
	@if command -v mypy >/dev/null 2>&1; then \
		mypy .; \
	else \
		echo "⚠️  MyPy no está instalado. Instala con: pip install mypy"; \
	fi

# Comando combinado para verificación completa
check-all: check-format check-lint check-types security-quick ## Ejecutar todas las verificaciones

# Comandos de desarrollo con entorno virtual
dev-setup: ## Configurar entorno de desarrollo completo
	@echo "🚀 Configurando entorno de desarrollo..."
	@$(PYTHON) -m venv $(VENV_DEV)
	@bash -c "source $(VENV_DEV)/bin/activate && pip install --upgrade pip && pip install -r requirements.txt"
	@echo "✅ Entorno de desarrollo configurado. Para activar: source $(VENV_DEV)/bin/activate"

# Comandos de información
info: ## Mostrar información del proyecto
	@echo "$(GREEN)📋 Información del entorno:$(NC)"
	@echo "$(YELLOW)Python:$(NC) $$($(PYTHON) --version 2>/dev/null || echo 'No disponible')"
	@echo "$(YELLOW)Ubicación Python:$(NC) $$(which $(PYTHON) 2>/dev/null || echo 'No encontrado')"
	@if $(PYTHON) -m pip --version >/dev/null 2>&1; then \
		echo "$(YELLOW)Pip:$(NC) $$($(PYTHON) -m pip --version)"; \
	else \
		echo "$(YELLOW)Pip:$(NC) No disponible"; \
	fi
	@if [ -d "$(VENV_DEV)" ]; then \
		echo "$(YELLOW)Virtualenv:$(NC) $(VENV_DEV) (existe)"; \
		if [ -f "$(VENV_BIN)/python" ]; then \
			echo "$(YELLOW)Python en venv:$(NC) $$($(PYTHON_VENV) --version)"; \
		fi; \
	else \
		echo "$(YELLOW)Virtualenv:$(NC) No existe"; \
	fi
	@echo "$(YELLOW)Directorio actual:$(NC) $$(pwd)"
	@echo "$(YELLOW)Archivo principal:$(NC) $(MANAGE)"
	@if [ -f "$(MANAGE)" ]; then \
		echo "$(GREEN)✅ manage.py encontrado$(NC)"; \
	else \
		echo "$(RED)❌ manage.py no encontrado$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)Dependencias instaladas:$(NC)"
	@if [ -f "$(VENV_BIN)/python" ]; then \
		PYTHON_CMD="$(PYTHON_VENV)"; \
	else \
		PYTHON_CMD="$(PYTHON)"; \
	fi; \
	if $$PYTHON_CMD -c "import django" 2>/dev/null; then \
		DJANGO_VERSION=$$($$PYTHON_CMD -c "import django; print(django.get_version())" 2>/dev/null); \
		echo "  ✅ Django ($$DJANGO_VERSION)"; \
	else \
		echo "  ❌ Django"; \
	fi; \
	if $$PYTHON_CMD -c "import httpx" 2>/dev/null; then \
		echo "  ✅ HTTPX"; \
	else \
		echo "  ❌ HTTPX"; \
	fi; \
	if $$PYTHON_CMD -c "import pydantic" 2>/dev/null; then \
		echo "  ✅ Pydantic"; \
	else \
		echo "  ❌ Pydantic"; \
	fi

# Comandos de Git
git-status: ## Mostrar estado de Git
	@echo "📊 Estado de Git:"
	@git status --short

git-log: ## Mostrar últimos commits
	@echo "📝 Últimos commits:"
	@git log --oneline -10

# Comandos de Docker
DOCKER_IMAGE := arboles-info-maps
DOCKER_TAG ?= dev
DOCKER_SHA ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

docker-build: ## Construir imagen Docker (uso: make docker-build DOCKER_TAG=v1.0.0)
	@echo "$(GREEN)🐳 Construyendo imagen Docker...$(NC)"
	@if [ ! -f "Dockerfile" ]; then \
		echo "$(RED)⚠️  No se encontró Dockerfile$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📦 Imagen: $(DOCKER_IMAGE)$(NC)"
	@echo "$(YELLOW)🏷️  Tag: $(DOCKER_TAG)$(NC)"
	@echo "$(YELLOW)🔖 SHA: $(DOCKER_SHA)$(NC)"
	@docker build \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE):$(DOCKER_SHA) \
		.
	@echo "$(GREEN)✅ Imagen construida exitosamente$(NC)"
	@echo "$(BLUE)💡 Para ejecutar: make docker-run$(NC)"

docker-build-ci: ## Construir imagen Docker para CI/CD (con SHA, tag y latest)
	@echo "$(GREEN)🐳 Construyendo imagen Docker para CI/CD...$(NC)"
	@if [ ! -f "Dockerfile" ]; then \
		echo "$(RED)⚠️  No se encontró Dockerfile$(NC)"; \
		exit 1; \
	fi
	@SHA=$${CIRCLE_SHA1:-$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")}; \
	TAG=$${DOCKER_TAG:-$${CIRCLE_TAG:-latest}}; \
	echo "$(YELLOW)📦 Imagen: $(DOCKER_IMAGE)$(NC)"; \
	echo "$(YELLOW)🔖 SHA: $$SHA$(NC)"; \
	echo "$(YELLOW)🏷️  Tag: $$TAG$(NC)"; \
	docker build \
		-t $(DOCKER_IMAGE):$$SHA \
		-t $(DOCKER_IMAGE):$$TAG \
		-t $(DOCKER_IMAGE):latest \
		. && \
	echo "$(GREEN)✅ Imagen construida exitosamente$(NC)"

docker-test: ## Verificar que la imagen Docker se construyó correctamente
	@echo "$(GREEN)🧪 Verificando imagen Docker...$(NC)"
	@docker images | grep $(DOCKER_IMAGE) || (echo "$(RED)❌ Imagen no encontrada$(NC)" && exit 1)
	@docker inspect $(DOCKER_IMAGE):$(DOCKER_TAG) > /dev/null 2>&1 || \
		(docker inspect $(DOCKER_IMAGE):latest > /dev/null 2>&1 && echo "$(GREEN)✅ Imagen verificada (latest)$(NC)") || \
		(echo "$(RED)❌ No se pudo verificar la imagen$(NC)" && exit 1)
	@echo "$(GREEN)✅ Imagen verificada correctamente$(NC)"

docker-run: ## Ejecutar contenedor Docker (uso: make docker-run PORT=8080 DOCKER_TAG=dev)
	@echo "$(GREEN)🚀 Ejecutando contenedor Docker...$(NC)"
	@if [ ! -f "Dockerfile" ]; then \
		echo "$(RED)⚠️  No se encontró Dockerfile$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📱 Disponible en:$(NC)"
	@echo "$(BLUE)   - http://localhost:$(PORT)$(NC)"
	@echo "$(BLUE)   - http://127.0.0.1:$(PORT)$(NC)"
	@echo "$(YELLOW)⏹️  Presiona Ctrl+C para detener$(NC)"
	@echo "$(YELLOW)📦 Usando imagen: $(DOCKER_IMAGE):$(DOCKER_TAG)$(NC)"
	@trap 'echo "$(YELLOW)🛑 Deteniendo contenedor...$(NC)"; docker stop $$CONTAINER_ID 2>/dev/null || true; exit' INT TERM; \
	if ! docker images | grep -q "$(DOCKER_IMAGE).*$(DOCKER_TAG)"; then \
		echo "$(YELLOW)⚠️  Imagen $(DOCKER_IMAGE):$(DOCKER_TAG) no encontrada. Construyendo...$(NC)"; \
		make docker-build DOCKER_TAG=$(DOCKER_TAG); \
	fi; \
	CONTAINER_ID=$$(docker run -d -p $(PORT):8080 \
		-e SECRET_KEY="$$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' 2>/dev/null || echo 'django-insecure-dev-key')" \
		-e DEBUG="True" \
		-e ALLOWED_HOSTS="localhost,127.0.0.1,0.0.0.0" \
		--name arboles-info-maps-$$(date +%s) \
		$(DOCKER_IMAGE):$(DOCKER_TAG)); \
	if [ -z "$$CONTAINER_ID" ]; then \
		echo "$(RED)❌ Error al iniciar el contenedor$(NC)"; \
		echo "$(YELLOW)💡 Asegúrate de que la imagen $(DOCKER_IMAGE):$(DOCKER_TAG) existe$(NC)"; \
		echo "$(YELLOW)💡 Ejecuta: make docker-build DOCKER_TAG=$(DOCKER_TAG)$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)✅ Contenedor iniciado: $$CONTAINER_ID$(NC)"; \
	docker logs -f $$CONTAINER_ID

docker-clean: ## Eliminar imágenes Docker del proyecto
	@echo "$(YELLOW)🧹 Limpiando imágenes Docker...$(NC)"
	@docker images | grep $(DOCKER_IMAGE) | awk '{print $$3}' | xargs -r docker rmi -f 2>/dev/null || true
	@echo "$(GREEN)✅ Imágenes eliminadas$(NC)"

docker-logs: ## Ver logs de contenedores Docker en ejecución
	@echo "$(YELLOW)📋 Logs de contenedores Docker:$(NC)"
	@docker ps --filter "ancestor=$(DOCKER_IMAGE)" --format "{{.ID}}" | xargs -r docker logs -f || \
		echo "$(YELLOW)⚠️  No hay contenedores en ejecución$(NC)"

docker-stop: ## Detener todos los contenedores Docker del proyecto
	@echo "$(YELLOW)🛑 Deteniendo contenedores Docker...$(NC)"
	@CONTAINERS=$$(docker ps --filter "ancestor=$(DOCKER_IMAGE)" --format "{{.ID}}"); \
	if [ -z "$$CONTAINERS" ]; then \
		echo "$(YELLOW)⚠️  No hay contenedores en ejecución$(NC)"; \
	else \
		echo "$$CONTAINERS" | xargs docker stop; \
		echo "$$CONTAINERS" | xargs docker rm 2>/dev/null || true; \
		echo "$(GREEN)✅ Contenedores detenidos y eliminados$(NC)"; \
	fi

docker-stop-all: ## Detener y eliminar todos los contenedores (incluso detenidos)
	@echo "$(YELLOW)🧹 Deteniendo y eliminando todos los contenedores Docker del proyecto...$(NC)"
	@CONTAINERS=$$(docker ps -a --filter "ancestor=$(DOCKER_IMAGE)" --format "{{.ID}}"); \
	if [ -z "$$CONTAINERS" ]; then \
		echo "$(YELLOW)⚠️  No hay contenedores$(NC)"; \
	else \
		echo "$$CONTAINERS" | xargs docker rm -f 2>/dev/null || true; \
		echo "$(GREEN)✅ Contenedores eliminados$(NC)"; \
	fi

# Comandos de Docker Compose
COMPOSE_FILE := compose.yaml

compose-up: ## Iniciar servicios con Docker Compose
	@echo "$(GREEN)🚀 Iniciando servicios con Docker Compose...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Servicios iniciados$(NC)"
	@echo "$(YELLOW)💡 Para ver logs: make compose-logs$(NC)"
	@echo "$(YELLOW)💡 Para detener: make compose-down$(NC)"

compose-down: ## Detener servicios de Docker Compose
	@echo "$(YELLOW)🛑 Deteniendo servicios de Docker Compose...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ Servicios detenidos$(NC)"

compose-down-volumes: ## Detener servicios y eliminar volúmenes de Docker Compose
	@echo "$(YELLOW)🧹 Deteniendo servicios y eliminando volúmenes...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)✅ Servicios detenidos y volúmenes eliminados$(NC)"

compose-logs: ## Ver logs de servicios de Docker Compose
	@echo "$(YELLOW)📋 Logs de servicios:$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) logs -f

compose-ps: ## Ver estado de servicios de Docker Compose
	@echo "$(YELLOW)📊 Estado de servicios:$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) ps

compose-restart: ## Reiniciar servicios de Docker Compose
	@echo "$(YELLOW)🔄 Reiniciando servicios...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)✅ Servicios reiniciados$(NC)"

compose-db-shell: ## Acceder a shell de PostgreSQL
	@echo "$(YELLOW)🐘 Accediendo a PostgreSQL...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) exec db psql -U arboles_user -d arboles_info

compose-db-create-extensions: ## Crear extensiones PostGIS en la base de datos
	@echo "$(YELLOW)🗺️  Creando extensiones PostGIS...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@docker compose -f $(COMPOSE_FILE) exec -T db psql -U arboles_user -d arboles_info -c "CREATE EXTENSION IF NOT EXISTS postgis;"
	@docker compose -f $(COMPOSE_FILE) exec -T db psql -U arboles_user -d arboles_info -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"
	@echo "$(GREEN)✅ Extensiones PostGIS creadas$(NC)"

compose-migrate: check-app-deps ## Ejecutar migraciones con base de datos de Docker Compose
	@echo "$(YELLOW)🔄 Ejecutando migraciones con base de datos de Docker Compose...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)💡 Asegúrate de que los servicios estén corriendo: make compose-up$(NC)"
	@export DB_HOST=localhost DB_PORT=5432 DB_NAME=arboles_info DB_USER=arboles_user DB_PASSWORD=arboles_password; \
	if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) migrate; \
	else \
		$(PYTHON) $(MANAGE) migrate; \
	fi
	@echo "$(GREEN)✅ Migraciones ejecutadas$(NC)"

compose-makemigrations: check-app-deps ## Crear migraciones con base de datos de Docker Compose
	@echo "$(YELLOW)📝 Creando migraciones...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@export DB_HOST=localhost DB_PORT=5432 DB_NAME=arboles_info DB_USER=arboles_user DB_PASSWORD=arboles_password; \
	if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) makemigrations; \
	else \
		$(PYTHON) $(MANAGE) makemigrations; \
	fi
	@echo "$(GREEN)✅ Migraciones creadas$(NC)"

compose-run: check-app-deps compose-up ## Ejecutar aplicación Django con base de datos de Docker Compose
	@echo "$(GREEN)🚀 Levantando Árboles Info Maps con Docker Compose...$(NC)"
	@echo "$(YELLOW)📱 Aplicación disponible en:$(NC)"
	@echo "$(BLUE)   - http://localhost:$(PORT)$(NC)"
	@echo "$(BLUE)   - http://127.0.0.1:$(PORT)$(NC)"
	@echo "$(YELLOW)⏹️  Presiona Ctrl+C para detener$(NC)"
	@export DB_HOST=localhost DB_PORT=5432 DB_NAME=arboles_info DB_USER=arboles_user DB_PASSWORD=arboles_password; \
	if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) runserver $(HOST):$(PORT); \
	else \
		$(PYTHON) $(MANAGE) runserver $(HOST):$(PORT); \
	fi

compose-shell: check-app-deps ## Acceder a shell de Django con base de datos de Docker Compose
	@echo "$(YELLOW)🐚 Accediendo a shell de Django...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)❌ No se encontró $(COMPOSE_FILE)$(NC)"; \
		exit 1; \
	fi
	@export DB_HOST=localhost DB_PORT=5432 DB_NAME=arboles_info DB_USER=arboles_user DB_PASSWORD=arboles_password; \
	if [ -f "$(VENV_BIN)/python" ]; then \
		$(PYTHON_VENV) $(MANAGE) shell; \
	else \
		$(PYTHON) $(MANAGE) shell; \
	fi

# Comando por defecto
.DEFAULT_GOAL := help