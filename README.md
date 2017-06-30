
# **这是我心中网络请求最应该有的功能**

# DLNetworking
 DLNetworking 是仿照 JS 的 Promise 链式写法，传统的 Block 回调如果在接口调用多的情况下会出现回调地狱（Callback Hell）的情况。
 如下代码所示

 ```
 a(function() {
    b(function() {
        c(function() {
            d(function() {
                e(function() {
                    ...
                });
            });
        });
    });
});
 ```

 使用 Promise 之后可以平铺开回调

 ```
 a()
.then(resolve=> {...})
.then(resolve=> {...})
 ```
# 特性
 * [x] 支持 Promise 的写法
 * [x] 链式调用
 * [x] Get
 * [x] Post
 * [x] 链式传递的 then 语法
 * [x] 链式传递的 fail 语法
 * [x] 取消请求
 * [x] 批量请求
 * [x] 单独设置 timeOut
 * [x] https 接口
 * [x] 下载
 * [x] 上传
 * [x] 提供请求前的处理，请求后的处理
 * [x] 统一的配置中心，如 baseUrl，timeOut等
 * [ ] 缓存


# 集成
 1. 复制文件夹到项目
 2. CocoaPods （TODO）

# 使用

## 基本使用

### get
```
DLRequest.new
        .get(@"https://httpbin.org/get")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        });
```
then 里面代表是成功请求，data 为请求回来的数据。

### Post
```
DLRequest.new
        .post(@"https://httpbin.org/post")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {

        });

```
### 处理成功和错误请求
```
DLRequest.new
        .post(@"https://404.org/post")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        })
        .failure(^(NSError *data, DLRequestContext *context) {
        });

```
failure 为失败的内容，data 为 error

### header
```
DLRequest.new
       .get(@"https://httpbin.org/get")
       .headers(@{@"header":@"ok"})
       .sendRequest()
       .then(^(id data, DLRequestContext *context) {
       });
```

### parameters

```
DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"p1":@"ok"})
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        });
```

## 高级用法

### RequestSerialization
```
 DLRequest.new
        .post(@"https://httpbin.org/post")
        .parameters(@[@"1",@"2"])
        .requestSerialization(DLRequestSerializationTypeJSON)
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        });

```
### ResponseSerialization
```
  DLRequest.new
        .post(@"https://httpbin.org/post")
        .responseSerialization(DLResponseSerializationTypeDATA)
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        });
```


未完待续





