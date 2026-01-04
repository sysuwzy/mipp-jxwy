import fs from '@ohos.file.fs';
import type common from '@ohos.app.ability.common';

export class DMFileStore {
  // Copy picked file into app sandbox: <filesDir>/dm/<timestamp>_<name>
  static async saveToSandbox(ctx: common.UIAbilityContext, srcUri: string): Promise<string> {
    const dstDir = `${ctx.filesDir}/dm`;
    if (!fs.accessSync(dstDir)) {
      fs.mkdirSync(dstDir);
    }

    const safeName = `${Date.now()}_${Math.floor(Math.random() * 100000)}.bin`;
    const dstPath = `${dstDir}/${safeName}`;

    // srcUri may be file:// or a real path depending on picker;
    // normalize: remove "file://" if present.
    const srcPath = srcUri.startsWith('file://') ? srcUri.substring('file://'.length) : srcUri;

    fs.copyFileSync(srcPath, dstPath);
    return dstPath;
  }

  static async deleteSandboxFile(path: string): Promise<void> {
    try {
      if (fs.accessSync(path)) fs.unlinkSync(path);
    } catch (_) { /* ignore */ }
  }
}
