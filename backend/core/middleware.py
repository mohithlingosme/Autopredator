from __future__ import annotations

from typing import Callable

from django.http import HttpRequest, HttpResponse

from .models import ApiUsageLog


class ApiUsageMiddleware:
    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]):
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        response = self.get_response(request)
        path = request.path
        if path.startswith('/api/'):
            ApiUsageLog.objects.create(
                user=request.user if request.user.is_authenticated else None,
                path=path,
                method=request.method,
                status_code=response.status_code,
                ip_address=request.META.get('REMOTE_ADDR'),
            )
        return response
