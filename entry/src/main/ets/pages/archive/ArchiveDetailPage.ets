import { HealthArchiveManager } from "../../manager/HealthArchiveManager";
import { prompt, router } from "@kit.ArkUI";

// pages/archive/ArchiveDetailPage.ets
@Component
export struct ArchiveDetailPage {
  @State archiveContent: string = '正在加载档案内容...';
  @State isLoading: boolean = true;
  @State archiveTitle: string = '';

  private manager: HealthArchiveManager = new HealthArchiveManager();
  private archiveId: string = '';

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    this.archiveId = params?.archiveId || '';

    this.loadArchiveData();
  }

  loadArchiveData() {
    setTimeout(() => {
      const record = this.manager.getRecordById(this.archiveId);

      if (record) {
        this.archiveTitle = record.title;
        this.archiveContent = record.content || '暂无内容';
      } else {
        this.archiveTitle = '档案不存在';
        this.archiveContent = '无法找到指定的健康档案';
      }

      this.isLoading = false;
    }, 600);
  }

  // 保存档案
  saveArchive() {
    prompt.showToast({
      message: '已保存到本地',
      duration: 2000
    });
  }

  // 分享档案
  shareArchive() {
    prompt.showToast({
      message: '准备分享档案...',
      duration: 2000
    });

    // 这里可以调用系统分享功能
    // 实际项目中可以集成鸿蒙的分享服务
  }

  // 编辑档案
  editArchive() {
    prompt.showToast({
      message: '编辑功能开发中',
      duration: 2000
    });
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text(this.archiveTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 16 })

        Blank()

        Image($r('app.media.ic_share'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => this.shareArchive())
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color('#007DFF')
          Text('加载中...')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          // 档案内容
          Scroll() {
            Column() {
              Text(this.archiveContent)
                .fontSize(16)
                .lineHeight(24)
                .fontColor('#333')
            }
            .padding(20)
          }
          .layoutWeight(1)

          // 操作按钮
          Row() {
            Button('保存')
              .width('30%')
              .height(48)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .onClick(() => this.saveArchive())

            Button('分享')
              .width('30%')
              .height(48)
              .backgroundColor('#2196F3')
              .fontColor(Color.White)
              .margin({ left: 12 })
              .onClick(() => this.shareArchive())

            Button('编辑')
              .width('30%')
              .height(48)
              .backgroundColor('#FF9800')
              .fontColor(Color.White)
              .margin({ left: 12 })
              .onClick(() => this.editArchive())
          }
          .justifyContent(FlexAlign.Center)
          .margin({ top: 20, bottom: 30 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}