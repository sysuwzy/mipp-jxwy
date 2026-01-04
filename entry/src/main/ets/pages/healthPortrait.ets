import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import HealthPortraitService from '../services/HealthPortraitService';
import { HealthPortraitData, HealthIndicator, AnalysisReport } from '../models/HealthPortraitModel';

@Entry
@Component
struct HealthPortraitPage {
  @State isAnalyzing: boolean = true;
  @State analysisProgress: number = 0;
  @State rotationAngle: number = 0;
  @State bodyLoadProgress: number = 0;
  @State displayedIndicators: HealthIndicator[] = [];
  @State healthData: HealthPortraitData | null = null;
  @State currentAnalysisText: string = '正在分析体征数据...';

  private rotationTimer: number = -1;
  private analysisTimer: number = -1;

  async aboutToAppear() {
    // 启动旋转动画
    this.startRotation();

    // 启动分析流程
    await this.startAnalysis();
  }

  aboutToDisappear() {
    if (this.rotationTimer !== -1) {
      clearInterval(this.rotationTimer);
    }
    if (this.analysisTimer !== -1) {
      clearInterval(this.analysisTimer);
    }
  }

  // 启动旋转动画
  startRotation() {
    this.rotationTimer = setInterval(() => {
      this.rotationAngle = (this.rotationAngle + 2) % 360;
    }, 30);
  }

  // 启动分析流程
  async startAnalysis() {
    try {
      this.healthData = await HealthPortraitService.analyzeHealthPortrait();

      const totalSteps = this.healthData.indicators.length;
      let currentStep = 0;

      // 逐步加载人体模型
      const bodyLoadInterval = setInterval(() => {
        if (this.bodyLoadProgress < 100) {
          this.bodyLoadProgress += 2;
        } else {
          clearInterval(bodyLoadInterval);
        }
      }, 50);

      // 逐步显示指标
      // for await (const indicator of HealthPortraitService.analyzeStep()) {
      //   this.displayedIndicators.push(indicator);
      //   currentStep++;
      //   this.analysisProgress = Math.floor((currentStep / totalSteps) * 100);
      //
      //   // 更新分析文本
      //   this.updateAnalysisText(indicator);
      // }

      // 分析完成
      setTimeout(() => {
        this.isAnalyzing = false;
        this.currentAnalysisText = '分析完成';
        promptAction.showToast({
          message: '健康画像分析完成',
          duration: 2000
        });
      }, 500);

    } catch (error) {
      promptAction.showToast({
        message: '分析失败，请重试',
        duration: 2000
      });
    }
  }

  // 更新分析文本
  updateAnalysisText(indicator: HealthIndicator) {
    const texts = [
      '正在分析体征数据...',
      '正在评估心血管健康...',
      '正在检测代谢指标...',
      '正在分析体成分...',
      '正在生成健康报告...'
    ];
    const index = Math.floor(Math.random() * texts.length);
    this.currentAnalysisText = texts[index];
  }

  // 顶部导航栏
  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.cancel'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
        .onClick(() => {
          router.back();
        })

