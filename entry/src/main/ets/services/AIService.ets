import { http } from '@kit.NetworkKit';

interface AIMessage {
  content: string;
}
interface AIChoice {
  message: AIMessage;
}
interface AIResponse {
  choices: AIChoice[];
}

export class AIService {
  private static readonly API_KEY: string = 'sk-f61ba1ed7d8d46868fa06e204053776d';
  // 建议保持这个不带 v1 的地址，通常更稳定
  private static readonly API_URL: string = 'https://api.deepseek.com/chat/completions';

  static async getHealthAdvice(disease: string, city: string): Promise<string> {
    let httpRequest = http.createHttp();

    // 优化点1：修改 Prompt，明确要求“纯文本”
    const prompt = `你是一个专业的医疗助手。用户病史：${disease}，目的地：${city}。
    请给出3条关键的健康建议。
    【重要格式要求】：
    1. 请直接输出纯文本，严禁使用Markdown格式。
    2. 不要使用 **星号** 或 # 号。
    3. 不要使用加粗语法。
    4. 分点建议请直接使用数字编号（1. 2. 3.）。`;

    try {
      let response = await httpRequest.request(AIService.API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${AIService.API_KEY}`
        },
        extraData: {
          "model": "deepseek-chat",
          "messages": [
            { "role": "system", "content": "你是一个严谨的助手，只输出纯文本，不使用任何格式符号。" },
            { "role": "user", "content": prompt }
          ],
          "temperature": 0.7 // 稍微降低一点，让回答更规矩
        },
        connectTimeout: 60000,
        readTimeout: 60000
      });

      if (response.responseCode === 200) {
        let resObj = JSON.parse(response.result as string) as AIResponse;
        let rawContent = resObj.choices[0].message.content;

        // 优化点2：后处理清洗，强制去除残留的 Markdown 符号
        // 1. 去掉 ** (加粗符号)
        // 2. 将 * (列表符号) 替换为实心点
        // 3. 去掉 # (标题符号)
        let cleanContent = rawContent
          .replace(/\*\*/g, '')
          .replace(/^\* /gm, '• ')
          .replace(/#/g, '');

        return cleanContent;
      } else {
        return `【服务器错误】代码：${response.responseCode}`;
      }
    } catch (err) {
      let errorInfo = JSON.stringify(err);
      if (errorInfo.includes("2300028")) {
        return "【AI 诊断】请求超时，网络响应较慢，请重试。";
      }
      return `【网络异常】请检查模拟器是否联网。`;
    } finally {
      httpRequest.destroy();
    }
  }
}