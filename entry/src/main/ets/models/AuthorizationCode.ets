
export class AuthorizationCode {
  code: string = ''; // 16位授权码
  recordIds: string[] = []; // 关联档案ID
  expireAt: number = 0; // 过期时间戳
  hospitalName: string = ''; // 目标医院
  createdAt: number = 0;
  used: boolean = false; // 是否已使用

  constructor(data?: Partial<AuthorizationCode>) {
    if (data) {
      // 手动赋值每个属性
      if (data.code !== undefined) this.code = data.code;
      if (data.recordIds !== undefined) this.recordIds = data.recordIds;
      if (data.expireAt !== undefined) this.expireAt = data.expireAt;
      if (data.hospitalName !== undefined) this.hospitalName = data.hospitalName;
      if (data.createdAt !== undefined) this.createdAt = data.createdAt;
      if (data.used !== undefined) this.used = data.used;
    }
  }

  // 检查是否过期
  isExpired(): boolean {
    return Date.now() > this.expireAt;
  }

  // 检查是否有效
  isValid(): boolean {
    return !this.isExpired() && !this.used;
  }
}