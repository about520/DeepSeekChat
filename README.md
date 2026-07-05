---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 0cb51bc4b6db581760778203a5ad41d8_9abb3754781011f1a7da5254006c9bbf
    ReservedCode1: P68nqie8fZ2ow+T+kqUbCo5hT5FM8BGRSyU+SBnQjqlHT0iq/ZyL2Hpt6JPgQbAYLUROt077A1O01qLZaoYsOPwlbeZnMVASa3h7MqCm33vRJ7r62XCx1KSRnbqNmf/wlL5RFUH5zXb3juiui4Um3Q3f/pZaxRItAmbFAfiFK6tkKZ/IjXuhGoRf8+k=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 0cb51bc4b6db581760778203a5ad41d8_9abb3754781011f1a7da5254006c9bbf
    ReservedCode2: P68nqie8fZ2ow+T+kqUbCo5hT5FM8BGRSyU+SBnQjqlHT0iq/ZyL2Hpt6JPgQbAYLUROt077A1O01qLZaoYsOPwlbeZnMVASa3h7MqCm33vRJ7r62XCx1KSRnbqNmf/wlL5RFUH5zXb3juiui4Um3Q3f/pZaxRItAmbFAfiFK6tkKZ/IjXuhGoRf8+k=
---

# DeepSeek AI - iOS App

iOS 原生 SwiftUI 应用，集成 DeepSeek AI 聊天 + 哔哩哔哩内嵌浏览器。

## 功能

- **DeepSeek AI 聊天**：流式对话，iMessage 风格气泡
- **哔哩哔哩浏览器**：内置 WKWebView，支持视频播放
- **API Key 管理**：本地安全存储

## 从 Windows 打出 IPA（4 步）

### 1. 推送到 GitHub

```bash
cd DeepSeekChat
git init
git add .
git commit -m "init"
git remote add origin https://github.com/你的用户名/DeepSeekChat.git
git push -u origin main
```

### 2. 注册 Codemagic

打开 https://codemagic.io ，用 GitHub 登录（免费 500 分钟/月）

### 3. 关联仓库

Codemagic → Add Application → 选择 `DeepSeekChat` 仓库
Codemagic 会自动检测 `codemagic.yaml`

### 4. 配置签名

在 Codemagic 项目设置 → iOS signing：
- 选择 **Automatic code signing**
- 关联你的 Apple ID（免费账号即可）

点击 **Start build**，编译完成后下载 IPA。

## 安装到 iPhone

1. 通过 Apple Configurator 2（Mac）
2. 或使用 AltStore / SideStore（Windows）
3. 或通过 Xcode 直接安装（Mac）

> 免费 Apple ID 签名的 IPA 有效期 7 天，到期需重签。

## 技术栈

- SwiftUI + WKWebView
- DeepSeek API 流式 SSE
- XcodeGen 项目生成
- Codemagic CI/CD
*（内容由AI生成，仅供参考）*
