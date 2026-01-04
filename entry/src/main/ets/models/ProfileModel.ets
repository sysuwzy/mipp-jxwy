export interface MenuItem {
  id: string;
  icon: Resource;
  title: string;
  subtitle?: string;
  showArrow: boolean;
  type: 'navigation' | 'action';
}

export interface AppInfo {
  version: string;
  description: string;
  features: string[];
}