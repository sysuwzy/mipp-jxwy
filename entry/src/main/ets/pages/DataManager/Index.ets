import router from '@ohos.router';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('PMR - Data Management (数据管理)')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Button('Enter Data Management')
        .width('100%')
        .onClick(() => {
          console.info('CLICKED: going to DMHome');
          router.pushUrl({ url: 'pages/DataManager/DMHome' })
            .then(() => {
              console.info('ROUTE OK');
            })
            .catch((err: Error) => {
              console.error('ROUTE FAIL: ' + JSON.stringify(err));
            });
        })
    }
    .padding(24)
    .width('100%')
    .height('100%')
  }
}
