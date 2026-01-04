import { HealthRecord, HealthRecordType } from "../../models/HealthRecord";

// pages/archive/ArchiveListItem.ets
@Component
export struct ArchiveListItem {
  private record: HealthRecord;
  private onViewDetail: () => void;

  build() {
    Row() {
      // 左侧图标
      Column() {
        Image(this.getIconByType(this.record.type))
          .width(24)
          .height(24)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)

      // 档案信息
      Column() {
        Text(this.record.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(this.record.hospital)
            .fontSize(12)
            .fontColor('#666')

          Text(' • ')
            .fontSize(12)
            .fontColor('#999')

          Text(this.record.date)
            .fontSize(12)
            .fontColor('#666')
        }
        .margin({ top: 4 })

        // 标签
        if (this.record.tags.length > 0) {
          Wrap() {
            ForEach(this.record.tags, (tag: string) => {
              Text(tag)
                .fontSize(10)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#E3F2FD')
                .borderRadius(4)
                .fontColor('#1976D2')
                .margin({ right: 4, bottom: 4 })
            })
          }
          .margin({ top: 8 })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右侧箭头
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      this.onViewDetail();
    })
  }

  private getIconByType(type: HealthRecordType): Resource {
    switch (type) {
      case HealthRecordType.OUTPATIENT:
        return $r('app.media.ic_outpatient');
      case HealthRecordType.EXAMINATION:
        return $r('app.media.ic_examination');
      case HealthRecordType.PRESCRIPTION:
        return $r('app.media.ic_prescription');
      case HealthRecordType.SPECIAL_ARCHIVE:
        return $r('app.media.ic_archive');
      default:
        return $r('app.media.ic_other');
    }
  }
}