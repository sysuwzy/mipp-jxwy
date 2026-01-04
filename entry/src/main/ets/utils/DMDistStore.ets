import type common from '@ohos.app.ability.common';
import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import type { MedicalRecord } from './DMTypes';

/**
 * 分布式 KV 数据库封装（用于多端同步）
 * - 使用 SINGLE_VERSION（单版本）KVStore
 * - 将 MedicalRecord 序列化为 JSON 存入 kvStore
 * - key 规则： "record:<id>"
 * - 删除使用 tombstone（软删除标记），避免跨端 delete 丢失
 */
interface DistRecordEnvelope {
  deleted: boolean;
  id: string;
  title?: string;
  type?: string;
  tag?: string;
  visitDate?: number;
  fileUri?: string;
  ocrText?: string;
  createdAt?: number;
  deletedAt?: number;
}

export class DMDistStore {
  private static kv: distributedKVStore.SingleKVStore | null = null;
  private static subscribed: boolean = false;

  private static readonly STORE_ID: string = 'dm_records_dist_store';
  private static readonly KEY_PREFIX: string = 'record:';

  private static buildKey(id: string): string {
    return `${DMDistStore.KEY_PREFIX}${id}`;
  }

  /**
   * 初始化 KVStore（只初始化一次）
   */
  static async init(ctx: common.UIAbilityContext): Promise<distributedKVStore.SingleKVStore> {
    if (DMDistStore.kv !== null) {
      return DMDistStore.kv;
    }

    // KVManagerConfig 需要 context + bundleName
    // 注意：bundleName 从 abilityInfo 获取（避免使用 any）
    const bundleName: string = ctx.abilityInfo.bundleName;
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: ctx,
      bundleName: bundleName
    };

    let kvManager: distributedKVStore.KVManager;
    try {
      kvManager = distributedKVStore.createKVManager(kvManagerConfig);
    } catch (e) {
      const err = e as BusinessError;
      throw new Error(`createKVManager failed: code=${err.code}, msg=${err.message}`);
    }

    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: true,
      autoSync: false,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    };

    // getKVStore 在很多 SDK 版本是 callback 风格，这里做 Promise 包装，兼容性更好
    const store: distributedKVStore.SingleKVStore = await new Promise((resolve, reject) => {
      try {
        kvManager.getKVStore<distributedKVStore.SingleKVStore>(DMDistStore.STORE_ID, options,
          (err: BusinessError | null, kv: distributedKVStore.SingleKVStore) => {
            if (err) {
              reject(new Error(`getKVStore failed: code=${err.code}, msg=${err.message}`));
              return;
            }
            resolve(kv);
          });
      } catch (e) {
        const ex = e as BusinessError;
        reject(new Error(`getKVStore exception: code=${ex.code}, msg=${ex.message}`));
      }
    });

    DMDistStore.kv = store;
    return store;
  }

  /**
   * 订阅数据变化（接收其它设备的变更）
   */
  static async ensureSubscribed(
    ctx: common.UIAbilityContext,
    onChanged: (changedKeys: string[]) => Promise<void>
  ): Promise<void> {
    if (DMDistStore.subscribed) return;

    const store: distributedKVStore.SingleKVStore = await DMDistStore.init(ctx);

    store.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL,
      (data: distributedKVStore.ChangeNotification) => {
        const keys: string[] = [];

        // 兼容不同字段是否存在
        if (data.insertEntries) {
          data.insertEntries.forEach((e: distributedKVStore.Entry) => { keys.push(e.key); });
        }
        if (data.updateEntries) {
          data.updateEntries.forEach((e: distributedKVStore.Entry) => { keys.push(e.key); });
        }
        if (data.deleteEntries) {
          data.deleteEntries.forEach((e: distributedKVStore.Entry) => { keys.push(e.key); });
        }

        // 不阻塞回调线程
        onChanged(keys).catch(() => { /* ignore */ });
      });

    DMDistStore.subscribed = true;
  }

  /**
   * 写入/更新一条记录
   * （严格模式下不使用 ...spread）
   */
  static async upsertRecord(ctx: common.UIAbilityContext, record: MedicalRecord): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await DMDistStore.init(ctx);
    const key: string = DMDistStore.buildKey(record.id);

    const env: DistRecordEnvelope = {
      deleted: false,
      id: record.id,
      title: record.title,
      type: record.type,
      tag: record.tag,
      visitDate: record.visitDate,
      fileUri: record.fileUri,
      ocrText: record.ocrText,
      createdAt: record.createdAt
    };

    const json: string = JSON.stringify(env);
    await store.put(key, json);
  }

  /**
   * 删除：写入 tombstone（deleted=true）
   */
  static async tombstoneDelete(ctx: common.UIAbilityContext, recordId: string): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await DMDistStore.init(ctx);
    const key: string = DMDistStore.buildKey(recordId);

    const env: DistRecordEnvelope = {
      deleted: true,
      id: recordId,
      deletedAt: Date.now()
    };

    const json: string = JSON.stringify(env);
    await store.put(key, json);
  }

  /**
   * 根据 key 批量读取
   */
  static async getByKeys(ctx: common.UIAbilityContext, keys: string[]): Promise<Map<string, string>> {
    const store: distributedKVStore.SingleKVStore = await DMDistStore.init(ctx);
    const out: Map<string, string> = new Map<string, string>();

    for (let i = 0; i < keys.length; i++) {
      const k: string = keys[i];
      if (!k.startsWith(DMDistStore.KEY_PREFIX)) continue;

      try {
        const v = await store.get(k);

        // 本项目中 KVStore 只写入 string(JSON)，只处理 string 即可
        if (typeof v === 'string') {
          out.set(k, v);
        }
        // 其它类型（number/boolean/Uint8Array）直接忽略，避免 ArkTS 报错
      } catch (_) {
        // key 不存在或读取失败，忽略
      }
    }
    return out;
  }


  /**
   * 手动触发同步（PUSH_PULL）
   * 注意：这里用变量 deviceIds，避免某些规则对 [] 直接传参报错
   */
  static async sync(ctx: common.UIAbilityContext): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await DMDistStore.init(ctx);
    const deviceIds: string[] = [];
    await store.sync(deviceIds, distributedKVStore.SyncMode.PUSH_PULL);
  }
}
