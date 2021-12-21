# 接入步骤

1. 添加依赖

```json
http://github.com/Authing/guard-ios
```

2. 在应用启动（如 AppDelegate）里面初始化 Authing：

```swift
Authing.start("your_authing_app_id");
```

3. 发起认证。调用：

```swift
OneAuth.start { code, message, userInfo in
    if (code == 200 && userInfo != nil) {
        
    }
}
```
