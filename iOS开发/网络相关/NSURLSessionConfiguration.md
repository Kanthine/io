
[NSURLSessionConfiguration](https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration?changes=latest_minor&language=objc) 是对请求回话 `NSURLSession`的配置：请求超时时间、缓存策略、连接需求以及其它信息！它还定义了在使用 `NSURLSession` 对象上传和下载数据时要使用的行为和策略。

创建`NSURLSession`时，使用的配置信息是传入的 `Configuration` 的拷贝副本，因此会话创建之后对 `Configuration` 修改，不会对会话实例产生任何影响！

在某些情况下，`Configuration` 定义的策略可能被为任务提供的 `NSURLRequest` 指定的策略所覆盖。在 `NSURLRequest` 上指定的任何策略都将被允许，除非`NSURLSession`的策略更具限制性。例如，如果`Configuration`指定不允许蜂窝网络，则`NSURLRequest`对象不能请求蜂窝网络。
 
####1、创建 `NSURLSessionConfiguration`

官方提供了三种创建`NSURLSessionConfiguration`的方法：

```
/** 默认会话配置 : 通过单例使用证书、缓存和cookie
 * 使用基于磁盘的持久缓存(除非结果下载到文件中)，并在用户的 keyChain 中存储证书；
 * 默认情况下它还将 Cookie 存储在与 NSURLConnection 和 NSURLDownload 类相同的共享cookie存储中。
 */
@property (class, readonly, strong) NSURLSessionConfiguration *defaultSessionConfiguration;

/** 临时会话配置：cookie、缓存或证书 可能存储在 RAM 中
 * 与默认 Configuration 类似，但相关的 NSURLSession 不向磁盘存储缓存、证书或 Cookie，这些数据存储在 RAM 中。
 * 临时配置向磁盘写入数据的惟一时间是告诉它将URL的内容写入文件。
 * 使用临时配置的主要优势是隐私：不向磁盘写入敏感数据，可以降低数据被拦截和以后使用的可能性；适用于 web 浏览器和其他类似情况下的私有浏览模式。
 * 临时配置缓存的大小受可用 RAM 限制，这意味着先前获取的资源可能不在缓存中，如用户退出并重新启动应用程序就不在缓存中；这会降低感知性能。
 * 当 NSURLSession 无效时，所有临时的会话数据将自动清除。
 * 此外，当iOS应用程序挂起时，RAM 缓存不会自动清除，但在应用程序终止或系统受到内存压力时，RAM 缓存可能会被清除。
*/
@property (class, readonly, strong) NSURLSessionConfiguration *ephemeralSessionConfiguration;//临时会话

/** 后台会话配置：挂起的应用在某些约束条件下可以使用该配置执行传输数据文件等网络操作。
 * 使用该配置的 NSURLSession 将传输的控制权交给系统，系统在单独的进程中处理传输任务；当传输大量数据时，建议将此属性 discretionary 的值设置为YES，以便实现最佳性能。
 * @discussion 在iOS中，该配置使得即使应用本身被暂停或终止，传输也可以继续；当被系统终止并重新启动，使用相同标识符创建一个新的 Configuration 和 NSURLSession，并检查终止时正在进行的传输状态。
 *    此行为仅适用于系统正常终止应用程序；如果用户从多任务屏幕上终止应用程序，系统将取消会话的所有后台传输。
 * 此外，被用户强制退出的应用程序必须显式地重新启动应用程序，然后才能重新开始传输。
 * @param identifier：配置对象的唯一标识符，这个参数不能是nil或空字符串。
 */
+ (NSURLSessionConfiguration *)backgroundSessionConfigurationWithIdentifier:(NSString *)identifier API_AVAILABLE(macos(10.10), ios(8.0), watchos(2.0), tvos(9.0));
```


注意：除了上述三种方法，不能使用 `-init` 或 `+new` 创建一个实例!


######eg、

```
//获取默认配置
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

//创建一个临时会话配置
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
```


####2、普通属性

