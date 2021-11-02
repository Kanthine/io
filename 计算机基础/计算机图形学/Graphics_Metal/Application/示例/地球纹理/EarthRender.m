//
//  EarthRender.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import "EarthRender.h"
#include "Shape3D.h"
#include "MatrixTransform.h"
#include "CameraUtilities.h"

@implementation EarthRender {
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    
    float _rotation;

    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
    id<MTLBuffer> _uniformBuffer;
    
    id<MTLTexture> _texture;
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
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentTextureShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"地球纹理·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;

        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@",error);
        
        _commandQueue = [_device newCommandQueue];
        
        _rotation = 0;
        int vertexSize = 0, indexSize = 0;
        UInt16 *indexs = NULL;
        Vertex3D *vertexs = sphere_3D_indexs(1, 100, &vertexSize, &indexs, &indexSize);
        _vertexBuffer = [_device newBufferWithBytes:vertexs length:vertexSize * sizeof(Vertex3D) options:MTLResourceStorageModeShared];
        _indexBuffer = [_device newBufferWithBytes:indexs length:indexSize * sizeof(UInt16) options:MTLResourceStorageModeShared];
        _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
        free(vertexs);
        free(indexs);
        
        _texture = [self loadTextureUsingMetalKit:[NSBundle.mainBundle URLForResource:@"earthMap" withExtension:@"jpg"] device:_device];
    }
    return self;
}

- (id<MTLTexture>)loadTextureUsingMetalKit:(NSURL *)url device: (id<MTLDevice>) device {
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice: device];
    id<MTLTexture> texture = [loader newTextureWithContentsOfURL:url options:nil error:nil];
    NSAssert(texture, @"Failed to create the texture from %@", url.absoluteString);
    return texture;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    Uniforms uniform = uniforms_default;
    uniform.worldMatrix = matrix_multiply(uniform.worldMatrix, matrix4x4_scale(0.6, 0.6, 0.6));
    uniform.worldMatrix = matrix_multiply(uniform.worldMatrix, matrix4x4_rotationY(_rotation));
    memcpy(_uniformBuffer.contents, &uniform, sizeof(Uniforms));
    _rotation += 0.01;
    
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor != nil) {
        
        id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"地球纹理·渲染编码";
        [renderEncoder setRenderPipelineState:_renderPipeline];
        
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];
        [renderEncoder setFragmentTexture:_texture
                                  atIndex:ShaderParamTypeTextureOutput];
        
        [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:_indexBuffer.length / sizeof(uint16_t) indexType:MTLIndexTypeUInt16 indexBuffer:_indexBuffer indexBufferOffset:0];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {}

@end
