import { HealthRecord, HealthRecordType } from '../../models/HealthRecord';
import { prompt } from '@kit.ArkUI';
import { AuthorizationCode } from '../../models/AuthorizationCode';
import { StorageHelper } from '../../utils/StorageHelper';
import { common } from '@kit.AbilityKit';
interface GeneratedTypeLiteralInterface_1 {
  id: string;
  title: string;
  type: HealthRecordType;
  content: string;
  hospital: string;
  date: string;
  tags?: string[];
}
// 在Index类上面添加接口定义
interface AuthCodeData {
  code?: string;
  recordIds?: string[];
  expireAt?: number;
  hospitalName?: string;
  createdAt?: number;
  used?: boolean;
}
interface OptionType {
  label: string;
  value: string;
}
@Entry
@Component
export struct Index {
  @State currentTab: number = 0;
  @State archiveList: HealthRecord[] = [];
  @State selectedArchive: HealthRecord | null = null;

  @State editTitle: string = '';
  @State editType:  string = '';
  @State editHospital: string = '';
  @State editDate: string = '';
  @State editContent: string = '';

  // ============ 新增：加密分享相关状态 ============
  @State showShareDialog: boolean = false;
  @State shareCode: string = '';
  @State shareExpireTime: string = '';
  @State authorizationCodes: AuthorizationCode[] = []; // 存储生成的授权码
  
  // ============ 下拉刷新相关状态 ============
  @State isRefreshing: boolean = false;
  
  // ============ 授权码管理相关状态 ============
  @State showAuthCodeDialog: boolean = false;

  private readonly typeOptions: OptionType[] = [
    { label: '门诊病历', value: '门诊病历' },
    { label: '检查报告', value: '检查报告' },
    { label: '用药处方', value: '用药处方' },
    { label: '专项档案', value: '专项档案' },
    { label: '其他', value: '其他' }
  ];
  // 创建健康记录工厂函数
  private createHealthRecord(data: GeneratedTypeLiteralInterface_1): HealthRecord {
    const record = new HealthRecord();
    record.id = data.id;
    record.title = data.title;
    record.type = data.type;
    record.content = data.content;
    record.hospital = data.hospital;
    record.date = data.date;
    record.tags = data.tags || [];
    return record;
  }

  // 模拟数据
  private mockData: HealthRecord[] = [
    this.createHealthRecord({
      id: '1',
      title: '2024年度体检报告',
      type: HealthRecordType.EXAMINATION,
      content: '体检结果正常，各项指标良好。',
      hospital: '北京协和医院',
      date: '2024-10-15',
      tags: ['年度体检', '重要']
    }),
    this.createHealthRecord({
      id: '2',
      title: '门诊就诊记录',
      type: HealthRecordType.OUTPATIENT,
      content: '感冒就诊，开具抗生素。',
      hospital: '上海市第一人民医院',
      date: '2024-09-20',
      tags: ['门诊', '感冒']
    }),
    this.createHealthRecord({
      id: '3',
      title: '异地就医专项档案',
      type: HealthRecordType.SPECIAL_ARCHIVE,
      content: '整合异地就医全部记录。',
      hospital: '异地就医档案',
      date: '2024-11-01',
      tags: ['异地就医', '必备']
    })
  ];

  async aboutToAppear() {
    // 初始化存储
    const context = getContext(this) as common.UIAbilityContext;
    await StorageHelper.init(context);
    
    // 从本地加载数据
    const savedArchives: HealthRecord[] = await StorageHelper.loadArchiveList();
    const savedCodes: AuthorizationCode[] = await StorageHelper.loadAuthorizationCodes();
    
    if (savedArchives.length > 0) {
      // 如果有保存的数据，使用保存的数据
      this.archiveList = savedArchives;
    } else {
      // 如果没有保存的数据，使用模拟数据（首次启动）
      this.archiveList = this.mockData;
      // 保存初始数据
      await StorageHelper.saveArchiveList(this.archiveList);
    }
    
    // 加载授权码
    if (savedCodes.length > 0) {
      this.authorizationCodes = savedCodes;
    }
  }

  // 创建新档案
  async createNewArchive() {
    const newRecord = this.createHealthRecord({
      id: `record_${Date.now()}`,
      title: '新建健康档案',
      type: HealthRecordType.OTHER,
      content: '请在此编辑档案内容。',
      hospital: '请填写医院',
      date: new Date().toISOString().split('T')[0],
      tags: ['新创建']
    });

    this.archiveList = [newRecord, ...this.archiveList];
    // 保存到本地
    await StorageHelper.saveArchiveList(this.archiveList);
    prompt.showToast({ message: '新建档案成功', duration: 2000 });
  }