```
/**  后台会话配置的唯一标识符
 */
@property (nullable, readonly, copy) NSString *identifier;

/** 发送请求的附加头
 * @note 只有在请求不存在时，才会将这些头添加到请求中。
 */
@property (nullable, copy) NSDictionary *HTTPAdditionalHeaders;

/** 所有任务的网络服务类型
 *  <ul>
 *     <li> NSURLNetworkServiceTypeDefault 标准的网络流量，大多数连接应该使用这种服务类型。
 *     <li> NSURLNetworkServiceTypeVoIP 指定该请求用于VoIP服务，内核在应用处于后台时继续监听传入流量。
 *     <li> NSURLNetworkServiceTypeVideo 指定请求用于视频通信
 *     <li> NSURLNetworkServiceTypeBackground 网络后台传输，优先级不高时可使用。对用户不需要的网络操作可使用
 *     <li> NSURLNetworkServiceTypeVoice   指定请求是语音通信
 *     <li> NSURLNetworkServiceTypeCallSignaling  电话信号
 *  </ul>
 */
@property NSURLRequestNetworkServiceType networkServiceType;

/** 是否允许 NSURLSession 中的任务通过蜂窝网络进行连接
 */
@property BOOL allowsCellularAccess;

/** 配置 NSURLSession 内所有任务的请求超时时限，以秒为单位
 * @discussion 每当 NSURLSession 发送一个新任务时，计时器从 0 开始计时，当到达该时间也没接收服务器的响应时，它会触发超时。
 */
@property NSTimeInterval timeoutIntervalForRequest;


/** 配置 NSURLSession 内所有任务的资源超时时限，以秒为单位，默认值是 7 天 ！
 * @discussion  资源计时器在请求被启动时开始并计数，直到请求完成或达到此超时间隔(以先出现的为准)；如果在指定时限无法检索到资源，则会导致超时。
 */
@property NSTimeInterval timeoutIntervalForResource;

/** 应用程序扩展及其应用之间共享容器的有效标识符，后台会话中的文件下载到该数据容器；
 * @note 如果从应用程序扩展中创建 NSURLSession，但未设置该标识符，那么创建的 NSURLSession 将无效
 *       返回 NSURLErrorBackgroundSessionRequiresSharedContainer 失败。
*/
@property (nullable, copy) NSString *sharedContainerIdentifier;

/** NSURLSession 是否应该等待网络可用，或立即返回失败；默认为NO不等待！
 * 当连接可用时，任务正常工作调用 delegate 或完成 Handler
 * @NO 无法连接则立即返回失败 NSURLErrorNotConnectedToInternet
 * @YES 无网连接时 NSURLSession 将调用 -URLSession:taskIsWaitingForConnectivity: 方法等待网络连接成功，
 *      等待时，属性 timeoutIntervalForRequest 不应用，但 timeoutIntervalForResource 应用。
 * @case 连接暂时不可用：如只有蜂窝网络但 allowsCellularAccess=NO 、或需要VPN连接才能到达所需的主机等设备连接有限或不足的情况下的任务。
 * 由于后台会话总需要等待，因此被后台会话忽略。
 */
@property BOOL waitsForConnectivity;
```




##### 2.1、 关于网络服务类型

枚举值`NSURLRequestNetworkServiceType`|描述
-|-
`NSURLNetworkServiceTypeDefault`|标准的网络流量，大多数连接应该使用这种服务类型
`NSURLNetworkServiceTypeVoIP`| 使用VoIP服务类型，当应用程序在后台时，内核会继续监听传入的流量，然后每当新数据到来时就会唤醒应用程序。只用于与VoIP服务通信的连接
`NSURLNetworkServiceTypeVideo`|指定请求用于视频通信
`NSURLNetworkServiceTypeBackground`|网络后台传输，优先级不高时可使用。对用户不需要的网络操作可使用
`NSURLNetworkServiceTypeVoice`|指定请求是语音通信
`NSURLNetworkServiceTypeCallSignaling`|电话信号
 




####3、Cookie、Cache、安全证书

