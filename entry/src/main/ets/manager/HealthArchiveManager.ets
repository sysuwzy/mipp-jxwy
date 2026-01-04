// manager/HealthArchiveManager.ets
import { HealthRecord, HealthRecordType } from '../models/HealthRecord';

interface GeneratedTypeLiteralInterface_1 {
  title: string;
  type: HealthRecordType;
  content: string;
  tags?: string[];
  hospital?: string;
  date?: string;
}

export class HealthArchiveManager {
  private records: Map<string, HealthRecord> = new Map();

  // 创建健康记录
  createRecord(data: GeneratedTypeLiteralInterface_1): HealthRecord {
    const record = new HealthRecord();

    // 生成唯一ID
    record.id = `record_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // 设置属性
    record.title = data.title;
    record.type = data.type;
    record.content = data.content;
    record.hospital = data.hospital || '';
    record.date = data.date || new Date().toISOString().split('T')[0];
    record.tags = data.tags ? [...data.tags] : [];
    record.createdAt = Date.now();

    this.records.set(record.id, record);
    return record;
  }

  // 创建异地就医专项档案
  createTravelArchive(recordIds: string[], title: string = '异地就医档案'): string {
    // 获取相关记录
    const records: HealthRecord[] = [];
    recordIds.forEach(id => {
      const record = this.records.get(id);
      if (record) records.push(record);
    });

    // 构建档案内容
    const archiveContent = this.buildArchiveContent(records);

    // 创建档案记录
    const archiveRecord = this.createRecord({
      title: title,
      type: HealthRecordType.SPECIAL_ARCHIVE,
      content: archiveContent,
      hospital: '异地就医档案',
      tags: ['异地就医必备']
    });

    return archiveRecord.id;
  }

  // 获取所有记录
  getAllRecords(): HealthRecord[] {
    return Array.from(this.records.values());
  }

  // 根据ID获取记录
  getRecordById(id: string): HealthRecord | undefined {
    return this.records.get(id);
  }

  // 删除记录
  deleteRecord(id: string): boolean {
    return this.records.delete(id);
  }

  // 构建档案内容
  private buildArchiveContent(records: HealthRecord[]): string {
    if (records.length === 0) {
      return '# 异地就医专项档案\n\n暂无相关健康记录';
    }

    let content = '# 异地就医专项档案\n\n';
    content += `生成时间：${new Date().toLocaleString()}\n\n`;

    records.forEach((record, index) => {
      content += `## ${index + 1}. ${record.title}\n`;
      content += `- **医院**：${record.hospital}\n`;
      content += `- **日期**：${record.date}\n`;
      content += `- **类型**：${record.type}\n`;

      if (record.tags.length > 0) {
        content += `- **标签**：${record.tags.join('、')}\n`;
      }

      content += '\n---\n\n';
    });

    return content;
  }
}