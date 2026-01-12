import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { promptAction } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';

// 1. 百科数据从组长的 component 目录获取
import { HEALTH_QA_DATA, QACategory, QAItem } from '../components/QADataSource';
// 2. AI 服务逻辑
import { AIService } from '../services/AIService';
// 3. 数据库与存储 (这里是你存放测试数据的地方)
import { StorageHelper } from '../utils/StorageHelper';
// 4. 数据模型
import { HealthRecord } from '../models/HealthRecord';

interface ReminderItem { id: number; title: string; timeDisplay: string; }

@Component
export struct HealthAssistantPage {
  @State reminders: ReminderItem[] = [];
  @State aiResult: string = "正在连线 AI 专家，请稍候...";
  @State isThinking: boolean = true;
  @State localQA: QACategory[] = HEALTH_QA_DATA;
  @State realHealthHistory: string = "";

  // 控制器定义
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: AddReminderDialog({
      confirm: (t: string, d: Date) => { this.saveReminder(t, d) }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  async aboutToAppear() {
    // 组件初始化：加载档案 -> 运行 AI -> 检查通知权限
    await this.initHealthData();
    this.runAIWithAPI();
    this.checkPermission();
  }

  async initHealthData() {
    try {
      // 1. 获取当前 UIAbility 的上下文
      const context = getContext(this) as common.UIAbilityContext;

      // 2. 调用初始化方法
      const isReady = await StorageHelper.init(context);

      if (isReady) {
        const archives = await StorageHelper.loadArchiveList();
        if (archives && archives.length > 0) {
          this.realHealthHistory = archives.map(item => `[${item.type}] ${item.title}: ${item.content}`).join('；');
        } else {
          // 如果是空，说明你在模拟器里还没去档案页面录入过数据
          this.realHealthHistory = "暂无本地档案，请先在档案模块添加记录。";
        }
      }
    } catch (e) {
      this.realHealthHistory = "读取档案异常";
    }
  }

  async runAIWithAPI() {
    // 1. 拦截空档案：如果没有内容，直接给出一个固定的文案，不调用 AI
    if (this.realHealthHistory === "暂无本地档案" || this.realHealthHistory === "") {
      this.aiResult = "您的档案库目前空空如也。请先去『档案』页面录入您的体检报告或病历，我才能为您生成精准的健康画像。";
      this.isThinking = false;
      return;
    }

    this.isThinking = true;
    try {
      // 2. 只有在有数据时才调用 AI
      const prompt = `用户真实的健康档案记录如下：${this.realHealthHistory}。请以此为唯一依据进行深度分析，严禁捏造不存在的病历。`;
      this.aiResult = await AIService.getHealthAdvice(prompt, ""); // 城市已留空
    } catch (e) {
      this.aiResult = "连线 AI 专家失败，请检查网络。";
    } finally {
      this.isThinking = false;
    }
  }

  async checkPermission() {
    try {
      let enabled = await notificationManager.isNotificationEnabled();
      if (!enabled) {
        await notificationManager.requestEnableNotification();
      }
    } catch (err) {
      console.error('Notification permission check failed');
    }
  }

  async saveReminder(title: string, time: Date) {
    if (time.getTime() <= new Date().getTime()) {
      promptAction.showDialog({ title: '时间错误', message: '提醒时间需晚于当前时间。' });
      return;
    }
    try {
      let req: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: time.getFullYear(),
          month: time.getMonth() + 1,
          day: time.getDate(),
          hour: time.getHours(),
          minute: time.getMinutes()
        },
        title: "健康助手助手",
        content: title,
        ringDuration: 60
      };
      let id = await reminderAgentManager.publishReminder(req);
      this.reminders.push({
        id: id,
        title: title,
        timeDisplay: `${time.getHours().toString().padStart(2, '0')}:${time.getMinutes().toString().padStart(2, '0')}`
      });
      promptAction.showToast({ message: '提醒设置成功' });
    } catch (e) {
      promptAction.showToast({ message: '提醒设置失败' });
    }
  }

