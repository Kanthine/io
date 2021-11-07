//
//  OBJ_Render_4.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import "OBJ_Render_4.h"
#import "MetalMesh.h"
#import "ShaderTypes.h"
#include "CameraUtilities.h"
#include "MatrixTransform.h"

@interface OBJ_Render_4 ()

{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    
    id<MTLDepthStencilState> _depthState;
    NSArray<MetalMesh *> *_meshes;
    MTLVertexDescriptor *_vertexDescriptor;
    
    id<MTLBuffer> _uniformBuffer;
    float _rotation; /// 做旋转动效
    float _aspect;
}

@end

@implementation OBJ_Render_4

- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if (self) {
        mtkView.sampleCount               = 1;/// 采样数
        mtkView.colorPixelFormat          = MTLPixelFormatBGRA8Unorm_sRGB;
        mtkView.depthStencilPixelFormat   = MTLPixelFormatDepth32Float_Stencil8;
        _device = mtkView.device;
        _commandQueue = [_device newCommandQueue];
        _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];

        _vertexDescriptor = [[MTLVertexDescriptor alloc] init];
        _vertexDescriptor.attributes[VertexAttributePosition].format       = MTLVertexFormatFloat3;
        _vertexDescriptor.attributes[VertexAttributePosition].offset       = 0;
        _vertexDescriptor.attributes[VertexAttributePosition].bufferIndex  = 0;
        _vertexDescriptor.attributes[VertexAttributeTexcoord].format       = MTLVertexFormatFloat2;
        _vertexDescriptor.attributes[VertexAttributeTexcoord].offset       = 12;
        _vertexDescriptor.attributes[VertexAttributeTexcoord].bufferIndex  = 0;
        _vertexDescriptor.attributes[VertexAttributeNormal].format = MTLVertexFormatHalf4;
        _vertexDescriptor.attributes[VertexAttributeNormal].offset = 20;
        _vertexDescriptor.attributes[VertexAttributeNormal].bufferIndex = 0;
        _vertexDescriptor.layouts[0].stride         = 44;
        _vertexDescriptor.layouts[0].stepRate       = 1;
        _vertexDescriptor.layouts[0].stepFunction   = MTLVertexStepFunctionPerVertex;
        
        NSError *error = NULL;
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"ChromePipeline";
        pipelineStateDescriptor.vertexDescriptor = _vertexDescriptor;
        pipelineStateDescriptor.sampleCount = mtkView.sampleCount;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        pipelineStateDescriptor.vertexFunction =
            [defaultLibrary newFunctionWithName:@"vertexTransform_Uniform_3"];
        pipelineStateDescriptor.fragmentFunction =
            [defaultLibrary newFunctionWithName:@"fragmentChromeLighting_4"];
        pipelineStateDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat;
        pipelineStateDescriptor.stencilAttachmentPixelFormat =  mtkView.depthStencilPixelFormat;
        _renderPipeline  =
            [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        NSAssert(_renderPipeline, @"Failed to create pipeline state: %@", error);
        
        MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
        depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
        depthStateDesc.depthWriteEnabled    = YES;
        _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
        
        [self loadAssetsWithMetalKitView:mtkView];
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor == nil) return;
    
    [self updateGameState];
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"OBJ·命令缓冲区";
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    renderEncoder.label = @"OBJ·命令编码器";

    [renderEncoder setRenderPipelineState:_renderPipeline];
    // 添加上下文信息到 GPU 帧捕获工具
    [renderEncoder pushDebugGroup:@"DrawActors"];
    [renderEncoder setCullMode:MTLCullModeBack];
    [renderEncoder setDepthStencilState:_depthState];

    [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];
    
    for (MetalMesh *mesh in _meshes) {
        MTKMesh *metalKitMesh = mesh.metalKitMesh;
        
        // 设置网格的顶点缓冲区数据
        for (NSUInteger bufferIndex = 0;
             bufferIndex < metalKitMesh.vertexBuffers.count;
             bufferIndex++) {
            MTKMeshBuffer *vertexBuffer = metalKitMesh.vertexBuffers[bufferIndex];
            if((NSNull*)vertexBuffer != [NSNull null]) {
                [renderEncoder setVertexBuffer: vertexBuffer.buffer
                                        offset: vertexBuffer.offset
                                       atIndex: bufferIndex];
            }
        }

        //绘制网格的每个子网格
        for(MetalSubmesh *submesh in mesh.submeshes) {
            /// 从渲染管道读取/采样的纹理
            id<MTLTexture> tex;

            tex = submesh.textures[TextureIndexBaseColor];
            if ((NSNull*)tex != [NSNull null]) {
                [renderEncoder setFragmentTexture:tex atIndex:TextureIndexBaseColor];
            }

            tex = submesh.textures [TextureIndexNormal];
            if ((NSNull*)tex != [NSNull null])
            {
                [renderEncoder setFragmentTexture:tex atIndex:TextureIndexNormal];
            }

            tex = submesh.textures[TextureIndexSpecular];
            if ((NSNull*)tex != [NSNull null])
            {
                [renderEncoder setFragmentTexture:tex atIndex:TextureIndexSpecular];
            }
            [renderEncoder setFragmentBuffer:_uniformBuffer offset:0 atIndex:ShaderParamTypeUniforms];

            MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

            [renderEncoder drawIndexedPrimitives:metalKitSubmesh.primitiveType
                                      indexCount:metalKitSubmesh.indexCount
                                       indexType:metalKitSubmesh.indexType
                                     indexBuffer:metalKitSubmesh.indexBuffer.buffer
                               indexBufferOffset:metalKitSubmesh.indexBuffer.offset];
        }
    }

    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _aspect = size.width / size.height;
}