      Text('健康画像')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位，保持标题居中
      Column()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#5FCCC4')
  }

  // 3D人体模型区域
  @Builder
  BodyModelArea() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height(500)
        .linearGradient({
          angle: 180,
          colors: [[0x0a2540, 0.0], [0x1a3a5a, 1.0]]
        })

      // 人体模型容器
      Column() {
        // 用户名称
        Text(this.healthData?.userName || '赵智晟')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 20, bottom: 30 })

        // 人体模型和指标
        Stack() {
          // 3D人体模型（使用Canvas绘制网格人体）this.getContext('bodyCanvas')
          Column() {
            Canvas()
              .width(200)
              .height(350)
              .rotate({
                angle: this.rotationAngle,
                centerY: '50%'
              })
              .onReady(() => {
                this.drawBodyModel();
              })
          }

          // 左侧指标
          Column() {
            ForEach(this.displayedIndicators.filter(item => item.position === 'left'),
              (indicator: HealthIndicator) => {
                this.IndicatorCard(indicator, 'left')
              })
          }
          .position({ x: 0, y: 0 })
          .width('35%')
          .height('100%')
          .justifyContent(FlexAlign.SpaceAround)

          // 右侧指标
          Column() {
            ForEach(this.displayedIndicators.filter(item => item.position === 'right'),
              (indicator: HealthIndicator) => {
                this.IndicatorCard(indicator, 'right')
              })
          }
          .position({ x: '65%', y: 0 })
          .width('35%')
          .height('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
        .width('100%')
        .height(350)
      }
      .width('100%')
    }
    .width('100%')
  }

  // 指标卡片
  @Builder
  IndicatorCard(indicator: HealthIndicator, position: string) {
    Row() {
      if (position === 'right') {
        Column()
          .width(40)
          .height(1)
          .backgroundColor('#5FCCC4')
          .opacity(0.5)
      }

      Column() {
        Text(indicator.label)
          .fontSize(12)
          .fontColor('#99FFFFFF')
          .margin({ bottom: 4 })

        Text(indicator.value)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .padding(8)
      .backgroundColor('rgba(91, 204, 196, 0.2)')
      .borderRadius(8)
      .border({ width: 1, color: '#5FCCC4' })
      .alignItems(position === 'left' ? HorizontalAlign.End : HorizontalAlign.Start)

      if (position === 'left') {
        Column()
          .width(40)
          .height(1)
          .backgroundColor('#5FCCC4')
          .opacity(0.5)
      }
    }
    .width('100%')
    .justifyContent(position === 'left' ? FlexAlign.End : FlexAlign.Start)
    .opacity(0)
    .animation({
      duration: 500,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal
    })
    .onAppear(() => {
      animateTo({ duration: 500 }, () => {
        // 触发动画
      });
    })
  }

  // 分析进度区域
  @Builder
  AnalysisProgressArea() {
    if (this.isAnalyzing) {
      Column() {
        // 进度条
        Row() {
          Column()
            .width(`${this.analysisProgress}%`)
            .height(3)
            .backgroundColor('#5FCCC4')
        }
        .width('100%')
        .height(3)
        .backgroundColor('rgba(91, 204, 196, 0.2)')
        .margin({ bottom: 16 })

        // 分析文本
        Text(this.currentAnalysisText)
          .fontSize(14)
          .fontColor('#99FFFFFF')
          .textAlign(TextAlign.Center)

        // 加载动画
        LoadingProgress()
          .width(30)
          .height(30)
          .color('#5FCCC4')
          .margin({ top: 12 })
      }
      .width('100%')
      .padding(20)
    }
  }

  // 分析报告区域
  @Builder
  AnalysisReportArea() {
    if (!this.isAnalyzing && this.healthData) {
      Column() {
        Text('健康分析报告')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .margin({ bottom: 16 })

        // 报告卡片列表
        ForEach(this.healthData.reports, (report: AnalysisReport, index: number) => {
          Column() {
            Row() {
              // 图标
              Column() {
                Image(this.getReportIcon(report.icon))
                  .width(40)
                  .height(40)
                  .fillColor(this.getReportColor(report.type))
              }
              .width(50)
              .height(50)
              .backgroundColor(this.getReportBgColor(report.type))
              .borderRadius(25)
              .justifyContent(FlexAlign.Center)

              // 内容
              Column() {
                Text(report.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#182431')
                  .margin({ bottom: 8 })

                Text(report.content)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .padding(16)
          .margin({ bottom: 12 })
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })
        })

        // 健康建议
        Column() {
          Text('健康建议')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ bottom: 12 })

          Column() {
            this.HealthTip('保持规律作息，每天睡眠7-8小时')
            this.HealthTip('每周进行3-5次有氧运动，每次30分钟以上')
            this.HealthTip('均衡饮食，多吃蔬菜水果，少油少盐')
            this.HealthTip('定期体检，关注身体变化')
          }
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(16)
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(16)
    }
  }

  // 健康提示项
  @Builder
  HealthTip(text: string) {
    Row() {
      Column()
        .width(6)
        .height(6)
        .backgroundColor('#5FCCC4')
        .borderRadius(3)
        .margin({ right: 8 })

      Text(text)
        .fontSize(14)
        .fontColor('#666666')
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  // 绘制人体模型
  private drawBodyModel() {
    const canvas = new CanvasRenderingContext2D();
    if (!canvas) return;

    const width = 200;
    const height = 350;
    const progress = this.bodyLoadProgress / 100;

    canvas.clearRect(0, 0, width, height);

    // 设置绘制样式
    canvas.strokeStyle = '#5FCCC4';
    canvas.lineWidth = 1;
    canvas.globalAlpha = 0.6;

    const centerX = width / 2;
    const drawHeight = height * progress;

    // 绘制头部（圆形网格）
    if (progress > 0.1) {
      this.drawHead(canvas, centerX, 30, 20);
    }

    // 绘制颈部
    if (progress > 0.15) {
      canvas.beginPath();
      canvas.moveTo(centerX - 5, 50);
      canvas.lineTo(centerX - 5, 70);
      canvas.moveTo(centerX + 5, 50);
      canvas.lineTo(centerX + 5, 70);
      canvas.stroke();
    }

    // 绘制躯干
    if (progress > 0.2) {
      this.drawTorso(canvas, centerX, 70, Math.min(drawHeight - 70, 120));
    }

    // 绘制手臂
    if (progress > 0.4) {
      this.drawArms(canvas, centerX, 80);
    }

    // 绘制腿部
    if (progress > 0.6) {
      this.drawLegs(canvas, centerX, 190, Math.min(drawHeight - 190, 150));
    }

    // 绘制网格效果
    if (progress > 0.3) {
      this.drawGrid(canvas, centerX, 70, drawHeight - 70);
    }
  }

  // 绘制头部
  private drawHead(canvas: CanvasRenderingContext2D, x: number, y: number, radius: number) {
    // 绘制圆形
    canvas.beginPath();
    canvas.arc(x, y, radius, 0, 2 * Math.PI);
    canvas.stroke();

    // 绘制网格线
    for (let i = -radius; i <= radius; i += 5) {
      canvas.beginPath();
      canvas.moveTo(x + i, y - Math.sqrt(radius * radius - i * i));
      canvas.lineTo(x + i, y + Math.sqrt(radius * radius - i * i));
      canvas.stroke();
    }
  }

  // 绘制躯干
  private drawTorso(canvas: CanvasRenderingContext2D, x: number, y: number, height: number) {
    const width = 40;

    canvas.beginPath();
    // 左侧轮廓
    canvas.moveTo(x - width / 2, y);
    canvas.lineTo(x - width / 2, y + height * 0.6);
    canvas.quadraticCurveTo(x - width / 2, y + height, x, y + height);

    // 右侧轮廓
    canvas.moveTo(x + width / 2, y);
    canvas.lineTo(x + width / 2, y + height * 0.6);
    canvas.quadraticCurveTo(x + width / 2, y + height, x, y + height);

    canvas.stroke();
  }

  // 绘制手臂
  private drawArms(canvas: CanvasRenderingContext2D, x: number, y: number) {
    // 左臂
    canvas.beginPath();
    canvas.moveTo(x - 20, y);
    canvas.lineTo(x - 50, y + 40);
    canvas.lineTo(x - 55, y + 80);
    canvas.stroke();

    // 右臂
    canvas.beginPath();
    canvas.moveTo(x + 20, y);
    canvas.lineTo(x + 50, y + 40);
    canvas.lineTo(x + 55, y + 80);
    canvas.stroke();
  }

  // 绘制腿部
  private drawLegs(canvas: CanvasRenderingContext2D, x: number, y: number, height: number) {
    // 左腿
    canvas.beginPath();
    canvas.moveTo(x - 10, y);
    canvas.lineTo(x - 15, y + height);
    canvas.stroke();

    // 右腿
    canvas.beginPath();
    canvas.moveTo(x + 10, y);
    canvas.lineTo(x + 15, y + height);
    canvas.stroke();
  }

  // 绘制网格效果
  private drawGrid(canvas: CanvasRenderingContext2D, x: number, y: number, height: number) {
    canvas.globalAlpha = 0.3;

    // 横向网格线
    for (let i = 0; i < height; i += 10) {
      canvas.beginPath();
      canvas.moveTo(x - 30, y + i);
      canvas.lineTo(x + 30, y + i);
      canvas.stroke();
    }

    // 纵向网格线
    for (let i = -30; i <= 30; i += 10) {
      canvas.beginPath();
      canvas.moveTo(x + i, y);
      canvas.lineTo(x + i, y + height);
      canvas.stroke();
    }
  }

  // 获取报告图标
  private getReportIcon(icon: string): Resource {
    const iconMap: Record<string, Resource> = {
      'heart': $r('app.media.startIcon'),
      'weight': $r('app.media.startIcon'),
      'oxygen': $r('app.media.startIcon'),
      'sugar': $r('app.media.startIcon')
    };
    return iconMap[icon] || $r('app.media.startIcon');
  }

  // 获取报告颜色
  private getReportColor(type: string): string {
    const colorMap: Record<string, string> = {
      'good': '#4CAF50',
      'warning': '#FF9800',
      'normal': '#2196F3'
    };
    return colorMap[type] || '#999999';
  }

  // 获取报告背景色
  private getReportBgColor(type: string): string {
    const colorMap: Record<string, string> = {
      'good': '#E8F5E9',
      'warning': '#FFF3E0',
      'normal': '#E3F2FD'
    };
    return colorMap[type] || '#F5F5F5';
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          this.BodyModelArea()
          this.AnalysisProgressArea()
          this.AnalysisReportArea()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}