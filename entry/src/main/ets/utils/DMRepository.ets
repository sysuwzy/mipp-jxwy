import type common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { DMDb } from './DMDb';
import { DMFileStore } from './DMFileStore';
import { DMOcrStub } from './DMOcrStub';
import { DMSyncStub } from './DMSyncStub';
import type { MedicalRecord } from './DMTypes';

export interface AddRecordInput {
  title: string;
  type: string;
  tag: string;
  visitDate: number;
  pickedFileUri: string;
  doOcr: boolean;
}

export class DMRepository {
  static async list(ctx: common.UIAbilityContext): Promise<MedicalRecord[]> {
    try {
      const store: relationalStore.RdbStore = await DMDb.getStore(ctx);
      const rs: relationalStore.ResultSet =
        await store.querySql(`SELECT * FROM ${DMDb.table()} ORDER BY createdAt DESC`);

      const out: MedicalRecord[] = [];
      while (rs.goToNextRow()) {
        const id: string = rs.getString(rs.getColumnIndex('id'));
        const title: string = rs.getString(rs.getColumnIndex('title'));
        const type: string = rs.getString(rs.getColumnIndex('type'));
        const tag: string = rs.getString(rs.getColumnIndex('tag'));
        const visitDate: number = Number(rs.getLong(rs.getColumnIndex('visitDate')));
        const fileUri: string = rs.getString(rs.getColumnIndex('fileUri'));

        const ocrIdx: number = rs.getColumnIndex('ocrText');
        const ocrText: string = ocrIdx >= 0 ? rs.getString(ocrIdx) : '';

        const createdAt: number = Number(rs.getLong(rs.getColumnIndex('createdAt')));

        out.push({ id, title, type, tag, visitDate, fileUri, ocrText, createdAt });
      }
      rs.close();
      return out;
    } catch (e) {
      throw new Error(`DMRepository.list failed: ${JSON.stringify(e)}`);
    }
  }

  static async get(ctx: common.UIAbilityContext, id: string): Promise<MedicalRecord | null> {
    try {
      const store: relationalStore.RdbStore = await DMDb.getStore(ctx);
      const rs: relationalStore.ResultSet =
        await store.querySql(`SELECT * FROM ${DMDb.table()} WHERE id=? LIMIT 1`, [id]);

      let row: MedicalRecord | null = null;
      if (rs.goToFirstRow()) {
        const title: string = rs.getString(rs.getColumnIndex('title'));
        const type: string = rs.getString(rs.getColumnIndex('type'));
        const tag: string = rs.getString(rs.getColumnIndex('tag'));
        const visitDate: number = Number(rs.getLong(rs.getColumnIndex('visitDate')));
        const fileUri: string = rs.getString(rs.getColumnIndex('fileUri'));

        const ocrIdx: number = rs.getColumnIndex('ocrText');
        const ocrText: string = ocrIdx >= 0 ? rs.getString(ocrIdx) : '';

        const createdAt: number = Number(rs.getLong(rs.getColumnIndex('createdAt')));

        row = { id, title, type, tag, visitDate, fileUri, ocrText, createdAt };
      }
      rs.close();
      return row;
    } catch (e) {
      throw new Error(`DMRepository.get failed: ${JSON.stringify(e)}`);
    }
  }

  static async add(ctx: common.UIAbilityContext, input: AddRecordInput): Promise<string> {
    try {
      const store: relationalStore.RdbStore = await DMDb.getStore(ctx);
      const id: string = `${Date.now()}_${Math.floor(Math.random() * 1000000)}`;

      // 空 uri 允许保存为 demo
      let finalUri: string = input.pickedFileUri;
      if (finalUri.trim().length === 0) {
        finalUri = 'demo://no-image';
      }

      const isDemo: boolean = finalUri.startsWith('demo://');

      // 真实文件：拷贝到沙箱；demo：直接用 demo uri
      let sandboxPath: string = finalUri;
      if (!isDemo) {
        sandboxPath = await DMFileStore.saveToSandbox(ctx, finalUri);
      }

      // OCR：仅对真实图片执行
      let ocrText: string = '';
      if (input.doOcr && !isDemo) {
        ocrText = await DMOcrStub.extractText(sandboxPath);
      }

      const createdAt: number = Date.now();
      const record: MedicalRecord = {
        id,
        title: input.title,
        type: input.type,
        tag: input.tag,
        visitDate: input.visitDate,
        fileUri: sandboxPath,
        ocrText,
        createdAt
      };

      const values: relationalStore.ValuesBucket = {
        id: record.id,
        title: record.title,
        type: record.type,
        tag: record.tag,
        visitDate: record.visitDate,
        fileUri: record.fileUri,
        ocrText: record.ocrText,
        createdAt: record.createdAt
      };

      await store.insert(DMDb.table(), values);

      // 多端同步入口（真实版：带 ctx + payload）
      await DMSyncStub.notifyRecordUpsert(ctx, record);

      return id;
    } catch (e) {
      throw new Error(`DMRepository.add failed: ${JSON.stringify(e)}`);
    }
  }

  static async update(ctx: common.UIAbilityContext, id: string, input: AddRecordInput): Promise<void> {
    try {
      const store: relationalStore.RdbStore = await DMDb.getStore(ctx);

      // 空 uri 允许保存为 demo
      let finalUri: string = input.pickedFileUri;
      if (finalUri.trim().length === 0) {
        finalUri = 'demo://no-image';
      }

      const isDemo: boolean = finalUri.startsWith('demo://');

      // 如果是新的真实 uri（不是沙箱路径），则拷贝到沙箱
      let targetUri: string = finalUri;
      if (!isDemo && !finalUri.includes('/data/storage/') && !finalUri.includes('/files/')) {
        targetUri = await DMFileStore.saveToSandbox(ctx, finalUri);
      }

      // OCR：仅对真实图片执行
      let ocrText: string = '';
      if (input.doOcr && !isDemo) {
        ocrText = await DMOcrStub.extractText(targetUri);
      }

      const values: relationalStore.ValuesBucket = {
        title: input.title,
        type: input.type,
        tag: input.tag,
        visitDate: input.visitDate,
        fileUri: targetUri,
        ocrText
      };

      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(DMDb.table());
      predicates.equalTo('id', id);

      await store.update(values, predicates);

      // 组装更新后的记录 payload，进入多端同步入口
      const updated: MedicalRecord = {
        id,
        title: input.title,
        type: input.type,
        tag: input.tag,
        visitDate: input.visitDate,
        fileUri: targetUri,
        ocrText,
        createdAt: Date.now()
      };

      await DMSyncStub.notifyRecordUpsert(ctx, updated);
    } catch (e) {
      throw new Error(`DMRepository.update failed: ${JSON.stringify(e)}`);
    }
  }

  static async remove(ctx: common.UIAbilityContext, id: string): Promise<void> {
    try {
      const store: relationalStore.RdbStore = await DMDb.getStore(ctx);

      const rec: MedicalRecord | null = await DMRepository.get(ctx, id);
      if (rec !== null) {
        if (!rec.fileUri.startsWith('demo://')) {
          await DMFileStore.deleteSandboxFile(rec.fileUri);
        }
      }

      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(DMDb.table());
      predicates.equalTo('id', id);

      await store.delete(predicates);

      // 多端同步入口（删除）
      await DMSyncStub.notifyRecordDelete(ctx, id);
    } catch (e) {
      throw new Error(`DMRepository.remove failed: ${JSON.stringify(e)}`);
    }
  }
}
