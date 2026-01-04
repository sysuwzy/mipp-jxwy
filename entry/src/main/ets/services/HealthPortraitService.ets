import { HealthPortraitData, HealthIndicator, AnalysisReport } from '../models/HealthPortraitModel';

class HealthPortraitService {
  // 模拟分析健康画像
  async analyzeHealthPortrait(): Promise<HealthPortraitData> {
    const indicators: HealthIndicator[] = [
      { id: '1', label: '年龄', value: '30岁', position: 'left', order: 1 },
      { id: '2', label: '身高', value: '180cm', position: 'right', order: 1 },
      { id: '3', label: '性别', value: '男', position: 'left', order: 2 },
      { id: '4', label: '体重', value: '80kg', position: 'right', order: 2 },
      { id: '5', label: '心率', value: '78', position: 'left', order: 3 },
      { id: '6', label: '血氧', value: '94%', position: 'right', order: 3 },
      { id: '7', label: '尿力', value: '2', position: 'left', order: 4 },
      { id: '8', label: '血压', value: '99-128', position: 'right', order: 4 },
      { id: '9', label: '体脂', value: '75', position: 'left', order: 5 },
      { id: '10', label: '血糖', value: '5', position: 'right', order: 5 }
    ];

    const reports: AnalysisReport[] = [
      {
        title: '心血管健康',
        content: '您的心率和血压处于正常范围，心血管系统运作良好。建议保持规律运动。',
        icon: 'heart',
        type: 'good'
      },
      {
        title: '体重管理',
        content: 'BMI指数为24.7，略微偏高。建议适当控制饮食，增加有氧运动。',
        icon: 'weight',
        type: 'warning'
      },
      {
        title: '血氧水平',
        content: '血氧饱和度94%，处于正常范围。呼吸系统功能良好。',
        icon: 'oxygen',
        type: 'good'
      },
      {
        title: '血糖监测',
        content: '空腹血糖5mmol/L，血糖控制良好。继续保持健康饮食习惯。',
        icon: 'sugar',
        type: 'good'
      }
    ];

    return {
      userName: '赵智晟',
      age: 30,
      gender: '男',
      height: 180,
      weight: 80,
      indicators,
      reports
    };
  }

  // 模拟逐步分析过程
  // async analyzeStep(): AsyncGenerator<HealthIndicator> {
  //   const data = await this.analyzeHealthPortrait();
  //
  //   for (const indicator of data.indicators) {
  //     await this.delay(500); // 每个指标分析延迟500ms
  //     yield indicator;
  //   }
  // }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

export default new HealthPortraitService();