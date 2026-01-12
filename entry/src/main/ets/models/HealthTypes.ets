// src/main/ets/model/HealthTypes.ets

export interface ReminderItem {
  id: number;
  title: string;
  timeDisplay: string; // 用于界面显示，如 "08:30"
  hour: number;        // 闹钟小时
  minute: number;      // 闹钟分钟
  isOn: boolean;
}

// 单个问答项
export interface QAItem {
  question: string;
  answer: string;
  isExpanded: boolean; // 控制答案显示
}

// 问答大类
export interface QACategory {
  title: string;       // 类名，如“医保报销类”
  items: QAItem[];     // 该类下的问题集合
  isExpanded: boolean; // 控制该分类是否展开
}

export interface TripContext {
  destination: string;
  climate: string;
  hasChronicDisease: boolean;
}