"""
Audit Log model for FleetCommand.

Comprehensive audit trail for compliance and debugging.
"""
from sqlalchemy import TIMESTAMP, Column, ForeignKey, Integer, String, func, Index, text
from sqlalchemy.dialects.postgresql import UUID, JSONB, INET
from sqlalchemy.orm import relationship

from app.db.base import Base


class AuditLog(Base):
    """Audit Log model."""

    __tablename__ = "audit_logs"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=func.gen_random_uuid(),
        nullable=False,
    )
    org_id = Column(
        UUID(as_uuid=True),
        ForeignKey("orgs.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    actor_user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    action = Column(String(100), nullable=False, index=True)
    entity_type = Column(String(100), nullable=False, index=True)
    entity_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    old_values = Column(JSONB)
    new_values = Column(JSONB)
    metadata = Column(JSONB, nullable=False, server_default="{}")
    ip_address = Column(INET)
    user_agent = Column(String)
    created_at = Column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=func.now(),
        index=True,
    )

    # Relationships
    org = relationship("Org", back_populates="audit_logs")
    actor_user = relationship("User", back_populates="audit_logs", foreign_keys=[actor_user_id])

    # Additional indexes for performance
    __table_args__ = (
        Index("idx_audit_logs_created_at", "created_at"),
        Index("idx_audit_logs_action", "action"),
        Index("idx_audit_logs_entity_type_id", "entity_type", "entity_id"),
    )

    @classmethod
    def log_action(
        cls,
        org_id: str,
        actor_user_id: str | None,
        action: str,
        entity_type: str,
        entity_id: str,
        old_values: dict | None = None,
        new_values: dict | None = None,
        metadata: dict | None = None,
        ip_address: str | None = None,
        user_agent: str | None = None,
    ) -> "AuditLog":
        """Create an audit log entry."""
        return cls(
            org_id=org_id,
            actor_user_id=actor_user_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            old_values=old_values,
            new_values=new_values,
            metadata=metadata or {},
            ip_address=ip_address,
            user_agent=user_agent,
        )

    def __repr__(self) -> str:
        """String representation of AuditLog."""
        return (
            f"<AuditLog(id={self.id}, org_id={self.org_id}, "
            f"action={self.action}, entity_type={self.entity_type}, "
            f"entity_id={self.entity_id})>"
        )
