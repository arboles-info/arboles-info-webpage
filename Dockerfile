# Dockerfile para Árboles Info Maps
# Multi-stage build para optimizar tamaño de imagen

# Stage 1: Build
FROM python:3.13-slim AS builder

# Variables de entorno para build
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar requirements e instalar dependencias
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.13-slim

# Variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/appuser/.local/bin:$PATH" \
    PORT=8080

# Instalar dependencias del sistema para GeoDjango (GDAL, GEOS, PROJ)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    libgeos-dev \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root para seguridad
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Crear directorio de trabajo
WORKDIR /app

# Copiar dependencias instaladas desde builder
COPY --from=builder /root/.local /home/appuser/.local

# Copiar código de la aplicación
COPY --chown=appuser:appuser . .

# Crear directorio staticfiles con permisos para appuser
RUN mkdir -p /app/staticfiles && chown -R appuser:appuser /app/staticfiles

# Cambiar a usuario no-root
USER appuser

# Recopilar archivos estáticos para WhiteNoise
# Necesitamos SECRET_KEY y DEBUG para collectstatic
# WhiteNoise requiere que collectstatic se ejecute correctamente
RUN SECRET_KEY=dummy DEBUG=False python manage.py collectstatic --noinput

# Exponer puerto (usar valor por defecto si PORT no está definido)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen(f'http://localhost:8080/')" || exit 1

# Comando por defecto (puede ser sobrescrito)
CMD ["sh", "-c", "exec gunicorn arboles_info_project.wsgi:application --bind 0.0.0.0:8080 --workers 2 --threads 2 --timeout 120 --access-logfile - --error-logfile -"]

