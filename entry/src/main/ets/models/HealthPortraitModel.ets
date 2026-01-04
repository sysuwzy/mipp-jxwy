export interface HealthIndicator {
  id: string;
  label: string;
  value: string;
  position: 'left' | 'right';
  order: number;
}

export interface AnalysisReport {
  title: string;
  content: string;
  icon: string;
  type: 'warning' | 'normal' | 'good';
}

export interface HealthPortraitData {
  userName: string;
  age: number;
  gender: string;
  height: number;
  weight: number;
  indicators: HealthIndicator[];
  reports: AnalysisReport[];
}