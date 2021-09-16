NSURLSession 的 task 是异步回调的，所有的回调都是在委托代理里面处理， 苹果为我们提供了 [NSURLSessionDelegate](https://developer.apple.com/documentation/foundation/nsurlsessiondelegate?changes=latest_minor&language=objc) 的一系列代理方法供我们选择使用，首先，我们先了解下 NSURLSession 的相关代理：


![NSURLSessionDelegate继承关系.png](https://upload-images.jianshu.io/upload_images/7112462-2822c578ba870f1f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



* `NSURLSessionDelegate`  : 是 session 级别的协议，主要管理 session 的生命周期、处理证书认证等
* `NSURLSessionTaskDelegate`     : 是 task 级别的协议，面向所有的委托方法
* `NSURLSessionDataDelegate`     : 是 task 级别的协议，主要用来处理 data 和 upload，如接收到响应，接收到数据，是否缓存数据
* `NSURLSession​Download​Delegate` : 是 task 级别的协议，用来处理下载任务
* `NSURLSessionStreamDelegate`   : 是 task 级别的协议，用来处理 streamTask
* `NSURLSessionWebSocketDelegate`: 是 task 级别的委托，处理特定于 WebSocketTask 的事件

这些协议都是继承关系，只要设置了 delegate，在`NSURLSession`实现中会去判断这些代理是否 `-respondsToSelector` 这些代理方法，如果响应了就去调用。


####1、[`NSURLSessionDelegate`](https://developer.apple.com/documentation/foundation/nsurlsessiondelegate?changes=latest_minor&language=objc)

是 `NSURLSession` 级别的委托，主要管理 `session` 的生命周期、处理证书认证等


#####1.1、管理 `NSURLSession` 生命周期

```
@optional

/** 当 NSURLSession 已经无效时，该方法被调用
 *  <li> -finishTasksAndInvalidate ： NSURLSession 将等到所有 task 结束或失败后才调用该方法
 *  <li> -invalidateAndCancel ： NSURLSession 将直接取消所有正在执行的 task，立即调用该方法
 *  <li> 由于系统错误，error 获取错误信息
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error;

/**
 * 在iOS中，当后台传输完成或需要凭据时如果App挂起，那么App将自动在后台重新启动，应用程序的UIApplicationDelegate将调用  -application:handleEventsForBackgroundURLSession:completionHandler: 方法，表明之前为这个会话排队的所有消息已经被传递。
 * 此调用包含导致NSURLSessionConfiguration.identifier，然后在创建具有相同标识符的Configuration 之前，应该存储该 completionHandler，并使用该 Configuration 创建一个会话，新创建的会话自动与正在进行的后台活动重新关联。
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session API_AVAILABLE(ios(7.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos);
```

#####1.2、处理 `NSURLSession` 身份验证


```
@optional

/**
 * 处理服务器的 NSURLSession 级身份验证请求
 * 此方法在两种情况下调用：
 *  <li> 当服务器请求客户端证书或NTLM身份验证时，调用该方法为服务器提供适当的证书
 *  <li> 在SSL握手阶段或TLS的服务器连接时，调用该方法验证服务器的证书
 *
 * 如果没有实现该方法，NSURLSession 将调用代理方法 -URLSession:task:didReceiveChallenge:completionHandler: 代替
 *
 * @param challenge 需要身份验证请求的对象
 * @param completionHandler
 *            disposition 如何处理身份验证
 *            credential 当disposition=NSURLSessionAuthChallengeUseCredential时用于身份验证的证书；否则为NULL
 *
 *  <ul> NSURLSessionAuthChallengeDisposition 如何处理身份验证
 *     <li> NSURLSessionAuthChallengeUseCredential 使用参数 credential 提供的指定证书，它可以是nil
 *     <li> NSURLSessionAuthChallengePerformDefaultHandling 默认处理方式，不使用参数 credential 提供的证书
 *     <li> NSURLSessionAuthChallengeCancelAuthenticationChallenge 取消整个请求，提供的证书被忽略
 *     <li> NSURLSessionAuthChallengeRejectProtectionSpace 拒绝该验证，提供的证书被忽略；应该尝试下一个身份验证保护空间
 *         该配置只适用于非常特殊的情况，如 Windows 服务器可能同时使用NSURLAuthenticationMethodNegotiate和NSURLAuthenticationMethodNTLM
 *         如果 App 只能处理 NTLM，则拒绝此验证，以获得队列的NTLM挑战。
 *         大多数App不会面对这种情况，如果不能提供某种身份验证的证书，通常使用 NSURLSessionAuthChallengePerformDefaultHandling
 *  </ul>
 *
 * @note 该方法只处理 NSURLAuthenticationMethodNTLM 、NSURLAuthenticationMethodNegotiate、NSURLAuthenticationMethodClientCertificate 和NSURLAuthenticationMethodServerTrust 类型的身份验证。对于所有其他身份验证，会话调用 -URLSession:task:didReceiveChallenge:completionHandler: 处理。
*/
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                                             completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;
```




######1.2.1、关于身份验证 `challenge`
                                
[NSURLAuthenticationChallenge](https://developer.apple.com/documentation/foundation/nsurlauthenticationchallenge?changes=latest_minor&language=objc) 来自服务器的身份验证请求，封装了需要客户端提供的信息：定义了身份验证类型、主机和端口号、网络协议、适用的身份验证领域(一组相关的url在同一台服务器上共享一组证书) 等。
通过 `challenge.protectionSpace.authenticationMethod` 可以知道服务端要通过哪种方式验证证书：

```
/** NSURLProtectionSpace 需要身份验证的服务器或服务器上的区域
 *
 *  <ul> Session 级别的身份验证
 *     <li> NSURLAuthenticationMethodNTLM 使用NTLM身份验证
 *     <li> NSURLAuthenticationMethodNegotiate 协商使用Kerberos或者NTLM身份验证
 *     <li> NSURLAuthenticationMethodClientCertificate 验证客户端的证书，可以应用于任何协议
 *     <li> NSURLAuthenticationMethodServerTrust 验证服务端提供的证书，可以应用于任何协议，常用于覆盖SSL和TLS链验证
 *  </ul>
 *
 *
 *  <ul> Task 级别的身份验证
 *     <li> NSURLAuthenticationMethodDefault 默认的验证
 *     <li> NSURLAuthenticationMethodHTMLForm 一般不会要求身份验证，在提交 web 表单进行身份验时可能用到
 *     <li> NSURLAuthenticationMethodHTTPBasic 基本的HTTP验证，通过 NSURLCredential 对象提供用户名和密码，相当于默认验证
 *     <li> NSURLAuthenticationMethodHTTPDigest 类似于HTTP验证，摘要会自动生成，同样通过 NSURLCredential 对象提供用户名和密码
 *  </ul>
 */
```

######1.2.2、  credential
          
[NSURLCredential](https://developer.apple.com/documentation/foundation/nsurlcredential?changes=latest_minor&language=objc)类型 ，一种身份验证凭证，包含特定于凭证类型的信息和用于使用的持久存储类型。
当 `disposition=NSURLSessionAuthChallengeUseCredential` 时，需要提供一个证书 `NSURLCredential`。可以创建3种类型的证书 `Credential` :

```
/** 当 protectionSpace.authenticationMethod = NSURLAuthenticationMethodHTTPBasic 或
 *    protectionSpace.authenticationMethod = NSURLAuthenticationMethodHTTPDigest 时
*/
- (instancetype)initWithUser:(NSString *)user password:(NSString *)password persistence:(NSURLCredentialPersistence)persistence;
+ (NSURLCredential *)credentialWithUser:(NSString *)user password:(NSString *)password persistence:(NSURLCredentialPersistence)persistence;

/** 当 protectionSpace.authenticationMethod = NSURLAuthenticationMethodClientCertificate 时
*/
- (instancetype)initWithIdentity:(SecIdentityRef)identity certificates:(nullable NSArray *)certArray persistence:(NSURLCredentialPersistence)persistence;
+ (NSURLCredential *)credentialWithIdentity:(SecIdentityRef)identity certificates:(nullable NSArray *)certArray persistence:(NSURLCredentialPersistence)persistence;

/** 当 protectionSpace.authenticationMethod = NSURLAuthenticationMethodServerTrust 时
*/
- (instancetype)initWithTrust:(SecTrustRef)trust;
+ (NSURLCredential *)credentialForTrust:(SecTrustRef)trust;
```



####2、 [`NSURLSessionTaskDelegate`](https://developer.apple.com/documentation/foundation/nsurlsessiontaskdelegate?changes=latest_minor&language=objc)

是 `NSURLSessionTask` 级别的委托


#####2.1、处理 task 的生命周期

```
@optional
/** 已完成传输数据的任务，调用该方法
 * @param error 客户端错误，例如无法解析主机名或连接到主机；
 *              服务器错误不会在此处显示；
 *              为 nil 表示没有发生错误，此任务已成功完成
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                           didCompleteWithError:(nullable NSError *)error;
```


#####2.2、处理 task 的重定向


```
@optional

/** 远程服务器请求HTTP重定向：一个HTTP请求试图重定向到一个不同的URL
 *
 * @param response 服务器对原始请求的响应
 * @param request 用新位置填充的 NSURLRequest
 * @param completionHandler 传入重定向的新NSURLRequest，那么执行重定向请求；
 *                          传入 nil，则不执行重定向请求并以当前响应体作为重定向后的响应
 *
 * @note 该方法仅被用于 defaultSessionConfiguration 和 ephemeralSessionConfiguration 的会话，后台会话中的任务自动重定向。
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
                              completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler;
```



#####2.3、处理上传任务


```
@optional

/** 当执行上传任务时，系统会定期的调用该方法，告知上传请求体的进度
 * @param bytesSent 自上次调用该方法以来发送的字节数
 * @param totalBytesSent 截止到目前发送的字节总数
 * @param totalBytesExpectedToSend 请求体 body data 的预期长度，该长度可以通过三种方式确定：
 *          <1> 作为上传 body 提供的 NSData 对象的长度
 *          <2> 磁盘中上传 body 提供的文件长度
 *          <3> 如果设置请求对象，请求头部的 Content-Length 字段
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                                didSendBodyData:(int64_t)bytesSent
                                 totalBytesSent:(int64_t)totalBytesSent
                       totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

/** 当任务需要新的 bodyStream 发送到服务器时，调用该方法
 * 这个任务在两种情况下必须调用：
 *  <li> 如果任务是通过 [NSURLsession uploadTaskWithStreamedRequest:] 创建的，必须调用该方法提供 bodyStream
 *  <li> 由于身份验证、上传失败时等，任务需要重新发送具有bodyStream的请求，则提供 bodyStream 用以替换 request
 *
 * @param completionHandler 传递 bodyStream
 * @note 如果使用文件或数据对象提供请求体，则不需要实现该方法
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                              needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler;
```



#####2.4、处理身份认证


```
@optional

/** 处理 task 级身份验证
 *
 * 对于 session 级别的验证：当 authenticationMethod 的值为：
 *      NSURLAuthenticationMethodNTLM、NSURLAuthenticationMethodNegotiate、
 *      NSURLAuthenticationMethodClientCertificate、 NSURLAuthenticationMethodServerTrust时，
 * 系统会先尝试调用 session 级的处理方法，若 session 级未实现，则尝试调用 task 级的处理方法；
 * 对于非 session 级别的验证：直接调用 task 级的处理方法，无论 session 级方法是否实现。
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                            didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                              completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;
```


#####2.5、处理延迟和等待任务


```
@optional
/** 处理延迟任务
 * 当任务的 task.earliestBeginDate 可能过时、并且网络加载被新请求替换时，将调用此方法
 * 如果该方法未被实现，加载将继续原始请求
 * @param completionHandler 如何处理延迟任务
 *          disposition 告诉NSURLSessionTask如何进行
 *          newRequest  当 disposition=NSURLSessionDelayedRequestUseNewRequest 时才使用的新请求对象
 *
 * <ul> NSURLSessionDelayedRequestDisposition 用于各种delegate消息的处理选项
 *     <li> NSURLSessionDelayedRequestContinueLoading 继续执行原始请求，请求参数 newRequest 被忽略
 *     <li> NSURLSessionDelayedRequestUseNewRequest   使用新请求 newRequest 执行下载
 *     <li> NSURLSessionDelayedRequestCancel          取消该任务 ; 请求参数 newRequest 被忽略
 *  </ul>
 *
 * 如果指定新请求，那么属性 allowsExpensiveNetworkAccess、allowsContrainedNetworkAccess 和allowsCellularAccess 将不会被使用;原始请求的属性将继续使用。
 * 取消任务相当于调用方法 [task cancel], 同时代理方法 -URLSession:task:didCompleteWithError: 将被调用并返回 NSURLErrorCancelled 错误
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                        willBeginDelayedRequest:(NSURLRequest *)request
                              completionHandler:(void (^)(NSURLSessionDelayedRequestDisposition disposition, NSURLRequest * _Nullable newRequest))completionHandler
    API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));

/** 任务正在等待，直到连接可用后才开始网络加载
 *  通过该方法更新用户界面：例如，通过显示脱机模式或只显示蜂窝模式
 * 每个任务最多调用一次该方法：当NSURLSessionConfiguration.waitsForConnectivity被设置为YES，并且只在连接最初不可用时调用。
 * 后台会话从不调用该方法，因为后台Configuration忽略了waitsForConnectivity
*/
- (void)URLSession:(NSURLSession *)session taskIsWaitingForConnectivity:(NSURLSessionTask *)task
    API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));
```


#####2.6、监控流量分析

```
@optional
/** 为任务收集的完整统计信息
 * @param metrics 统计信息，用来监控流量分析
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));
```

####3、[`NSURLSessionDataDelegate`](https://developer.apple.com/documentation/foundation/nsurlsessiondatadelegate?changes=latest_minor&language=objc)

是 task 级别的协议，主要用来处理 data 和 upload，如接收到响应，接收到数据，是否缓存数据


#####3.1、处理 task 生命周期

```
@optional

/** 当 DataTask 收到响应时，会调用该方法；
 * 后台上传任务、无法转为下载任务 均不会调用此方法
 *
 * @param completionHandler
 *  disposition 允许取消请求或将数据任务转换为下载任务、streamTask
 *
 * <ul> NSURLSessionResponseDisposition 在收到初始头后应该如何进行
 *     <li> NSURLSessionResponseCancel         该任务被取消，与 [task cancel] 相同
 *     <li> NSURLSessionResponseAllow          允许继续加载，任务正常进行
 *     <li> NSURLSessionResponseBecomeDownload 转换为下载任务，会调用代理方法 -URLSession:dataTask:didBecomeDownloadTask: ，此方法不再调用
 *     <li> NSURLSessionResponseBecomeStream   转换为 streamTask，会调用代理方法 -URLSession:dataTask:didBecomeStreamTask:
 *  </ul>
 *
 *
 * @note 该方法可选，如果没有实现它，可以使用 dataTask.response 获取响应数据；
 *       但如果该任务的请求头中 content-type 支持 multipart/x-mixed-replace，服务器会将数据分片传回来，而且每次传回来的数据会覆盖之前的数据；
 *       每次返回新的数据时会调用该方法，开发者需要在该方法中合理地处理先前的数据，否则会被新数据覆盖。
 *       如果没有提供该方法的实现，那么session将会继续任务，也就是说会覆盖之前的数据。
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;


/** 当 disposition 值为 NSURLSessionResponseBecomeDownload 时转换为下载任务，调用该方法提供新的下载任务
 * 调用该方法后，不再调用与接收原始数据相关的代理方法；
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                              didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/** 当 disposition 值为 NSURLSessionResponseBecomeStream 时转换为 streamTask，调用该方法提供新的streamTask
 * 调用该方法后，不再调用与接收原始数据相关的代理方法；
 *
 * @param streamTask 将携带原始请求 streamTask.originalRequest 与响应 streamTask.response
 *
 * 对于 pipelined 的请求，stream 将只允许读取，并立即调用代理方法 -URLSession:writeClosedForStreamTask: 可以通过 NSURLRequest.HTTPShouldUsePipelining 禁用一个会话中的所有请求
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask;

```

#####3.2、接收数据

当客户端获取到数据，会反复调用下述方法，服务器返回的数据在这被拼装完整

```
@optional

/** 客户端已收到服务器返回的部分数据
 * @param data 自上次调用以来收到的数据
 * 该方法可能被多次调用，并且每次调用只提供自上次调用以来收到的数据；因此 NSData 通常是由许多不同的data拼凑在一起的，所以尽量使用 [NSData enumerateByteRangesUsingBlock:] 方法迭代数据，而非 [NSData getBytes]
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                     didReceiveData:(NSData *)data;
```


#####3.3、处理缓存

```
@optional

/** 当 dataTask 接收完所有数据后，session会调用该方法，主要是防止缓存指定的URL或修改与 NSCacheURLResponse 相关联的字典userInfo
 * 如果没有实现该方法，那么使用 configuration 决定缓存策略
 *
 * @param proposedResponse 默认的缓存行为；根据当前缓存策略和响应头的某些字段，如 Pragma 和 Cache-Control 确定
 * @param completionHandler 缓存数据；传递 nil 不做缓存
 * @note 不应该依赖该方法来接收数据，只有 NSURLRequest.cachePolicy 决定缓存 response 时候调用该方法：
 *       只有当以下所有条件都成立时，才会缓存 responses:
 *          <li> 是HTTP或HTTPS请求，或者自定义的支持缓存的网络协议；
 *          <li> 确保请求成功，响应头的状态码在200-299范围内
 *          <li> response 是来自服务器的，而非缓存中本身就有的
 *          <li> NSURLRequest.cachePolicy 允许缓存
 *          <li> NSURLSessionConfiguration.requestCachePolicy 允许缓存
 *          <li> 响应头的某些字段 如 Pragma 和 Cache-Control 允许缓存
 *          <li> response 不能比提供的缓存空间大太多，如不能比提供的磁盘缓存空间还要大5%
*/
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                  willCacheResponse:(NSCachedURLResponse *)proposedResponse
                                  completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler;
```



####4、[`NSURLSessionDownloadDelegate`](https://developer.apple.com/documentation/foundation/nsurlsessiondownloaddelegate?changes=latest_minor&language=objc)

是 task 级别的委托，用来处理下载任务

#####4.1、处理 `DownloadTask` 生命周期

```
@required
/** 下载完成时必须调用
 * 该方法调用完毕后，路径 location 下的文件会被删除；
 * @param location 临时文件路径；因为文件是临时的，所以在该方法中，必须打开该文件以便读取，或者将其移动到沙盒的永久位置；
 *                 如果选择打开文件进行读取，则应该在另一个线程中进行实际读取，以避免阻塞 delegateQueue；
 *
 * 同时 -URLSession:task:didCompleteWithError: 仍然会被调用
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location;
```


#####4.2、恢复暂停下载


```
@optional
/** 断点续传：当下载任务被取消或者失败后，重新恢复下载时调用，表明该任务重新开始下载
 * @param downloadTask 重新开始的下载任务
 * @param fileOffset 如果文件的 cachePolicy 或 last modified 日期阻止重用现有内容，则该值为 0；
 *                   否则，该值是当前已经下载 data 的偏移量，表示磁盘上不需要再次检索的字节数
 *                   在某些情况下，可以在文件中比先前传输结束的位置更早地恢复传输。
 * @param expectedTotalBytes 文件的预期长度，由 Content-Length 提供；如果没有提供，则值为 NSURLSessionTransferSizeUnknown
 *
 * @Discussion 如果一个正在下载的任务被取消或者下载失败，可以在字典 userInfo 中通过 NSURLSessionDownloadTaskResumeData 键来获取 resumeData ；
 *    随后使用 resumeData 作为 -downloadTaskWithResumeData: 或 -downloadTaskWithResumeData:completionHandler: 的入参，重新开始下载任务；
 *    一旦任务开启，URLSession 会调用该方法表明下载任务重新开始！
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                      didResumeAtOffset:(int64_t)fileOffset
                                     expectedTotalBytes:(int64_t)expectedTotalBytes;
```


#####4.3、接收进度更新

```
@optional
/** 周期性地调用，告知下载进度
 * @param bytesWritten 表示自上次调用该方法后，截止到现在，接收的数据字节数
 * @param totalBytesWritten 任务开始，截止到目前，已经接收到的数据字节数
 * @param totalBytesExpectedToWrite 预期将接收的文件总字节数，由 Content-Length 提供；
 *                              如果没有提供，默认是 NSURLSessionTransferSizeUnknown
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
```


 


####5、[`NSURLSessionStreamDelegate`](https://developer.apple.com/documentation/foundation/nsurlsessionstreamdelegate?changes=latest_minor&language=objc)

是 task 级别的委托，用来处理 streamTask

#####5.1、处理路由

```
@optional

/** 为 stream 检测到更好的到服务器的路由时调用该方法：如当Wi-Fi 可用时
 * 应该为待完成的工作创建一个新的 streamTask，以便在它们可用时利用更好的路由
 * @note 不能保证新的 streamTask 能够连接到主机，所以调用者应该为任何新接口的读写失败做好准备
 */
- (void)URLSession:(NSURLSession *)session betterRouteDiscoveredForStreamTask:(NSURLSessionStreamTask *)streamTask;
```


#####5.2、完成流捕获

```
@optional
/** 调用 -[NSURLSessionStreamTask captureStreams]，完成队列中所有的读和写 StreamTask 之后调用该方法
 * 此后 streamTask 将不再接收任何 delegate 消息
 * @param inputStream  创建的输入流，这个 NSInputStream 对象未打开
 * @param outputStream 创建的输出流，这个 NSOutputStream 对象未打开
 */
- (void)URLSession:(NSURLSession *)session streamTask:(NSURLSessionStreamTask *)streamTask
                                 didBecomeInputStream:(NSInputStream *)inputStream
                                         outputStream:(NSOutputStream *)outputStream;
```


#####5.3、处理关闭事件

```
@optional

/** 告知委托底层Socket连接的读端已关闭
 * 即使当前没有读取操作 [NSURLSessionStreamTask -readData]，也可以调用该方法；
 * 该方法并不表示 Stream 到达文件的结束 EOF 而不能读取更多的数据，可能仍然有可用的字节；
*/
- (void)URLSession:(NSURLSession *)session readClosedForStreamTask:(NSURLSessionStreamTask *)streamTask;

/** 告知委托底层Socket连接的写端已关闭
 * 即使当前没有写操作 [NSURLSessionStreamTask -writeData]，也可以调用该方法；
 */
- (void)URLSession:(NSURLSession *)session writeClosedForStreamTask:(NSURLSessionStreamTask *)streamTask;
```




####6、[`NSURLSessionWebSocketDelegate`](https://developer.apple.com/documentation/foundation/nsurlsessionwebsocketdelegate?changes=latest_minor&language=objc)


是 task 级别的委托，处理特定于 WebSocketTask 的事件

```
API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0))
@protocol NSURLSessionWebSocketDelegate <NSURLSessionTaskDelegate>

#pragma mark - 处理 WebSocket 生命周期事件

@optional

/** 指示WebSocket握手成功并且连接已经升级到 webSockets
 * @param webSocketTask 开启的WebSocket任务
 * @param protocol 在握手阶段选择的协议；如果服务器没有选择协议，或者客户机在创建任务时没有发布协议，则此参数为nil。
 * @note 握手失败不会调用该方法
 */
- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didOpenWithProtocol:(NSString * _Nullable) protocol;

/** 指示WebSocket已经接收到来自服务器端点的关闭帧
 * @param webSocketTask 关闭的WebSocket任务
 * @param closeCode 服务器提供的关闭代码；如果 close frame 没有包含关闭代码，这个值为nil
 * @param reason    服务器提供的关闭原因；如果 close frame 没有包含原因，这个值为nil
 */
- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode reason:(NSData * _Nullable)reason;
@end
```
