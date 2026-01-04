import preferences from '@ohos.data.preferences';
import { UserEntity } from '../models/UserModel';

class SessionManager {
  private static readonly PREF_NAME = 'user_session';
  private static readonly KEY_USER_ID = 'user_id';
  private static readonly KEY_USER_PHONE = 'user_phone';

  private pref: preferences.Preferences | null = null;
  private currentUser: UserEntity | null = null;

  // 初始化
  async init(context: Context): Promise<void> {
    this.pref = await preferences.getPreferences(context, SessionManager.PREF_NAME);
  }

  // 保存登录会话
  async saveSession(user: UserEntity): Promise<void> {
    if (!this.pref || !user.id) return;

    this.setCurrentUser(user);
    await this.pref.put(SessionManager.KEY_USER_ID, user.id);
    await this.pref.put(SessionManager.KEY_USER_PHONE, user.phone);
    await this.pref.flush();
  }

  // 获取当前用户ID
  async getCurrentUserId(): Promise<number | null> {
    if (!this.pref) return null;

    const userId = await this.pref.get(SessionManager.KEY_USER_ID, -1);
    return userId as number > 0 ? userId as number : null;
  }

  // 获取当前用户手机号
  async getCurrentUserPhone(): Promise<string | null> {
    if (!this.pref) return null;

    const phone = await this.pref.get(SessionManager.KEY_USER_PHONE, '');
    return phone as string || null;
  }

  // 设置当前用户
  setCurrentUser(user: UserEntity): void {
    this.currentUser = user;
  }

  // 获取当前用户
  getCurrentUser(): UserEntity | null {
    return this.currentUser;
  }

  // 清除会话
  async clearSession(): Promise<void> {
    if (!this.pref) return;

    this.currentUser = null;
    await this.pref.clear();
    await this.pref.flush();
  }

  // 检查是否已登录
  async isLoggedIn(): Promise<boolean> {
    const userId = await this.getCurrentUserId();
    return userId !== null;
  }
}

export default new SessionManager();