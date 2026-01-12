import { PromptAction, Router } from '@kit.ArkUI';

import { UserInfoCard } from '../components/UserInfoCard';
import ProfileService from '../services/ProfileService';
import { AppInfo } from '../models/ProfileModel';
import { UserProfileForm } from '../models/UserModel';

@Entry
@Component
export struct ProfilePage {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @State currentTabIndex: number = 4;
  @State appInfo: AppInfo | null = null;
  @State cardStyle: 'default' | 'compact' = 'compact';

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
      this.appInfo = ProfileService.getAppInfo();

    } catch (error) {
      this.promptAction.showToast({
        message: '加载用户数据失败',
        duration: 2000
      });
    } finally {}
  }

  async onPageShow() {
    await this.aboutToAppear();
  }

  // 处理退出登录
  async handleLogout() {
    AlertDialog.show({
      title: '退出登录',
      message: '确定要退出登录吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#FF0000',
        action: async () => {
          const success = await ProfileService.logout();
          if (success) {
            this.promptAction.showToast({
              message: '已退出登录',
              duration: 2000
            });

            // 跳转到登录页
            setTimeout(() => {
              this.router.replaceUrl({
                url: 'pages/Index'
              });
            }, 500);
          }
        }
      }
    });
  }

  // 关于APP卡片
  @Builder
  AboutAppCard() {
    if (this.appInfo) {
      Column() {
        Text('关于APP')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .width('100%')
          .margin({ bottom: 12 })

        Text(this.appInfo.description)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(22)
          .margin({ bottom: 12 })

        Text('主要功能包括：')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        Column() {
          ForEach(this.appInfo.features, (feature: string, index: number) => {
            Row() {
              Text(`${index + 1}.`)
                .fontSize(14)
                .fontColor('#666666')
                .width(20)

              Text(feature)
                .fontSize(14)
                .fontColor('#666666')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 6 })
          })
        }

        Text('>>> 点击查看AI健康画像 <<<')
          .fontSize(14)
          .fontColor('#5FCCC4')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 8 })
          .onClick(()=>{
            this.router.pushUrl({
              url: 'pages/healthPortrait'
            })
          })
      }
      .width('95%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding(16)
      .margin({ left: 16, right: 16, top: 12, bottom: 12 })
    }
  }

  // 菜单项
  @Builder
  MenuItem(icon: Resource, title: string, showArrow: boolean = true, onClick?: () => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor('#666666')
        .margin({ right: 12 })

      Text(title)
        .fontSize(15)
        .fontColor('#182431')
        .layoutWeight(1)

      if (showArrow) {
        Image($r('app.media.arrow_to_right'))
          .width(16)
          .height(16)
          .fillColor('#CCCCCC')
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  // 退出登录按钮
  @Builder
  LogoutButton() {
    Row() {
      Image($r('app.media.logout'))
        .width(20)
        .height(20)
        .fillColor('#666666')
        .margin({ right: 12 })

      Text('退出登录')
        .fontSize(15)
        .fontColor('#182431')
        .layoutWeight(1)

      Image($r('app.media.arrow_to_right'))
        .width(16)
        .height(16)
        .fillColor('#555')
    }
    .width('95%')
    .shadow({offsetX:0,offsetY:0,radius:2,color:'#E5E5E5'})
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
    .onClick(() => {
      this.handleLogout();
    })
  }


  build() {
    // 主内容区域
    Scroll() {
      Column() {
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

        // 关于APP
        this.AboutAppCard()

        // 退出登录
        this.LogoutButton()

        // 底部留白
        Column()
          .height(20)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({
      top: `${this.topRectHeight}px`
    })
    .backgroundColor($r('app.color.default_status_bar_background'))
  }
}