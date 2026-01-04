export class DatabaseConfig {
  static readonly DATABASE_NAME: string = 'jxwy.db';
  static readonly DATABASE_VERSION: number = 1;

  // 用户表
  static readonly TABLE_USER: string = 'user';
  static readonly CREATE_TABLE_USER: string = `
    CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      name TEXT,
      gender TEXT,
      birthday TEXT,
      height INTEGER,
      weight REAL,
      avatar TEXT,
      tags TEXT,
      created_at INTEGER,
      updated_at INTEGER
    )
  `;

  // 健康数据表
  static readonly TABLE_HEALTH_DATA: string = 'health_data';
  static readonly CREATE_TABLE_HEALTH_DATA: string = `
    CREATE TABLE IF NOT EXISTS health_data (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      heart_rate INTEGER,
      oxygen INTEGER,
      temperature REAL,
      blood_sugar REAL,
      blood_pressure_systolic INTEGER,
      blood_pressure_diastolic INTEGER,
      recorded_at INTEGER,
      FOREIGN KEY (user_id) REFERENCES user(id)
    )
  `;
}