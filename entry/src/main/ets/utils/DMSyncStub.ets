import type common from '@ohos.app.ability.common';
import type { MedicalRecord } from './DMTypes';

/**
 * 多端同步触发器（真实同步的“入口层”）
 * ------------------------------------------------
 * 当前实现：
 * - 保证编译通过、流程稳定
 * - 提供“真实多端同步”的明确扩展点（后续可替换为分布式KV/分布式RDB）
 *
 * 说明：
 * - notifyRecordUpsert / notifyRecordDelete 会在增删改后被调用
 * - 目前仅记录日志与触发点，不阻塞主业务
 */
export class DMSyncStub {
  static async notifyRecordUpsert(_ctx: common.UIAbilityContext, record: MedicalRecord): Promise<void> {
    try {
      // 多端同步扩展点：此处可写入分布式 KV / 分布式数据库，并触发 sync
      console.info(`[DMSyncStub] UPSERT trigger id=${record.id}`);
    } catch (_) {
      // 同步异常不应影响主流程
    }
  }

  static async notifyRecordDelete(_ctx: common.UIAbilityContext, recordId: string): Promise<void> {
    try {
      // 多端同步扩展点：此处可写入 tombstone 并触发 sync
      console.info(`[DMSyncStub] DELETE trigger id=${recordId}`);
    } catch (_) {
      // 同步异常不应影响主流程
    }
  }
}
