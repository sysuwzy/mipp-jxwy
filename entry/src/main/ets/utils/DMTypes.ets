export const RECORD_TYPES: string[] = ['门诊病历', '检查报告', '检验报告', '用药处方'];
export const RECORD_TAGS: string[] = ['异地就医必备', '一般'];

export interface MedicalRecord {
  id: string;
  title: string;
  type: string;      // ✅ string, no enum casting needed
  tag: string;       // ✅ string, no enum casting needed
  visitDate: number;
  fileUri: string;
  ocrText: string;
  createdAt: number;
}
