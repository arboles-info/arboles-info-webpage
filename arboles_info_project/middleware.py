"""
Middleware personalizado para permitir todos los hosts cuando ALLOWED_HOSTS contiene '*'.

Django no soporta ALLOWED_HOSTS = ['*'] directamente, por lo que este middleware
intercepta la validación de hosts y permite cualquier host cuando se detecta '*'
en la configuración de ALLOWED_HOSTS.
"""

from django.conf import settings
from django.core.exceptions import DisallowedHost


class AllowAllHostsMiddleware:
    """
    Middleware que permite todos los hosts cuando ALLOWED_HOSTS contiene '*'.
    
    Esto es útil para entornos como DigitalOcean App Platform donde los health checks
    usan IPs internas dinámicas que no se pueden predecir.
    
    Este middleware debe ir ANTES de SecurityMiddleware en MIDDLEWARE para interceptar
    la validación de hosts.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
        # Verificar si ALLOWED_HOSTS contiene '*'
        self.allow_all = '*' in getattr(settings, 'ALLOWED_HOSTS', [])
    
    def __call__(self, request):
        # Si allow_all está activado, agregar el host actual a ALLOWED_HOSTS
        # antes de que SecurityMiddleware lo valide
        if self.allow_all:
            # Obtener el host del request (sin puerto para la validación)
            host_header = request.META.get('HTTP_HOST', '')
            if host_header:
                # Separar host y puerto
                host = host_header.split(':')[0]
                # Agregar el host a ALLOWED_HOSTS si no está ya presente
                # Esto permite que pase la validación de SecurityMiddleware
                if host and host not in settings.ALLOWED_HOSTS:
                    settings.ALLOWED_HOSTS.append(host)
        
        response = self.get_response(request)
        return response

