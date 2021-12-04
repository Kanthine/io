# 编译设置 `MTLCompileOptions`

[MTLCompileOptions](https://developer.apple.com/documentation/metal/mtlcompileoptions?language=objc) Metal 着色器库的编译设置。

```
typedef NS_ENUM(NSInteger, MTLLibraryType) {
    MTLLibraryTypeExecutable = 0,
    MTLLibraryTypeDynamic = 1,
};

@interface MTLCompileOptions : NSObject <NSCopying>

// 预处理配置

/// 编译程序时的预处理器宏列表，默认值为 nil
@property (nullable, readwrite, copy, nonatomic) NSDictionary <NSString *, NSObject *> *preprocessorMacros;

// Math intrinsics options

/// 默认值为 YES，允许编译器对浮点运算执行可能违反 IEEE 754 标准的优化。
@property (readwrite, nonatomic) BOOL fastMathEnabled;

/// 设置用于解释源文件的 Metal 语言版本
@property (readwrite, nonatomic) MTLLanguageVersion languageVersion;

/** 应该将库编译为哪种类型，默认使用 MTLLibraryTypeExecutable
 * MTLLibraryTypeExecutable 适用于构建 kernel、vertex 和 fragment 等类型函数；
 * MTLDynamicLibrary 编译的库用来实例化，未限定的函数可以用作编译其他库的外部依赖项。
 */
@property (readwrite, nonatomic) MTLLibraryType libraryType;

/** 动态库的加载名称
 @property installName
 @discussion The install name is used when a pipeline state is created that depends, directly or indirectly, on a dynamic library.
 The installName is embedded into any other MTLLibrary that links against the compilation result.
 This property should be set such that the dynamic library can be found in the file system at the time a pipeline state is created.
 Specify one of:
 - an absolute path to a file from which the dynamic library can be loaded, or
 - a path relative to @executable_path, where @executable_path is substituted with the directory name from which the MTLLibrary containing the MTLFunction entrypoint used to create the pipeline state is loaded, or
 - a path relative to @loader_path, where @loader_path is substituted with the directory name from which the MTLLibrary with the reference to this installName embedded is loaded.
 The first is appropriate for MTLDynamicLibrary written to the file-system using its serializeToURL:error: method on the current device.
 The others are appropriate when the MTLDynamicLibrary is installed as part of a bundle or app, where the absolute path is not known.
 This property is ignored when the type property is not set to MTLLibraryTypeDynamic.
 This propery should not be null if the property type is set to MTLLibraryTypeDynamic: the compilation will fail in that scenario.
 */
@property (readwrite, nullable, copy, nonatomic) NSString *installName;

/** 一组要链接的动态库，将 installName 嵌入到编译结果中
 * 使用动态库中的函数作为渲染管道的执行函数时，将自动加载动态库；
 * 如果无需加载动态库，直接将该属性置为 nil；
 */
@property (readwrite, nullable, copy, nonatomic) NSArray<id<MTLDynamicLibrary>> *libraries;

/** 默认值为 NO
 * 当为 YES 时，Metal 编译器会查看它编译的所有着色器顶点输出的坐标值，
 * 如果坐标值具有不变性，编译器会保守地编译相应的顶点着色器，以保证 GPU 以相同的方式执行计算；
 * 当 Metal 渲染器包含多个渲染管道，并且需要在每个渲染管道中计算相同的坐标时，需要保持不变。
 */
@property (readwrite, nonatomic) BOOL preserveInvariance;

@end
```
