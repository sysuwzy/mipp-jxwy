export interface UserProfile {
  name: string;
  gender: string;
  birthday: string;
  height: number;
  weight: number;
  tags: string[];
  avatar?: string;
}

export interface HeartRateData {
  current: number;
  unit: string;
  chartData: number[];
}

export interface OxygenData {
  values: number[];
  unit: string;
}

export interface TemperatureData {
  current: number;
  unit: string;
}

export interface BloodSugarData {
  current: number;
  status: string;
}

export interface BloodPressureData {
  systolic: number;
  diastolic: number;
}

export interface HealthData {
  userProfile: UserProfile;
  heartRate: HeartRateData;
  oxygen: OxygenData;
  temperature: TemperatureData;
  bloodSugar: BloodSugarData;
  bloodPressure: BloodPressureData;
}