  // 查看档案详情
  viewArchiveDetail(record: HealthRecord) {
    this.selectedArchive = record;
    this.currentTab = 1;
  }

  // 删除档案
  async deleteArchive(id: string) {
    this.archiveList = this.archiveList.filter(item => item.id !== id);
    if (this.selectedArchive?.id === id) {
      this.selectedArchive = null;
      this.currentTab = 0;
    }
    // 保存到本地
    await StorageHelper.saveArchiveList(this.archiveList);
    prompt.showToast({ message: '删除成功', duration: 2000 });
  }

  // 返回列表
  backToList() {
    this.currentTab = 0;
    this.selectedArchive = null;
  }

  build() {
    Column() {
      // 顶部标题栏（保持不变）
      Row() {
        Text('健康档案')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 16 })

        Blank()

        if (this.currentTab === 1) {
          Text('返回')
            .fontSize(16)
            .fontColor(Color.White)
            .margin({ right: 16 })
            .onClick(() => this.backToList())
        }
      }
      .width('100%')
      .height(60)
      .backgroundColor('#5FCCC4')

      // 主内容区域
      if (this.currentTab === 0) {
        this.buildArchiveList()
      } else if (this.currentTab === 1 && this.selectedArchive) {
        this.buildArchiveDetail()
      } else if (this.currentTab === 2 && this.selectedArchive) {
        this.buildEditPage()
      }

      // ============ 新增：分享弹窗 ============
      if (this.showShareDialog) {
        this.buildShareDialog()
      }

