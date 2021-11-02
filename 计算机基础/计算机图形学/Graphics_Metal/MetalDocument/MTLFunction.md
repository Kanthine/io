# 函数 `MTLFunction`

```
/*!
 @enum MTLFunctionType
 @abstract An identifier for a top-level Metal function.
 @discussion Each location in the API where a program is used requires a function written for that specific usage.
 
 @constant MTLFunctionTypeVertex
 A vertex shader, usable for a MTLRenderPipelineState.
 
 @constant MTLFunctionTypeFragment
 A fragment shader, usable for a MTLRenderPipelineState.
 
 @constant MTLFunctionTypeKernel
 A compute kernel, usable to create a MTLComputePipelineState.
 */
typedef NS_ENUM(NSUInteger, MTLFunctionType) {
    MTLFunctionTypeVertex = 1,
    MTLFunctionTypeFragment = 2,
    MTLFunctionTypeKernel = 3,
    MTLFunctionTypeVisible API_AVAILABLE(macos(11.0), ios(14.0)) = 5,
    MTLFunctionTypeIntersection API_AVAILABLE(macos(11.0), ios(14.0)) = 6,
} API_AVAILABLE(macos(10.11), ios(8.0));


/*!
 @interface MTLFunctionConstant
 @abstract describe an uberShader constant used by the function
 */
MTL_EXPORT API_AVAILABLE(macos(10.12), ios(10.0))
@interface MTLFunctionConstant : NSObject

@property (readonly) NSString *name;
@property (readonly) MTLDataType type;
@property (readonly) NSUInteger index;
@property (readonly) BOOL required;

@end

/*!
 @protocol MTLFunction
 @abstract A handle to intermediate code used as inputs for either a MTLComputePipelineState or a MTLRenderPipelineState.
 @discussion MTLFunction is a single vertex shader, fragment shader, or compute function.  A Function can only be used with the device that it was created against.
*/
API_AVAILABLE(macos(10.11), ios(8.0))
@protocol MTLFunction <NSObject>

/*!
 @property label
 @abstract A string to help identify this object.
 */
@property (nullable, copy, atomic) NSString *label  API_AVAILABLE(macos(10.12), ios(10.0));

/*!
 @property device
 @abstract The device this resource was created against.  This resource can only be used with this device.
 */
@property (readonly) id <MTLDevice> device;

/*!
 @property functionType
 @abstract The overall kind of entry point: compute, vertex, or fragment.
 */
@property (readonly) MTLFunctionType functionType;

/*!
 @property patchType
 @abstract Returns the patch type. MTLPatchTypeNone if it is not a post tessellation vertex shader.
 */
@property (readonly) MTLPatchType patchType API_AVAILABLE(macos(10.12), ios(10.0));

/*!
 @property patchControlPointCount
 @abstract Returns the number of patch control points if it was specified in the shader. Returns -1 if it
 was not specified.
 */
@property (readonly) NSInteger patchControlPointCount API_AVAILABLE(macos(10.12), ios(10.0));

@property (nullable, readonly) NSArray <MTLVertexAttribute *> *vertexAttributes;

/*!
 @property stageInputAttributes
 @abstract Returns an array describing the attributes
 */
@property (nullable, readonly) NSArray <MTLAttribute *> *stageInputAttributes API_AVAILABLE(macos(10.12), ios(10.0));

/*!
 @property name
 @abstract The name of the function in the shading language.
 */
@property (readonly) NSString *name;

/*!
 @property functionConstantsDictionary
 @abstract A dictionary containing information about all function contents, keyed by the constant names.
 */
@property (readonly) NSDictionary<NSString *, MTLFunctionConstant *> *functionConstantsDictionary API_AVAILABLE(macos(10.12), ios(10.0));


/*!
 * @method newArgumentEncoderWithBufferIndex:
 * @abstract Creates an argument encoder which will encode arguments matching the layout of the argument buffer at the given bind point index.
 */
- (id <MTLArgumentEncoder>)newArgumentEncoderWithBufferIndex:(NSUInteger)bufferIndex API_AVAILABLE(macos(10.13), ios(11.0));

/*!
 * @method newArgumentEncoderWithBufferIndex:
 * @abstract Creates an argument encoder which will encode arguments matching the layout of the argument buffer at the given bind point index.
 */
- (id <MTLArgumentEncoder>)newArgumentEncoderWithBufferIndex:(NSUInteger)bufferIndex
                                                                  reflection:(MTLAutoreleasedArgument * __nullable)reflection API_AVAILABLE(macos(10.13), ios(11.0));



/*!
 @property options
 @abstract The options this function was created with.
 */
@property (readonly) MTLFunctionOptions options API_AVAILABLE(macos(11.0), ios(14.0));


@end

typedef NS_ENUM(NSUInteger, MTLLanguageVersion) {
    MTLLanguageVersion1_0 API_AVAILABLE(ios(9.0)) API_UNAVAILABLE(macos, macCatalyst) = (1 << 16),
    MTLLanguageVersion1_1 API_AVAILABLE(macos(10.11), ios(9.0)) = (1 << 16) + 1,
    MTLLanguageVersion1_2 API_AVAILABLE(macos(10.12), ios(10.0)) = (1 << 16) + 2,
    MTLLanguageVersion2_0 API_AVAILABLE(macos(10.13), ios(11.0)) = (2 << 16),
    MTLLanguageVersion2_1 API_AVAILABLE(macos(10.14), ios(12.0)) = (2 << 16) + 1,
    MTLLanguageVersion2_2 API_AVAILABLE(macos(10.15), ios(13.0)) = (2 << 16) + 2,
    MTLLanguageVersion2_3 API_AVAILABLE(macos(11.0), ios(14.0)) = (2 << 16) + 3,

} API_AVAILABLE(macos(10.11), ios(9.0));





/*!
 @constant MTLLibraryErrorDomain
 @abstract NSErrors raised when creating a library.
 */
API_AVAILABLE(macos(10.11), ios(8.0))
MTL_EXTERN NSErrorDomain const MTLLibraryErrorDomain;
```

