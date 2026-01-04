import router from '@ohos.router';
import type common from '@ohos.app.ability.common';
import { DMRepository } from '../../utils/DMRepository';
import type { MedicalRecord } from '../../utils/DMTypes';

function fmtDate(ms: number): string {
  const d: Date = new Date(ms);
  const y: number = d.getFullYear();
  const m: string = String(d.getMonth() + 1).padStart(2, '0');
  const day: string = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

@Entry
@Component
struct DMDetail {
  private ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  // ✅ DO NOT name it "id"
  private recordId: string = '';

  @State rec: MedicalRecord | null = null;
  @State err: string = '';
  @State working: boolean = false;

  aboutToAppear() {
    const p = router.getParams() as Record<string, Object>;
    this.recordId = (p?.id as string) ?? '';
    this.load();
  }

  private toErrString(e: Object | string | number | boolean | undefined | null): string {
    try {
      if (typeof e === 'string') return e;
      return JSON.stringify(e);
    } catch (_) {
      return String(e);
    }
  }

  private async load(): Promise<void> {
    this.err = '';
    try {
      this.rec = await DMRepository.get(this.ctx, this.recordId);
      if (!this.rec) this.err = 'Record not found';
    } catch (e) {
      this.err = 'Load failed: ' + this.toErrString(e as Object);
      this.rec = null;
    }
  }

  private onEdit(): void {
    router.pushUrl({ url: 'pages/DataManager/DMAddRecord', params: { mode: 'edit', id: this.recordId } })
      .then(() => this.load());
  }

  private async onDelete(): Promise<void> {
    if (this.working) return;
    this.working = true;
    this.err = '';
    try {
      await DMRepository.remove(this.ctx, this.recordId);
      router.back();
    } catch (e) {
      this.err = 'Delete failed: ' + this.toErrString(e as Object);
    } finally {
      this.working = false;
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('Record Detail').fontSize(22).fontWeight(FontWeight.Bold);
        Blank();
        Button('Back').onClick(() => { router.back(); });
      }.width('100%');

      if (this.err.length > 0) {
        Text(this.err).fontColor(Color.Red).fontSize(12);
      }

      if (this.rec !== null) {
        Text(this.rec.title).fontSize(20).fontWeight(FontWeight.Medium);
        Text(`${this.rec.type} · ${this.rec.tag} · ${fmtDate(this.rec.visitDate)}`)
          .opacity(0.7);

        Text(`URI: ${this.rec.fileUri}`).fontSize(12).opacity(0.7);

        Row({ space: 10 }) {
          Button('Edit')
            .layoutWeight(1)
            .enabled(!this.working)
            .onClick(() => { this.onEdit(); });

          Button('Delete')
            .layoutWeight(1)
            .enabled(!this.working)
            .onClick(() => { this.onDelete(); });
        }.width('100%').margin({ top: 20 });
      }
    }
    .padding(16)
    .width('100%')
    .height('100%');
  }
}

export default DMDetail;
