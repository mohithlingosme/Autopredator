from pathlib import Path

from joblib import dump
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


def build_samples():
    vehicle_types = ['sedan', 'suv', 'truck', 'van', 'coupe']
    samples = []
    for idx, vehicle_type in enumerate(vehicle_types):
        for mileage in (5000, 15000, 30000, 50000):
            samples.append(
                {
                    'mileage': mileage,
                    'vehicle_type': vehicle_type,
                    'days_since_service': 15 * (idx + 1),
                    'days_to_next': max(7, 180 - (mileage // 1000)),
                }
            )
    # add a few higher-mileage rows
    samples.extend(
        [
            {'mileage': 80000, 'vehicle_type': 'truck', 'days_since_service': 90, 'days_to_next': 30},
            {'mileage': 65000, 'vehicle_type': 'suv', 'days_since_service': 75, 'days_to_next': 45},
            {'mileage': 120000, 'vehicle_type': 'van', 'days_since_service': 120, 'days_to_next': 20},
        ]
    )
    return samples


def train_model(output_path: Path):
    data = build_samples()
    X = [[row['mileage'], row['vehicle_type'], row['days_since_service']] for row in data]
    y = [row['days_to_next'] for row in data]

    preprocessor = ColumnTransformer(
        transformers=[
            ('vehicle_type', OneHotEncoder(handle_unknown='ignore'), [1]),
        ],
        remainder='passthrough',
    )

    pipeline = Pipeline(
        [
            ('preprocessor', preprocessor),
            ('scaler', StandardScaler()),
            ('regressor', LinearRegression()),
        ]
    )
    pipeline.fit(X, y)
    dump(pipeline, output_path)
    print(f'Saved prediction model to {output_path}')


def main():
    output_path = Path(__file__).resolve().parent.parent / 'model.pkl'
    train_model(output_path)


if __name__ == '__main__':
    main()
