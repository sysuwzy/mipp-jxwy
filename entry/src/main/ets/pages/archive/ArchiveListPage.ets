// pages/archive/ArchiveListPage.ets
@Component
export struct ArchiveListPage {
  @State archiveList: HealthRecord[] = [];
  @State isLoading: boolean = true;

  private manager: HealthArchiveManager = new HealthArchiveManager();

  aboutToAppear() {
    this.loadArchives();
  }

  loadArchives() {
    // 模拟加载数据
    setTimeout(() => {
      // 添加示例数据
      const exampleRecord = this.manager.createRecord({
        title: '2024年体检报告',
        type: HealthRecordType.EXAMINATION,
        content: '体检结果正常，各项指标均在正常范围内。',
        hospital: '北京协和医院',
        tags: ['年度体检', '健康检查']
      });

      this.archiveList = this.manager.getAllRecords();
      this.isLoading = false;
    }, 800);
  }

  // 创建新档案
  createNewArchive() {
    const newArchiveId = this.manager.createTravelArchive([], '新建档案');
    const newArchive = this.manager.getRecordById(newArchiveId);

    if (newArchive) {
      this.archiveList = [newArchive, ...this.archiveList];
      prompt.showToast({
        message: '新建档案成功',
        duration: 2000
      });
    }
  }

  // 查看档案详情
  viewArchiveDetail(record: HealthRecord) {
    // 路由跳转到详情页
    router.pushUrl({
      url: 'pages/archive/ArchiveDetailPage',
      params: { archiveId: record.id }
    });
  }

  build() {
    Column() {
      // 页面标题
      Text('健康档案')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      // 操作按钮
      Row() {
        Button('+ 新建档案')
          .width(120)
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => this.createNewArchive())
      }
      .margin({ bottom: 20 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color('#007DFF')
          Text('加载中...')
            .margin({ top: 10 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.archiveList.length === 0) {
        Column() {
          Image($r('app.media.ic_empty'))
            .width(100)
            .height(100)
            .margin({ bottom: 20 })
          Text('暂无健康档案')
            .fontSize(18)
            .fontColor('#666')
          Text('点击"新建档案"开始创建')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        // 档案列表
        List() {
          ForEach(this.archiveList, (item: HealthRecord) => {
            ListItem() {
              ArchiveListItem({ record: item, onViewDetail: () => this.viewArchiveDetail(item) })
            }
          })
        }
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: '#EEE' })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}