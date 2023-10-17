# i茅台

> 代码使用Quantumult X调试, 理论支持其他平台, 其他平台请自行测试

## 配置

```properties
[mitm]
hostname = app.moutai519.com.cn

[rewrite_local]
https://app.moutai519.com.cn/xhr/front/user/info url script-response-body https://raw.githubusercontent.com/Yuheng0101/X/main/Tasks/imaotai/imaotai.js

[task_local]
# 茅台自动预约
0 9 * * * https://raw.githubusercontent.com/Yuheng0101/X/main/Tasks/imaotai/imaotai.js, tag=i茅台自动预约, img-url=https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/ae/f4/18/aef41811-955e-e6b0-5d23-6763c2eef1ab/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/144x144.png, enabled=true
```

## 说明

> 脚本只是对商品进行预约, 并不是抢购❗❗❗并不是抢购❗❗❗并不是抢购❗❗❗

> 重写脚本是为了获取相关参数, 获取成功后请禁用重写脚本

> 务必添加 [BoxJS订阅](https://raw.githubusercontent.com/Yuheng0101/X/main/Tasks/boxjs.json) 并添加相关参数

## 感谢

[@CTBU_JayChou](https://blog.csdn.net/weixin_47481826/article/details/128893239)

[@tianyagogogo](https://github.com/tianyagogogo/imaotai)

[@oddfar](https://github.com/oddfar/campus-imaotai)

[@chavyleung](https://github.com/chavyleung)
