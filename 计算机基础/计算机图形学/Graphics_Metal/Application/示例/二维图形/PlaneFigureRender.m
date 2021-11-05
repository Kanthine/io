//
//  PlaneFigureRender.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import "PlaneFigureRender.h"
#include "Shape2D.h"

@import simd;

@interface PlaneFigureRender ()
{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
    
    id<MTLBuffer> _vertexBuffer;
}
@end


@implementation PlaneFigureRender

- (instancetype)initWithMTKView:(MTKView *)mtkView {
    self = [super init];
    if (self) {
        mtkView.delegate = self;
        mtkView.device = MTLCreateSystemDefaultDevice();
        _device = mtkView.device;
        NSAssert(_device, @"设备获取失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"2D图像渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        NSError *error = nil;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败: %@",error);
        
        _commandQueue = [_device newCommandQueue];
        self.figureType = PlaneFigureTypeHello;
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view { 
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor != nil) {
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];;
        commandBuffer.label = @"渲染命令缓冲区";
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"命令编码器";
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setViewport:(MTLViewport){0, 0, _viewportSize.x, _viewportSize.y, 0, 1.0}];
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexBuffer.length / sizeof(Vertex2D)];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size { 
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

#pragma mark - setters and getters

- (void)setFigureType:(PlaneFigureType)figureType {
    _figureType = figureType;
    int size = 0;
    Vertex2D *vertexDatas = NULL;
    switch (figureType) {
        case PlaneFigureTypeHello:{
            vertexDatas = hello_2D(&size);
        }break;
        case PlaneFigureTypeTriangle:{
            vertexDatas = equilateralTriangle_2D(300, &size);
        }break;
        case PlaneFigureTypeRhombus:{
            vertexDatas = rhombus_2D(300, &size);
        }break;
        case PlaneFigureTypeCircle:{
            vertexDatas = circle_2D(70, 10.0, &size);
        }break;
        case PlaneFigureTypePolarCoordinate:{
            vertexDatas = polarCoordinates_2D(10, 1, &size);
        }break;
        default:
            break;
    }
    _vertexBuffer = [_device newBufferWithBytes:vertexDatas length:sizeof(Vertex2D) * size options:MTLResourceStorageModeShared];
}

@end

