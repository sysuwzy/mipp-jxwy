// utils/StorageHelper.ets
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { HealthRecord } from '../models/HealthRecord';
import { AuthorizationCode } from '../models/AuthorizationCode';

const PREFERENCE_NAME = 'HealthArchiveData';
const KEY_ARCHIVE_LIST = 'archiveList';
const KEY_AUTHORIZATION_CODES = 'authorizationCodes';

// 定义类型别名
type HealthRecordTypeLiteral = '门诊病历' | '检查报告' | '用药处方' | '专项档案' | '其他';

// 定义数据接口，避免使用 any
interface HealthRecordData {
  id: string;
  userId: string;
  title: string;
  type: HealthRecordTypeLiteral;
  content: string;
  attachments: string[];
  hospital: string;
  date: string;
  tags: string[];
  isSynced: boolean;
  createdAt: number;
  isEditing: boolean;
}

interface AuthorizationCodeData {
  code: string;
  recordIds: string[];
  expireAt: number;
  hospitalName: string;
  createdAt: number;
  used: boolean;
}

export class StorageHelper {
  private static dataPreferences: preferences.Preferences | null = null;

  // 初始化Preferences
  static async init(context: common.UIAbilityContext): Promise<boolean> {
    try {
      StorageHelper.dataPreferences = await preferences.getPreferences(context, PREFERENCE_NAME);
      return true;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to get preferences. Code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  // 保存健康档案列表
  static async saveArchiveList(records: HealthRecord[]): Promise<boolean> {
    if (!StorageHelper.dataPreferences) {
      console.error('Preferences not initialized');
      return false;
    }

    try {
      // 将HealthRecord数组转换为JSON字符串
      const recordsJson = JSON.stringify(records.map((record: HealthRecord): HealthRecordData => ({
        id: record.id,
        userId: record.userId,
        title: record.title,
        type: record.type,
        content: record.content,
        attachments: record.attachments,
        hospital: record.hospital,
        date: record.date,
        tags: record.tags,
        isSynced: record.isSynced,
        createdAt: record.createdAt,
        isEditing: record.isEditing
      })));

      await StorageHelper.dataPreferences.put(KEY_ARCHIVE_LIST, recordsJson);
      await StorageHelper.dataPreferences.flush();
      return true;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to save archive list. Code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  // 加载健康档案列表
  static async loadArchiveList(): Promise<HealthRecord[]> {
    if (!StorageHelper.dataPreferences) {
      console.error('Preferences not initialized');
      return [];
    }

    try {
      const recordsJson = await StorageHelper.dataPreferences.get(KEY_ARCHIVE_LIST, '[]');
      
      if (typeof recordsJson !== 'string' || recordsJson === '[]') {
        return [];
      }

      const recordsData = JSON.parse(recordsJson as string) as HealthRecordData[];
      return recordsData.map((data: HealthRecordData) => {
        const record = new HealthRecord();
        record.id = data.id || '';
        record.userId = data.userId || '';
        record.title = data.title || '';
        // 验证并转换 type 字段
        const validTypes: HealthRecordTypeLiteral[] = ['门诊病历', '检查报告', '用药处方', '专项档案', '其他'];
        record.type = (validTypes.includes(data.type) ? data.type : '其他') as HealthRecordTypeLiteral;
        record.content = data.content || '';
        record.attachments = data.attachments || [];
        record.hospital = data.hospital || '';
        record.date = data.date || '';
        record.tags = data.tags || [];
        record.isSynced = data.isSynced || false;
        record.createdAt = data.createdAt || 0;
        record.isEditing = data.isEditing || false;
        return record;
      });
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to load archive list. Code: ${error.code}, message: ${error.message}`);
      return [];
    }
  }

  // 保存授权码列表
  static async saveAuthorizationCodes(codes: AuthorizationCode[]): Promise<boolean> {
    if (!StorageHelper.dataPreferences) {
      console.error('Preferences not initialized');
      return false;
    }

    try {
      const codesJson = JSON.stringify(codes.map((code: AuthorizationCode): AuthorizationCodeData => ({
        code: code.code,
        recordIds: code.recordIds,
        expireAt: code.expireAt,
        hospitalName: code.hospitalName,
        createdAt: code.createdAt,
        used: code.used
      })));

      await StorageHelper.dataPreferences.put(KEY_AUTHORIZATION_CODES, codesJson);
      await StorageHelper.dataPreferences.flush();
      return true;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to save authorization codes. Code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  // 加载授权码列表
  static async loadAuthorizationCodes(): Promise<AuthorizationCode[]> {
    if (!StorageHelper.dataPreferences) {
      console.error('Preferences not initialized');
      return [];
    }

    try {
      const codesJson = await StorageHelper.dataPreferences.get(KEY_AUTHORIZATION_CODES, '[]');
      
      if (typeof codesJson !== 'string' || codesJson === '[]') {
        return [];
      }

      const codesData = JSON.parse(codesJson as string) as AuthorizationCodeData[];
      return codesData.map((data: AuthorizationCodeData) => {
        const code = new AuthorizationCode();
        code.code = data.code || '';
        code.recordIds = data.recordIds || [];
        code.expireAt = data.expireAt || 0;
        code.hospitalName = data.hospitalName || '';
        code.createdAt = data.createdAt || 0;
        code.used = data.used || false;
        return code;
      });
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to load authorization codes. Code: ${error.code}, message: ${error.message}`);
      return [];
    }
  }

  // 清空所有数据
  static async clearAll(): Promise<boolean> {
    if (!StorageHelper.dataPreferences) {
      console.error('Preferences not initialized');
      return false;
    }

    try {
      await StorageHelper.dataPreferences.delete(KEY_ARCHIVE_LIST);
      await StorageHelper.dataPreferences.delete(KEY_AUTHORIZATION_CODES);
      await StorageHelper.dataPreferences.flush();
      return true;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to clear all data. Code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }
}

