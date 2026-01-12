import { PromptAction, Router } from '@kit.ArkUI';

import AuthService from '../services/AuthenticationService';
import { LoginResult, UserProfileForm } from '../models/UserModel';
import UserProfileService from '../services/UserProfileService';

@Entry
@Component
struct LoginPage {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;
  @State phoneNumber: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State showPasswordLogin: boolean = false;
  // @State passwordVisible: boolean = false;

  private ctx: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.ctx.getPromptAction();
  private router: Router = this.ctx.getRouter();

  // 全局管理用户资料吧，不要每个页面从后端get一次了

  // 一键登录
  async handleQuickLogin() {
    if (this.isLoading) return;

    this.isLoading = true;

    try {
      const result: LoginResult = await AuthService.quickLogin();

      if (result.isSuccess && result.userInfo) {
        AppStorage.setOrCreate<UserProfileForm>("userProfileForm", await UserProfileService.getUserProfile());

        this.promptAction.showToast({
          message: `欢迎 ${result.userInfo.phoneNumber}`,
          duration: 2000
        });

        // 登录成功后跳转到主页
        setTimeout(() => {
          this.router.replaceUrl({
            url: 'pages/ModuleRouter'
          });
        }, 1000);
      } else {
        this.promptAction.showToast({
          message: result.message,
          duration: 2000
        });
      }
    } catch (error) {
      this.promptAction.showToast({
        message: '登录失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 账号密码登录
  async handlePasswordLogin() {
    if (this.isLoading) return;

    if (!this.phoneNumber.trim()) {
      this.promptAction.showToast({
        message: '请输入手机号',
        duration: 2000
      });
      return;
    }

    if (!this.password.trim()) {
      this.promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return;
    }

    this.isLoading = true;

    try {
      const result: LoginResult = await AuthService.loginWithPassword(
        this.phoneNumber,
        this.password
      );

      if (result.isSuccess && result.userInfo) {
        AppStorage.setOrCreate<UserProfileForm>("userProfileForm", await UserProfileService.getUserProfile());

        this.promptAction.showToast({
          message: result.message,
          duration: 2000
        });

        setTimeout(() => {
          this.router.replaceUrl({
            url: 'pages/ModuleRouter'
          });
        }, 1000);
      } else {
        this.promptAction.showToast({
          message: result.message,
          duration: 2000
        });
      }
    } catch (error) {
      this.promptAction.showToast({
        message: '登录失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // APP Logo区
      Column() {
        Image($r('app.media.appicon'))
          .width($r('app.float.app_logo_size'))
          .height($r('app.float.app_logo_size'))
          .margin({
            top: $r('app.float.app_logo_margin_top'),
            bottom: $r('app.float.app_logo_margin_bottom')
          })

        Text('欢迎登录')
          .fontSize($r('app.float.welcome_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.welcome_font_color'))
          .margin({ bottom: $r('app.float.welcome_margin_bottom') })

        Text('健行无忧APP')
          .fontSize(16)
          .fontColor('#99182431')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 登录表单区
      Column() {
        if (!this.showPasswordLogin) {
          // 一键登录
          Column() {
            Button(this.isLoading ? '登录中...' : '一键登录')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.login_button_color'))
              .borderRadius(24)
              .enabled(!this.isLoading)
              .onClick(() => this.handleQuickLogin())

            Row() {
              Text('登录即代表同意')
                .fontSize(12)
                .fontColor('#99182431')
              Text('《用户协议》')
                .fontSize(12)
                .fontColor('#007DFF')
              Text('和')
                .fontSize(12)
                .fontColor('#99182431')
              Text('《隐私政策》')
                .fontSize(12)
                .fontColor('#007DFF')
            }
            .margin({ top: 16 })
            .justifyContent(FlexAlign.Center)

            Divider()
              .margin({ top: 40, bottom: 20 })
              .color($r('app.color.divider_color'))

            Text('其他登录方式')
              .fontSize(14)
              .fontColor('#99182431')
              .margin({ bottom: 20 })

            Row() {
              Column() {
                Image($r('app.media.loginWayIcon'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.default_window_background'))
                  .padding(8)

                Text('账号登录')
                  .fontSize(12)
                  .fontColor('#182431')
                  .margin({ top: 8 })
              }
              .onClick(() => {
                this.showPasswordLogin = true;
              })
            }
            .justifyContent(FlexAlign.Center)
          }
          .padding({ left: 32, right: 32 })
        } else {
          // 账号密码登录
          Column() {
            Column() {
              TextInput({ placeholder: '请输入手机号' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .onChange((value: string) => {
                  this.phoneNumber = value;
                })

              Divider()
                .color($r('app.color.divider_color'))
            }
            .margin({ bottom: 20 })

            Column() {
              Row() {
                TextInput({ placeholder: '请输入密码' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor(Color.Transparent)
                  .type(InputType.Password)
                  // this.passwordVisible ? InputType.Normal :
                  .maxLength(20)
                  .layoutWeight(1)
                  .onChange((value: string) => {
                    this.password = value;
                  })

                // Image(this.passwordVisible ? $r('app.media.startIcon') : $r('app.media.startIcon'))
                //   .width(24)
                //   .height(24)
                //   .onClick(() => {
                //     this.passwordVisible = !this.passwordVisible;
                //   })
              }
              .width('100%')

              Divider()
                .color($r('app.color.divider_color'))
            }
            .margin({ bottom: 30 })

            Button(this.isLoading ? '登录中...' : '登录')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.login_button_color'))
              .borderRadius(24)
              .enabled(!this.isLoading)
              .onClick(() => this.handlePasswordLogin())

            Text('返回一键登录')
              .fontSize(14)
              .fontColor($r('app.color.login_button_color'))
              .margin({ top: 20 })
              .onClick(() => {
                this.showPasswordLogin = false;
                this.phoneNumber = '';
                this.password = '';
              })
          }
          .padding({ left: 32, right: 32 })
        }
      }
      .layoutWeight(1)
      .margin({ top: 60 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.default_window_background'))
    .padding({
      top: `${this.topRectHeight}px`,
      bottom: `${this.bottomRectHeight}px`
    })
  }
}