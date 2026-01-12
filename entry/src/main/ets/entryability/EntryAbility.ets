import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

import DatabaseManager from '../backend/DatabaseManager';
import SessionManager from '../services/SessionManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

      this.initializeApp();

    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  async initializeApp() {
    try {
      // 初始化db
      await DatabaseManager.initDatabase(this.context);
      hilog.info(0x0000, 'testTag', '数据库初始化成功');

      // 初始化会话管理
      await SessionManager.init(this.context);
      hilog.info(0x0000, 'testTag', '会话管理初始化成功');

    } catch (error) {
      hilog.error(0x0000, 'testTag', '应用初始化失败: %{public}s', JSON.stringify(error));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      windowStage.getMainWindow((err: BusinessError<void>, windowClass) => {
        if (err.code) {
          hilog.info(0x0000, 'EntryAbility', '%{public}s', 'getMainWindow failed');
          return;
        }
        windowClass.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
          hilog.error(0x0000, 'EntryAbility',
            `setWindowLayoutFullScreen failed. code=${err.code}, message=${err.message}`);
        })

        let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
        let avoidArea = windowClass.getWindowAvoidArea(type);
        let bottomRectHeight = avoidArea.bottomRect.height;
        AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

        type = window.AvoidAreaType.TYPE_SYSTEM;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let topRectHeight = avoidArea.topRect.height;
        AppStorage.setOrCreate('topRectHeight', topRectHeight);
      })

      windowStage.loadContent('pages/Index', (err, data) => {
        if (err.code) {
          hilog.error(0x0000, 'EntryAbility', 'Failed to load the content. Cause: %{public}s',
            JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content. Data: %{public}s',
          JSON.stringify(data) ?? '');
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'EntryAbility', `onWindowStageCreate failed. code=${err.code}, message=${err.message}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}