import router from '@ohos.router';
import picker from '@ohos.file.picker';
import type common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { DMRepository } from '../../utils/DMRepository';
import { RECORD_TAGS, RECORD_TYPES } from '../../utils/DMTypes';

function joinList(arr: string[]): string {
  // show as hint text
  return arr.join(' / ');
}

@Entry
@Component
struct DMAddRecord {
  private ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  @State isEdit: boolean = false;
  private editId: string = '';

  @State title: string = '';
  @State pickedUri: string = '';
  @State tag: string = RECORD_TAGS[0];     // user can edit by typing
  @State type: string = RECORD_TYPES[0];   // user can edit by typing
  @State visitDateMs: number = Date.now();

  @State doOcr: boolean = false;
  @State saving: boolean = false;
  @State err: string = '';

  aboutToAppear() {
    const p = router.getParams() as Record<string, Object>;
    const mode: string = (p?.mode as string) ?? '';
    const id: string = (p?.id as string) ?? '';

    if (mode === 'edit' && id.length > 0) {
      this.isEdit = true;
      this.editId = id;
      this.loadForEdit(id);
    } else {
      this.isEdit = false;
      this.editId = '';
      this.title = '';
      this.pickedUri = '';
      this.tag = RECORD_TAGS[0];
      this.type = RECORD_TYPES[0];
      this.visitDateMs = Date.now();
      this.doOcr = false;
      this.err = '';
    }
  }
  // Load bundled rawfile image (ocr_test.png) into sandbox and set pickedUri
  private async useBundledTestImage(): Promise<void> {
    this.err = '';
    try {
      // 1) Read the PNG bytes from entry/resources/rawfile/ocr_test.png
      const bytes: Uint8Array = await this.ctx.resourceManager.getRawFileContent('ocr_test.png');

      // 2) Ensure sandbox dir exists: <filesDir>/dm
      const dstDir = `${this.ctx.filesDir}/dm`;
      if (!fs.accessSync(dstDir)) {
        fs.mkdirSync(dstDir);
      }

      // 3) Write file into sandbox (so OCR can read a real local path)
      const dstPath = `${dstDir}/ocr_test.png`;

      // Create/overwrite file then write bytes
      const f = fs.openSync(dstPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(f.fd, bytes);
      fs.closeSync(f);

      // 4) Set pickedUri to sandbox path
      this.pickedUri = dstPath;
    } catch (e) {
      this.err = 'Load bundled image failed: ' + this.toErrString(e as Object);
    }
  }


  private toErrString(e: Object | string | number | boolean | undefined | null): string {
    try {
      if (typeof e === 'string') return e;
      return JSON.stringify(e);
    } catch (_) {
      return String(e);
    }
  }

  private async loadForEdit(id: string): Promise<void> {
    this.err = '';
    try {
      const rec = await DMRepository.get(this.ctx, id);
      if (!rec) {
        this.err = 'Record not found';
        return;
      }
      this.title = rec.title;
      this.pickedUri = rec.fileUri;
      this.tag = rec.tag;
      this.type = rec.type;
      this.visitDateMs = rec.visitDate;
      this.doOcr = false;
    } catch (e) {
      this.err = 'Load failed: ' + this.toErrString(e as Object);
    }
  }

  private async pickFromLibrary(): Promise<void> {
    this.err = '';
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const res = await photoPicker.select({ maxSelectNumber: 1 });
      if (res?.photoUris?.length) {
        this.pickedUri = res.photoUris[0];
      } else {
        this.err = 'No file selected (emulator may have empty gallery).';
      }
    } catch (e) {
      this.err = 'Pick failed: ' + this.toErrString(e as Object);
    }
  }

