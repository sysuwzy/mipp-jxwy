// src/main/ets/model/QADataSource.ets
export interface QAItem { question: string; answer: string; isExpanded: boolean; }
export interface QACategory { title: string; isExpanded: boolean; items: QAItem[]; }

export const HEALTH_QA_DATA: QACategory[] = [
  {
    title: '一、 医保报销类',
    isExpanded: true, // 默认展开第一个
    items: [
      { question: '异地就医如何办理医保报销？', answer: '需先在参保地办理备案，备案后可在就医地直接结算。推荐使用“国家医保服务平台”APP线上办理。', isExpanded: false },
      { question: '异地就医报销比例会降低吗？', answer: '通常会低于本地就医，具体比例由您参保地的政策决定，请提前咨询当地医保局。', isExpanded: false },
      { question: '异地就医可以刷医保卡吗？', answer: '在已开通异地直接结算的定点医院，可以直接刷卡或使用电子医保凭证。否则需先自费，再回参保地报销。', isExpanded: false },
      { question: '异地门诊费用可以报销吗？', answer: '跨省门诊直接结算正在逐步推广中，具体是否支持，需查询您参保地和就医地的开通情况。', isExpanded: false },
      { question: '事后报销需要哪些材料和时限？', answer: '通常需要发票、费用清单、出院小结、医保卡复印件等。报销时限一般为出院后3-6个月内。', isExpanded: false }
    ]
  },
  {
    title: '二、 就诊流程类',
    isExpanded: false,
    items: [
      { question: '异地就医的完整流程是什么？', answer: '核心三步：① 参保地备案 → ② 选择异地定点医院 → ③ 持医保卡就医结算。', isExpanded: false },
      { question: '如何选择异地医院？', answer: '优先选择接入国家异地就医结算系统的“定点医院”。可在本APP内使用地图服务查找。', isExpanded: false },
      { question: '如何办理异地转诊？', answer: '通常需要本地医院开具转诊证明，并在医保部门办理转诊备案。具体流程请咨询您本地的医院。', isExpanded: false },
      { question: '如何预约异地医院的号？', answer: '可通过目标医院的官方APP、微信公众号、第三方挂号平台（如114）进行预约。', isExpanded: false },
      { question: '就诊时应该找哪个科室？', answer: '可根据您的症状，在本APP的健康档案中查看历史就诊科室，或使用AI助手进行初步分诊建议。', isExpanded: false }
    ]
  },
  {
    title: '三、 材料与准备类',
    isExpanded: false,
    items: [
      { question: '异地就诊必须带哪些核心材料？', answer: '身份证、医保卡、历史病历和检查报告。推荐使用本APP拍照存档生成电子档案。', isExpanded: false },
      { question: '如何避免重复检查？', answer: '提前将以往所有的检查报告拍照上传至本APP，形成完整的电子健康档案。', isExpanded: false },
      { question: '慢性病患者异地就医要注意什么？', answer: '带齐本地医生开具的长期处方和病历。提前查询异地医院是否有所需药品。', isExpanded: false },
      { question: '如何获取异地医院的病历和报告副本？', answer: '出院时向医院病案室申请复印。部分医院提供线上查询下载服务。', isExpanded: false }
    ]
  },
  {
    title: '四、 健康管理与应急类',
    isExpanded: false,
    items: [
      { question: '异地期间如何管理日常用药？', answer: '使用本APP的“用药提醒”功能，可设置多设备同步提醒。', isExpanded: false },
      { question: '如何应对异地就医时的突发不适？', answer: '提前在APP中保存就医地急救电话和目标医院的急诊地址。', isExpanded: false },
      { question: '异地气候、饮食变化如何适应？', answer: '本APP的健康助手可结合您的行程和目的地气候，给出温馨提示。', isExpanded: false },
      { question: '复查提醒怎么设置？', answer: '在“健康助手”模块中，根据医嘱设置日期。APP会通过鸿蒙分布式通知服务同步提醒。', isExpanded: false }
    ]
  },
  {
    title: '五、 实用工具与便民信息类',
    isExpanded: false,
    items: [
      { question: '不熟悉医院环境怎么办？', answer: '使用本APP内置的鸿蒙地图服务，可提供医院内部科室分布导航。', isExpanded: false },
      { question: '如何找到医院附近的住宿和交通？', answer: '使用APP内的地图服务搜索周边酒店和交通站点。', isExpanded: false },
      { question: '如何保护我上传的健康隐私？', answer: '数据通过鸿蒙原生加密技术本地存储。分享时会生成加密授权码，安全可控。', isExpanded: false },
      { question: '如何评价就医体验或反馈问题？', answer: '通过“我的-反馈”入口提交，或通过医院官方渠道评价。', isExpanded: false }
    ]
  }
];