import { UserInfo, LoginResult, UserEntity } from '../models/UserModel';
import UserDao from '../backend/UserDao';
import SessionManager from './SessionManager';

class AuthService {
  // 一键登录
  async quickLogin(): Promise<LoginResult> {
    try {
      // 模拟获取本机手机号
      const phoneNumber = '13800138000';

      const user = await UserDao.getUserByPhone(phoneNumber);

      if (user && user.id) {
        await SessionManager.saveSession(user);
        SessionManager.setCurrentUser(user);

        const userInfo: UserInfo = {
          phoneNumber: user.phone,
          userId: user.id.toString(),
          token: this.generateToken()
        };

        return {
          isSuccess: true,
          message: '登录成功',
          userInfo: userInfo
        };
      } else {
        return {
          isSuccess: false,
          message: '用户不存在'
        };
      }
    } catch (error) {
      return {
        isSuccess: false,
        message: '一键登录失败，请尝试其他方式'
      };
    }
  }

  // 账号密码登录
  async loginWithPassword(phone: string, password: string): Promise<LoginResult> {
    if (!this.validatePhone(phone)) {
      return {
        isSuccess: false,
        message: '请输入正确的手机号'
      };
    }

    if (!password || password.length < 6) {
      return {
        isSuccess: false,
        message: '密码长度不能少于6位'
      };
    }

    try {
      const user = await UserDao.login(phone, password);

      if (user && user.id) {
        await SessionManager.saveSession(user);
        SessionManager.setCurrentUser(user);

        const userInfo: UserInfo = {
          phoneNumber: user.phone,
          userId: user.id.toString(),
          token: this.generateToken()
        };

        return {
          isSuccess: true,
          message: '登录成功',
          userInfo: userInfo
        };
      } else {
        return {
          isSuccess: false,
          message: '手机号或密码错误'
        };
      }
    } catch (error) {
      return {
        isSuccess: false,
        message: '登录失败，请重试'
      };
    }
  }

  // 退出登录
  async logout(): Promise<boolean> {
    try {
      await SessionManager.clearSession();
      return true;
    } catch (error) {
      return false;
    }
  }

  // 工具方法
  private validatePhone(phone: string): boolean {
    const phoneReg = /^1[3-9]\d{9}$/;
    return phoneReg.test(phone);
  }

  private generateToken(): string {
    return 'TOKEN_' + Date.now() + '_' + Math.random().toString(36).substr(2, 16);
  }
}

export default new AuthService();