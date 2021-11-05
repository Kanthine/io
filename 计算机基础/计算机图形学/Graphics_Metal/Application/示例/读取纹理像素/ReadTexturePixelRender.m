//
//  ReadTexturePixelRender.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/10.
//

#import "ReadTexturePixelRender.h"
#import "ShaderTypes.h"

@interface ReadTexturePixelRender ()

{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
    
    id<MTLBuffer> _readBuffer;
    MTKView *_mtkView;
    BOOL _drewSceneForReadThisFrame;
}

@end

@implementation ReadTexturePixelRender

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview {
    self = [super init];
    if (self) {
        mtkview.delegate = self;
        mtkview.device = MTLCreateSystemDefaultDevice();
        mtkview.framebufferOnly = NO;
        ((CAMetalLayer *)mtkview.layer).allowsNextDrawableTimeout = NO;
        mtkview.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        mtkview.clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0);
        _mtkView = mtkview;
        
        _device = mtkview.device;
        NSAssert(_device, @"获取设备失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexShader_depth"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"从绘制纹理中读取像素数据·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;
        
        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败: %@",error);
        
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

#pragma mark - private method

- (void)drawScene:(MTKView *)view withCommandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (!descriptor || !commandBuffer) return;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    renderEncoder.label = @"渲染命令编码器";
    [renderEncoder setRenderPipelineState:_renderPipeline];
    [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
    
    /// 绘制顶点数据
    {
        const Vertex2D quadVertices[] =
        {
            { {                0,               0 }, { 1, 0, 0, 1 } },
            { {  _viewportSize.x,               0 }, { 0, 1, 0, 1 } },
            { {  _viewportSize.x, _viewportSize.y }, { 0, 0, 1, 1 } },

            { {  _viewportSize.x, _viewportSize.y }, { 0, 0, 1, 1 } },
            { {                0, _viewportSize.y }, { 1, 1, 1, 1 } },
            { {                0,               0 }, { 1, 0, 0, 1 } },
        };

        [renderEncoder setVertexBytes:quadVertices
                               length:sizeof(quadVertices)
                              atIndex:ShaderParamTypeVertices];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:6];
    }
    
    if (_drawOutline) {
        const float x = _outlineRect.origin.x;
        const float y = _outlineRect.origin.y;
        const float w = _outlineRect.size.width;
        const float h = _outlineRect.size.height;
        const Vertex2D outlineVertices[] = {
            { {   x,   y },  { 1, 1, 1, 1 } }, // 左下角
            { {   x, y+h },  { 1, 1, 1, 1 } }, // 左上角
            { { x+w, y+h },  { 1, 1, 1, 1 } }, // 右上角
            { { x+w,   y },  { 1, 1, 1, 1 } }, // 右下角
            { {   x,   y },  { 1, 1, 1, 1 } }, // 左下角(完成线带)
        };
        [renderEncoder setVertexBytes:outlineVertices
                               length:sizeof(outlineVertices)
                              atIndex:ShaderParamTypeVertices];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeLineStrip
                          vertexStart:0
                          vertexCount:5];
    }
    [renderEncoder endEncoding];
}

// 本项目只支持 MTLPixelFormatBGRA8Unorm 和  MTLPixelFormatR32Uint 格式
static inline uint32_t sizeofPixelFormat(NSUInteger format) {
    return ((format) == MTLPixelFormatBGRA8Unorm ? 4 :
            (format) == MTLPixelFormatR32Uint    ? 4 : 0);
}

- (id<MTLBuffer>)readPixelsWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
                                 fromTexture:(id<MTLTexture>)texture
                                    atOrigin:(MTLOrigin)origin
                                    withSize:(MTLSize)size {
    MTLPixelFormat pixelFormat = texture.pixelFormat;
    switch (pixelFormat) {
        case MTLPixelFormatBGRA8Unorm:
        case MTLPixelFormatR32Uint:
            break;
        default:
            NSAssert(0, @"Unsupported pixel format: 0x%X.", (uint32_t)pixelFormat);
    }
    
    /// 验证是否读取纹理区域之外的像素
    NSAssert(origin.x >= 0, @"Reading outside the left texture bounds.");
    NSAssert(origin.y >= 0, @"Reading outside the top texture bounds.");
    NSAssert((origin.x + size.width)  < texture.width,  @"Reading outside the right texture bounds.");
    NSAssert((origin.y + size.height) < texture.height, @"Reading outside the bottom texture bounds.");
    NSAssert(!((size.width == 0) || (size.height == 0)), @"Reading zero-sized area: %dx%d.", (uint32_t)size.width, (uint32_t)size.height);

    /// 计算待拷贝的像素总字节数
    NSUInteger bytesPerPixel = sizeofPixelFormat(texture.pixelFormat);
    NSUInteger bytesPerRow   = size.width * bytesPerPixel;
    NSUInteger bytesPerImage = size.height * bytesPerRow;
    /// 拷贝像素数据至缓冲区
    _readBuffer = [texture.device newBufferWithLength:bytesPerImage options:MTLResourceStorageModeShared];
    NSAssert(_readBuffer, @"Failed to create buffer for %zu bytes.", bytesPerImage);
    
    // 将所选区域的像素数据复制到具有共享存储模式的 Metal 缓冲区，使CPU可以访问该缓冲区
    id <MTLBlitCommandEncoder> blitEncoder = [commandBuffer blitCommandEncoder];
    
    [blitEncoder copyFromTexture:texture
                     sourceSlice:0
                     sourceLevel:0
                    sourceOrigin:origin
                      sourceSize:size
                        toBuffer:_readBuffer
               destinationOffset:0
          destinationBytesPerRow:bytesPerRow
        destinationBytesPerImage:bytesPerImage];

    [blitEncoder endEncoding];

    [commandBuffer commit];
    
    // 阻塞CPU线程, 直到 GPU 完成 blit 传递，才能从 _readBuffer 读取数据
    [commandBuffer waitUntilCompleted];

    /// 阻塞线程，会导致程序性能的下降，开发者应最大化 CPU 和 GPU 的并行执行
    /// 可以使用异步处理 [commandBuffer addCompletedHandler:...]
    return _readBuffer;
}

#pragma mark - public method

- (nonnull TagImageParser *)renderAndReadPixelsFromView:(nonnull MTKView *)view withRegion:(CGRect)region {
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    // 编码一个渲染通道来渲染图像到可绘制纹理
    [self drawScene:view withCommandBuffer:commandBuffer];
    _drewSceneForReadThisFrame = YES;
    
    id<MTLTexture> readTexture = view.currentDrawable.texture;
    MTLOrigin readOrigin = MTLOriginMake(region.origin.x, region.origin.y, 0);
    MTLSize readSize = MTLSizeMake(region.size.width, region.size.height, 1);
    
    const id<MTLBuffer> pixelBuffer = [self readPixelsWithCommandBuffer:commandBuffer
                                                            fromTexture:readTexture
                                                               atOrigin:readOrigin
                                                               withSize:readSize];
    
    PixelBGRA8Unorm *pixels = (PixelBGRA8Unorm *)pixelBuffer.contents;
    
    // 拿到像素数据创建一个新图像
    NSData *data = [[NSData alloc] initWithBytes:pixels length:pixelBuffer.length];
    TagImageParser *image = [[TagImageParser alloc] initWithBGRA8UnormData:data
                                                                     width:readSize.width
                                                                    height:readSize.height];
    return image;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor == nil || _drewSceneForReadThisFrame) return;
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    [self drawScene:view withCommandBuffer:commandBuffer];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
