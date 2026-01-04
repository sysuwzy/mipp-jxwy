import { AppInfo } from '../models/ProfileModel';

class ProfileService {
  // 获取APP信息
  getAppInfo(): AppInfo {
    return {
      version: '1.0.0',
      description: '健行无忧APP可用于收集并管理用户的个人健康数据。',
      features: [
        '用户健康数据上传、管理、同步、分享',
        '智能问诊室',
        '检测报告、用药提示',
        'AI健康助理'
      ]
    };
  }

  // 退出登录
  async logout(): Promise<boolean> {
    // 模拟退出登录操作
    await this.delay(500);
    return true;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

export default new ProfileService();