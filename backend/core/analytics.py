from typing import Mapping, Optional

from django.contrib.auth import get_user_model

from .models import FeatureUsageLog, VehicleCountSnapshot

User = get_user_model()


def record_feature_usage(user: Optional[User], feature_name: str, metadata: Mapping[str, object] | None = None) -> None:
    FeatureUsageLog.objects.create(
        user=user,
        feature_name=feature_name,
        metadata=metadata or {},
    )


def snapshot_vehicle_count(user: User, count: int) -> None:
    VehicleCountSnapshot.objects.create(user=user, count=count)
