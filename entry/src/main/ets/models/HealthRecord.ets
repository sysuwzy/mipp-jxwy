export enum HealthRecordType {
  OUTPATIENT = '门诊病历',
  EXAMINATION = '检查报告',
  PRESCRIPTION = '用药处方',
  SPECIAL_ARCHIVE = '专项档案',  // 确保有这个值
  OTHER = '其他'
}

export class HealthRecord {
  id: string = ''; // 记录ID
  userId: string = ''; // 用户ID
  title: string = ''; // 记录标题
  type: '门诊病历' | '检查报告' | '用药处方' | '专项档案' | '其他' = '其他';
  content: string = ''; // 健康内容
  attachments: string[] = []; // 附件路径
  hospital: string = ''; // 医院名称
  date: string = ''; // 就诊日期 yyyy-MM-dd
  tags: string[] = []; // 标签
  isSynced: boolean = false; // 是否同步
  createdAt: number = 0; // 创建时间戳
  isEditing: boolean = false;

  constructor(data?: Partial<HealthRecord>) {
    if (data) {
      if (data.id !== undefined) this.id = data.id;
      if (data.userId !== undefined) this.userId = data.userId;
      if (data.title !== undefined) this.title = data.title;
      if (data.type !== undefined) this.type = data.type;
      if (data.content !== undefined) this.content = data.content;
      if (data.attachments !== undefined) this.attachments = [...data.attachments];
      if (data.hospital !== undefined) this.hospital = data.hospital;
      if (data.date !== undefined) this.date = data.date;
      if (data.tags !== undefined) this.tags = [...data.tags];
      if (data.isSynced !== undefined) this.isSynced = data.isSynced;
      if (data.createdAt !== undefined) this.createdAt = data.createdAt;
    }
  }
}
