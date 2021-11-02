# 编译设置 `MTLCompileOptions`

[MTLCompileOptions](https://developer.apple.com/documentation/metal/mtlcompileoptions?language=objc) Metal 着色器库的编译设置。

```
typedef NS_ENUM(NSInteger, MTLLibraryType) {
    MTLLibraryTypeExecutable = 0,
    MTLLibraryTypeDynamic = 1,
} API_AVAILABLE(macos(11.0), ios(14.0));

MTL_EXPORT API_AVAILABLE(macos(10.11), ios(8.0))
@interface MTLCompileOptions : NSObject <NSCopying>

// Pre-processor options

/*!
 @property preprocessorNames
 @abstract List of preprocessor macros to consider to when compiling this program. Specified as key value pairs, using a NSDictionary. The keys must be NSString objects and values can be either NSString or NSNumber objects.
 @discussion The default value is nil.
 */
@property (nullable, readwrite, copy, nonatomic) NSDictionary <NSString *, NSObject *> *preprocessorMacros;

// Math intrinsics options

/*!
 @property fastMathEnabled
 @abstract If YES, enables the compiler to perform optimizations for floating-point arithmetic that may violate the IEEE 754 standard. It also enables the high precision variant of math functions for single precision floating-point scalar and vector types. fastMathEnabled defaults to YES.
 */
@property (readwrite, nonatomic) BOOL fastMathEnabled;

/*!
 @property languageVersion
 @abstract set the metal language version used to interpret the source.
 */
@property (readwrite, nonatomic) MTLLanguageVersion languageVersion API_AVAILABLE(macos(10.11), ios(9.0));

/*!
 @property type
 @abstract Which type the library should be compiled as. The default value is MTLLibraryTypeExecutable.
 @discussion MTLLibraryTypeExecutable is suitable to build a library of "kernel", "vertex" and "fragment" qualified functions.
 MTLLibraryType is suitable when the compilation result will instead be used to instantiate a MTLDynamicLibrary.
 MTLDynamicLibrary contains no qualified functions, but it's unqualified functions and variables can be used as an external dependency for compiling other libraries.
*/
@property (readwrite, nonatomic) MTLLibraryType libraryType API_AVAILABLE(macos(11.0), ios(14.0));

/*!
 @property installName
 @abstract The install name of this dynamic library.
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
@property (readwrite, nullable, copy, nonatomic) NSString *installName API_AVAILABLE(macos(11.0), ios(14.0));

/*!
 @property libraries
 @abstract A set of MTLDynamicLibrary instances to link against.
 The installName of the provided MTLDynamicLibrary is embedded into the compilation result.
 When a function from the resulting MTLLibrary is used (either as an MTLFunction, or as an to create a pipeline state, the embedded install names are used to automatically load the MTLDynamicLibrary instances.
 This property can be null if no libraries should be automatically loaded, either because the MTLLibrary has no external dependencies, or because you will use insertLibraries to specify the libraries to use at pipeline creation time.
*/
@property (readwrite, nullable, copy, nonatomic) NSArray<id<MTLDynamicLibrary>> *libraries API_AVAILABLE(macos(11.0), ios(14.0));


/*!
 @property preserveInvariance
 @abstract If YES,  set the compiler to compile shaders to preserve invariance.  The default is false.
 */
@property (readwrite, nonatomic) BOOL preserveInvariance API_AVAILABLE(macos(11.0), macCatalyst(14.0), ios(13.0));
@end
```
