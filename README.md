# Árboles Info Maps 🌳

Una aplicación web desarrollada con **Django** para visualizar y gestionar información sobre árboles y tocones, utilizando datos de **OpenStreetMap (OSM)** y potentes capacidades de geolocalización.

## Características

- 🌳 **Visualización Geoespacial**: Mapa interactivo con Leaflet.js para mostrar árboles y tocones.
- 🗺️ **Integración OSM**: Obtención de datos en tiempo real mediante la API de Overpass.
- 📍 **GeoDjango**: Uso de capacidades espaciales avanzadas con PostGIS.
- 📱 **Diseño Responsive**: Interfaz adaptada a dispositivos móviles y escritorio.
- 🔒 **Seguridad**: Escaneos de seguridad integrados y mejores prácticas de Django.
- 🐳 **Dockerizado**: Entorno de desarrollo y producción listo para usar con Docker Compose.

## Tecnologías

- **Backend**: Django 5.2+ (Python)
- **Base de Datos**: SQLite (desarrollo local) / PostgreSQL + PostGIS (producción)
- **Frontend**: HTML5, CSS3, JavaScript (ES6+), Leaflet.js
- **Seguridad**: Semgrep, Safety, Bandit (vía scripts integrados)
- **Despliegue**: WhiteNoise para estáticos, Gunicorn, Docker

## Instalación y Configuración

El proyecto utiliza un `Makefile` para orquestar todas las tareas comunes.

### 1. Requisitos previos
Verifica que tienes las dependencias necesarias:
```bash
make check-deps
```

### 2. Configuración del entorno
Crea el entorno virtual e instala las dependencias:
```bash
make setup
```

### 3. Base de datos y migraciones
Prepara la base de datos (SQLite por defecto):
```bash
make migrate
```

## Uso

### Ejecución en desarrollo
Para iniciar el servidor con recarga automática:
```bash
make dev
```
La aplicación estará disponible en `http://localhost:8000`.

### Docker Compose
Si prefieres usar Docker (incluyendo base de datos PostgreSQL/PostGIS):
```bash
make compose-up
make compose-migrate
```

## Comandos Principales

### Desarrollo
- `make run`: Inicia el servidor Django.
- `make dev`: Servidor con recarga automática.
- `make lint`: Verifica el estilo del código.
- `make format`: Formatea el código automáticamente.
- `make security-quick`: Ejecución rápida de herramientas de seguridad.
- `make info`: Muestra información detallada del entorno.

### Testing (BDD/Specifications)
Este proyecto usa **Specification-Driven Development** con **Behave** (BDD):

- `make behave`: Ejecuta todos los tests BDD.
- `make behave-critical`: Ejecuta solo tests críticos.
- `make behave-no-slow`: Ejecuta tests excluyendo los lentos.
- `make pytest`: Ejecuta tests con pytest.
- `make test-all`: Ejecuta todos los tests (Django + BDD + pytest).
- `make test-coverage`: Ejecuta tests con reporte de cobertura.

**Ver documentación completa**: [docs/BDD-GUIDE.md](docs/BDD-GUIDE.md)

**Ejemplo de uso**:
```bash
# Ver todas las especificaciones
ls features/*.feature

# Ejecutar tests BDD
make behave

# Ejecutar solo tests críticos
make behave-critical

# Ver cobertura
make test-coverage
```

## Estructura del Proyecto

- `arboles_info_project/`: Configuración global de Django.
- `maps/`: Aplicación principal de gestión de mapas y datos.
- `osm/`: Módulo de integración con OpenStreetMap.
- `features/`: Especificaciones BDD (Behavior-Driven Development).
  - `*.feature`: Especificaciones en formato Gherkin.
  - `steps/`: Implementaciones de los pasos de prueba.
- `tests/`: Tests unitarios y de integración (pytest).
  - `factories.py`: Generadores de datos de prueba.
  - `conftest.py`: Configuración y fixtures de pytest.
- `static/`: Archivos estáticos (CSS, JS logic).
- `templates/`: Plantillas HTML.
- `scripts/`: Utilidades de seguridad y mantenimiento.
- `docs/`: Documentación del proyecto.

## Contribución

1. Crea un fork del repositorio.
2. Crea una rama para tu funcionalidad (`git checkout -b feature/nueva-funcionalidad`).
3. Realiza tus cambios y asegúrate de que pasen los tests (`make test`).
4. Haz commit de tus cambios.
5. Abre un Pull Request.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---
*Desarrollado para la visualización y conservación del patrimonio arbóreo.*
