# 合并说明

无需关注登录验证（在其他部分已经实现好了），但是需要修改调用模块功能的入口：需要获取会话以识别用户token（可以通过模拟的api：service/sessionManager，也可以通过全局存储AppStorage：@StorageProp("userProfileForm")）

数据模型保存在models下，主要关注usermodel，如果有需要请新建自定义模型文件

公用组件保存在component

不要直接访问数据库，通过userProfileService访问userDAO操作数据库

代码在master支
