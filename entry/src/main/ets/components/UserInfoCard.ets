@Component
export struct UserInfoCard {
  @Prop userName: string = '名字';
  @Prop gender: string = '性别';
  @Prop birthday: string = '出生日期';
  @Prop tall: number = 180;
  @Prop weight: number = 80;
  @Prop tags: string = '个人信息、过敏信息、既往病史等';
  @Prop avatar: string = '';
  @Prop showEditButton: boolean = true;
  @Prop cardStyle: 'default' | 'compact' = 'default';
  onEditClick?: () => void;

  build() {
    Column() {
      // 顶部标题和编辑按钮
      if (this.showEditButton) {
        Row() {
          Text(this.cardStyle === 'default' ? '首页' : '我的')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)

          Text('完善资料 >>')
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.9)
            .onClick(() => {
              if (this.onEditClick) {
                this.onEditClick();
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }

      // 用户信息卡片
      Column() {
        Row() {
          // 头像
          Image($r(this.avatar))
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor('#E0E0E0')
            .alt($r('app.media.avatar_default'))

          // 信息
          Column() {
            Text(this.userName)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .margin({ bottom: 8 })

            Row() {
              Text(this.gender)
                .fontSize(14)
                .fontColor('#666666')
              Text(this.birthday)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 12 })
              Text(`${this.tall}cm`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 12 })
              Text(`${this.weight}kg`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 12 })
            }

            if (this.cardStyle === 'default') {
              Text(this.tags!=''?this.tags:'个人信息、过敏信息、既往病史等')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 6 })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
          .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        // compact否？
        if (this.cardStyle === 'compact') {
          Text(this.tags!=''?this.tags:'个人信息、过敏信息、既往病史等')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 12 })
            .width('100%')
        }
      }
      .width('95%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding(16)
      .margin({ left: 16, right: 16, bottom: 12 })
    }
    .width('100%')
    .backgroundColor('#5FCCC4')
    .padding({ bottom: 12 })
  }
}