```
/** 决定何时应该接受 Cookie
 * 这将覆盖 Cookie 存储所指定的策略
 *  <ul>
 *     <li> NSHTTPCookieAcceptPolicyAlways 默认策略，接收所有的cookie
 *     <li> NSHTTPCookieAcceptPolicyNever 拒绝所有的cookies
 *     <li> NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain 只从 MainDocumentDomain 接收cookie
 *  </ul>
*/
@property NSHTTPCookieAcceptPolicy HTTPCookieAcceptPolicy;

/** 是否允许 NSURLSession 对请求设置 Cookie，默认为 YES
 * 确定请求是否应该包含来自 Cookie 存储区的cookie
 */
@property BOOL HTTPShouldSetCookies;

/** NSURLSession 中所有 task 使用的 cookie 存储对象
 * nil 表示不应处理cookie
 */
@property (nullable, retain) NSHTTPCookieStorage *HTTPCookieStorage;


/** 为 NSURLSession 中的请求提供缓存响应的URL缓存
 * nil表示不执行缓存
 */
@property (nullable, retain) NSURLCache *URLCache;

/** NSURLSession 中 task 使用的请求缓存策略
 *  <ul>
 *     <li> NSURLRequestUseProtocolCachePolicy 基础策略
 *     <li> NSURLRequestReloadIgnoringLocalCacheData 忽略本地缓存
 *     <li> NSURLRequestReloadIgnoringLocalAndRemoteCacheData 无视任何缓存策略，无论是本地的还是远程的，总是从服务器重新下载
 *     <li> NSURLRequestReloadIgnoringCacheData 忽略本地缓存
 *     <li> NSURLRequestReturnCacheDataElseLoad 首先使用缓存，如果没有本地缓存，才从服务器下载
 *     <li> NSURLRequestReturnCacheDataDontLoad 使用本地缓存，从不下载，如果本地没有缓存，则请求失败，此策略多用于离线操作
 *     <li> NSURLRequestReloadRevalidatingCacheData 如果本地缓存是有效的则不下载，其他任何情况都从原地址重新下载
 *  </ul>
 */
@property NSURLRequestCachePolicy requestCachePolicy;

/** NSURLSession 进行连接时，客户端请求的TLS协议允许的最大版本。
 */
@property tls_protocol_version_t TLSMaximumSupportedProtocolVersion API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));
@property SSLProtocol TLSMaximumSupportedProtocol API_DEPRECATED_WITH_REPLACEMENT("TLSMaximumSupportedProtocolVersion", macos(10.9, API_TO_BE_DEPRECATED), ios(7.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED));

/** NSURLSession 进行连接时，客户端请求的TLS协议允许的最小版本。
*/
@property tls_protocol_version_t TLSMinimumSupportedProtocolVersion API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));
@property SSLProtocol TLSMinimumSupportedProtocol API_DEPRECATED_WITH_REPLACEMENT("TLSMinimumSupportedProtocolVersion", ios(7.0, API_TO_BE_DEPRECATED));

/** 确定 NSURLSession 中 task 使用的证书存储对象
 * 为 nil 表示不使用凭据存储
 */
@property (nullable, retain) NSURLCredentialStorage *URLCredentialStorage;
```



#####3.1、 关于 HTTPCookieAcceptPolicy

指定由 `NSHTTPCookieStorage` 类实现的 `cookie` 接收策略

枚举值`HTTPCookieAcceptPolicy`|描述
-|-
`NSHTTPCookieAcceptPolicyAlways`|默认策略，接收所有的`cookie`
`NSHTTPCookieAcceptPolicyNever`|拒绝所有的`cookies`
`NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain`|只从 `MainDocumentDomain` 接收`cookie`

如果想要直接控制接收哪些`cookie`，可以将该值设置为`NSHTTPCookieAcceptPolicyNever`，然后使用 `allHeaderFields` 和 `-cookiesWithResponseHeaderFields:forURL: ` 从URL响应对象中提取 `cookie` !

[NSHTTPCookieStorage](https://developer.apple.com/documentation/foundation/nshttpcookiestorage?changes=latest_minor&language=objc) 是管理 `Cookie` 存储的单例对象；每个 `cookie` 都由 `NSHTTPCookie` 类的实例表示。iOS中的应用程序之间不共享 `cookie`。


 
#####3.2、缓存策略

缓存策略 `NSURLRequestCachePolicy` 作用于 `NSURLRequest` 中

枚举值`NSURLRequestCachePolicy`|描述
-| -
`NSURLRequestUseProtocolCachePolicy`|NSURLRequest` 中的默认策略
`NSURLRequestReloadIgnoringLocalCacheData`|忽略本地缓存
`NSURLRequestReloadIgnoringLocalAndRemoteCacheData`|无视任何缓存策略，无论是本地的还是远程的，总是从服务器重新下载
`NSURLRequestReloadIgnoringCacheData` | 忽略本地缓存
`NSURLRequestReturnCacheDataElseLoad` | 首先使用缓存，如果没有本地缓存，才从服务器下载
`NSURLRequestReturnCacheDataDontLoad` | 使用本地缓存，从不下载，如果本地没有缓存，则请求失败，此策略多用于离线操作
`NSURLRequestReloadRevalidatingCacheData` | 如果本地缓存是有效的则不下载，其他任何情况都从原地址重新下载

![tree.png](https://upload-images.jianshu.io/upload_images/7112462-a1d1ea27bc13fe21.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 






####4、后台传输

```
/** 当后台会话中的任务完成或需要身份认证时，是否允许应用程序在后台恢复或启动；
 * 默认值是YES，系统自动在后台唤醒或启动iOS应用程序；此时系统调用 AppDelegate 的 -handleEventsForBackgroundURLSession:completionHandler:方法提供会话标识符；使用该标识符创建一个新的配置和会话对象。
 * @note 仅适用于 +backgroundSessionConfigurationWithIdentifier 创建的 Configuration 。
 */
@property BOOL sessionSendsLaunchEvents API_AVAILABLE(ios(7.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos);

/** 它决定后台任务是否可以由系统自行安排以获得最佳性能，默认为NO ；
 * @discussion 当传输大量数据时，建议设置该值为 YES ；由系统自行安排安排传输。例如，系统可能会延迟传输大文件，直到设备插入并通过Wi-Fi连接到网络。
 * @note 仅适用于 +backgroundSessionConfigurationWithIdentifier: 方法创建的 Configuration 对象，为系统控制传输何时发生。
*/
@property (getter=isDiscretionary) BOOL discretionary API_AVAILABLE(macos(10.10), ios(7.0), watchos(2.0), tvos(9.0));

/** 为创建的任何 TCP Socket 启用扩展的后台空闲模式；
 * 启用此模式要求系统保持 Socket 打开，并在进程移动到后台时延迟收回
 */
@property BOOL shouldUseExtendedBackgroundIdleMode API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0));
```



####5、其它

```
/** 一个可选的NSURLProtocol子类对象数组,默认值是一个空数组；
 * @discussion NSURLSession 默认支持许多公共网络协议：还可扩展多个自定义协议 NSURLProtocol；
 *    在处理请求之前，NSURLSession  首先搜索默认协议，然后检查自定义协议，直到找到能够处理指定请求的协议为止。
 *    类方法 +canInitWithRequest: 返回 YES 表明 NSURLSession 能够处理指定的请求。
 * @note 不能使用 +[NSURLProtocol registerClass:]，因为该方法将使用默认会话而非 NSURLSession  的实例来注册。
 * @note 自定义的 NSURLProtocol 子类不能用于后台会话。
 */
