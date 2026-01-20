"""
Organization model for multi-tenant architecture.
"""
from sqlalchemy import Column, String, TIMESTAMP, func, JSON
from sqlalchemy.dialects.postgresql import UUID

from ..db.base import Base


class Org(Base):
    """Organization entity for multi-tenant data isolation."""

    __tablename__ = "orgs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    name = Column(String(255), nullable=False)
    status = Column(String(50), default="active", nullable=False)
    settings = Column(JSON, default=dict, nullable=False)  # Flexible settings storage
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)

    def __repr__(self):
        return f"<Org(id={self.id}, name={self.name}, status={self.status})>"
