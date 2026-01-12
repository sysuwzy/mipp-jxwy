import { HomePage } from './home';
import { ProfilePage } from './my';
import { Index as ArchivePage } from './archive/Index';
import { HealthAssistantPage } from './HealthAssistantPage';

@Entry
@Component
struct ModuleRouter {
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;
  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomePage()
      }.tabBar({
        text: '首页',
        icon: $r('app.media.homeIcon')
      })

      TabContent() {
        ArchivePage()
      }.tabBar({
        text: '档案',
        icon: $r('app.media.note')
      })

      TabContent() {
        HealthAssistantPage()
      }.tabBar({
        text: '助手',
        icon: $r('app.media.health_icon')
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
    .padding({
      bottom: `${0.5*this.bottomRectHeight}px`
    })
  }
}