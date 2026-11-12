# iOS 打包与 iloader 安装

本项目使用 Capacitor 8 和 Swift Package Manager，最低支持 iOS 15。
iOS 版本号与构建号在 `npm run ios:sync` 时从 `package.json` 同步。

## Windows 上通过 GitHub Actions 打包

1. 将代码推送到自己的 fork 的 `main` 分支。
2. 打开 GitHub 仓库的 **Actions → Build iOS IPA**。
3. 修改构建相关文件后的推送会自动运行；也可以通过 **Run workflow** 手动运行。
   如果 GitHub 在 fork 中提示工作流已禁用，先点击启用，再手动运行。
4. 等待构建成功，在该次运行的 **Artifacts** 下载 `planner-ios-unsigned`。
5. 解压下载的 ZIP，取得 `planner-<版本号>-unsigned.ipa`。

构建运行在 GitHub 的 macOS 15 / Xcode 26 环境，不需要上传 Apple ID、证书或描述文件。
工作流不会上传 App Store，也不会创建公开 Release。IPA 构件保留 14 天。
失败时可下载 `ios-build-log` 查看完整 Xcode 日志。

## 用 iloader 安装到 iPhone

1. 从 [iloader 官方网站](https://iloader.app/) 下载 Windows 版，并按官方说明安装 iTunes 设备驱动。
2. 通过 USB 连接 iPhone，解锁并信任电脑。
3. 打开 iloader，在本机登录用于侧载的 Apple ID。
4. 选择导入 IPA，导入解压得到的 `.ipa`，按提示签名和安装。
5. 如果 iPhone 提示需要信任开发者，前往 **设置 → 通用 → VPN 与设备管理** 信任相应开发者。
6. 如果系统要求，前往 **设置 → 隐私与安全性 → 开发者模式** 开启并重启。

免费 Apple 开发者账号的签名通常有效 7 天，到期后需要重新签名安装。
覆盖安装时使用同一个 Apple ID，并保持相同的应用标识；安装前可以在“我的”页面导出备份。
设备提醒、键盘和备份分享需要在实际 iPhone 上验证。

## 在 Mac 本地打包

安装 Xcode 26、对应的 iOS 平台组件及 Node.js 24，然后运行：

```bash
npm ci
npm run ios:ipa
```

输出位于 `artifacts/ios/planner-<版本号>-unsigned.ipa`，可交给 iloader 签名。
需要在 Xcode 中调试时运行 `npm run ios:open`，选择自己的 Signing Team 和连接的 iPhone。