  build() {
    Column() {
      Text('健康助手').fontSize(26).fontWeight(FontWeight.Bold).margin({ top: 40, bottom: 20 })

      Scroll() {
        Column({ space: 15 }) {
          // 1. AI 画像展示区域 (动态读取档案)
          Column() {
            Row() {
              if (this.isThinking) LoadingProgress().width(24).height(24).color(Color.White).margin({ right: 10 })
              Text("AI 健康画像").fontColor(Color.White).fontWeight(FontWeight.Bold)
            }.width('100%')
            Text(this.aiResult).fontColor(Color.White).fontSize(14).margin({ top: 10 }).lineHeight(22)

            // 增加一个刷新按钮，方便用户更新档案后手动重新分析
            Button('重新分析档案').fontSize(12).height(25).margin({ top: 10 })
              .backgroundColor('#FFFFFF').fontColor('#224ABE').opacity(0.8)
              .onClick(() => this.runAIWithAPI())
          }
          .width('100%').padding(20).borderRadius(15)
          .linearGradient({ direction: GradientDirection.Right, colors: [[0x4E73DF, 0.0], [0x224ABE, 1.0]] })

          // 2. 提醒系统区域
          Column() {
            Row() {
              Text('用药/打卡提醒').fontSize(18).fontWeight(FontWeight.Bold)
              Button('+').onClick(() => this.dialogController.open()).width(40).height(40)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            if (this.reminders.length === 0) {
              Text('暂无提醒，点击 + 号添加').fontSize(14).fontColor('#999').margin({ top: 10 })
            }

            ForEach(this.reminders, (item: ReminderItem, index: number) => {
              Row() {
                Column() {
                  Text(item.title).fontWeight(FontWeight.Medium)
                  Text(item.timeDisplay).fontSize(12).fontColor('#666')
                }.alignItems(HorizontalAlign.Start)

                Blank()
                Button('取消').fontSize(12).backgroundColor('#FFEDED').fontColor('#FF4D4F')
                  .onClick(() => {
                    reminderAgentManager.cancelReminder(item.id);
                    this.reminders.splice(index, 1);
                  })
              }.width('100%').margin({ top: 10 }).padding(10).backgroundColor('#FAFAFA').borderRadius(8)
            })
          }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15)

          // 3. 异地就医百科区域 (折叠列表)
          Column() {
            Text('健康知识库').fontSize(18).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 10 })
            ForEach(this.localQA, (cat: QACategory, cIdx: number) => {
              Column() {
                Row() {
                  Text(cat.title).fontWeight(FontWeight.Bold).layoutWeight(1)
                  Text(cat.isExpanded ? '▲' : '▼').fontSize(12).fontColor('#999')
                }
                .width('100%').padding(15)
                .onClick(() => {
                  // 手动触发状态更新
                  this.localQA[cIdx] = { title: cat.title, isExpanded: !cat.isExpanded, items: cat.items };
                  this.localQA = [...this.localQA];
                })

                if (cat.isExpanded) {
                  ForEach(cat.items, (item: QAItem) => {
                    Column() {
                      Text("问: " + item.question).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#007DFF').margin({ bottom: 4 })
                      Text("答: " + (item.answer || "详见就医指南")).fontSize(13).fontColor('#666')
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%').padding({ left: 15, right: 15, bottom: 10 })
                  })
                }
              }.border({ width: { bottom: 1 }, color: '#F5F5F5' })
            })
          }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 30 })
        }
      }.width('92%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}

// --- 弹窗组件适配 ---
@CustomDialog
struct AddReminderDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: '' })
  @State title: string = ''
  @State selectTime: Date = new Date()
  confirm: (t: string, d: Date) => void = () => {}

  build() {
    Column() {
      Text('新建提醒').fontSize(18).fontWeight(FontWeight.Bold).margin(15)
      TextInput({ placeholder: '例如：感冒药、测量血压', text: this.title })
        .onChange(v => this.title = v).width('90%').margin({ bottom: 10 })

      TimePicker({ selected: this.selectTime }).onChange(v => {
        this.selectTime.setHours(v.hour, v.minute);
      }).height(120).width('100%')

      Row({ space: 20 }) {
        Button('取消').onClick(() => this.controller.close()).backgroundColor('#F5F5F5').fontColor('#666').layoutWeight(1)
        Button('确认').onClick(() => {
          this.confirm(this.title, this.selectTime);
          this.controller.close();
        }).layoutWeight(1)
      }.width('90%').margin(20)
    }.padding(10).backgroundColor(Color.White).borderRadius(20)
  }
}