# Authing Guard

Authing guard 是一个面向身份认证领域的业务组件库，该组件库将复杂的认证系统语义化，标准化。通过使用该组件库，业务 App 可以极速实现认证流程。相比手动实现，效率提升 x10。

<br>

## 快速开始

1. 通过 Swift Package Manager 引入依赖

https://github.com/Authing/guard-ios

![](./images/add_guard.png)

2. 在应用启动（如 AppDelegate.swift）里面调用：

```swift
Authing.start(appid: "your_authing_app_id");
```

3. 在需要启动认证流程的 ViewController（如闪屏）上，调用：

```swift
AuthFlow.start { userInfo in
    if (userInfo != nil) {
        // logged in
    } else {
        // handle error
    }
}
```

4. 访问受保护资源时，带上用户的 token：

```swift
request.addValue("Bearer \(userInfo.token!)", forHTTPHeaderField: "Authorization")
```
