import { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import { textRecognition } from '@kit.CoreVisionKit';

export class DMOcrStub {
  // 使用 Core Vision Kit 的通用文字识别（端侧 OCR，不走云端 REST API）
  static async extractText(sandboxFilePath: string): Promise<string> {
    // 1) 打开图片文件，拿到 fd（文件描述符）
    let fd: number = -1;
    let imgSource: image.ImageSource | undefined = undefined;
    let pixelMap: image.PixelMap | undefined = undefined;

    try {
      const file = fs.openSync(sandboxFilePath, fs.OpenMode.READ_ONLY);
      fd = file.fd;

      // 2) 通过 fd 创建 ImageSource，再创建 PixelMap
      imgSource = image.createImageSource(fd);
      pixelMap = await imgSource.createPixelMap();

      // 3) 组装 OCR 输入参数
      const visionInfo: textRecognition.VisionInfo = {
        pixelMap: pixelMap
      };

      // OCR 配置：是否开启方向检测（按需）
      const cfg: textRecognition.TextRecognitionConfiguration = {
        isDirectionDetectionSupported: false
      };

      // 4) 调用 OCR（callback 风格，封装成 Promise）
      const text: string = await new Promise((resolve, reject) => {
        textRecognition.recognizeText(
          visionInfo,
          cfg,
          (err: BusinessError, data: textRecognition.TextRecognitionResult) => {
            if (err && err.code !== 0) {
              reject(err);
              return;
            }
            // data.value 通常是识别到的文字结果（可 toString）
            resolve(data?.value?.toString?.() ?? '');
          }
        );
      });

      return text;
    } catch (e) {
      // 出错时返回空字符串（不阻塞保存流程），也可以改成抛错
      return '';
    } finally {
      // 5) 释放资源，避免内存泄漏
      try { pixelMap?.release(); } catch (_) {}
      try { imgSource?.release(); } catch (_) {}
      try {
        if (fd >= 0) fs.closeSync(fd);
      } catch (_) {}
    }
  }
}
