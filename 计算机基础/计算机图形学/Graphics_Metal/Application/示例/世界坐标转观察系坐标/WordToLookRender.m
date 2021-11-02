//
//  WordToLookRender.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "WordToLookRender.h"
#include "Shape3D.h"
#include "MatrixTransform.h"
#include "CameraUtilities.h"

@implementation WordToLookRender {
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    float _aspect;
    float _rotation;

    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _uniformBuffer;
}

- (instancetype)initWithMTKView:(MTKView *)mtkview {
    self = [super init];
    if (self) {
        mtkview.delegate = self;
        mtkview.device = MTLCreateSystemDefaultDevice();
        _device = mtkview.device;
        NSAssert(_device, @"设备获取失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexRender_Transform_3D"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"世界坐标转观察系坐标·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;

        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@",error);
        
        _commandQueue = [_device newCommandQueue];
        
        _rotation = 0;
        [self loadVertexDatas];
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (Uniforms)getUniformsMatrix:(BOOL)isCameraRemove {
    Uniforms uniform = uniforms_default;
    float scale = 2 / 210.0;
    uniform.worldMatrix = matrix_multiply(uniform.worldMatrix, matrix4x4_scale(scale, -scale, scale));
    
    if (isCameraRemove) { /// 眼睛绕着物体转动
        uniform.viewMatrix = lookAt(self.tx, self.ty, self.tz, self.ax, self.ay, self.az);
        uniform.viewMatrix = matrix_multiply(uniform.viewMatrix, matrix4x4_rotationY(_rotation));
    }else{ /// 物体绕着眼睛转动
        uniform.worldMatrix = matrix_multiply(uniform.worldMatrix, matrix4x4_rotationY(_rotation));
        uniform.viewMatrix = lookAt(self.tx, self.ty, self.tz, self.ax, self.ay, self.az);
    }
    
    uniform.projectionMatrix = matrix_perspective_left_hand(0.8 * M_PI, _aspect, 1.0, 100);
    _rotation -= 0.01;
    return uniform;
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    Uniforms uniform = [self getUniformsMatrix:NO];
    memcpy(_uniformBuffer.contents, &uniform, sizeof(Uniforms));
    
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor != nil) {
        
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"命令缓冲区";
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"世界坐标转观察系坐标·渲染编码";
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [renderEncoder setCullMode:MTLCullModeFront];
        
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexBuffer.length / sizeof(Vertex3D)];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _aspect = size.width / size.height;
}


- (void)loadVertexDatas {
    int size = 0;
    Vertex3D *vertexs = fMore_3D(10, &size);
    _vertexBuffer = [_device newBufferWithBytes:vertexs length:size * sizeof(Vertex3D) options:MTLResourceStorageModeShared];
    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
    free(vertexs);
    
    _tz = -2.2;
}

@end
