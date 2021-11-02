//
//  OffscreenRender.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "OffscreenRender.h"
#import "ShaderTypes.h"

@interface OffscreenRender ()

{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLRenderPipelineState> _renderPipeline;
    
    id<MTLRenderPipelineState> _offscreenPipeline;
    id<MTLTexture> _offscreenTexture;
    MTLRenderPassDescriptor *_offscreenRenderPassDescriptor;
    
    vector_float2 _viewportSize;
    float _aspect;
}

@end

@implementation OffscreenRender

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if (self) {
        mtkView.delegate = self;
        mtkView.device = MTLCreateSystemDefaultDevice();
        mtkView.clearColor = MTLClearColorMake(1.0, 0.5, 0.5, 1.0);
        _device = mtkView.device;
        NSAssert(_device, @"无法获取设备");
        
        MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
        textureDescriptor.textureType = MTLTextureType2D;
        textureDescriptor.width = 1024;
        textureDescriptor.height = 1024;
        textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
        textureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
        _offscreenTexture = [_device newTextureWithDescriptor:textureDescriptor];
        NSAssert(_offscreenTexture, @"创建一个纹理");
        
        _offscreenRenderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        _offscreenRenderPassDescriptor.colorAttachments[0].texture = _offscreenTexture;
        _offscreenRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        _offscreenRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0);
        _offscreenRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"渲染管道";
        descriptor.sampleCount = mtkView.sampleCount;
        descriptor.vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        descriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentTextureShader"];
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        descriptor.vertexBuffers[ShaderParamTypeVertices].mutability = MTLMutabilityImmutable;
        NSError *error = nil;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@",error);
        
        descriptor.label = @"离屏·渲染管道";
        descriptor.sampleCount = 1;
        descriptor.vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        descriptor.fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        descriptor.colorAttachments[0].pixelFormat = _offscreenTexture.pixelFormat;
        _offscreenPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_offscreenPipeline, @"离屏·渲染管道创建失败 : %@",error);
        
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil) return;
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"命令缓冲区";
    
    static const float sideLength = 250.0f;
    
    /// 1、离屏渲染一个三角形
    {
        static const Vertex2D triVertices[] =
        {
            { {  sideLength,  -sideLength },  { 1.0, 0.0, 0.0, 1.0 } },
            { { -sideLength,  -sideLength },  { 0.0, 1.0, 0.0, 1.0 } },
            { {         0.0,   sideLength },  { 0.0, 0.0, 1.0, 0.0 } },
        };
        
        id<MTLRenderCommandEncoder> offscreenEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_offscreenRenderPassDescriptor];
        offscreenEncoder.label = @"离屏纹理·命令编码器";
        
        [offscreenEncoder setRenderPipelineState:_offscreenPipeline];
        
        [offscreenEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
        [offscreenEncoder setVertexBytes:triVertices length:sizeof(triVertices) atIndex:ShaderParamTypeVertices];
        [offscreenEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [offscreenEncoder endEncoding];
    }
    
    /// 2、拿到上述步骤的纹理，使用片段着色器贴到四边形上
    {
        static const Vertex2D quadVertices[] =
        {
            { {  sideLength,  -sideLength }, { 0.0, 0.0, 0.0, 0.0 }, { 1.0, 1.0 } },
            { { -sideLength,  -sideLength }, { 0.0, 0.0, 0.0, 0.0 }, { 0.0, 1.0 } },
            { { -sideLength,   sideLength }, { 0.0, 0.0, 0.0, 0.0 }, { 0.0, 0.0 } },
            
            { {  sideLength,  -sideLength }, { 0.0, 0.0, 0.0, 0.0 }, { 1.0, 1.0 } },
            { { -sideLength,   sideLength }, { 0.0, 0.0, 0.0, 0.0 }, { 0.0, 0.0 } },
            { {  sideLength,   sideLength }, { 0.0, 0.0, 0.0, 0.0 }, { 1.0, 0.0 } },
        };
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"纹理·命令编码器";
        [renderEncoder setRenderPipelineState:_renderPipeline];
        
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
        [renderEncoder setVertexBytes:quadVertices length:sizeof(quadVertices) atIndex:ShaderParamTypeVertices];
        [renderEncoder setFragmentTexture:_offscreenTexture atIndex:ShaderParamTypeTextureOutput];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        [renderEncoder endEncoding];
    }
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
    
    /// 注意：渲染出来的纹理贴图由于宽高比的缘故，会被压缩
    ///      可以换算宽高比，实现精确贴图
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _aspect = size.width / size.height;
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
