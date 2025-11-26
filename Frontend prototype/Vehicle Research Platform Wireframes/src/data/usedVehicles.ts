export interface UsedVehicle {
  id: string;
  name: string;
  brand: string;
  model: string;
  year: number;
  price: number;
  originalPrice: number;
  image: string;
  kmDriven: number;
  fuelType: string;
  transmission: string;
  ownerType: string;
  location: string;
  verified: boolean;
  blockchainVerified: boolean;
  rtoSynced: boolean;
  sellerType: 'dealer' | 'individual' | 'certified';
  condition: string;
  rating: number;
  registrationNumber: string;
  serviceHistory: boolean;
  accidentHistory: boolean;
  predictedValue: number;
  valueConfidence: number;
  negotiable: boolean;
  sellerInfo: {
    name: string;
    phone: string;
    rating: number;
    vehiclesSold: number;
  };
}

export const usedVehicles: UsedVehicle[] = [
  {
    id: 'u1',
    name: '2022 Hyundai Creta SX Diesel',
    brand: 'Hyundai',
    model: 'Creta',
    year: 2022,
    price: 1450000,
    originalPrice: 1850000,
    image: 'https://images.unsplash.com/photo-1570829194611-71a926d70ff8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjBzdXYlMjBjYXJ8ZW58MXx8fHwxNzYxNzg3ODk4fDA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 22000,
    fuelType: 'Diesel',
    transmission: 'Manual',
    ownerType: '1st Owner',
    location: 'Delhi NCR',
    verified: true,
    blockchainVerified: true,
    rtoSynced: true,
    sellerType: 'certified',
    condition: 'Excellent',
    rating: 4.8,
    registrationNumber: 'DL3CXX1234',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 1425000,
    valueConfidence: 95,
    negotiable: true,
    sellerInfo: {
      name: 'AutoCertified Showroom',
      phone: '+91 98765 43210',
      rating: 4.7,
      vehiclesSold: 342
    }
  },
  {
    id: 'u2',
    name: '2021 Maruti Swift VXI',
    brand: 'Maruti Suzuki',
    model: 'Swift',
    year: 2021,
    price: 625000,
    originalPrice: 850000,
    image: 'https://images.unsplash.com/photo-1627280052756-cc5e080c8458?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXRjaGJhY2slMjBjYXJ8ZW58MXx8fHwxNzYxODA2NzI1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 35000,
    fuelType: 'Petrol',
    transmission: 'Manual',
    ownerType: '1st Owner',
    location: 'Mumbai',
    verified: true,
    blockchainVerified: false,
    rtoSynced: true,
    sellerType: 'individual',
    condition: 'Good',
    rating: 4.3,
    registrationNumber: 'MH02XX5678',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 615000,
    valueConfidence: 88,
    negotiable: true,
    sellerInfo: {
      name: 'Rajesh Kumar',
      phone: '+91 98765 11111',
      rating: 4.5,
      vehiclesSold: 2
    }
  },
  {
    id: 'u3',
    name: '2020 Honda City ZX CVT',
    brand: 'Honda',
    model: 'City',
    year: 2020,
    price: 975000,
    originalPrice: 1450000,
    image: 'https://images.unsplash.com/photo-1658662160331-62f7e52e63de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzZWRhbiUyMGNhcnxlbnwxfHx8fDE3NjE3MTY3MTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 48000,
    fuelType: 'Petrol',
    transmission: 'CVT',
    ownerType: '1st Owner',
    location: 'Bangalore',
    verified: true,
    blockchainVerified: true,
    rtoSynced: true,
    sellerType: 'dealer',
    condition: 'Good',
    rating: 4.5,
    registrationNumber: 'KA03XX9012',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 960000,
    valueConfidence: 92,
    negotiable: true,
    sellerInfo: {
      name: 'Premium Auto Dealers',
      phone: '+91 98765 22222',
      rating: 4.6,
      vehiclesSold: 187
    }
  },
  {
    id: 'u4',
    name: '2021 Tata Nexon XZ Plus',
    brand: 'Tata',
    model: 'Nexon',
    year: 2021,
    price: 875000,
    originalPrice: 1250000,
    image: 'https://images.unsplash.com/photo-1593941707874-ef25b8b4a92b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxlbGVjdHJpYyUyMHZlaGljbGV8ZW58MXx8fHwxNzYxNzQ3NDUzfDA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 28000,
    fuelType: 'Diesel',
    transmission: 'Manual',
    ownerType: '1st Owner',
    location: 'Pune',
    verified: true,
    blockchainVerified: false,
    rtoSynced: true,
    sellerType: 'certified',
    condition: 'Excellent',
    rating: 4.6,
    registrationNumber: 'MH12XX3456',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 865000,
    valueConfidence: 90,
    negotiable: true,
    sellerInfo: {
      name: 'AutoCertified Showroom',
      phone: '+91 98765 43210',
      rating: 4.7,
      vehiclesSold: 342
    }
  },
  {
    id: 'u5',
    name: '2019 Mahindra Scorpio S11',
    brand: 'Mahindra',
    model: 'Scorpio',
    year: 2019,
    price: 1125000,
    originalPrice: 1850000,
    image: 'https://images.unsplash.com/photo-1649793395985-967862a3b73f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaWNrdXAlMjB0cnVja3xlbnwxfHx8fDE3NjE3NTk5NDN8MA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 65000,
    fuelType: 'Diesel',
    transmission: 'Manual',
    ownerType: '2nd Owner',
    location: 'Jaipur',
    verified: true,
    blockchainVerified: false,
    rtoSynced: true,
    sellerType: 'individual',
    condition: 'Good',
    rating: 4.2,
    registrationNumber: 'RJ14XX7890',
    serviceHistory: true,
    accidentHistory: true,
    predictedValue: 1095000,
    valueConfidence: 85,
    negotiable: true,
    sellerInfo: {
      name: 'Vikram Singh',
      phone: '+91 98765 33333',
      rating: 4.3,
      vehiclesSold: 1
    }
  },
  {
    id: 'u6',
    name: '2022 Kia Seltos HTX',
    brand: 'Kia',
    model: 'Seltos',
    year: 2022,
    price: 1375000,
    originalPrice: 1750000,
    image: 'https://images.unsplash.com/photo-1701314860844-cd2152fa9071?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21wYWN0JTIwY2FyJTIwY2l0eXxlbnwxfHx8fDE3NjE4MDY3MjR8MA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 18000,
    fuelType: 'Petrol',
    transmission: 'DCT',
    ownerType: '1st Owner',
    location: 'Hyderabad',
    verified: true,
    blockchainVerified: true,
    rtoSynced: true,
    sellerType: 'certified',
    condition: 'Excellent',
    rating: 4.7,
    registrationNumber: 'TS09XX2345',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 1365000,
    valueConfidence: 93,
    negotiable: false,
    sellerInfo: {
      name: 'AutoCertified Showroom',
      phone: '+91 98765 43210',
      rating: 4.7,
      vehiclesSold: 342
    }
  },
  {
    id: 'u7',
    name: '2020 Toyota Innova Crysta',
    brand: 'Toyota',
    model: 'Innova Crysta',
    year: 2020,
    price: 1850000,
    originalPrice: 2450000,
    image: 'https://images.unsplash.com/photo-1591307599088-ed301ba209d0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21tZXJjaWFsJTIwdmFufGVufDF8fHx8MTc2MTgwNjcyNXww&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 52000,
    fuelType: 'Diesel',
    transmission: 'Automatic',
    ownerType: '1st Owner',
    location: 'Chennai',
    verified: true,
    blockchainVerified: true,
    rtoSynced: true,
    sellerType: 'dealer',
    condition: 'Good',
    rating: 4.8,
    registrationNumber: 'TN01XX6789',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 1825000,
    valueConfidence: 91,
    negotiable: true,
    sellerInfo: {
      name: 'Premium Auto Dealers',
      phone: '+91 98765 22222',
      rating: 4.6,
      vehiclesSold: 187
    }
  },
  {
    id: 'u8',
    name: '2021 Honda Amaze VX',
    brand: 'Honda',
    model: 'Amaze',
    year: 2021,
    price: 725000,
    originalPrice: 1050000,
    image: 'https://images.unsplash.com/photo-1658662160331-62f7e52e63de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzZWRhbiUyMGNhcnxlbnwxfHx8fDE3NjE3MTY3MTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    kmDriven: 32000,
    fuelType: 'Petrol',
    transmission: 'Manual',
    ownerType: '1st Owner',
    location: 'Ahmedabad',
    verified: true,
    blockchainVerified: false,
    rtoSynced: true,
    sellerType: 'individual',
    condition: 'Good',
    rating: 4.4,
    registrationNumber: 'GJ01XX4567',
    serviceHistory: true,
    accidentHistory: false,
    predictedValue: 710000,
    valueConfidence: 87,
    negotiable: true,
    sellerInfo: {
      name: 'Amit Patel',
      phone: '+91 98765 44444',
      rating: 4.4,
      vehiclesSold: 1
    }
  }
];
