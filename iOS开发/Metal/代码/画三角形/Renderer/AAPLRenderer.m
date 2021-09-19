@import simd;
@import MetalKit;

#import "AAPLRenderer.h"

// Header shared between C code here, which executes Metal API commands, and .metal files, which uses these types as inputs to the shaders.
//
#import "AAPLShaderTypes.h"

// 渲染器
@implementation AAPLRenderer {
    id<MTLDevice> _device; /// GPU
    id<MTLRenderPipelineState> _pipelineState; // 渲染管道
    id<MTLCommandQueue> _commandQueue;
    vector_uint2 _viewportSize; // 视图的当前大小，用作顶点着色器的输入
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView {
    self = [super init];
    if(self) {
        NSError *error;
        _device = mtkView.device;
        
        /// 加载默认库，获取自定义的顶点着色器、片段着色器
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"]; /// 顶点着色器
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"]; /// 片段着色器

        // 渲染管道配置项
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction; /// 顶点着色器
        pipelineStateDescriptor.fragmentFunction = fragmentFunction; /// 片段着色器
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        
        /// 如果管道描述符没有配置正确，渲染管可能会创建失败
        /// 使用Xcode debug 程序时，默认开启 Metal API 验证，获取详细的出错信息
        NSAssert(_pipelineState, @"Failed to create pipeline state: %@", error);
        _commandQueue = [_device newCommandQueue];
    }

    return self;
}

/// 当视图改变方向或调整大小时调用
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    // 保存绘图的大小，传递给顶点着色器
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

/// 当视图更新内容,需要渲染时调用
- (void)drawInMTKView:(nonnull MTKView *)view {
    static const AAPLVertex triangleVertices[] =
    {
        // 2D 位置,           RGBA colors
        { {  250,  -250 }, { 1, 0, 0, 1 } },
        { { -250,  -250 }, { 0, 1, 0, 1 } },
        { {    0,   250 }, { 0, 0, 1, 1 } },
    };

    /// 为当前绘制的每个渲染管道创建一个命令缓冲池
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    // Obtain a renderPassDescriptor generated from the view's drawable textures.
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil) {
        // Create a render command encoder.
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";

        // 设置绘制对象的区域
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0 }];
        
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        // Pass in the parameter data.
        [renderEncoder setVertexBytes:triangleVertices
                               length:sizeof(triangleVertices)
                              atIndex:AAPLVertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:AAPLVertexInputIndexViewportSize];
        
        // 绘制三角形命令
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:3];
        
        [renderEncoder endEncoding];
        
        // Schedule a present once the framebuffer is complete using the current drawable.
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    // Finalize rendering here & push the command buffer to the GPU.
    [commandBuffer commit];
}

@end