@property (nullable, copy) NSArray<Class> *protocolClasses;


/** multipathServiceType 一种服务类型，用于指定通过 Wi-Fi 和 蜂窝 接口传输数据的多路径TCP连接策略。
 *
 *  <ul>
 *     <li> NSURLSessionMultipathServiceTypeNone 默认的服务类型，禁用多路径TCP
 *     <li> NSURLSessionMultipathServiceTypeHandover 一种多路径TCP服务，在Wi-Fi和蜂窝网络之间提供无缝切换，以保持连接
 *     <li> NSURLSessionMultipathServiceTypeInteractive 多路径TCP试图使用低延迟接口的一种服务(为可能使用蜂窝数据的延迟敏感、低容量连接指定此选项)
 *     <li> NSURLSessionMultipathServiceTypeAggregate 聚合其他多路径选项容量的服务，以增加吞吐量并最小化延迟(设置此选项将使用大量的蜂窝数据)
 *  </ul>
 *
 * @discussion 多路径TCP是由RFC 6824中的IETF定义的TCP扩展，允许多个接口传输单个数据流；
 *      当用户使用 iOS App 时，他们很可能在Wi-Fi范围内进进出出，切换到蜂窝网络，然后再返回；
 *      该功能允许从Wi-Fi无缝切换到蜂窝网络，使这两个界面更有效，并改善用户体验，提高 App 的性能；
 *      但需要目标服务器启用多路径TCP。
 *
 * 默认配置中，NSURLSession 使用单一 Wi-Fi 网络调用，而不是蜂窝网络； 然而，在启用多路径TCP 时，NSURLSession  会在两个收音机上启动请求，并选择两个中响应更强的那个，并优先使用 Wi-Fi。
 *
 * @note 必须在应用程序的Xcode capability 中设置 Multipath 权限
*/
@property NSURLSessionMultipathServiceType multipathServiceType API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(macos, watchos, tvos);



/** 确定基于此配置的 NSURLSession 中的任务对每台主机进行的同步连接的最大数量。
 * macOS的默认值是6，iOS的默认值是4。
 * 该值限制每个 NSURLSession，如果使用多个 NSURLSession，App 作为一个整体可能会超过这个限制。
 * 此外，根据 App 与网络的连接，NSURLSession 可能使用比该限制更低的限制。
 */
@property NSInteger HTTPMaximumConnectionsPerHost;


/** 是否允许使用HTTP pipelining，默认为 NO
 * @note 此属性确定基于此配置的 NSURLSession 中的任务是否应该使用HTTP pipelining。
 *       还可以通过使用 NSURLRequest 对象创建任务，从而在每个任务基础上启用流水线！
*/
@property BOOL HTTPShouldUsePipelining;

/** 包含在 NSURLSession 中使用的代理信息的字典；
 * 默认值为NULL，使用系统设置
*/
@property (nullable, copy) NSDictionary *connectionProxyDictionary;

/** 是否允许请求路由 expensive networks；默认值为YES */
@property BOOL allowsExpensiveNetworkAccess API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));

/** 是否允许在受限模式下通过网络路由请求，默认值为YES */
@property BOOL allowsConstrainedNetworkAccess API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0));
```