  private async onSave(): Promise<void> {
    this.err = '';
    if (this.title.trim().length === 0) { this.err = 'Title is required'; return; }
    if (this.tag.trim().length === 0) { this.err = 'Tag is required'; return; }
    if (this.type.trim().length === 0) { this.err = 'Type is required'; return; }

    // allow demo save if empty uri
    const uri: string = this.pickedUri.trim().length ? this.pickedUri.trim() : 'demo://no-image';

    this.saving = true;
    try {
      if (!this.isEdit) {
        await DMRepository.add(this.ctx, {
          title: this.title.trim(),
          type: this.type.trim(),
          tag: this.tag.trim(),
          visitDate: this.visitDateMs,
          pickedFileUri: uri,
          doOcr: this.doOcr
        });
      } else {
        await DMRepository.update(this.ctx, this.editId, {
          title: this.title.trim(),
          type: this.type.trim(),
          tag: this.tag.trim(),
          visitDate: this.visitDateMs,
          pickedFileUri: uri,
          doOcr: this.doOcr
        });
      }
      router.back();
    } catch (e) {
      this.err = (this.isEdit ? 'Update failed: ' : 'Save failed: ') + this.toErrString(e as Object);
    } finally {
      this.saving = false;
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.isEdit ? 'Edit Record' : 'Add Record')
          .fontSize(22)
          .fontWeight(FontWeight.Bold);
        Blank();
        Button('Back').onClick(() => { router.back(); });
      }.width('100%');

      if (this.err.length > 0) {
        Text(this.err).fontColor(Color.Red).fontSize(12);
      }

      TextInput({ placeholder: 'Title', text: this.title })
        .onChange((v: string) => { this.title = v; })
        .width('100%');

      // ✅ Date picker (fix number|undefined by fallback)
      Column({ space: 6 }) {
        Text('Visit Date').fontSize(12).opacity(0.7);

        DatePicker({ selected: new Date(this.visitDateMs) })
          .onChange((value) => {
            const y: number = (value.year ?? new Date().getFullYear());
            const m: number = (value.month ?? (new Date().getMonth() + 1));
            const d: number = (value.day ?? new Date().getDate());
            this.visitDateMs = new Date(y, m - 1, d).getTime();
          });
      }.width('100%');

      // ✅ Tag typed input (no chip tap issues, no Select object-literals)
      Column({ space: 6 }) {
        Text('Tag').fontSize(12).opacity(0.7);
        Text(`Suggested: ${joinList(RECORD_TAGS)}`).fontSize(11).opacity(0.5);

        TextInput({ placeholder: 'Tag (copy from suggested)', text: this.tag })
          .onChange((v: string) => { this.tag = v; })
          .width('100%');
      }.width('100%');

      // ✅ Type typed input
      Column({ space: 6 }) {
        Text('Type').fontSize(12).opacity(0.7);
        Text(`Suggested: ${joinList(RECORD_TYPES)}`).fontSize(11).opacity(0.5);

        TextInput({ placeholder: 'Type (copy from suggested)', text: this.type })
          .onChange((v: string) => { this.type = v; })
          .width('100%');
      }.width('100%');

      Row({ space: 8 }) {
        TextInput({ placeholder: 'File uri (optional; empty = demo://no-image)', text: this.pickedUri })
          .onChange((v: string) => { this.pickedUri = v; })
          .layoutWeight(1);

        Button('Pick')
          .enabled(!this.saving)
          .onClick(() => { this.pickFromLibrary(); });

        Button('Use Bundled')
          .enabled(!this.saving)
          .onClick(() => { this.useBundledTestImage(); });
      }.width('100%');


      Row({ space: 8 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.doOcr })
          .onChange((v: boolean) => { this.doOcr = v; });
        Text('Run OCR (stub)').opacity(0.7);
      }

      Button(this.saving ? 'Saving...' : (this.isEdit ? 'Update' : 'Save'))
        .width('100%')
        .enabled(!this.saving)
        .onClick(() => { this.onSave(); });
    }
    .padding(16)
    .width('100%')
    .height('100%');
  }
}

export default DMAddRecord;
