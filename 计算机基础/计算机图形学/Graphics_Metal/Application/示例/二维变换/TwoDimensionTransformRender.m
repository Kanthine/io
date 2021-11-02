//
//  TwoDimensionTransformRender.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import "TwoDimensionTransformRender.h"
#include "Shape2D.h"
#include "ShaderTypes.h"
#include "MatrixTransform.h"

@import simd;

@implementation TwoDimensionTransformRender {
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
    
    vector_float2 _center;
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _uniformBuffer;
}

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if (self) {
        mtkView.delegate = self;
        mtkView.device = MTLCreateSystemDefaultDevice();
        _device = mtkView.device;
        NSAssert(_device, @"获取设备失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexRender_Transform_2D"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"二维矩阵变换·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@",error);
        
        _commandQueue = [_device newCommandQueue];
        
        int size = 0;
        Vertex2D *vertexDatas = f_2D((vector_float2){100, 160}, 30, &size);
        _vertexBuffer = [_device newBufferWithBytes:vertexDatas length:size * sizeof(Vertex2D) options:MTLResourceStorageModeShared];
        free(vertexDatas);
        
        _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms3x3) options:MTLResourceStorageModeShared];
        
        _scale = 1.0;
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor != nil) {
        Uniforms3x3 uniform;
        uniform.worldMatrix = [self matrixTransform];
        memcpy(_uniformBuffer.contents, &uniform, sizeof(Uniforms3x3));
        
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"命令缓冲区";
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"命令编码器";
        
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setViewport:(MTLViewport){0, 0, _viewportSize.x, _viewportSize.y, 0, 1.0}];
        
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
        [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];

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

- (void)setPrimitiveCenter:(CGPoint)primitiveCenter {
    int size = 0;
    Vertex2D *vertexDatas = f_2D((vector_float2){100, 160}, 30, &size);
    memcpy(_vertexBuffer.contents, vertexDatas, size * sizeof(Vertex2D));
    free(vertexDatas);
}

/** 多个矩阵相乘，不满足交换律
 * 复合矩阵的乘积，对最终图形效果产生直接影响
 *  先平移，再旋转:
 *  先旋转，再平移:
 */
- (matrix_float3x3)matrixTransform {
    matrix_float3x3 transform = matrix3x3_identity();
    transform = matrix_multiply(transform, matrix3x3_scale(_scale, _scale));
    transform = matrix_multiply(transform, rotate_2D(_rotate));
    transform = matrix_multiply(transform, matrix3x3_translation(_tx, _ty));
    return transform;
}

@end

/**
 * 1、绕坐标原点旋转的效果
 *    直接旋转
 * 2、绕自身中心点旋转
 *    2.1、中心点与坐标原点重合
 *         直接旋转
 *    2.2、中心点与坐标原点不重合
 *         先平移至坐标原点，再旋转，再平移至原位置
 * 3、绕任意点旋转
 *    先将任意点平移至坐标原点，再旋转，再平移至原位置
 */
