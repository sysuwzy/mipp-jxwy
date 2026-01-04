import UserDao from '../backend/UserDao';
import SessionManager from './SessionManager';
import { UserProfileForm, WeightScaleData, UserEntity, ValidResult } from '../models/UserModel';

class UserProfileService {
  // 获取当前用户资料
  async getUserProfile(): Promise<UserProfileForm | null> {
    const currentUser = SessionManager.getCurrentUser();
    if (!currentUser || !currentUser.id) return null;

    const user = await UserDao.getUserById(currentUser.id);
    if (!user) return null;

    return {
      name: user.name || '',
      height: user.height || 0,
      weight: user.weight || 0,
      birthday: user.birthday || '',
      gender: user.gender || '',
      avatar: user.avatar || '',
      tags: user.tags || '个人信息、过敏信息、既往病史等'
    };
  }

  // 保存用户资料
  async saveUserProfile(profile: UserProfileForm): Promise<boolean> {
    const currentUser = SessionManager.getCurrentUser();
    if (!currentUser || !currentUser.id) return false;

    const updateData: Partial<UserEntity> = {
      name: profile.name,
      height: profile.height,
      weight: profile.weight,
      birthday: profile.birthday,
      gender: profile.gender,
      avatar: profile.avatar
    };

    const success = await UserDao.updateUser(currentUser.id, updateData);

    if (success) {
      // 更新会话中的用户信息
      const updatedUser = await UserDao.getUserById(currentUser.id);
      if (updatedUser) {
        SessionManager.setCurrentUser(updatedUser);
      }
    }

    return success;
  }

  // 从华为智能体重称获取数据（模拟）
  async getWeightScaleData(): Promise<WeightScaleData> {
    await this.delay(1500);

    return {
      weight: 78.5,
      bmi: 24.2,
      bodyFat: 18.5,
      timestamp: Date.now()
    };
  }

  // 验证表单数据
  validateProfile(profile: UserProfileForm): ValidResult {
    if (!profile.name || profile.name.trim().length === 0) {
      return { valid: false, message: '请输入姓名' };
    }

    if (profile.name.length > 20) {
      return { valid: false, message: '姓名长度不能超过20个字符' };
    }

    if (!profile.height || profile.height <= 0 || profile.height > 300) {
      return { valid: false, message: '请输入有效的身高（1-300cm）' };
    }

    if (!profile.weight || profile.weight <= 0 || profile.weight > 500) {
      return { valid: false, message: '请输入有效的体重（1-500kg）' };
    }

    if (!profile.birthday) {
      return { valid: false, message: '请选择生日' };
    }

    return { valid: true, message: '' };
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

export default new UserProfileService();