import { relationalStore } from '@kit.ArkData';

import DatabaseManager from './DatabaseManager';
import { DatabaseConfig } from './DatabaseConfig';
import { UserEntity } from '../models/UserModel';

class UserDao {
  // 用户登录验证
  async login(phone: string, password: string): Promise<UserEntity | null> {
    const store = DatabaseManager.getStore();
    if (!store) return null;

    const predicates = new relationalStore.RdbPredicates(DatabaseConfig.TABLE_USER);
    predicates.equalTo('phone', phone).and().equalTo('password', password);

    const resultSet = await store.query(predicates);

    if (resultSet.goToFirstRow()) {
      const user = this.parseUser(resultSet);
      resultSet.close();
      return user;
    }

    resultSet.close();
    return null;
  }

  // 根据手机号获取用户
  async getUserByPhone(phone: string): Promise<UserEntity | null> {
    const store = DatabaseManager.getStore();
    if (!store) return null;

    const predicates = new relationalStore.RdbPredicates(DatabaseConfig.TABLE_USER);
    predicates.equalTo('phone', phone);

    const resultSet = await store.query(predicates);

    if (resultSet.goToFirstRow()) {
      const user = this.parseUser(resultSet);
      resultSet.close();
      return user;
    }

    resultSet.close();
    return null;
  }

  // 根据ID获取用户
  async getUserById(id: number): Promise<UserEntity | null> {
    const store = DatabaseManager.getStore();
    if (!store) return null;

    const predicates = new relationalStore.RdbPredicates(DatabaseConfig.TABLE_USER);
    predicates.equalTo('id', id);

    const resultSet = await store.query(predicates);

    if (resultSet.goToFirstRow()) {
      const user = this.parseUser(resultSet);
      resultSet.close();
      return user;
    }

    resultSet.close();
    return null;
  }

  // 更新用户信息
  async updateUser(id: number, user: Partial<UserEntity>): Promise<boolean> {
    const store = DatabaseManager.getStore();
    if (!store) return false;

    const userNew: relationalStore.ValuesBucket = {
      name: user.name??'',
      height: user.height??0,
      weight: user.weight??0,
      birthday: user.birthday??'',
      gender: user.gender??'',
      avatar: user.avatar??'',
      updated_at: Date.now()
    };
    // 垃圾鸿蒙不支持... 不支持object.assign 不支持for in

    const predicates = new relationalStore.RdbPredicates(DatabaseConfig.TABLE_USER);
    predicates.equalTo('id', id);

    const rows = await store.update(userNew, predicates);
    return rows > 0;
  }

  // 插入新用户
  async insertUser(user: UserEntity): Promise<number> {
    const store = DatabaseManager.getStore();
    if (!store) return -1;

    const userNew: relationalStore.ValuesBucket = {
      name: user.name??'',
      height: user.height??0,
      weight: user.weight??0,
      birthday: user.birthday??'',
      gender: user.gender??'',
      avatar: user.avatar??'',
      updated_at: Date.now()
    };

    return await store.insert(DatabaseConfig.TABLE_USER, userNew);
  }

  // 解析用户数据
  private parseUser(resultSet: relationalStore.ResultSet): UserEntity {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      phone: resultSet.getString(resultSet.getColumnIndex('phone')),
      password: resultSet.getString(resultSet.getColumnIndex('password')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      gender: resultSet.getString(resultSet.getColumnIndex('gender')),
      birthday: resultSet.getString(resultSet.getColumnIndex('birthday')),
      height: resultSet.getLong(resultSet.getColumnIndex('height')),
      weight: resultSet.getDouble(resultSet.getColumnIndex('weight')),
      avatar: resultSet.getString(resultSet.getColumnIndex('avatar')),
      tags: resultSet.getString(resultSet.getColumnIndex('tags')),
      created_at: resultSet.getLong(resultSet.getColumnIndex('created_at')),
      updated_at: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
    };
  }
}

export default new UserDao();