
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
## 链式
### 请求链式
```
DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            [self logName:@"testChainRequest --- 1" info:data];
            [context setReturnValue:DLRequest.new.get(@"https://httpbin.org/get").parameters(@{@"c":@"d"})];
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
            [self logName:@"testChainRequest --- 2" info:data];
        });
```
链式多个请求，只需要调用 DLRequestContext 的 setReturnValue 返回一个 return 即可

### 链式处理回调
```
DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            [context setReturnValue:data[@"args"]];
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
        });
```
链式请求回调之后，可以通过多个 then 来处理返回参数，设置 setReturnValue 将会传递到下一个处理 then 

### 链式处理错误回调
```
DLRequest.new
        .get(@"https://httpbin.org/404")
        .sendRequest()
        .failure(^(NSError *data, DLRequestContext *context) {
            [context setReturnValue:data.userInfo[@"NSLocalizedDescription"]];
        })
        .failure(^(NSString *data, DLRequestContext *context) {
        });
```
链式请求回调之后，可以通过多个 failure 来处理返回错误参数，设置 setReturnValue 将会传递到下一个处理 failure 

### 中断传递
```
 DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            // 如果没设置，那么将会断言失败。
            [context stopPropagate];
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
        });

```

如果设置了 DLRequestContext 的 stopPropagate 将会中断传递，包括 then 和 faliure。

### 批量发送

```
	DLRequest *r1 = DLRequest.new.get(@"https://httpbin.org/get");
        DLRequest *r2 = DLRequest.new.post(@"https://httpbin.org/post");
        [DLRequest sendBatchRequests:@[r1, r2]].then(^(NSArray *data, DLRequestContext *context) {
        });
        
```
同时 发送多个请求

## 其他用法

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

### 取消
```
 DLRequest *request = DLRequest.new
        .get(@"https://httpbin.org/delay/10")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
          
        }).failure(^(NSError *data, DLRequestContext *context) {
        });
        request.cancel();
```
取消一个 request

### 请求开始的回调

```
 DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .willStartRequest(^{
        })
        .sendRequest();
```

### 请求结束的回调
```
 DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .didFinishedRequest(^{
        });

```
## 上传
### upload data
```
  DLRequest.new
            .uploadData([NSData dataWithContentsOfFile:file], @"https://httpbin.org/post")
            .sendRequest()
            .then(^(id data, DLRequestContext *context) {
            });
```

### uplaod file
```
DLRequest.new
        .uploadFile(file, @"https://httpbin.org/post")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        });

```

### MultipartForm
```
DLRequest.new
        .post(@"https://httpbin.org/post")
        .multipartFormData(^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFormData:[@"ok" dataUsingEncoding:NSUTF8StringEncoding] name:@"test"];
        })
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        });
```

## download 
### download file 
```
DLRequest.new
        .download(@"https://httpbin.org/image/png", file)
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
        });
```


更多用法可以查看 DLNetworkingTest 测试用例。





