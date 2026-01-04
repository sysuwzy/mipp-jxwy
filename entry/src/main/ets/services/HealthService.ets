import { HealthData, UserProfile, HeartRateData, OxygenData, TemperatureData, BloodSugarData, BloodPressureData } from '../models/HealthModel';

class HealthService {
  // 模拟获取健康数据
  async getHealthData(): Promise<HealthData> {
    // 模拟网络延迟
    await this.delay(500);

    const userProfile: UserProfile = {
      name: '赵智晟',
      gender: '男',
      birthday: '1949-12-15',
      height: 180,
      weight: 80,
      tags: ['个人信息', '过敏信息', '既往病史等']
    };

    const heartRate: HeartRateData = {
      current: 78,
      unit: '次/分钟',
      chartData: [75, 72, 68, 70, 73, 78, 76, 74]
    };

    const oxygen: OxygenData = {
      values: [94, 95, 93, 94],
      unit: '%'
    };

    const temperature: TemperatureData = {
      current: 35.2,
      unit: '℃'
    };

    const bloodSugar: BloodSugarData = {
      current: 5,
      status: '餐前餐后血糖'
    };

    const bloodPressure: BloodPressureData = {
      systolic: 99,
      diastolic: 128
    };

    return {
      userProfile,
      heartRate,
      oxygen,
      temperature,
      bloodSugar,
      bloodPressure
    };
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

export default new HealthService();