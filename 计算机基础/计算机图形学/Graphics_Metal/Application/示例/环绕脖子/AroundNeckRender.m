//
//  AroundNeckRender.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "AroundNeckRender.h"
#include "Shape3D.h"
#include "MatrixTransform.h"
#include "CameraUtilities.h"

@implementation AroundNeckRender {
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
    
    id<MTLTexture> _texture;

    id<MTLBuffer> _vertexBuffrer;
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
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentTextureShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"环绕脖子·渲染管道";
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
    uniforms.worldMatrix = matrix_multiply(uniforms.worldMatrix, matrix4x4_scale(0.2, 0.2, 0.2));
    uniforms.worldMatrix = matrix_multiply(uniforms.worldMatrix, matrix4x4_rotationY(_rotation));
    uniforms.viewMatrix = matrix_look_at_left_hand(self.tx, self.ty, self.tz, self.ax, self.ay, self.az, 0, 1, 0);
    uniforms.projectionMatrix = matrix_perspective_left_hand(_fov, _aspect, _zNear, _zFar);
    memcpy(_uniformBuffer.contents, &uniforms, sizeof(Uniforms));
    
    _rotation += M_PI_4 / 100.0;
    
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;

    if (descriptor != nil) {
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        commandBuffer.label = @"环绕脖子·缓冲池";
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"环绕脖子·命令编码";
        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [renderEncoder setCullMode:MTLCullModeFront];
        
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setViewport:(MTLViewport){0,0,_viewportSize.x,_viewportSize.y,0,0.0}];
        
        [renderEncoder setVertexBuffer:_vertexBuffrer offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];
        [renderEncoder setFragmentTexture:_texture
                                  atIndex:ShaderParamTypeTextureOutput];
        
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
    
    int vertexSize = 0, indexSize = 0;
    UInt16 *indexs = NULL;
    Vertex3D *vertexs = cylinder_3D(1, 5, &vertexSize, &indexs, &indexSize);
    _vertexBuffrer = [_device newBufferWithBytes:vertexs length:vertexSize * sizeof(Vertex3D) options:MTLResourceStorageModeShared];
    _indexBuffer = [_device newBufferWithBytes:indexs length:indexSize * sizeof(UInt16) options:MTLResourceStorageModeShared];
    
    _texture = [self loadTextureUsingMetalKit:[NSBundle.mainBundle URLForResource:@"text" withExtension:@"png"] device:_device];
    
    _uniformBuffer =  [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
    
    _fov = M_PI * 0.3;
    _zNear = 1.0;
    _zFar = 300.0f;
    _zPos = 3.0;
    _rotation = 0.0;
    
    _tx = 1.5;
    _ty = 0.85;
    _tz = 1.0;
    _ax = -0.02;
    _ay = 0.5;
    _az = -0.13;
}


- (id<MTLTexture>)loadTextureUsingMetalKit:(NSURL *)url device: (id<MTLDevice>) device {
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice: device];
    id<MTLTexture> texture = [loader newTextureWithContentsOfURL:url options:nil error:nil];
    NSAssert(texture, @"Failed to create the texture from %@", url.absoluteString);
    return texture;
}

@end
