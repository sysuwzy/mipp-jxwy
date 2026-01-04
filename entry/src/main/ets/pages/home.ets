import { PromptAction, Router } from '@kit.ArkUI';

import { UserInfoCard } from '../components/UserInfoCard';
import HealthService from '../services/HealthService';
import { HealthData } from '../models/HealthModel';
import { UserProfileForm } from '../models/UserModel';

@Entry
@Component
struct HomePage {
  @State healthData: HealthData | null = null;
  @State isLoading: boolean = true;
  @State currentTabIndex: number = 0;
  @State cardStyle: 'default' | 'compact' = 'default';

  @StorageProp("userProfileForm") userProfileForm: UserProfileForm = {
    name: '张三',
    height: 181,
    weight: 81,
    birthday: '2000-11-15',
    gender: '男'
  };

  private ctx: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.ctx.getPromptAction();
  private router: Router = this.ctx.getRouter();

  async aboutToAppear() {
    try {
      this.healthData = await HealthService.getHealthData();
    } catch (error) {
      this.promptAction.showToast({
        message: '数据加载失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 用户信息卡片
  @Builder
  UserProfileCard() {
    Column() {
      Row() {
        Text('首页')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)

        Text('完善资料 >>')
          .fontSize(14)
          .fontColor(Color.White)
          .opacity(0.9)
          .onClick(() => {
            this.promptAction.showToast({
              message: '跳转到完善资料页面',
              duration: 2000
            });
            this.router.pushUrl({
              url: 'pages/editProfile'
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.healthData) {
        Column() {
          Row() {
            // 头像
            Image($r(this.userProfileForm.avatar))
              .width(60)
              .height(60)
              .borderRadius(30)
              .backgroundColor('#E0E0E0')
              .alt($r('app.media.startIcon'))

            // 用户信息
            Column() {
              Text(this.userProfileForm.name)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#182431')
                .margin({ bottom: 8 })

              Row() {
                Text(this.userProfileForm.gender)
                  .fontSize(14)
                  .fontColor('#666666')
                Text(this.userProfileForm.birthday)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 12 })
                Text(`${this.userProfileForm.height}cm`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 12 })
                Text(`${this.userProfileForm.weight}kg`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 12 })
              }

              Text(this.userProfileForm.tags)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }
        .width('95%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(16)
        .margin({ left: 16, right: 16, bottom: 12 })
      }
    }
    .width('100%')
    .backgroundColor('#5FCCC4')
    .padding({ bottom: 12 })
  }

  // 健康画像卡片
  @Builder
  HealthProfileCard() {
    Row() {
      Image($r('app.media.protrait'))
        .width(48)
        .height(48)
        .backgroundColor('#5FCCC4')
        .borderRadius(8)
        .padding(10)

      Column() {
        Text('健康画像')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .margin({ bottom: 4 })

        Text('点击查看您的健康画像，我们将为您总结健康情况，并提供健康建议')
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(Color.White)
    // .borderRadius(12)
    .padding(16)
    .margin({ left: 16, right: 16, top: 12, bottom: 12 })
    .onClick(() => {
      this.promptAction.showToast({
        message: '查看健康画像',
        duration: 2000
      });
      this.router.pushUrl({
        url: 'pages/healthPortrait'
      });
    })
  }

  // 心率卡片
  @Builder
  HeartRateCard() {
    if (this.healthData) {
      Column() {
        Row() {
          Text('心率')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text(this.healthData.heartRate.current.toString())
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B9D')

          Text(this.healthData.heartRate.unit)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 4, bottom: 4 })
            .alignSelf(ItemAlign.End)
        }
        .margin({ bottom: 12 })

        // 简化的心率曲线图this.getUIContext('heartRateCanvas')
        Canvas()
          .width('100%')
          .height(80)
          .backgroundColor('#FFE8F0')
          .borderRadius(8)
          .onReady(() => {
            this.drawHeartRateChart();
          })
      }
      .width('95%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding(16)
      .margin({ left: 16, right: 16, bottom: 12 })
    }
  }

  // 血氧和体温卡片
  @Builder
  OxygenTemperatureRow() {
    if (this.healthData) {
      Row() {
        // 血氧饱和度
        Column() {
          Row() {
            Text('血氧饱和度')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#182431')
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(this.healthData.oxygen.values[0].toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')

            Text(this.healthData.oxygen.unit)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ left: 4, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ bottom: 16 })

          // 血氧柱状图
          Row() {
            ForEach(this.healthData.oxygen.values, (value: number, index: number) => {
              Column() {
                Column()
                  .width(12)
                  .height(`${value}%`)
                  .backgroundColor('#4CAF50')
                  .borderRadius(6)
              }
              .height(60)
              .justifyContent(FlexAlign.End)
              .margin({ right: index < this.healthData!.oxygen.values.length - 1 ? 8 : 0 })
            })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(16)
        .alignItems(HorizontalAlign.Start)

        // 体温
        Column() {
          Row() {
            Text('体温')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#182431')
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(this.healthData.temperature.current.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B6B')

            Text(this.healthData.temperature.unit)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ left: 4, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ bottom: 16 })

          // 温度计图示
          Row() {
            Column()
              .width('80%')
              .height(8)
              .backgroundColor('#FFE0E0')
              .borderRadius(4)

            Column()
              .width('60%')
              .height(8)
              .backgroundColor('#FF6B6B')
              .borderRadius(4)
              .position({ x: 0, y: 0 })
          }
          .width('100%')
          .height(40)
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(16)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 12 })
    }
  }

  // 血糖和血压卡片
  @Builder
  SugarPressureRow() {
    if (this.healthData) {
      Row() {
        // 血糖
        Column() {
          Row() {
            Text('血糖')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#182431')
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(this.healthData.bloodSugar.current.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9800')

            Text(this.healthData.bloodSugar.status)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 8, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ bottom: 16 })

          // 血糖波动图示this.getContext('bloodSugarCanvas')
          Canvas()
            .width('100%')
            .height(40)
            .backgroundColor('#FFF3E0')
            .borderRadius(8)
            .onReady(() => {
              this.drawBloodSugarChart();
            })
        }
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(16)
        .alignItems(HorizontalAlign.Start)

        // 血压
        Column() {
          Row() {
            Text('血压')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#182431')
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(`${this.healthData.bloodPressure.systolic} - ${this.healthData.bloodPressure.diastolic}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E91E63')
          }
          .margin({ bottom: 16 })

          // 血压图示this.getContext('bloodPressureCanvas')
          Canvas()
            .width('100%')
            .height(40)
            .backgroundColor('#FCE4EC')
            .borderRadius(8)
            .onReady(() => {
              this.drawBloodPressureChart();
            })
        }
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(16)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 12 })
    }
  }

  // 底部导航栏
  // @Builder
  // BottomNavigation() {
  //   Row() {
  //     Column() {
  //       Image($r('app.media.home_selected'))
  //         .width(24)
  //         .height(24)
  //         .fillColor(this.currentTabIndex === 0 ? '#5FCCC4' : '#999999')
  //
  //       Text('首页')
  //         .fontSize(12)
  //         .fontColor(this.currentTabIndex === 0 ? '#5FCCC4' : '#999999')
  //         .margin({ top: 4 })
  //     }
  //     .layoutWeight(1)
  //     .onClick(() => {
  //       this.currentTabIndex = 0;
  //     })
  //
  //     Column() {
  //       Image($r('app.media.data'))
  //         .width(24)
  //         .height(24)
  //         .fillColor(this.currentTabIndex === 1 ? '#5FCCC4' : '#999999')
  //
  //       Text('数据管理')
  //         .fontSize(12)
  //         .fontColor(this.currentTabIndex === 1 ? '#5FCCC4' : '#999999')
  //         .margin({ top: 4 })
  //     }
  //     .layoutWeight(1)
  //     .onClick(() => {
  //       this.currentTabIndex = 1;
  //       promptAction.showToast({
  //         message: '数据管理',
  //         duration: 2000
  //       });
  //     })
  //
  //     Column() {
  //       Image($r('app.media.health'))
  //         .width(24)
  //         .height(24)
  //         .fillColor(this.currentTabIndex === 2 ? '#5FCCC4' : '#999999')
  //
  //       Text('健康档案')
  //         .fontSize(12)
  //         .fontColor(this.currentTabIndex === 2 ? '#5FCCC4' : '#999999')
  //         .margin({ top: 4 })
  //     }
  //     .layoutWeight(1)
  //     .onClick(() => {
  //       this.currentTabIndex = 2;
  //       promptAction.showToast({
  //         message: '健康档案',
  //         duration: 2000
  //       });
  //     })
  //
  //     Column() {
  //       Image($r('app.media.ai'))
  //         .width(24)
  //         .height(24)
  //         .fillColor(this.currentTabIndex === 3 ? '#5FCCC4' : '#999999')
  //
  //       Text('AI问诊')
  //         .fontSize(12)
  //         .fontColor(this.currentTabIndex === 3 ? '#5FCCC4' : '#999999')
  //         .margin({ top: 4 })
  //     }
  //     .layoutWeight(1)
  //     .onClick(() => {
  //       this.currentTabIndex = 3;
  //       promptAction.showToast({
  //         message: 'AI问诊',
  //         duration: 2000
  //       });
  //     })
  //
  //     Column() {
  //       Image($r('app.media.mine'))
  //         .width(24)
  //         .height(24)
  //         .fillColor(this.currentTabIndex === 4 ? '#5FCCC4' : '#999999')
  //
  //       Text('我的')
  //         .fontSize(12)
  //         .fontColor(this.currentTabIndex === 4 ? '#5FCCC4' : '#999999')
  //         .margin({ top: 4 })
  //     }
  //     .layoutWeight(1)
  //     .onClick(() => {
  //       this.currentTabIndex = 4;
  //       promptAction.showToast({
  //         message: '我的',
  //         duration: 2000
  //       });
  //     })
  //   }
  //   .width('100%')
  //   .height(56)
  //   .backgroundColor(Color.White)
  //   .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  // }

  // 绘制心率图表
  private drawHeartRateChart() {
    if (!this.healthData) return;

    const canvas = new CanvasRenderingContext2D();
    if (!canvas) return;

    const width = 300; // 根据实际宽度调整
    const height = 80;
    const data = this.healthData.heartRate.chartData;
    const padding = 10;
    const chartWidth = width - padding * 2;
    const chartHeight = height - padding * 2;

    canvas.clearRect(0, 0, width, height);

    canvas.beginPath();
    canvas.strokeStyle = '#FF6B9D';
    canvas.lineWidth = 2;

    const stepX = chartWidth / (data.length - 1);
    const minValue = Math.min(...data);
    const maxValue = Math.max(...data);
    const range = maxValue - minValue;

    data.forEach((value, index) => {
      const x = padding + index * stepX;
      const y = padding + chartHeight - ((value - minValue) / range) * chartHeight;

      if (index === 0) {
        canvas.moveTo(x, y);
      } else {
        canvas.lineTo(x, y);
      }
    });

    canvas.stroke();

    data.forEach((value, index) => {
      const x = padding + index * stepX;
      const y = padding + chartHeight - ((value - minValue) / range) * chartHeight;

      canvas.beginPath();
      canvas.fillStyle = '#FF6B9D';
      canvas.arc(x, y, 3, 0, 2 * Math.PI);
      canvas.fill();
    });
  }

  // 绘制血糖图表
  private drawBloodSugarChart() {
    const canvas = new CanvasRenderingContext2D();
    if (!canvas) return;

    const width = 140;
    const height = 40;

    canvas.clearRect(0, 0, width, height);

    canvas.beginPath();
    canvas.strokeStyle = '#FF9800';
    canvas.lineWidth = 2;

    canvas.moveTo(10, 20);
    canvas.quadraticCurveTo(30, 10, 50, 20);
    canvas.quadraticCurveTo(70, 30, 90, 20);
    canvas.quadraticCurveTo(110, 10, 130, 20);

    canvas.stroke();
  }

  // 绘制血压图表
  private drawBloodPressureChart() {
    const canvas = new CanvasRenderingContext2D();
    if (!canvas) return;

    const width = 140;
    const height = 40;

    canvas.clearRect(0, 0, width, height);

    canvas.beginPath();
    canvas.strokeStyle = '#E91E63';
    canvas.lineWidth = 2;

    canvas.moveTo(10, 25);
    canvas.quadraticCurveTo(30, 15, 50, 25);
    canvas.quadraticCurveTo(70, 35, 90, 25);
    canvas.quadraticCurveTo(110, 15, 130, 25);

    canvas.stroke();
  }

  build() {
    Scroll() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#5FCCC4')

            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              // this.UserProfileCard()
              UserInfoCard({
                userName: this.userProfileForm.name,
                gender: this.userProfileForm.gender,
                birthday: this.userProfileForm.birthday,
                tall: this.userProfileForm.height,
                weight: this.userProfileForm.weight,
                avatar: this.userProfileForm.avatar??'',
                tags: this.userProfileForm.tags??'',
                showEditButton: true,
                cardStyle: this.cardStyle,
                onEditClick: () => {
                  this.promptAction.showToast({
                    message: '跳转到完善资料页面',
                    duration: 2000
                  });
                  this.router.pushUrl({
                    url: 'pages/editProfile'
                  })
                }
              })
              this.HealthProfileCard()
              this.HeartRateCard()
              this.OxygenTemperatureRow()
              this.SugarPressureRow()
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .backgroundColor('#F5F5F5')

          // 底部导航
          // this.BottomNavigation()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#00d6b8', 0.0],['#F1F3F5', 0.6],['#F1F3F5', 1.0]]
    })
  }
}