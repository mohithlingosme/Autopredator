"""
User-Organization membership model for role-based access control.
"""
from sqlalchemy import Boolean, Column, String, TIMESTAMP, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from ..db.base import Base


class UserOrgMembership(Base):
    """User-Organization membership with roles."""

    __tablename__ = "user_org_memberships"

    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), primary_key=True)
    org_id = Column(UUID(as_uuid=True), ForeignKey("orgs.id"), primary_key=True)
    role = Column(String(50), nullable=False)  # Admin, Manager, Operator, Driver, Accountant, Viewer
    status = Column(String(50), default="active", nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now(), nullable=False)

    def __repr__(self):
        return f"<UserOrgMembership(user_id={self.user_id}, org_id={self.org_id}, role={self.role})>"
