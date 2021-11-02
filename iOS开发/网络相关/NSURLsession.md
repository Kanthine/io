iOS 提供了 [NSURLSession](https://developer.apple.com/documentation/foundation/nsurlsession?changes=latest_minor&language=objc) 来处理复杂的通信任务，无论是从服务器请求数据还是下载文件到本地；请求是高度异步的！还支持身份验证、接收HTTP重定向等事件；当 App 挂起时，支持后台下载。


`NSURLSession`  是网络通信的管理者，协调一组相关类完成网络通信：

 * [`NSURLSessionConfiguration`](https://www.jianshu.com/p/f52f1f5f1171) ：配置选项的封装，如与主机同时连接的最大并发数目、使用的多路径TCP策略、以及是否允许蜂窝网络, 请求缓存策略, 请求超时, cookies/证书存储等等；
 * `NSURLSessionDelegate` : 用于处理响应数据的委托代理；
 * [`NSURLSessionTask`](https://developer.apple.com/documentation/foundation/nsurlsessiontask?changes=latest_minor&language=objc) : 通过请求创建的任务；
 * `NSURLSessionTaskMetrics` ：对发送请求/DNS查询/TLS握手/请求响应等各种环节时间上的统计. 可用于分析App的请求缓慢到底是发生在哪个环节, 并对此优化APP性能。
 * `NSURLSessionTaskTransactionMetrics`

![NSURLSession相关类关系图.png](https://upload-images.jianshu.io/upload_images/7112462-aba9b894bd53b18d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


完成一个网络通信的流程为：
 
```
//step1 ：配置一些选项
NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//step2：设置处理响应数据的队列
NSOperationQueue *queue = [NSOperationQueue mainQueue];
//step3：创建 session
NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
//step4：利用 session 创建任务
NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:@""]];
//step5：开始任务
[task resume];//刚创建出来的task默认是挂起状态的，需要调用该方法来启动任务（执行任务）
```



#### 1、创建 `NSURLSession`

`NSURLSession` API 提供了三种方法用来实例化：

```
/** 全局共享单例
 * 有很大局限性：
 *  <li> 没有设置 delegate，因此不会调用代理方法;
 *  <li> 没有定制 configuration 用于基本请求；
 *  <li> 当收到服务器的响应报文时，不能增量地获取数据；
 *  <li> 无法对默认连接行为进行定制；
 *  <li> 执行身份验证的能力是有限的；
 *  <li> App 挂起时，不能执行后台下载或上传。
 * sharedSession 使用全局 NSURLCache、NSHTTPCookieStorage、NSURLCredentialStorage
 * @note 如果使用缓存、cookie、身份验证或自定义网络协议进行任何操作，应该使用默认会话而不是共享会话。
 * @note ：不管 session 执行的线程为主线程还是子线程，completionHandler 代码均在任意子线程执行。
*/
@property (class, readonly, strong) NSURLSession *sharedSession;

/** 根据指定的 Configuration 创建一个网络会话
 * 由于没有设置 delegate ，因此不会调用代理方法；
 * completionHandler 中的代码均在任意子线程执行
 */
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;


/** 使用指定的会话配置，委托和操作队列创建会话
 * 设置了 delegate，因此期望响应数据通过代理方式处理；但是在创建Task的时候，若使用参数 completionHandler ，则响应仍然会在completionHandler 中处理，而非代理方法。因此，若保证使用代理方式处理，则需将 completionHandler 设置为nil 。
 * @note   会话对象保存对 delegate 的强引用，直到应用程序退出或显式地使会话无效为止。如果不使会话无效，App 就会泄露内存，直到它退出。
*/
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;
```

创建 `NSURLSession` 时几个关键的参数，需要说明一下：

*  代理`delegate`：可以设置一个 `delegate`，在会话生命周期内接收响应报文，处理身份验证等事件；
也可以 `delegate=nil` 使用 `completionHandler` 来处理服务器的响应报文；
* `queue`：用来处理响应数据的线程，
  若为 `mainQueue`，则代理方法或者  `completionHandler` 中的代码在主线程程执行；
  若为 `nil` 或者创建一个操作队列，则在任意子线程执行；
* `configuration`：对会话一些配置的封装：如使用`Cache`、`Cookie`、证书，或者是否允许在蜂窝网络上进行连接！


`NSURLSession` 对`delegate`、`queue`持有强引用，为避免内存泄漏，需要显式地使会话无效！


`NSURLSession` 实例是线程安全的：可以在任何线程中创建会话和任务；当代理方法调用时，将在正确的委托队列上调用。



__注意__：只能使用上述方法获取一个 `NSURLSession` 对象，禁止使用 `-init` 或 `+new`等方法实例化；

###### eg、错误的创建方法

虽然 `-init` 编译时没报错，但在运行时发送一个请求会出错：

```
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunes_URL]];
    NSURLSession *session = [[NSURLSession alloc] init];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) { }];
    [dataTask resume];
    
/** 异常终止的部分信息：
-[NSURLSession dataTaskForRequest:completion:]: unrecognized selector sent to instance 0x1702007f0
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[NSURLSession dataTaskForRequest:completion:]: unrecognized selector sent to instance 0x1702007f0'
*** First throw call stack:
(0x1836aefe0 0x182110538 0x1836b5ef4 0x1836b2f54 0x1835aed4c 0x1000fe458 0x10011edec 0x18990ba9c 0x1899bb820 0x189a6d594 0x189a5f630 0x1897d328c 0x18365c9a8 0x18365a630 0x18365aa7c 0x18358ada4 0x184ff5074 0x189845c9c 0x10012fe70 0x18259959c)
libc++abi.dylib: terminating with uncaught exception of type NSException
 */
}
```

当向方法传送非法参数时引发的异常 `NSInvalidArgumentException` ，这是由于没有配置 `configuration` 属性。


#### 2、`NSURLSession` 的一些属性


```
/**  操作队列：需要在创建此对象时提供
 * 作用域：与 NSURLSession 相关的所有代理方法调用和 completionHandler 都在这个队列上执行；
 * @note 在 App 退出或 NSURLSession 被释放之前，session 对该队列保持强引用；为避免内存泄漏，需要使会话无效。
 */
@property (readonly, retain) NSOperationQueue *delegateQueue;

/** 委托代理：需要在创建此对象时设置，负责处理身份验证挑战、缓存以及处理其它与会话相关的事件
 * @note 会话对象对该委托具有强引用，为避免内存泄漏，需要显式地使会话无效；
 */
@property (nullable, readonly, retain) id <NSURLSessionDelegate> delegate;

/** 一些配置选项：需要在创建此对象时设置
 * @note 在iOS9之前，由于不是拷贝的副本，允许在初始化后通过修改 Configuration 的某些属性来进一步配置会话行为，这是一个 bug；
 *       从iOS9开始，是入参的拷贝副本，以便会话的配置在初始化后不被影响！
*/
@property (readonly, copy) NSURLSessionConfiguration *configuration;

/** 用于调试程序的描述性标签，默认为nil
 */
@property (nullable, copy) NSString *sessionDescription;
```



#### 3、管理会话


```
/** 完成任务并将 NSURLSession 置为无效！
 * 异步方法，会立即返回，此时 NSURLSession 需要等待现有任务完成后才会无效，但新的任务不被创建；
 * 代理方法继续执行，直到 -URLSession:didBecomeInvalidWithError: 执行，NSURLSession 无效。
 * @note sharedSession 调用该方法没有任何影响。
 */
- (void)finishTasksAndInvalidate;

/** 将 NSURLSession 置为无效，向此会话中所有未完成的任务发出 -cancel；但新的任务不被创建；
 * @note: 任务取消取决于任务的状态，有些任务在发送 -cancel 时可能已经完成。
 * @note sharedSession 调用该方法没有任何影响。
 */
- (void)invalidateAndCancel;

 /** 清空所有 Cookie、Cache 和证书，删除磁盘文件，将正在进行的下载刷新到磁盘，并确保将来的请求发生在新的 socket上。
  * @param completionHandler 当 reset 操作完成时被调用，handler 在委托队列上执行。
  */
- (void)resetWithCompletionHandler:(void (^)(void))completionHandler;

/** 将Cookie和证书刷新到磁盘，清除临时缓存，并确保将来的请求发生在新的TCP连接上。
 * @param completionHandler 当 reset 操作完成时被调用，handler 在委托队列上执行。
 */
- (void)flushWithCompletionHandler:(void (^)(void))completionHandler;

/** 对会话中创建的未完成的 dataTasks、上传和下载任务调用 completionHandler
 * @param completionHandler 要使用任务列表调用，在委托队列上执行；不包括完成、失败或被取消后无效的任何任务。
 */
- (void)getTasksWithCompletionHandler:(void (^)(NSArray<NSURLSessionDataTask *> *dataTasks, NSArray<NSURLSessionUploadTask *> *uploadTasks, NSArray<NSURLSessionDownloadTask *> *downloadTasks))completionHandler;

/** 获取会话中的所有任务
 * @param completionHandler 要使用任务列表调用
 */
- (void)getAllTasksWithCompletionHandler:(void (^)(NSArray<__kindof NSURLSessionTask *> *tasks))completionHandler API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
```


#### 4、向会话添加任务

在网络通信中，`NSURLSession`根据请求`NSURLRequest`可以创建多种[任务](https://developer.apple.com/documentation/foundation/nsurlsessiontask?changes=latest_minor&language=objc)：
* `NSURLSessionDataTask`：数据任务，使用`NSData`对象发送和接收数据；数据任务旨在向服务器发出简短的，经常是交互式的请求；支持默认会话、临时会话，但不支持后台会话；
通过对代理方法 `-URLSession:dataTask:didReceiveData:` 的一系列调用来接收资源；该任务供使用者立即解析。
* `NSURLSessionUploadTask` ：上传任务，与数据任务相似，但是它们还发送数据（通常以文件形式），并在应用程序不运行时支持后台上传；
通过引用要上传的文件或数据对象，或利用 `-URLSession:task:needNewBodyStream:` 来提供上传主体显式创建的；与数据任务的区别在于实例构造方式不同！
* `NSURLSessionDownloadTask` ：下载任务，直接将响应数据写入临时文件，任何类型的会话都支持下载和上传任务。
任务完成后，`delegate` 调用 `-URLSession:downloadTask:didFinishDownloadingToURL:` 在适当时机将该文件移动到沙盒的永久位置、或者读取该文件；
如果取消任务，`NSURLSessionDownloadTask` 可以生成一个 `data blob`，用于稍后恢复下载。
* `NSURLSessionWebSocketTask` ：`WebSocket`任务，使用 `RFC 6455` 中定义的`WebSocket`协议通过TCP和TLS交换消息。
* `NSURLSessionStreamTask`：从 iOS9 开始支持该任务，这允许TCP/IP连接到指定的主机和可选的安全握手和代理导航的端口；


![NSURLSessionTask.png](https://upload-images.jianshu.io/upload_images/7112462-46eedc6f3e8d0b6e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


通过`NSURLSession` 创建任务，有两种响应方式：
* 设置 `delegate`：响应报文被 `NSURLSessionDelegate` 的代理方法处理；
* 使用 `completionHandler` 创建任务，那么在 `completionHandler` 中处理响应数据（即使设置了 `delegate`）；



如果设置了`delegate`，根据不通的任务，由不同的 `NSURLSessionDelegate` 方法来处理：

* `NSURLSessionDelegate`  : 是 session 级别的协议，主要管理 session 的生命周期、处理证书认证等
* `NSURLSessionTaskDelegate`     : 是 task 级别的协议，面向所有的委托方法
* `NSURLSessionDataDelegate`     : 是 task 级别的协议，主要用来处理 data 和 upload，如接收到响应，接收到数据，是否缓存数据
* `NSURLSession​Download​Delegate` : 是 task 级别的协议，用来处理下载任务
* `NSURLSessionStreamDelegate`   : 是 task 级别的协议，用来处理 streamTask
* `NSURLSessionWebSocketDelegate`: 是 task 级别的委托，处理特定于 WebSocketTask 的事件

 ![NSURLSessionDelegate.png](https://upload-images.jianshu.io/upload_images/7112462-f39cfd013b70c972.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


可以重复使用一个`NSURLSession`来创建多个任务，创建的 `NSURLSessionTask` 对象总是处于挂起状态，在它们执行之前必须调用 `-resume` 方法。




##### 4.1、向会话中添加 DataTasks


```
/** 使用指定的 NSURLRequest 创建一个数据任务
 * @param 请求可以有一个 body stream
*/
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request;

/** 使用指定的 URL 创建一个数据任务
 */
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url;

/** 使用指定的 NSURLRequest 创建一个数据任务
 * @param completionHandler 任务完成时调用；绕过正常的代理调用响应和数据传递；
 *          如果设置了 delegate，在 authentication challenges 仍然会被调用；
 *          该参数传递 nil，任务完成时调用代理方法，此时等同于 -dataTaskWithRequest: 方法
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/** 使用指定的 URL 创建一个数据任务，提供一个简单的可取消异步接口来接收数据。
 * @param completionHandler 任务完成时调用；绕过正常的代理调用响应和数据传递；
 *          如果设置了 delegate，在 authentication challenges 仍然会被调用；
 *          该参数传递 nil，任务完成时调用代理方法，此时等同于 -dataTaskWithRequest: 方法
 */
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
```




##### 4.2、向会话中添加 DownloadTasks

当下载成功完成时，需要将下载数据从临时文件拷贝至指定文件，临时文件将被自动删除。

```
/** 使用指定的 NSURLRequest 创建一个下载任务
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request;
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/** 使用指定的 url 创建一个下载任务
 */
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/** 使用 resume Data 创建一个下载任务，以恢复先前取消或失败的下载
 * @resumeData 提供恢复下载所需的数据对象
 * @note 如果下载不能恢复，将调用 -URLSession:task:didCompleteWithError:
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData;
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
```



##### 4.3、向会话中添加 UploadTasks

```
/** 使用指定的 NSURLRequest 创建一个上传任务
 * @request 上传任务的请求包含一个请求体以上传元数据，比如POST或PUT请求。
 * @param fileURL 待上载的文件的URL
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/** 使用指定的 NSURLRequest 创建一个上传任务
 * @param bodyData 请求体的元数据由 bodyData 提供
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/** 使用指定的 NSURLRequest 创建一个上传任务
 * @note 必须由代理方法 -URLSession:task:needNewBodyStream: 提供上传的元数据
 */
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request;
```


##### 4.4、向会话中添加  StreamTasks

```
/** 创建一个 StreamTask，该任务建立指定主机名和端口的双向TCP/IP连接
 * @param hostname 主机名
 * @param 端口
*/
- (NSURLSessionStreamTask *)streamTaskWithHostName:(NSString *)hostname port:(NSInteger)port API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));

/** 使用指定的 NSNetService 创建双向TCP/IP连接的 streamTask
 * @param service 用于确定TCP/IP连接端点的NSNetService对象；在将任何数据读取或写入结果的streamTask 之前解析此网络服务。
*/
- (NSURLSessionStreamTask *)streamTaskWithNetService:(NSNetService *)service API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0)) API_UNAVAILABLE(watchos);
```


##### 4.5、向会话中添加 WebSocketTasks

```
/** 使用指定的 URL 创建一个 WebSocket 任务
 * @param url 要连接 WebSocket 的 URL，必须有一个ws或wss方案；
*/
- (NSURLSessionWebSocketTask *)webSocketTaskWithURL:(NSURL *)url API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));

/** 根据指定的 URL 和协议数组，创建一个WebSocket任务
 * @param url 要连接 WebSocket 的 URL
 * @param protocols 与服务器进行协商的协议数组；这些协议将在WebSocket握手中用于与服务器协商一个优先的协议
*/
- (NSURLSessionWebSocketTask *)webSocketTaskWithURL:(NSURL *)url protocols:(NSArray<NSString *>*)protocols API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));

/** 使用指定的 NSURLRequest 创建一个WebSocket任务
 * 可以在调用 -resume 之前修改请求的属性，该任务在 HTTP 握手阶段使用这些属性。
 * 要添加自定义协议，请添加一个带有 Sec-WebSocket-Protocol的 HTTP headers，以及一个以逗号分隔的要与服务器协商的协议列表。
 * 客户端提供的 HTTP headers 在与服务器握手时将保持不变。
*/
- (NSURLSessionWebSocketTask *)webSocketTaskWithRequest:(NSURLRequest *)request API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));
```


#### 5、 使用 `NSURLsession` 完成一个网络通信



##### 5.1、使用 `completionHandler` 方式创建一个 `Get` 请求

##### 5.1.1、 使用 `sharedSession` 单例创建会话：

创建了一个简单的 `Get` 请求， `sharedSession` 默认配置类，代理对象与操作队列默认为` nil`，来看下会话的回调结果：

```
{
    //注意：NSURLRequest 默认是 GET 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunes_URL]];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"currentThread : %@",[NSThread currentThread]);
        if (error){
            NSLog(@"请求失败：%@",error);
        }else{
            NSLog(@"请求成功");
        }
    }];
    [dataTask resume];
}

/** 打印日志
currentThread : <NSThread: 0x174263080>{number = 5, name = (null)}
请求成功
*/
```

这个会话成功的收到响应，而且响应的回调为任意分线程，这时如果要更新 UI ，就要回到主线程去!

##### 5.1.2、配置 `session` 时，不设置 `delegate`
 
创建了一个简单的 `Get` 请求，为 `session` 设置了配置类，代理对象与操作队列默认为 `nil`，来看下会话的回调结果：
 
```
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunes_URL]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"currentThread : %@",[NSThread currentThread]);
        if (error){
            NSLog(@"请求失败：%@",error);
        }else{
            NSLog(@"请求成功");
        }
    }];
    [dataTask resume];
/** 打印日志
currentThread : <NSThread: 0x174263170>{number = 8, name = (null)}
请求成功
*/
}
```
 
这个会话成功的收到响应，而且响应的回调为任意分线程!

##### 5.1.3、配置 `session` 时，设置 `delegate` ,设置 `delegateQueue`
 
创建了一个简单的 `Get` 请求，为 `session` 设置了配置类，代理对象，操作队列，来看下会话的回调结果：
 

```
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunes_URL]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"currentThread : %@",[NSThread currentThread]);
        if (error){
            NSLog(@"请求失败：%@",error);
        }else{
            NSLog(@"请求成功");
        }
    }];
    [dataTask resume];
 
/** 打印日志：
currentThread : <NSThread: 0x17006c740>{number = 1, name = main}
请求成功
*/
}
```

##### 注意：内存泄露

使用 Instruments 监控了以上请求的内存情况，发现除了 `sharedSession` 方式配置的 `session` ，其余的方式创建 task 都存在内存泄露：

![Instruments结果.png](https://upload-images.jianshu.io/upload_images/7112462-a49c46841a97a1f2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这是为什么呢？还记得我们前文强调的嘛：
> 会话对象保存对委托的强引用，直到应用程序退出或显式地使会话无效为止。如果你不使会话无效，你的应用程序就会泄露内存，直到它退出。
也就是说：如果我们不调用以下两个方法中的一个使 session 失效，session 是会内存泄露的。

 

  

##### 5.2、使用 `completionHandler` 方式创建一个 `Post` 请求

###### 5.2.1、创建`Post` 请求下载图片
 
使用 `session` 创建了一个简单的下载图片的 downloadTask，下载成功后将文件从临时路径转移到我们指定的位置
 
```
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString *imagePath = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528867244313&di=904a1b5eb7db534ea15ce4c266bfa1c4&imgtype=0&src=http%3A%2F%2Fpic.58pic.com%2F58pic%2F15%2F36%2F01%2F58PIC2958PICbAX_1024.jpg";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imagePath]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"currentThread : %@",[NSThread currentThread]);
        if (error){
            NSLog(@"请求失败：%@",error);
        }else{
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *newFilePath = [documentsPath stringByAppendingPathComponent:response.suggestedFilename];
            [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:newFilePath error:nil];
            NSLog(@"请求成功：%@",newFilePath);
        }
    }];
    [downloadTask resume];
}
```
 


 
###### 5.2.2、创建`Post` 请求上传一个图片
 
上传一个文件时，需要在请求头添加 `Content-Type` ，设置边界 `boundary` 为任意值，有兴趣的可以去了解下 [HTTP协议](http://www.cnblogs.com/EricaMIN1987_IT/p/3837436.html)

 
```
{
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"updateFile"]];
    request.HTTPMethod = @"POST";
    [request setValue:@"multipart/form-data;boundary=***" forHTTPHeaderField:@"Content-Type"];
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"myBack"], 0.5);
    NSMutableData *bodyData = [NSMutableData dataWithData:imageData];
    NSURLSessionUploadTask *dask = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"currentThread : %@",[NSThread currentThread]);
        if (error){
            NSLog(@"请求失败：%@",error);
        }else{
            NSLog(@"请求成功");
        }
    }];
    [dask resume];
}
```