      // ============ 授权码管理弹窗 ============
      if (this.showAuthCodeDialog) {
        this.buildAuthCodeDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildArchiveList() {
    Column() {
      // 标题区域
      Row() {
        Column() {
          Text(`${this.archiveList.length} 条记录`)
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      if (this.archiveList.length === 0) {
        Column() {
          Text('📂')
            .fontSize(80)
            .margin({ bottom: 24 })
          Text('暂无健康档案')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .margin({ bottom: 8 })
          Text('点击下方按钮创建第一个档案')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 使用Refresh组件实现下拉刷新
        Refresh({ 
          offset: 72, 
          friction: 100, 
          builder: this.refreshBuilder,
          refreshing: this.isRefreshing
        }) {
          List() {
            ForEach(this.archiveList, (item: HealthRecord, index: number) => {
              ListItem() {
                this.buildArchiveCard(item, index)
              }
            }, (item: HealthRecord) => item.id)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
          .padding({ left: 16, right: 16, bottom: 100 })
        }
        .onRefreshing(() => {
          this.handleRefresh();
        })
        .layoutWeight(1)
      }

      // 底部操作按钮区域 - 固定在底部
      Column() {
        Row() {
          Button('+ 新建档案', { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height(50)
            .backgroundColor('#5FCCC4')
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .onClick(() => this.createNewArchive())

          Button('查看授权码', { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height(50)
            .backgroundColor('#FF9800')
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })
            .onClick(() => this.viewAuthorizationCodes())
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .padding({ top: 12, bottom: 80 })
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 构建档案卡片
  @Builder
  buildArchiveCard(item: HealthRecord, index: number) {
    Column() {
      Row() {
        // 左侧图标区域
        Column() {
          Text(this.getTypeIcon(item.type))
            .fontSize(36)
        }
        .width(72)
        .height(72)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.getTypeColor(item.type))
        .borderRadius(14)

        // 中间内容区域
        Column() {
          Text(item.title)
            .fontSize(19)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 10 })

          Row() {
            Text(item.hospital)
              .fontSize(14)
              .fontColor('#666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(' • ')
              .fontSize(14)
              .fontColor('#999')
            Text(item.date)
              .fontSize(14)
              .fontColor('#666')
          }
          .width('100%')
          .margin({ bottom: 10 })

          // 标签区域
          if (item.tags && item.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(item.tags.slice(0, 3), (tag: string) => {
                Text(tag)
                  .fontSize(11)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#E3F2FD')
                  .fontColor('#1976D2')
                  .borderRadius(10)
                  .margin({ right: 6, bottom: 4 })
              })
            }
          }
        }
        .layoutWeight(1)
        .margin({ left: 20 })
        .alignItems(HorizontalAlign.Start)

        // 右侧箭头
        Text('›')
          .fontSize(28)
          .fontColor('#999')
          .fontWeight(FontWeight.Lighter)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(18)
    .margin({ bottom: 16 })
    .shadow({
      radius: 8,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.viewArchiveDetail(item))
  }

  // 刷新构建器
  @Builder
  refreshBuilder() {
    Row() {
      if (this.isRefreshing) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color('#5FCCC4')
        Text('正在刷新...')
          .fontSize(14)
          .fontColor('#666')
          .margin({ left: 12 })
      } else {
        Text('下拉刷新')
          .fontSize(14)
          .fontColor('#999')
      }
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  // 处理刷新
  private async handleRefresh(): Promise<void> {
    this.isRefreshing = true;
    // 重新加载数据
    const savedArchives: HealthRecord[] = await StorageHelper.loadArchiveList();
    if (savedArchives.length > 0) {
      this.archiveList = savedArchives;
    }
    // 模拟刷新延迟
    setTimeout(() => {
      this.isRefreshing = false;
    }, 1000);
  }

  // 获取类型颜色
  private getTypeColor(type: string): string {
    if (type === '门诊病历') return '#E3F2FD';
    if (type === '检查报告') return '#F3E5F5';
    if (type === '用药处方') return '#FFF3E0';
    if (type === '专项档案') return '#E8F5E9';
    return '#F5F5F5';
  }

  @Builder
  buildArchiveDetail() {
    Scroll() {
      Column() {
        // 档案基本信息卡片
        Column() {
          // 标题和类型图标
          Row() {
            Column() {
              Text(this.getTypeIcon(this.selectedArchive!.type))
                .fontSize(32)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.getTypeColor(this.selectedArchive!.type))
            .borderRadius(16)
            .margin({ right: 16 })

            Column() {
              Text(this.selectedArchive!.title)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ bottom: 8 })

              Text(this.selectedArchive!.type)
                .fontSize(14)
                .fontColor('#666')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor('#F0F0F0')
                .borderRadius(12)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 信息网格
          Row() {
            Column() {
              Text('🏥')
                .fontSize(20)
                .margin({ bottom: 8 })
              Text('医院')
                .fontSize(12)
                .fontColor('#999')
                .margin({ bottom: 4 })
              Text(this.selectedArchive!.hospital)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .padding({ right: 12 })

            Column() {
              Text('📅')
                .fontSize(20)
                .margin({ bottom: 8 })
              Text('日期')
                .fontSize(12)
                .fontColor('#999')
                .margin({ bottom: 4 })
              Text(this.selectedArchive!.date)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .border({ width: 1, color: '#F0F0F0' })
          .borderRadius(12)
          .margin({ bottom: 20 })

          // 操作按钮
          Row() {
            Button('编辑')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#FF9800')
              .fontColor(Color.White)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .borderRadius(22)
              .onClick(() => this.enterEditMode(this.selectedArchive!))

            Button('分享')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#5FCCC4')
              .fontColor(Color.White)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .borderRadius(22)
              .margin({ left: 12 })
              .onClick(() => this.shareArchive())

            Button('删除')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#F44336')
              .fontColor(Color.White)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .borderRadius(22)
              .margin({ left: 12 })
              .onClick(() => this.deleteArchive(this.selectedArchive!.id))
          }
          .width('100%')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .margin({ top: 16, left: 16, right: 16 })
        .shadow({
          radius: 12,
          color: '#1F000000',
          offsetX: 0,
          offsetY: 4
        })

        // 档案内容卡片
        Column() {
          Row() {
            Text('📄 档案内容')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
            Blank()
            Button('编辑')
              .fontSize(13)
              .height(32)
              .backgroundColor('#F0F0F0')
              .fontColor('#666')
              .borderRadius(16)
              .onClick(() => this.enterEditMode(this.selectedArchive!))
          }
          .width('100%')
          .margin({ bottom: 16 })

          Text(this.selectedArchive!.content || '暂无内容')
            .fontSize(15)
            .lineHeight(26)
            .fontColor('#333')
            .width('100%')
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .margin({ top: 12, left: 16, right: 16, bottom: 20 })
        .shadow({
          radius: 12,
          color: '#1F000000',
          offsetX: 0,
          offsetY: 4
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  @Builder
  buildEditPage() {
    Scroll() {
      Column() {
        // 编辑表单卡片
        Column() {
          // 标题
          Row() {
            Text('✏️ 编辑档案')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 标题输入
          Column() {
            Text('标题')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 })
            TextInput({
              text: this.editTitle,
              placeholder: '请输入档案标题'
            })
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .fontSize(15)
              .onChange((value: string) => {
                this.editTitle = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 类型选择
          Column() {
            Text('类型')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.typeOptions, (option: OptionType) => {
                Text(option.label)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                  .backgroundColor(this.editType === option.value ? '#5FCCC4' : '#F0F0F0')
                  .fontColor(this.editType === option.value ? Color.White : '#666')
                  .borderRadius(24)
                  .margin({ right: 12, bottom: 12 })
                  .onClick(() => {
                    this.editType = option.value;
                  })
              })
            }
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 医院输入
          Column() {
            Text('医院')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 })
            TextInput({
              text: this.editHospital,
              placeholder: '请输入医院名称'
            })
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .fontSize(15)
              .onChange((value: string) => {
                this.editHospital = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 日期输入
          Column() {
            Text('日期')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 })
            TextInput({
              text: this.editDate,
              placeholder: '格式: YYYY-MM-DD'
            })
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .fontSize(15)
              .onChange((value: string) => {
                this.editDate = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 内容编辑
          Column() {
            Text('内容')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 })
            TextArea({
              text: this.editContent,
              placeholder: '请输入档案内容...'
            })
              .width('100%')
              .height(200)
              .padding(16)
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .fontSize(15)
              .onChange((value: string) => {
                this.editContent = value;
              })
          }
          .width('100%')
          .margin({ bottom: 32 })

          // 操作按钮
          Row() {
            Button('取消', { type: ButtonType.Normal })
              .layoutWeight(1)
              .height(50)
              .backgroundColor('#F0F0F0')
              .fontColor('#333')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(25)
              .onClick(() => this.cancelEdit())

            Button('保存', { type: ButtonType.Normal })
              .layoutWeight(1)
              .height(50)
              .backgroundColor('#5FCCC4')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(25)
              .margin({ left: 12 })
              .onClick(() => this.saveEdit())
          }
          .width('100%')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .margin({ top: 16, left: 16, right: 16, bottom: 40 })
        .shadow({
          radius: 12,
          color: '#1F000000',
          offsetX: 0,
          offsetY: 4
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  @Builder
  buildShareDialog() {
    // 遮罩层
    Column() {
      // 点击遮罩层关闭弹窗
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .onClick(() => this.closeShareDialog())
    .position({ x: 0, y: 0 })

    // 弹窗内容
    Column() {
      // 弹窗标题
      Row() {
        Text('授权码分享')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('×')
          .fontSize(24)
          .fontColor('#666')
          .onClick(() => this.closeShareDialog())
      }
      .width('100%')
      .padding({ bottom: 20 })

      // 档案信息
      if (this.selectedArchive) {
        Column() {
          Row() {
            Column() {
              Text(this.getTypeIcon(this.selectedArchive.type))
                .fontSize(24)
            }
            .margin({ right: 16 })

            Column() {
              Text(this.selectedArchive.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })
                .maxLines(2)
              Text(this.selectedArchive.hospital)
                .fontSize(14)
                .fontColor('#666')
            }
          }
          .width('100%')
          .padding({ bottom: 16 })
        }
      }

      // 授权码展示
      Column() {
        Text('16位授权码')
          .fontSize(14)
          .fontColor('#666')
          .margin({ bottom: 12 })

        if (this.shareCode) {
          Column() {
            Text(this.shareCode)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#5FCCC4')
              .textAlign(TextAlign.Center)
              .width('100%')
              .padding({ top: 16, bottom: 16 })
              .backgroundColor('#F0F7FF')
              .borderRadius(8)

            Text('有效期至：' + this.shareExpireTime)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 8 })
          }
        } else {
          Text('点击下方按钮生成授权码')
            .fontSize(14)
            .fontColor('#999')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(20)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
        }
      }
      .margin({ bottom: 24 })
      // 操作按钮
      Row() {
        if (!this.shareCode) {
          Button('生成授权码', { type: ButtonType.Normal })
            .layoutWeight(1)
            .height(48)
            .backgroundColor('#5FCCC4')
            .fontColor(Color.White)
            .onClick(() => this.shareArchive())
        } else {
          // 只有一个"重新生成"按钮
          Button('重新生成', { type: ButtonType.Normal })
            .width('100%')
            .height(48)
            .backgroundColor('#FF9800')
            .fontColor(Color.White)
            .onClick(() => this.regenerateShareCode())
        }
      }
      .width('100%')
    }
    .width('80%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .position({ x: '10%', y: '20%' })
    .zIndex(1000)
  }
  private getTypeIcon(type: string): string {
    // 直接使用字符串比较
    if (type === '门诊病历') return '🏥';
    if (type === '检查报告') return '🔬';
    if (type === '用药处方') return '💊';
    if (type === '专项档案') return '📋';
    return '📄';
  }
  // 进入编辑模式
  private enterEditMode(record: HealthRecord) {
    this.selectedArchive = record;
    this.editTitle = record.title;
    this.editType = record.type;
    this.editHospital = record.hospital;
    this.editDate = record.date;
    this.editContent = record.content;
    this.currentTab = 2; // 切换到编辑页
  }

  // 保存编辑
  private async saveEdit() {
    if (!this.selectedArchive) return;

    // 更新选中的档案
    this.selectedArchive.title = this.editTitle;
    this.selectedArchive.type = this.editType as '门诊病历' | '检查报告' | '用药处方' | '专项档案' | '其他';
    this.selectedArchive.hospital = this.editHospital;
    this.selectedArchive.date = this.editDate;
    this.selectedArchive.content = this.editContent;

    // 更新列表
    this.archiveList = this.archiveList.map((item: HealthRecord): HealthRecord =>
    item.id === this.selectedArchive!.id ? this.selectedArchive! : item
    );

    // 保存到本地
    await StorageHelper.saveArchiveList(this.archiveList);

    this.currentTab = 1; // 返回详情页
    prompt.showToast({ message: '保存成功', duration: 2000 });
  }

  // 取消编辑
  private cancelEdit() {
    this.currentTab = 1; // 返回详情页
  }

  // ============ 加密分享方法 ============
  private generateShareCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 16; i++) {
      if (i > 0 && i % 4 === 0) code += '-';
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  private async shareArchive() {
    if (!this.selectedArchive) return;

    // 生成授权码
    this.shareCode = this.generateShareCode();

    // 设置过期时间
    const expireTime = new Date();
    expireTime.setHours(expireTime.getHours() + 24);
    this.shareExpireTime = expireTime.toLocaleString();

    // 创建AuthorizationCode对象 - 添加类型断言
    const authCodeData: AuthCodeData = {
      code: this.shareCode,
      recordIds: [this.selectedArchive.id],
      hospitalName: '',
      expireAt: expireTime.getTime(),
      createdAt: Date.now(),
      used: false
    };
    const authCode = new AuthorizationCode(authCodeData);

    // 保存到列表
    this.authorizationCodes.push(authCode);

    // 保存到本地
    await StorageHelper.saveAuthorizationCodes(this.authorizationCodes);

    // 显示弹窗
    this.showShareDialog = true;

    prompt.showToast({
      message: '授权码已生成',
      duration: 2000
    });
  }



  private closeShareDialog() {
    this.showShareDialog = false;
    this.shareCode = '';
    // 可以选择是否清空目标医院
    // this.targetHospital = '';
  }

  private viewAuthorizationCodes() {
    if (this.authorizationCodes.length === 0) {
      prompt.showToast({
        message: '暂无生成的授权码',
        duration: 2000
      });
      return;
    }
    // 显示授权码管理弹窗
    this.showAuthCodeDialog = true;
  }

  // 构建授权码管理弹窗
  @Builder
  buildAuthCodeDialog() {
    // 遮罩层
    Column() {
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .onClick(() => this.closeAuthCodeDialog())
    .position({ x: 0, y: 0 })

    // 弹窗内容
    Column() {
      // 标题栏
      Row() {
        Text('授权码管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        Text('×')
          .fontSize(28)
          .fontColor('#666')
          .onClick(() => this.closeAuthCodeDialog())
      }
      .width('100%')
      .padding({ bottom: 20 })

      // 统计信息
      Row() {
        Text(`共 ${this.authorizationCodes.length} 个授权码`)
          .fontSize(14)
          .fontColor('#666')
        Blank()
        Button('删除已过期', { type: ButtonType.Normal })
          .height(32)
          .fontSize(12)
          .backgroundColor('#FF9800')
          .fontColor(Color.White)
          .onClick(() => this.deleteExpiredCodes())
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 授权码列表
      if (this.authorizationCodes.length === 0) {
        Column() {
          Text('暂无授权码')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.authorizationCodes, (code: AuthorizationCode, index: number) => {
              this.buildAuthCodeItem(code, index)
            }, (code: AuthorizationCode) => code.code)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('90%')
    .height('80%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .position({ x: '5%', y: '10%' })
    .zIndex(1000)
  }

  // 构建单个授权码项
  @Builder
  buildAuthCodeItem(code: AuthorizationCode, index: number) {
    Column() {
      Row() {
        Column() {
          Text(code.code)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .margin({ bottom: 8 })

          Text(`档案：${this.getRecordTitle(code.recordIds[0] || '')}`)
            .fontSize(13)
            .fontColor('#666')
            .margin({ bottom: 4 })

          Row() {
            Text('状态：')
              .fontSize(12)
              .fontColor('#999')
            Text(code.isExpired() ? '已过期' : code.used ? '已使用' : '可用')
              .fontSize(12)
              .fontColor(code.isExpired() ? '#FF9800' : code.used ? '#999' : '#5FCCC4')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 4 })

          Text(`有效期：${new Date(code.expireAt).toLocaleString()}`)
            .fontSize(12)
            .fontColor('#999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 删除按钮
        Button('删除', { type: ButtonType.Normal })
          .height(36)
          .fontSize(13)
          .backgroundColor('#F44336')
          .fontColor(Color.White)
          .borderRadius(18)
          .onClick(() => {
            this.deleteAuthCode(code.code);
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  // 关闭授权码管理弹窗
  private closeAuthCodeDialog() {
    this.showAuthCodeDialog = false;
  }

  // 删除单个授权码
  private async deleteAuthCode(code: string) {
    prompt.showDialog({
      title: '确认删除',
      message: `确定要删除授权码 ${code} 吗？`,
      buttons: [
        {
          text: '取消',
          color: '#666'
        },
        {
          text: '删除',
          color: '#F44336'
        }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        // 删除授权码
        const beforeCount = this.authorizationCodes.length;
        this.authorizationCodes = this.authorizationCodes.filter(c => c.code !== code);
        const deletedCount = beforeCount - this.authorizationCodes.length;

        // 保存到本地
        await StorageHelper.saveAuthorizationCodes(this.authorizationCodes);

        if (deletedCount > 0) {
          prompt.showToast({
            message: '授权码已删除',
            duration: 2000
          });

          // 如果删除后没有授权码了，关闭弹窗
          if (this.authorizationCodes.length === 0) {
            setTimeout(() => {
              this.closeAuthCodeDialog();
            }, 1500);
          }
        }
      }
    });
  }

  // 辅助方法：根据ID获取档案标题
  private getRecordTitle(recordId: string): string {
    const record: HealthRecord | undefined = this.archiveList.find((r: HealthRecord) => r.id === recordId);
    return record ? record.title : '未知档案';
  }

  // ============ 新增：重新生成授权码方法 ============
  private async regenerateShareCode() {
    if (!this.selectedArchive) return;

    // 生成新的授权码
    this.shareCode = this.generateShareCode();

    // 更新过期时间
    const expireTime = new Date();
    expireTime.setHours(expireTime.getHours() + 24);
    this.shareExpireTime = expireTime.toLocaleString();

    // 创建新的AuthorizationCode对象 - 添加类型断言
    const newAuthCodeData: AuthCodeData = {
      code: this.shareCode,
      recordIds: [this.selectedArchive.id],
      hospitalName: '',
      expireAt: expireTime.getTime(),
      createdAt: Date.now(),
      used: false
    };
    const newAuthCode = new AuthorizationCode(newAuthCodeData);

    // 添加到列表
    this.authorizationCodes.push(newAuthCode);

    // 保存到本地
    await StorageHelper.saveAuthorizationCodes(this.authorizationCodes);

    prompt.showToast({
      message: '已重新生成授权码',
      duration: 2000
    });
  }
  // 删除已过期的授权码
  private async deleteExpiredCodes() {
    const beforeCount = this.authorizationCodes.length;

    // 过滤掉已过期的
    this.authorizationCodes = this.authorizationCodes.filter(code => !code.isExpired());

    const deletedCount = beforeCount - this.authorizationCodes.length;

    // 保存到本地
    await StorageHelper.saveAuthorizationCodes(this.authorizationCodes);

    if (deletedCount > 0) {
      prompt.showToast({
        message: `已删除 ${deletedCount} 个过期授权码`,
        duration: 2000
      });

      // 可选：自动重新打开管理页面
      setTimeout(() => {
        this.viewAuthorizationCodes();
      }, 1500);
    } else {
      prompt.showToast({
        message: '没有已过期的授权码',
        duration: 2000
      });
    }
  }
}