export interface UserInfo {
  userId: string;
  phoneNumber: string;
  token: string;
}

export interface UserProfileForm {
  // userId?: string;
  name: string;
  height: number;
  weight: number;
  birthday: string;
  gender: string;
  avatar?: string;
  tags?: string;
}

export interface WeightScaleData {
  userId?: string;
  weight: number;
  bmi: number;
  bodyFat: number;
  timestamp: number;
}

export interface ValidResult {
  valid: boolean;
  message: string;
}

export interface LoginResult {
  isSuccess: boolean;
  message: string;
  userInfo?: UserInfo;
}

export interface UserEntity {
  id?: number;
  phone: string;
  password: string;
  name?: string;
  gender?: string;
  birthday?: string;
  height?: number;
  weight?: number;
  avatar?: string;
  tags?: string;
  created_at?: number;
  updated_at?: number;
}