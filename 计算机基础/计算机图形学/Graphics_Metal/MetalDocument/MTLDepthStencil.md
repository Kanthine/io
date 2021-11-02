# 深度测试

```
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MTLCompareFunction) {
    MTLCompareFunctionNever = 0,
    MTLCompareFunctionLess = 1,
    MTLCompareFunctionEqual = 2,
    MTLCompareFunctionLessEqual = 3,
    MTLCompareFunctionGreater = 4,
    MTLCompareFunctionNotEqual = 5,
    MTLCompareFunctionGreaterEqual = 6,
    MTLCompareFunctionAlways = 7,
} API_AVAILABLE(macos(10.11), ios(8.0));

typedef NS_ENUM(NSUInteger, MTLStencilOperation) {
    MTLStencilOperationKeep = 0,
    MTLStencilOperationZero = 1,
    MTLStencilOperationReplace = 2,
    MTLStencilOperationIncrementClamp = 3,
    MTLStencilOperationDecrementClamp = 4,
    MTLStencilOperationInvert = 5,
    MTLStencilOperationIncrementWrap = 6,
    MTLStencilOperationDecrementWrap = 7,
} API_AVAILABLE(macos(10.11), ios(8.0));
```


`Stencil`:模版!

```
@interface MTLStencilDescriptor : NSObject <NSCopying>

@property (nonatomic) MTLCompareFunction stencilCompareFunction;

/// 第一步为 模版测试，测试失败时的操作
@property (nonatomic) MTLStencilOperation stencilFailureOperation;

/// 模版测试通过，接着深度测试，深度测试失败时的操作
@property (nonatomic) MTLStencilOperation depthFailureOperation;

/// 如果模版测试、深度测试都通过，接下来的操作
@property (nonatomic) MTLStencilOperation depthStencilPassOperation;

@property (nonatomic) uint32_t readMask;
@property (nonatomic) uint32_t writeMask;

@end

@interface MTLDepthStencilDescriptor : NSObject <NSCopying>

/*默认为MTLCompareFuncAlways，有效地跳过深度测试*/
/* Defaults to MTLCompareFuncAlways, which effectively skips the depth test */
@property (nonatomic) MTLCompareFunction depthCompareFunction;

/// 默认为NO，不执行深度写入
@property (nonatomic, getter=isDepthWriteEnabled) BOOL depthWriteEnabled;

/// 模板状态分前模和后模。通过给前后两者分配相同的 MTLStencilDescriptor，可以使前后两者跟踪相同的状态
@property (copy, nonatomic, null_resettable) MTLStencilDescriptor *frontFaceStencil;
@property (copy, nonatomic, null_resettable) MTLStencilDescriptor *backFaceStencil;

/// 标识符，用于调试程序
@property (nullable, copy, nonatomic) NSString *label;

@end

/// 设备指定的编译深度/模板状态对象
@protocol MTLDepthStencilState <NSObject>

/// 标识符，用于调试程序
@property (nullable, readonly) NSString *label;

/// 持有创建该资源的设备
@property (readonly) id <MTLDevice> device;

@end
```
