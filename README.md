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
 * [ ] 统一设置服务器地址
 * [ ] 支持文件的断点续传
 * [ ] 支持多个网络请求依次发送 
 * [ ] 支持批量的网络请求发送
 * [ ] 支持网络请求 URL 的 filter
 
 
# 使用
可以使用如何实例代码发起请求

```
    DLRequest.get(@"https://httpbin.org/get").send().then(^id(id data){
        NSLog(@"response = %@", data);
        return DLRequest.get(@"https://httpbin.org/get?a=b");
    }).then(^id(id data) {
        NSLog(@"scond response = %@", data);
        return data[@"headers"];
    }).then(^id(id data){
        NSLog(@"scond header = %@", data);
        return nil;
    });
```
这里展示的是调用 2 个接口的情况，每一个 then 的返回值可以传递给下一个参数，进一步做数据的流向。
 

