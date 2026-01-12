import { PromptAction, Router } from '@kit.ArkUI';

import UserProfileService from '../services/UserProfileService';
import { UserProfileForm, WeightScaleData } from '../models/UserModel';

@Entry()
@Component
struct EditProfile {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageProp("userProfileForm") userProfileForm: UserProfileForm = {
    name: '张三',
    height: 181,
    weight: 81,
    birthday: '2000-11-15',
    gender: '男'
  };

  @State isLoading: boolean = true;
  @State isSaving: boolean = false;
  @State isLoadingWeight: boolean = false;
  @State showDatePicker: boolean = false;
  @State selectedDate: Date = new Date();

  private ctx: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.ctx.getPromptAction();
  private router: Router = this.ctx.getRouter();

  async aboutToAppear() {
    try {
      // const profileForm = await UserProfileService.getUserProfile();
      // if (!profileForm) return;
      //
      // this.profileForm = profileForm;
      // 改为全局管理usr profile

      // 解析生日字符串为Date对象
      if (this.userProfileForm.birthday) {
        this.selectedDate = new Date(this.userProfileForm.birthday);
      }
    } catch (error) {
      this.promptAction.showToast({
        message: '加载数据失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 保存资料
  async handleSave() {
    if (this.isSaving) return;

    // 验证表单
    const validation = UserProfileService.validateProfile(this.userProfileForm);
    if (!validation.valid) {
      this.promptAction.showToast({
        message: validation.message,
        duration: 2000
      });
      return;
    }

    this.isSaving = true;

    try {
      // 存云
      const success = await UserProfileService.saveUserProfile(this.userProfileForm);

      if (success) {
        this.promptAction.showToast({
          message: '保存成功',
          duration: 2000
        });

        // 存本地
        AppStorage.setOrCreate<UserProfileForm>("userProfileForm", this.userProfileForm);

        // 延迟返回
        setTimeout(() => {
          this.router.back();
        }, 500);
      } else {
        this.promptAction.showToast({
          message: '保存失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      this.promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    } finally {
      this.isSaving = false;
    }
  }

  // 从体重称获取数据
  async handleGetWeightFromScale() {
    if (this.isLoadingWeight) return;

    this.isLoadingWeight = true;

    try {
      this.promptAction.showToast({
        message: '正在连接体重称...',
        duration: 2000
      });

      const scaleData: WeightScaleData = await UserProfileService.getWeightScaleData();

      // 更新体重数据
      this.userProfileForm.weight = Math.round(scaleData.weight * 10) / 10;

      this.promptAction.showToast({
        message: `已获取体重数据：${scaleData.weight}kg`,
        duration: 2000
      });
    } catch (error) {
      this.promptAction.showToast({
        message: '获取体重数据失败，请检查设备连接',
        duration: 2000
      });
    } finally {
      this.isLoadingWeight = false;
    }
  }

  // 格式化日期显示
  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
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
          this.router.back();
        })

      Text('完善资料')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('保存')
        .fontSize(16)
        .fontColor(Color.White)
        .opacity(this.isSaving ? 0.5 : 1)
        .onClick(() => {
          this.handleSave();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#5FCCC4')
  }

  // 表单项 - 输入框
  @Builder
  FormInputItem(label: string, key: string, placeholder: string,
    inputType: InputType, maxLength: number,
    onChange: (value: string) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor('#182431')
          .width(80)

        TextInput({
          text: Reflect.get(this.userProfileForm, key) ?
            Reflect.get(this.userProfileForm, key).toString() : '',
          placeholder: placeholder
        })
          .fontSize(15)
          .fontColor('#182431')
          .backgroundColor(Color.Transparent)
          .type(inputType)
          .maxLength(maxLength)
          .layoutWeight(1)
          .onChange((value: string) => {
            onChange(value);
          })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)

      Divider()
        .color('#F0F0F0')
    }
  }

  // 表单项 - 选择器
  @Builder
  FormPickerItem(label: string, key: string, placeholder: string,
    icon: string, onClick: () => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor('#182431')
          .width(80)

        Text(Reflect.get(this.userProfileForm, key) || placeholder)
          .fontSize(15)
          .fontColor(Reflect.get(this.userProfileForm, key) ? '#182431' : '#CCCCCC')
          .layoutWeight(1)

        Image($r(icon))
          .width(16)
          .height(16)
          .fillColor('#2C2C2C')
          .alt($r('app.media.cancel'))
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .onClick(onClick)

      Divider()
        .color('#F0F0F0')
    }
  }

  // 体重测量卡片
  @Builder
  WeightMeasureCard() {
    Column() {
      Row() {
        Column() {
          Image($r('app.media.weighter'))
            .width(40)
            .height(40)
            .fillColor('#5FCCC4')
        }
        .width(56)
        .height(56)
        .backgroundColor('#E8F8F7')
        .borderRadius(28)
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('使用华为智能体重称')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .margin({ bottom: 4 })

          Text('自动同步身高体重数据')
            .fontSize(13)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)

        Button(this.isLoadingWeight ? '连接中...' : '测量')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#5FCCC4')
          .height(36)
          .padding({ left: 20, right: 20 })
          .borderRadius(18)
          .enabled(!this.isLoadingWeight)
          .onClick(() => {
            this.handleGetWeightFromScale();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(16)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
  }

  // 表单区域
  @Builder
  FormArea() {
    Column() {
      Text('基本信息')
        .fontSize(14)
        .fontColor('#999999')
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 8 })

      // 表单卡片
      Column() {
        this.FormInputItem(
          '姓名',
          'name',
          '请输入姓名',
          InputType.Normal,
          20,
          (value: string) => {
            this.userProfileForm.name = value;
          }
        )

        this.FormPickerItem(
          '性别',
          'gender',
          '请选择性别',
          'app.media.gender',
          () => {
            ActionSheet.show({
              title: '选择性别',
              message: '',
              confirm: {
                value: '取消',
                action: () => {}
              },
              sheets: [
                {
                  title: '男',
                  action: () => {
                    this.userProfileForm.gender = '男';
                  }
                },
                {
                  title: '女',
                  action: () => {
                    this.userProfileForm.gender = '女';
                  }
                }
              ]
            });
          }
        )

        this.FormPickerItem(
          '生日',
          'birthday',
          '请选择生日',
          'app.media.birthday',
          () => {
            this.showDatePicker = true;
          }
        )

        this.FormInputItem(
          '身高',
          'height',
          '请输入身高（cm）',
          InputType.Number,
          3,
          (value: string) => {
            this.userProfileForm.height = value ? parseInt(value) : 0;
          }
        )

        this.FormInputItem(
          '体重',
          'weight',
          '请输入体重（kg）',
          InputType.NUMBER_DECIMAL,
          5,
          (value: string) => {
            this.userProfileForm.weight = value ? parseFloat(value) : 0;
          }
        )
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 16, right: 16 })
      .padding({ left: 16, right: 16 })
    }
  }

  // 提示信息
  @Builder
  TipArea() {
    Column() {
      Row() {
        Image($r('app.media.note'))
          .width(16)
          .height(16)
          .fillColor('#FF9800')
          .margin({ right: 8 })

        Text('请您放心录入您的基本信息，APP严格遵循保密规范，承诺信息仅用于管理您的健康档案。')
          .fontSize(13)
          .fontColor('#999999')
          .lineHeight(20)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF8E1')
      .borderRadius(8)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  // 日期选择器
  @Builder
  DatePickerDialog() {
    if (this.showDatePicker) {
      Column() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .onClick(() => {
            this.showDatePicker = false;
          })

        Column() {
          Row() {
            Text('取消')
              .fontSize(16)
              .fontColor('#666666')
              .onClick(() => {
                this.showDatePicker = false;
              })

            Text('选择生日')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Text('确定')
              .fontSize(16)
              .fontColor('#5FCCC4')
              .onClick(() => {
                this.userProfileForm.birthday = this.formatDate(this.selectedDate);
                this.showDatePicker = false;
              })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .border({ width: { bottom: 0.5 }, color: '#E5E5E5' })

          DatePicker({
            start: new Date('1900-01-01'),
            end: new Date(),
            selected: this.selectedDate
          })
            .onDateChange((value: Date) => {
              this.selectedDate = value;
            })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  build() {
    Stack() {
      Column() {
        this.TopBar()

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
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              this.WeightMeasureCard()
              this.FormArea()
              this.TipArea()

              // 底部留白
              Column()
                .height(40)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .backgroundColor('#F5F5F5')
        }
      }
      .width('100%')
      .height('100%')

      this.DatePickerDialog()
    }
    .width('100%')
    .height('100%')
    .padding({
      top: `${this.topRectHeight}px`
    })
    .backgroundColor($r('app.color.default_status_bar_background'))
  }
}