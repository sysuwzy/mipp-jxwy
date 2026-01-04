import relationalStore from '@ohos.data.relationalStore';
import type common from '@ohos.app.ability.common';

const DB_NAME: string = 'dm_records.db';
const TABLE_NAME: string = 'records';

const SQL_CREATE_TABLE: string = `
CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  tag TEXT NOT NULL,
  visitDate INTEGER NOT NULL,
  fileUri TEXT NOT NULL,
  ocrText TEXT,
  createdAt INTEGER NOT NULL
)`;

/**
 * Local RDB helper for Data Management module
 * Compatible with getRdbStore(context, config, callback) style
 */
export class DMDb {
  private static store: relationalStore.RdbStore | null = null;

  static table(): string {
    return TABLE_NAME;
  }

  static async getStore(ctx: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (DMDb.store) {
      return DMDb.store;
    }

    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    // Wrap callback-style getRdbStore into a Promise (most compatible)
    const store: relationalStore.RdbStore = await new Promise((resolve, reject) => {
      relationalStore.getRdbStore(ctx, config, (err: Error | null, rdb: relationalStore.RdbStore) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(rdb);
      });
    });

    // Create table if not exists
    await store.executeSql(SQL_CREATE_TABLE);

    DMDb.store = store;
    return store;
  }
}
