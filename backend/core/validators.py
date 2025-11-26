from django.core.exceptions import ValidationError


ALLOWED_DOCUMENT_TYPES = {
    'application/pdf',
    'image/jpeg',
    'image/png',
}
MAX_DOCUMENT_SIZE = 5 * 1024 * 1024  # 5 MB


def validate_upload_file(file):
    size = getattr(file, 'size', None)
    if size and size > MAX_DOCUMENT_SIZE:
        raise ValidationError(f'File must be smaller than {MAX_DOCUMENT_SIZE // (1024 * 1024)} MB.')

    content_type = getattr(file, 'content_type', '') or ''
    if content_type and content_type not in ALLOWED_DOCUMENT_TYPES:
        raise ValidationError('Unsupported file type for document uploads.')

    name = getattr(file, 'name', '')
    if name and not name.lower().split('.')[-1] in {'pdf', 'jpg', 'jpeg', 'png'}:
        raise ValidationError('File extension is not allowed for document uploads.')