#pragma mark - private method

- (void)updateGameState {
    Uniforms uniform = uniforms_default;
    uniform.worldMatrix = matrix4x4_rotationY(_rotation); /// 从物体坐标转到空间坐标
    uniform.viewMatrix = lookAt(0, 0.2, -2.5, 0.2, 0, 0);     /// 从空间坐标转到观察坐标
    uniform.projectionMatrix = matrix_perspective_left_hand(0.32 * M_PI, _aspect, 1.0, 1500.0f); /// 从观察坐标转到透视坐标
    _rotation += 0.002f;
    
    // 平行光
    uniform.directionalLightDirection = (vector_float3){-1.0,-1.0,-1.0};
    uniform.directionalLightColor = (vector_float3){0.8,0.8,0.8};
    
    uniform.IL = 10.0f;
    uniform.Kd = 0.1f;
    
    uniform.Ks = 0.9f;
    uniform.shininess = 15.0f;
    
    uniform.cameraPos = (vector_float3){0,0.2,-2.5};

    memcpy(_uniformBuffer.contents, &uniform, sizeof(Uniforms));
}

- (void)loadAssetsWithMetalKitView:(nonnull MTKView*)mtkView {
    MDLVertexDescriptor *modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(_vertexDescriptor);
    modelIOVertexDescriptor.attributes[VertexAttributePosition].name  = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[VertexAttributeTexcoord].name  = MDLVertexAttributeTextureCoordinate;
    modelIOVertexDescriptor.attributes[VertexAttributeNormal].name  = MDLVertexAttributeNormal;

    NSURL *modelFileURL = [[NSBundle mainBundle] URLForResource:@"Temple.obj" withExtension:nil];
    NSAssert(modelFileURL,@"Could not find model file (%@) in bundle",modelFileURL.absoluteString);

    NSError *error = NULL;
    MDLAxisAlignedBoundingBox templeAabb;
    _meshes = [MetalMesh newMeshesFromUrl:modelFileURL
                 modelIOVertexDescriptor: modelIOVertexDescriptor
                             metalDevice: _device
                                   error: &error
                                    aabb: templeAabb];
    NSAssert(_meshes, @"Could not create sphere meshes: %@", error);
}

@end
