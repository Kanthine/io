//
//  DepthRender.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "DepthRender.h"
#include "ShaderTypes.h"
@import simd;

@implementation DepthRender

{
    id<MTLDevice>              _device;
    id<MTLCommandQueue>        _commandQueue;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLDepthStencilState> _depthState;
    vector_float2            _viewportSize;
}

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if (self) {
        
        /// 设置一个黑色的清晰颜色
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 1);
        
        /// 每个像素使用 32 位浮点值存储深度
        mtkView.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
        
        /// 指示 Metal 清除深度缓冲区中所有深度值为 1.0
        mtkView.clearDepth = 1.0;
        
        mtkView.delegate = self;
        mtkView.device = MTLCreateSystemDefaultDevice();
        _device = mtkView.device;
        NSAssert(_device, @"获取设备失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexShader_depth"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"深度测试·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        /// 启用渲染管道的深度测试
        descriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat;
        /// 标记缓冲区不可变
        descriptor.vertexBuffers[ShaderParamTypeVertices].mutability = MTLMutabilityImmutable;

        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@", error);
        
        /// 配置深度测试
        MTLDepthStencilDescriptor *depthDescriptor = [MTLDepthStencilDescriptor new];
        depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual;
        depthDescriptor.depthWriteEnabled = YES;
        _depthState = [_device newDepthStencilStateWithDescriptor:depthDescriptor];

        _commandQueue = [_device newCommandQueue];
        
        _topVertexDepth = 0.5;
        _leftVertexDepth = 1.0;
        _rightVertexDepth = 0.0;
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil) {
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"深度测试·命令缓冲区";
        
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"深度测试·命令编码器";
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setDepthStencilState:_depthState];
        
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:ShaderParamTypeViewport];
        
        // 灰色四边形，通过 z 设置顶点深度值为 0.5
        const Vertex3D quadVertices[] = {
                    // 像素坐标 (x, y)  剪裁深度 (z)
            { {                 100,                   100, 0.5, 1.0}, { 0.5, 0.5, 0.5, 1 } },
            { {                 100, _viewportSize.y - 100, 0.5, 1.0 }, { 0.5, 0.5, 0.5, 1 } },
            { { _viewportSize.x-100, _viewportSize.y - 100, 0.5, 1.0 }, { 0.5, 0.5, 0.5, 1 } },
            
            { {                 100,                   100, 0.5, 1.0 }, { 0.5, 0.5, 0.5, 1 } },
            { { _viewportSize.x-100, _viewportSize.y - 100, 0.5, 1.0 }, { 0.5, 0.5, 0.5, 1 } },
            { { _viewportSize.x-100,                   100, 0.5, 1.0 }, { 0.5, 0.5, 0.5, 1 } },
        };
        [renderEncoder setVertexBytes:quadVertices
                               length:sizeof(quadVertices)
                              atIndex:ShaderParamTypeVertices];
        //为灰色四边形编码绘制命令
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:6];
        
        /// 白色三角形，点深度值由用户交互设置
        const Vertex3D triangleVertices[] =
        {
            { {                    200, _viewportSize.y - 200, _leftVertexDepth, 1.0  }, { 1, 1, 1, 1 } },
            { {  _viewportSize.x / 2.0,                   200, _topVertexDepth, 1.0   }, { 1, 1, 1, 1 } },
            { {  _viewportSize.x - 200, _viewportSize.y - 200, _rightVertexDepth, 1.0 }, { 1, 1, 1, 1 } }
        };
        
        [renderEncoder setVertexBytes:triangleVertices
                               length:sizeof(triangleVertices)
                              atIndex:ShaderParamTypeVertices];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:3];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
