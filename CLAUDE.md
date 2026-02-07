# Claude Project Guide - Árboles Info Maps

Guía para que Claude y otras herramientas de IA trabajen eficientemente en este proyecto Django de visualización de árboles de OSM.

## Comandos Principales (Makefile)

### Desarrollo y Ejecución
- `make setup`: Configura el entorno virtual e instala dependencias.
- `make run`: Ejecuta el servidor Django localmente.
- `make dev`: Modo desarrollo con recarga automática.
- `make migrate`: Ejecuta las migraciones de base de datos.
- `make makemigrations`: Crea nuevas migraciones basadas en cambios en modelos.
- `make shell`: Accede al shell de Django (vía docker compose si está activo).

### Docker & Compose
- `make docker-build`: Construye la imagen Docker.
- `make compose-up`: Levanta los servicios (Django + PostgreSQL/PostGIS).
- `make compose-down`: Detiene los servicios.
- `make compose-migrate`: Ejecuta migraciones dentro del contenedor web.

### Calidad y Seguridad
- `make lint`: Verifica el código con linters (flake8, isort).
- `make format`: Formatea el código automáticamente (black, isort).
- `make test`: Ejecuta la suite de tests de Django.
- `make security-quick`: Ejecuta verificaciones rápidas de seguridad.
- `make security-full`: Ejecuta un escaneo completo de seguridad.

## Estructura del Proyecto

- `arboles_info_project/`: Configuración principal de Django (settings, urls, wsgi).
- `maps/`: Aplicación principal para la gestión y visualización de árboles.
- `osm/`: Aplicación para integración con OpenStreetMap (API Overpass).
- `templates/`: Plantillas HTML globales.
- `static/`: Archivos estáticos (CSS, JS).
- `scripts/`: Scripts de utilidad y seguridad.
- `manage.py`: Punto de entrada de gestión de Django.
- `Makefile`: Orquestación de comandos comunes.

## Guías de Estilo y Convenciones

- **Framework**: Django 5.2+.
- **Base de Datos**: SQLite (local) / PostgreSQL con PostGIS (Docker/Prod).
- **Frontend**: HTML5, CSS3, JavaScript puro (ES6+), Leaflet.js para mapas.
- **Python**: PEP 8, uso de `black` para formateo (100 caracteres por línea), `isort` para imports.
- **Geolocalización**: Uso de GeoDjango para el manejo de datos espaciales.
- **Seguridad**: Seguir las recomendaciones de Django y ejecutar `make security-quick` antes de proponer cambios significativos.

## Flujo de Trabajo Recomendado

1. Siempre verificar el estado con `make info`.
2. Al añadir modelos, crear migraciones con `make makemigrations`.
3. Antes de finalizar una tarea, ejecutar `make lint` y `make test`.
4. Si se introducen cambios en dependencias, actualizar `requirements.txt`.
