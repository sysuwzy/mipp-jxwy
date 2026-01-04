import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';

import { DMRepository } from '../../utils/DMRepository';
import { DMDb } from '../../utils/DMDb';
import { DMDistStore } from '../../utils/DMDistStore';

import type { MedicalRecord } from '../../utils/DMTypes';
import { RECORD_TAGS, RECORD_TYPES } from '../../utils/DMTypes';

function fmtDate(ms: number): string {
  const d: Date = new Date(ms);
  const y: number = d.getFullYear();
  const m: string = String(d.getMonth() + 1).padStart(2, '0');
  const day: string = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

// 用于解析分布式 KV 中存储的 JSON（tombstone 或正常记录）
interface DistRecordEnvelope {
  deleted?: boolean;
  id?: string;
  title?: string;
  type?: string;
  tag?: string;
  visitDate?: number;
  fileUri?: string;
  ocrText?: string;
  createdAt?: number;
  deletedAt?: number;
}

@Entry
@Component
struct DMHome {
  private ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  @State records: MedicalRecord[] = [];
  @State keyword: string = '';
  @State tagFilter: string = 'ALL';
  @State typeFilter: string = 'ALL';

  // 用于防止并发重复处理远端变更
  @State applyingRemote: boolean = false;

  aboutToAppear() {
    // 1) 先加载本地数据
    this.reload();

    // 2) 订阅分布式 KV 变化：远端设备写入/删除时，本地会收到回调
    // DMDistStore 内部有 subscribed 标记，重复调用不会重复订阅
    DMDistStore.ensureSubscribed(this.ctx, async (changedKeys: string[]) => {
      // 避免并发叠加
      if (this.applyingRemote) return;
      this.applyingRemote = true;

      try {
        // 拉取变化的 key 对应内容（JSON 字符串）
        const map: Map<string, string> = await DMDistStore.getByKeys(this.ctx, changedKeys);

        // 将远端变化落地到本地 RDB（UI 读取的是本地 RDB）
        await this.applyRemoteToLocalRdb(map);

        // 刷新 UI
        await this.reload();
      } catch (_) {
        // 忽略远端同步失败，不影响本地使用
      } finally {
        this.applyingRemote = false;
      }
    }).catch(() => { /* ignore */ });
  }

  private async reload(): Promise<void> {
    try {
      this.records = await DMRepository.list(this.ctx);
    } catch (_) {
      this.records = [];
    }
  }

  /**
   * 将分布式 KV 的变化写入本地 RDB
   * - deleted=true -> 本地删除
   * - deleted=false -> 本地 upsert（简化：先删后插）
   */
  private async applyRemoteToLocalRdb(map: Map<string, string>): Promise<void> {
    const store: relationalStore.RdbStore = await DMDb.getStore(this.ctx);

    // 避免使用 for (const [, v] of map) 这种解构写法（ArkTS 禁止）
    const it = map.entries();
    let next = it.next();

    while (!next.done) {
      const pair = next.value;       // pair: [key, value]
      const json: string = pair[1];  // value: JSON 字符串

      let rawObj: Object;
      try {
        rawObj = JSON.parse(json) as Object;
      } catch (_) {
        next = it.next();
        continue;
      }

      if (typeof rawObj !== 'object' || rawObj === null) {
        next = it.next();
        continue;
      }

      const obj: Record<string, Object> = rawObj as Record<string, Object>;

      const idVal: Object | undefined = obj['id'];
      if (typeof idVal !== 'string' || idVal.length === 0) {
        next = it.next();
        continue;
      }
      const id: string = idVal;

      const deletedVal: Object | undefined = obj['deleted'];
      const deleted: boolean = (typeof deletedVal === 'boolean') ? deletedVal : false;

      if (deleted) {
        const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(DMDb.table());
        predicates.equalTo('id', id);
        try {
          await store.delete(predicates);
        } catch (_) {
          // ignore
        }
        next = it.next();
        continue;
      }

      const titleVal: Object | undefined = obj['title'];
      const typeVal: Object | undefined = obj['type'];
      const tagVal: Object | undefined = obj['tag'];
      const visitDateVal: Object | undefined = obj['visitDate'];
      const fileUriVal: Object | undefined = obj['fileUri'];
      const ocrTextVal: Object | undefined = obj['ocrText'];
      const createdAtVal: Object | undefined = obj['createdAt'];

      const title: string = (typeof titleVal === 'string') ? titleVal : '';
      const type: string = (typeof typeVal === 'string') ? typeVal : '';
      const tag: string = (typeof tagVal === 'string') ? tagVal : '';
      const visitDate: number = (typeof visitDateVal === 'number') ? visitDateVal : Date.now();
      const fileUri: string = (typeof fileUriVal === 'string') ? fileUriVal : 'demo://no-image';
      const ocrText: string = (typeof ocrTextVal === 'string') ? ocrTextVal : '';
      const createdAt: number = (typeof createdAtVal === 'number') ? createdAtVal : Date.now();

      const delPred: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(DMDb.table());
      delPred.equalTo('id', id);
      try {
        await store.delete(delPred);
      } catch (_) {
        // ignore
      }

      const values: relationalStore.ValuesBucket = {
        id: id,
        title: title,
        type: type,
        tag: tag,
        visitDate: visitDate,
        fileUri: fileUri,
        ocrText: ocrText,
        createdAt: createdAt
      };

      try {
        await store.insert(DMDb.table(), values);
      } catch (_) {
        // ignore
      }

      next = it.next();
    }
  }


  private getFiltered(): MedicalRecord[] {
    const key: string = this.keyword.trim();
    return this.records.filter((r: MedicalRecord) => {
      const hitKeyword: boolean =
        (key.length === 0) || r.title.includes(key) || r.ocrText.includes(key);

      const hitTag: boolean = (this.tagFilter === 'ALL') || (r.tag === this.tagFilter);
      const hitType: boolean = (this.typeFilter === 'ALL') || (r.type === this.typeFilter);
      return hitKeyword && hitTag && hitType;
    });
  }

  @Builder
  private Chip(text: string, selected: boolean, onTap: () => void) {
    Stack() {
      Text(text)
        .fontSize(13)
        .fontColor(selected ? Color.White : Color.Black);
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .margin({ right: 10, bottom: 10 })
    .backgroundColor(selected ? 0x317AF7 : 0xEEEEEE)
    .borderRadius(18)
    .gesture(
      TapGesture().onAction(() => { onTap(); })
    );
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('数据管理').fontSize(22).fontWeight(FontWeight.Bold);
        Blank();
        Button('+ Add')
          .onClick(() => {
            router.pushUrl({ url: 'pages/DataManager/DMAddRecord' })
              .then(() => this.reload());
          });
      }.width('100%');

      TextInput({ placeholder: 'Search title / OCR text...' })
        .onChange((v: string) => { this.keyword = v; })
        .width('100%');

      Column({ space: 6 }) {
        Text('Tag Filter').fontSize(12).opacity(0.7);

        Flex({ wrap: FlexWrap.Wrap }) {
          this.Chip('ALL', this.tagFilter === 'ALL', () => { this.tagFilter = 'ALL'; });

          ForEach(RECORD_TAGS, (t: string) => {
            this.Chip(t, this.tagFilter === t, () => { this.tagFilter = t; });
          }, (t: string) => t);
        }.width('100%');
      }.width('100%');

      Column({ space: 6 }) {
        Text('Type Filter').fontSize(12).opacity(0.7);

        Flex({ wrap: FlexWrap.Wrap }) {
          this.Chip('ALL', this.typeFilter === 'ALL', () => { this.typeFilter = 'ALL'; });

          ForEach(RECORD_TYPES, (tp: string) => {
            this.Chip(tp, this.typeFilter === tp, () => { this.typeFilter = tp; });
          }, (tp: string) => tp);
        }.width('100%');
      }.width('100%');

      List() {
        ForEach(this.getFiltered(), (r: MedicalRecord) => {
          ListItem() {
            Row({ space: 10 }) {
              Column({ space: 4 }) {
                Text(r.title).fontSize(18).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });

                Text(`${r.type} · ${r.tag} · ${fmtDate(r.visitDate)}`)
                  .fontSize(12).opacity(0.7);

                Text(`URI: ${r.fileUri}`)
                  .fontSize(11).opacity(0.6).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }.layoutWeight(1);

              Button('View')
                .onClick(() => {
                  router.pushUrl({ url: 'pages/DataManager/DMDetail', params: { id: r.id } })
                    .then(() => this.reload());
                });
            }
            .padding(12)
            .width('100%');
          }
        }, (r: MedicalRecord) => r.id);
      }
      .width('100%')
      .layoutWeight(1);

      Row({ space: 10 }) {
        Button('Refresh')
          .layoutWeight(1)
          .onClick(() => { this.reload(); });

        Button('Clear Filters')
          .layoutWeight(1)
          .onClick(() => {
            this.keyword = '';
            this.tagFilter = 'ALL';
            this.typeFilter = 'ALL';
          });
      }.width('100%');
    }
    .padding(16)
    .width('100%')
    .height('100%');
  }
}

export default DMHome;
