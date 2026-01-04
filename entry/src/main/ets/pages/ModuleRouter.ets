import { HomePage } from './home';
import { ProfilePage } from './my';

@Entry
@Component
struct ModuleRouter {
  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomePage()
      }.tabBar({
        text: '首页',
        icon: $r('app.media.homeIcon')
      })

      TabContent() {
        ProfilePage()
      }.tabBar({
        text: '我的',
        icon: $r('app.media.myIcon')
      })
    }
    .width('100%')
    .height('100%')
  }
}