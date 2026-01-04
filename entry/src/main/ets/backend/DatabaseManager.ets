import { relationalStore } from '@kit.ArkData';

import { DatabaseConfig } from './DatabaseConfig';
// import { UserEntity } from '../models/UserModel';

class DatabaseManager {
  private store: relationalStore.RdbStore | null = null;
  private context: Context | null = null;

  // 初始化数据库
  async initDatabase(context: Context): Promise<void> {
    this.context = context;

    const config: relationalStore.StoreConfig = {
      name: DatabaseConfig.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.store = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      await this.initDefaultData();
    } catch (error) {
      console.error('数据库初始化失败:', JSON.stringify(error));
      throw new Error('数据库初始化失败:');
    }
  }

  // 创建表
  private async createTables(): Promise<void> {
    if (!this.store) return;

    await this.store.executeSql(DatabaseConfig.CREATE_TABLE_USER);
    await this.store.executeSql(DatabaseConfig.CREATE_TABLE_HEALTH_DATA);
  }

  // 初始化默认数据
  private async initDefaultData(): Promise<void> {
    if (!this.store) return;

    // 检查是否已有用户数据
    const predicates = new relationalStore.RdbPredicates(DatabaseConfig.TABLE_USER);
    const resultSet = await this.store.query(predicates);
    const count = resultSet.rowCount;
    resultSet.close();

    // 如果没有数据，插入测试账号
    if (count === 0) {
      const testUsr1: relationalStore.ValuesBucket = {
        phone: '13800138000',
        password: '123456',
        name: '赵智晟',
        gender: '男',
        birthday: '1949-12-15',
        height: 180,
        weight: 80,
        avatar: '',
        tags: '个人信息、过敏信息、既往病史等',
        created_at: Date.now(),
        updated_at: Date.now()
      };
      const testUsr2: relationalStore.ValuesBucket = {
        phone: '13900139000',
        password: '123456',
        name: '张三',
        gender: '女',
        birthday: '1990-05-20',
        height: 165,
        weight: 55,
        avatar: '',
        tags: '抽烟喝酒、熬夜、从不锻炼',
        created_at: Date.now(),
        updated_at: Date.now()
      };
      await this.store.insert(DatabaseConfig.TABLE_USER, testUsr1);
      await this.store.insert(DatabaseConfig.TABLE_USER, testUsr2);
    }
  }

  // 获取数据库实例
  getStore(): relationalStore.RdbStore | null {
    return this.store;
  }

  // 关闭数据库
  async closeDatabase(): Promise<void> {
    if (this.store) {
      this.store = null;
    }
  }
}

export default new DatabaseManager();
