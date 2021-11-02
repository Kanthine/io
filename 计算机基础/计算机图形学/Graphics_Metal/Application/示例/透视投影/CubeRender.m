//
//  CubeRender.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "CubeRender.h"
#include "Shape3D.h"
#include "MatrixTransform.h"
#include "CameraUtilities.h"

@implementation CubeRender {
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
    
    id<MTLBuffer> _vertexBuffre;
    id<MTLBuffer> _indexBuffer;
    id<MTLBuffer> _uniformBuffer;
    float _rotation;
    float _aspect;
}

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview {
    self = [super init];
    if (self) {
        mtkview.delegate = self;
        mtkview.device = MTLCreateSystemDefaultDevice();
        _device = mtkview.device;
        NSAssert(_device, @"无法获取设备");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexRender_Transform_3D"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"透视投影·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;
        descriptor.vertexBuffers[ShaderParamTypeVertices].mutability = MTLMutabilityImmutable;
        
        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@",error);
        
        _commandQueue = [_device newCommandQueue];
        [self loadBufferDatas];
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    Uniforms uniforms = uniforms_default;
    uniforms.worldMatrix = matrix_multiply(uniforms.worldMatrix, matrix4x4_scale(0.6, 0.6, 0.6));
    uniforms.worldMatrix = matrix_multiply(uniforms.worldMatrix, matrix4x4_rotationZ(_rotation));
    uniforms.worldMatrix = matrix_multiply(uniforms.worldMatrix, matrix4x4_rotationY(_rotation));
    uniforms.viewMatrix = matrix4x4_translation(0, 0, _zPos);
    uniforms.projectionMatrix = matrix_perspective_left_hand(_fov, _aspect, _zNear, _zFar);
    memcpy(_uniformBuffer.contents, &uniforms, sizeof(Uniforms));
    
    _rotation += M_PI_4 / 100.0;
    
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;

    if (descriptor != nil) {
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"透视投影·缓冲池";
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"透视投影·命令编码";
        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        
        ///背面剔除(Backface Culling)，这就是说，每一个三角面其实都只绘制了能看得见的那一面，
        ///所以事实上每一个背面的点只有当它转向摄像机的时候才会被绘制。
        ///这些都是依据你为三角面片指定顶点的顺序来决定的。
        [renderEncoder setCullMode:MTLCullModeFront];
        
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setViewport:(MTLViewport){0,0,_viewportSize.x,_viewportSize.y,0,0.0}];
        
        [renderEncoder setVertexBuffer:_vertexBuffre offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];
        
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:_indexBuffer.length / sizeof(uint16_t) indexType:MTLIndexTypeUInt16 indexBuffer:_indexBuffer indexBufferOffset:0];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
    _aspect = size.width / size.height;
}

#pragma mark - private method

- (void)loadBufferDatas {
    
    Vertex3D vertexDatas[] = {
        {{-1.0, -1.0,  1.0, 1.0},{1, 1, 1, 1}},
        {{1.0, -1.0,  1.0, 1.0},{1, 0, 0, 1}},
        {{1.0,  1.0,  1.0, 1.0},{1, 1, 0, 1}},
        {{-1.0,  1.0,  1.0, 1.0},{0, 1, 0, 1}},
        
        {{-1.0, -1.0, -1.0, 1.0},{0, 0, 1, 1}},
        {{1.0, -1.0, -1.0, 1.0},{1, 0, 1, 1}},
        {{1.0,  1.0, -1.0, 1.0},{0, 0, 0, 1}},
        {{-1.0,  1.0, -1.0, 1.0},{0, 1, 1, 1}},
    };
    
    uint16_t indexs[36] = { 0, 1, 2, 2, 3, 0,  // 前
                      1, 5, 6, 6, 2, 1,   // 右
                      3, 2, 6, 6, 7, 3,   // 上
                      4, 5, 1, 1, 0, 4,   // 下
                      4, 0, 3, 3, 7, 4,   // 左
                      7, 6, 5, 5, 4, 7    // 后
    };
    
    _vertexBuffre = [_device newBufferWithBytes:vertexDatas length:sizeof(vertexDatas) options:MTLResourceStorageModeShared];
    _indexBuffer = [_device newBufferWithBytes:indexs length:sizeof(indexs) options:MTLResourceStorageModeShared];
    _uniformBuffer =  [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
    
    _rotation = 0.0;
    _fov = M_PI * 0.3;
    _zNear = 1.0;
    _zFar = 300.0f;
    _zPos = 3.0;
}

@end

/// 一个矩阵乘以单位矩阵，得到的矩阵是它自身
/// 单位矩阵乘以一个矩阵，得到的矩阵是这个矩阵
