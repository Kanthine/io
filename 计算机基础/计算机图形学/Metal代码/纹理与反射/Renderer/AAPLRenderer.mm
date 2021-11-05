#import <ModelIO/ModelIO.h>
#import <MetalKit/MetalKit.h>
#import <vector>
#import "AAPLRenderer.h"
#import "AAPLMesh.h"
#import "AAPLMathUtilities.h"
#import "AAPLShaderTypes.h"
#include "AAPLRendererUtils.h"

static const NSUInteger    MaxBuffersInFlight       = 3;  // 帧缓冲区的最大数量
static const NSUInteger    MaxActors                = 32; // 最多有几个视角
static const NSUInteger    MaxVisibleFaces          = 5;  // 最多可以同时看到多少个面
static const NSUInteger    CubemapResolution        = 256;
static const vector_float3 SceneCenter              = (vector_float3){0.f, -250.f, 1000.f};
static const vector_float3 CameraDistanceFromCenter = (vector_float3){0.f, 300.f, -550.f};
static const vector_float3 CameraRotationAxis       = (vector_float3){0,1,0};
static const float         CameraRotationSpeed      = 0.0025f;

@implementation AAPLRenderer

{
    dispatch_semaphore_t _inFlightSemaphore;
    id<MTLDevice>       _device;
    id<MTLCommandQueue> _commandQueue;

    // 在缓冲区数组中，当前索引
    uint8_t _uniformBufferIndex;

    // CPU app-specific data
    Camera                           _cameraFinal;
    CameraProbe                      _cameraReflection; /// 反射视角
    AAPLActorData *                  _reflectiveActor;  /// 反射
    NSMutableArray <AAPLActorData*>* _actorData;

    // GPU 缓冲区
    id<MTLBuffer> _frameParamsBuffers                [MaxBuffersInFlight]; // frame-constant parameters
    id<MTLBuffer> _viewportsParamsBuffers_final      [MaxBuffersInFlight]; // frame-constant parameters, final viewport
    id<MTLBuffer> _viewportsParamsBuffers_reflection [MaxBuffersInFlight]; // frame-constant parameters, probe's viewports
    id<MTLBuffer> _actorsParamsBuffers               [MaxBuffersInFlight]; // per-actor parameters
    id<MTLBuffer> _instanceParamsBuffers_final       [MaxBuffersInFlight]; // per-instance parameters for final pass
    id<MTLBuffer> _instanceParamsBuffers_reflection  [MaxBuffersInFlight]; // per-instance parameters for reflection pass
    
    id<MTLDepthStencilState> _depthState;
    id<MTLTexture>           _reflectionCubeMap;
    id<MTLTexture>           _reflectionCubeMapDepth;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView {
    self = [super init];
    if(self) {
        _device = mtkView.device;
        _inFlightSemaphore = dispatch_semaphore_create(MaxBuffersInFlight);
        [self loadMetalWithMetalKitView:mtkView];
        [self loadAssetsWithMetalKitView:mtkView];
    }
    return self;
}

// 创建并加载基本的Metal状态对象
- (void)loadMetalWithMetalKitView:(nonnull MTKView *)mtkView {
    
    // 分配三重缓冲区：GPU从一个缓冲区读取、而CPU写入另一个缓冲区
    for (int i = 0; i < MaxBuffersInFlight; i++) {
        id<MTLBuffer> frameParamsBuffer = [_device newBufferWithLength:sizeof(FrameParams) options:MTLResourceStorageModeShared];
        frameParamsBuffer.label = [NSString stringWithFormat:@"frameParams[%i]", i];
        _frameParamsBuffers[i] = frameParamsBuffer;
        
        id<MTLBuffer> finalViewportParamsBuffer = [_device newBufferWithLength:sizeof(ViewportParams) options:MTLResourceStorageModeShared];
        finalViewportParamsBuffer.label = [NSString stringWithFormat:@"viewportParams_final[%i]", i];
        _viewportsParamsBuffers_final[i] = finalViewportParamsBuffer;
        
        id<MTLBuffer> cubemapViewportParamsBuffer = [_device newBufferWithLength:sizeof(ViewportParams) * 6 options:MTLResourceStorageModeShared];
        cubemapViewportParamsBuffer.label = [NSString stringWithFormat:@"_viewportsParamsBuffers_reflection[%i]", i];
        _viewportsParamsBuffers_reflection[i] = cubemapViewportParamsBuffer;
        
        // actorParamsBuffer 包含着色器所需的每个 actor 数据
        //
        // 当批量渲染 actor 时，着色器将通过引用访问对应的 actor 数据，无需知道缓冲区中数据的实际偏移量。
        // 在每次调用 -draw 之前，在设置缓冲区时显式设置偏移量
        //
        // ActorData 以 256 个字节对齐
        id<MTLBuffer> actorParamsBuffer =
            [_device newBufferWithLength:Align<BufferOffsetAlign>(sizeof(ActorParams)) * MaxActors
                                 options:MTLResourceStorageModeShared];
        actorParamsBuffer.label = [NSString stringWithFormat:@"actorsParams[%i]", i];
        _actorsParamsBuffers[i] = actorParamsBuffer;

        // InstanceParams 无需内存对齐，因为着色器提供一个指针指向缓冲区的开始，并进入它的索引
        id<MTLBuffer> finalInstanceParamsBuffer =
            [_device newBufferWithLength: MaxActors*sizeof(InstanceParams)
                                 options: MTLResourceStorageModeShared];
        finalInstanceParamsBuffer.label = [NSString stringWithFormat:@"instanceParams_final[%i]", i];

        // 在 final pass 只有一个 viewport，viewportIndex = 0。因此，将每个actor的 final pass 的每个viewportIndex设置为0
        for(NSUInteger actorIdx = 0; actorIdx < MaxActors; actorIdx++) {
            InstanceParams *instanceParams =
                ((InstanceParams*)finalInstanceParamsBuffer.contents)+actorIdx;
            instanceParams->viewportIndex = 0;
        }
        _instanceParamsBuffers_final[i] = finalInstanceParamsBuffer;

        id<MTLBuffer> reflectionInstanceParamsBuffer =
            [_device newBufferWithLength: MaxVisibleFaces*MaxActors*sizeof(InstanceParams)
                                 options: MTLResourceStorageModeShared];
        reflectionInstanceParamsBuffer.label = [NSString stringWithFormat:@"_instanceParamsBuffers_reflection[%i]", i];
        _instanceParamsBuffers_reflection[i] = reflectionInstanceParamsBuffer;
    }
    
    mtkView.sampleCount               = 1;/// 采样数
    mtkView.colorPixelFormat          = MTLPixelFormatBGRA8Unorm_sRGB;
    mtkView.depthStencilPixelFormat   = MTLPixelFormatDepth32Float;
    
    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled    = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    
    _commandQueue = [_device newCommandQueue];
}

- (void)loadAssetsWithMetalKitView:(nonnull MTKView*)mtkView {
    // 顶点描述符：指定渲染管道预期的顶点布局，这可以优化渲染管道效率
    // 用于顶点着色器：世界坐标，蒙版，渐变权重…与其他属性(纹理坐标，法线)分离。
    MTLVertexDescriptor* mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    // 位置
    mtlVertexDescriptor.attributes[VertexAttributePosition].format       = MTLVertexFormatFloat3;
    mtlVertexDescriptor.attributes[VertexAttributePosition].offset       = 0;
    mtlVertexDescriptor.attributes[VertexAttributePosition].bufferIndex  = BufferIndexMeshPositions;

    // 纹理坐标
    mtlVertexDescriptor.attributes[VertexAttributeTexcoord].format       = MTLVertexFormatFloat2;
    mtlVertexDescriptor.attributes[VertexAttributeTexcoord].offset       = 0;
    mtlVertexDescriptor.attributes[VertexAttributeTexcoord].bufferIndex  = BufferIndexMeshGenerics;

    // Normals.
    mtlVertexDescriptor.attributes[VertexAttributeNormal].format         = MTLVertexFormatHalf4;
    mtlVertexDescriptor.attributes[VertexAttributeNormal].offset         = 8;
    mtlVertexDescriptor.attributes[VertexAttributeNormal].bufferIndex    = BufferIndexMeshGenerics;

    // Tangents
    mtlVertexDescriptor.attributes[VertexAttributeTangent].format        = MTLVertexFormatHalf4;
    mtlVertexDescriptor.attributes[VertexAttributeTangent].offset        = 16;
    mtlVertexDescriptor.attributes[VertexAttributeTangent].bufferIndex   = BufferIndexMeshGenerics;

    // Bitangents
    mtlVertexDescriptor.attributes[VertexAttributeBitangent].format      = MTLVertexFormatHalf4;
    mtlVertexDescriptor.attributes[VertexAttributeBitangent].offset      = 24;
    mtlVertexDescriptor.attributes[VertexAttributeBitangent].bufferIndex = BufferIndexMeshGenerics;

    // Position Buffer Layout
    mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride         = 12;
    mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepRate       = 1;
    mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepFunction   = MTLVertexStepFunctionPerVertex;

    // Generic Attribute Buffer Layout
    mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stride          = 32;
    mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepRate        = 1;
    mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepFunction    = MTLVertexStepFunctionPerVertex;

    //-------------------------------------------------------------------------------------------

    NSError *error = NULL;
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexDescriptor                = mtlVertexDescriptor;
    pipelineStateDescriptor.inputPrimitiveTopology          = MTLPrimitiveTopologyClassTriangle;
    pipelineStateDescriptor.vertexFunction =
        [defaultLibrary newFunctionWithName:@"vertexTransform"];
    pipelineStateDescriptor.fragmentFunction =
        [defaultLibrary newFunctionWithName:@"fragmentLighting"];
    pipelineStateDescriptor.sampleCount                     = mtkView.sampleCount;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat      = mtkView.depthStencilPixelFormat;

    pipelineStateDescriptor.label = @"TemplePipeline";
    id<MTLRenderPipelineState> templePipelineState =
        [_device newRenderPipelineStateWithDescriptor: pipelineStateDescriptor error:&error];
    NSAssert(templePipelineState, @"Failed to create pipeline state: %@", error);

    pipelineStateDescriptor.label = @"GroundPipeline";
    pipelineStateDescriptor.fragmentFunction =
        [defaultLibrary newFunctionWithName:@"fragmentGround"];
    id<MTLRenderPipelineState> groundPipelineState  =
        [_device newRenderPipelineStateWithDescriptor: pipelineStateDescriptor error:&error];
    NSAssert(groundPipelineState, @"Failed to create pipeline state: %@", error);
    
    pipelineStateDescriptor.label = @"ChromePipeline";
    pipelineStateDescriptor.sampleCount = 1;
    pipelineStateDescriptor.fragmentFunction =
        [defaultLibrary newFunctionWithName:@"fragmentChromeLighting"];
    id<MTLRenderPipelineState> chromePipelineState  =
        [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    NSAssert(chromePipelineState, @"Failed to create pipeline state: %@", error);

    _cameraReflection.distanceNear = 50.f;   /// 近剪裁平面
    _cameraReflection.distanceFar  = 3000.f; /// 远剪裁平面
    _cameraReflection.position     = SceneCenter; /// 场景中心
    
    _cameraFinal.rotation = 0;
    
    //-------------------------------------------------------------------------------------------
    // 创建和加载资源，包括网格和纹理
    MTLTextureDescriptor* cubeMapDesc =
        [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat: MTLPixelFormatBGRA8Unorm_sRGB
                                                              size: CubemapResolution
                                                         mipmapped: NO];
    cubeMapDesc.storageMode = MTLStorageModePrivate;
    cubeMapDesc.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    _reflectionCubeMap = [_device newTextureWithDescriptor:cubeMapDesc];

    MTLTextureDescriptor* cubeMapDepthDesc =
        [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat: MTLPixelFormatDepth32Float
                                                              size: CubemapResolution
                                                         mipmapped: NO];
    cubeMapDepthDesc.storageMode = MTLStorageModePrivate;
    cubeMapDepthDesc.usage = MTLTextureUsageRenderTarget;
    _reflectionCubeMapDepth = [_device newTextureWithDescriptor:cubeMapDepthDesc];

    // 创建一个 I/O 模型顶点描述符，以便格式化/布局我们的 I/O 模型网格顶点，来适应渲染管道的顶点描述符布局
    MDLVertexDescriptor *modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor);
    // 表示每个顶点描述符属性如何映射到每个模型I/O属性
    modelIOVertexDescriptor.attributes[VertexAttributePosition].name  = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[VertexAttributeTexcoord].name  = MDLVertexAttributeTextureCoordinate;
    modelIOVertexDescriptor.attributes[VertexAttributeNormal].name    = MDLVertexAttributeNormal;
    modelIOVertexDescriptor.attributes[VertexAttributeTangent].name   = MDLVertexAttributeTangent;
    modelIOVertexDescriptor.attributes[VertexAttributeBitangent].name = MDLVertexAttributeBitangent;

    NSURL *modelFileURL = [[NSBundle mainBundle] URLForResource:@"Models/Temple.obj" withExtension:nil];
    NSAssert(modelFileURL,@"Could not find model file (%@) in bundle",modelFileURL.absoluteString);

    MDLAxisAlignedBoundingBox templeAabb;
    NSArray <AAPLMesh*>* templeMeshes = [AAPLMesh newMeshesFromUrl: modelFileURL
                                           modelIOVertexDescriptor: modelIOVertexDescriptor
                                                       metalDevice: _device
                                                             error: &error
                                                              aabb: templeAabb];
    NSAssert(templeMeshes, @"Could not create meshes from model file: %@", modelFileURL.absoluteString);
    
    vector_float4 templeBSphere;
    templeBSphere.xyz = (templeAabb.maxBounds + templeAabb.minBounds)*0.5;
    templeBSphere.w = vector_length ((templeAabb.maxBounds - templeAabb.minBounds)*0.5);

    MTKMeshBufferAllocator *meshBufferAllocator =
        [[MTKMeshBufferAllocator alloc] initWithDevice:_device];

    MDLMesh* mdlSphere = [MDLMesh newEllipsoidWithRadii: 200.0
                                         radialSegments: 30
                                       verticalSegments: 20
                                           geometryType: MDLGeometryTypeTriangles
                                          inwardNormals: false
                                             hemisphere: false
                                              allocator: meshBufferAllocator];

    vector_float4 sphereBSphere;
    sphereBSphere.xyz = (vector_float3){0,0,0};
    sphereBSphere.w = 200.f;

    NSArray <AAPLMesh*>* sphereMeshes = [AAPLMesh newMeshesFromObject: mdlSphere
                                              modelIOVertexDescriptor: modelIOVertexDescriptor
                                                metalKitTextureLoader: NULL
                                                          metalDevice: _device
                                                                error: &error ];

    NSAssert(sphereMeshes, @"Could not create sphere meshes: %@", error);

    MDLMesh* mdlGround = [MDLMesh newPlaneWithDimensions: {100000.f, 100000.f}
                                                segments: {1,1}
                                            geometryType: MDLGeometryTypeTriangles
                                               allocator: meshBufferAllocator];

    vector_float4 groundBSphere;
    groundBSphere.xyz = (vector_float3){0,0,0};
    groundBSphere.w = 1415.f;

    NSArray <AAPLMesh*>* groundMeshes = [AAPLMesh newMeshesFromObject: mdlGround
                                              modelIOVertexDescriptor: modelIOVertexDescriptor
                                                metalKitTextureLoader: NULL
                                                          metalDevice: _device
                                                                error: &error ];
    
    NSAssert(groundMeshes, @"Could not create ground meshes: %@", error);

    // Finally, we create the actor list :
    _actorData = [NSMutableArray new];
    [_actorData addObject:[AAPLActorData new]];
    _actorData.lastObject.translation       = (vector_float3) {0.f, 0.f, 0.f};
    _actorData.lastObject.rotationPoint     = SceneCenter + (vector_float3) {-1000, -150.f, 1000.f};
    _actorData.lastObject.rotationAmount    = 0.f;
    _actorData.lastObject.rotationSpeed     = 1.f;
    _actorData.lastObject.rotationAxis      = (vector_float3) {0.f, 1.f, 0.f};
    _actorData.lastObject.diffuseMultiplier = (vector_float3) {1.f, 1.f, 1.f};
    _actorData.lastObject.bSphere           = templeBSphere;
    _actorData.lastObject.gpuProg           = templePipelineState;
    _actorData.lastObject.meshes            = templeMeshes;
    _actorData.lastObject.passFlags         = EPassFlags::ALL_PASS;

    [_actorData addObject:[AAPLActorData new]];
    _actorData.lastObject.translation       = (vector_float3) {0.f, 0.f, 0.f};
    _actorData.lastObject.rotationPoint     = SceneCenter + (vector_float3) {1000.f, -150.f, 1000.f};
    _actorData.lastObject.rotationAmount    = 0.f;
    _actorData.lastObject.rotationSpeed     = 2.f;
    _actorData.lastObject.rotationAxis      = (vector_float3) {0.f, 1.f, 0.f};
    _actorData.lastObject.diffuseMultiplier = (vector_float3) {0.6f, 1.f, 0.6f};
    _actorData.lastObject.bSphere           = templeBSphere;
    _actorData.lastObject.gpuProg           = templePipelineState;
    _actorData.lastObject.meshes            = templeMeshes;
    _actorData.lastObject.passFlags         = EPassFlags::ALL_PASS;

    [_actorData addObject:[AAPLActorData new]];
    _actorData.lastObject.translation       = (vector_float3) {0.f, 0.f, 0.f};
    _actorData.lastObject.rotationPoint     = SceneCenter + (vector_float3) {1150.f, -150.f, -400.f};
    _actorData.lastObject.rotationAmount    = 0.f;
    _actorData.lastObject.rotationSpeed     = 3.f;
    _actorData.lastObject.rotationAxis      = (vector_float3) {0.f, 1.f, 0.f};
    _actorData.lastObject.diffuseMultiplier = (vector_float3) {0.45f, 0.45f, 1.f};
    _actorData.lastObject.bSphere           = templeBSphere;
    _actorData.lastObject.gpuProg           = templePipelineState;
    _actorData.lastObject.meshes            = templeMeshes;
    _actorData.lastObject.passFlags         = EPassFlags::ALL_PASS;

    [_actorData addObject:[AAPLActorData new]];
    _actorData.lastObject.translation       = (vector_float3) {0.f, 0.f, 0.f};
    _actorData.lastObject.rotationPoint     = SceneCenter + (vector_float3) {-1200.f, -150.f, -300.f};
    _actorData.lastObject.rotationAmount    = 0.f;
    _actorData.lastObject.rotationSpeed     = 4.f;
    _actorData.lastObject.rotationAxis      = (vector_float3) {0.f, 1.f, 0.f};
    _actorData.lastObject.diffuseMultiplier = (vector_float3) {1.f, 0.6f, 0.6f};
    _actorData.lastObject.bSphere           = templeBSphere;
    _actorData.lastObject.gpuProg           = templePipelineState;
    _actorData.lastObject.meshes            = templeMeshes;
    _actorData.lastObject.passFlags         = EPassFlags::ALL_PASS;

    [_actorData addObject:[AAPLActorData new]];
    _actorData.lastObject.translation       = (vector_float3) {0.f, 0.f, 0.f};
    _actorData.lastObject.rotationPoint     = SceneCenter + (vector_float3){0.f, -200.f, 0.f};
    _actorData.lastObject.rotationAmount    = 0.f;
    _actorData.lastObject.rotationSpeed     = 0.f;
    _actorData.lastObject.rotationAxis      = (vector_float3) {0.f, 1.f, 0.f};
    _actorData.lastObject.diffuseMultiplier = (vector_float3) {1.f, 1.f, 1.f};
    _actorData.lastObject.bSphere           = groundBSphere;
    _actorData.lastObject.gpuProg           = groundPipelineState;
    _actorData.lastObject.meshes            = groundMeshes;
    _actorData.lastObject.passFlags         = EPassFlags::ALL_PASS;

    _reflectiveActor = [AAPLActorData new];
    [_actorData addObject:_reflectiveActor];
    _actorData.lastObject.rotationPoint     = _cameraReflection.position;
    _actorData.lastObject.translation       = (vector_float3) {100.f, -50.f, 0.f};
    _actorData.lastObject.rotationAmount    = 0.f;
    _actorData.lastObject.rotationSpeed     = 6.f;
    _actorData.lastObject.rotationAxis      = (vector_float3) {0.5f, 1.f, 0.f};
    _actorData.lastObject.diffuseMultiplier = (vector_float3) {1.f, 1.f, 1.f};
    _actorData.lastObject.bSphere           = sphereBSphere;
    _actorData.lastObject.gpuProg           = chromePipelineState;
    _actorData.lastObject.meshes            = sphereMeshes;
    _actorData.lastObject.passFlags         = EPassFlags::Render;
}

- (void)updateGameState {
    FrustumCuller culler_final;
    FrustumCuller culler_probe [6];

    // 更新每个actor的位置和参数缓冲区
    {
        ActorParams *actorParams  =
            (ActorParams *)_actorsParamsBuffers[_uniformBufferIndex].contents;

        for (int i = 0; i < _actorData.count; i++) {
            const matrix_float4x4 modelTransMatrix    = matrix4x4_translation(_actorData[i].translation);
            const matrix_float4x4 modelRotationMatrix = matrix4x4_rotation (_actorData[i].rotationAmount, _actorData[i].rotationAxis);
            const matrix_float4x4 modelPositionMatrix = matrix4x4_translation(_actorData[i].rotationPoint);

            matrix_float4x4 modelMatrix;
            modelMatrix = matrix_multiply(modelRotationMatrix, modelTransMatrix);
            modelMatrix = matrix_multiply(modelPositionMatrix, modelMatrix);
            
            _actorData[i].modelPosition = matrix_multiply(modelMatrix, (vector_float4) {0, 0, 0, 1});
            
            // 在 CPU 中更新下一帧的 actor 旋转
            _actorData[i].rotationAmount += 0.004 * _actorData[i].rotationSpeed;
            
            // 更新 actor 的着色器参数
            actorParams[i].modelMatrix = modelMatrix;
            actorParams[i].diffuseMultiplier = _actorData[i].diffuseMultiplier;
            actorParams[i].materialShininess = 4;
        }
    }
    //更新视野视口
    {
         _cameraReflection.position = _reflectiveActor.modelPosition.xyz;

        ViewportParams *viewportBuffer =
            (ViewportParams *)_viewportsParamsBuffers_reflection[_uniformBufferIndex].contents;

        const matrix_float4x4 projectionMatrix = _cameraReflection.GetProjectionMatrix_LH();
        matrix_float4x4 viewMatrix [6];

        for(int i = 0; i < 6; i++) {
            // 1) 获得视图矩阵: 世界坐标到观察坐标的转换
            viewMatrix[i] = _cameraReflection.GetViewMatrixForFace_LH (i);
            // 2)使用视图矩阵计算包围视景体的平面
            /// 稍后使用这些平面来测试 actor 的边界球是否与视景体相交，因此在这个面的视口中可见
            culler_probe[i].Reset_LH(viewMatrix [i], _cameraReflection);
            // 3)更新观察点位置，在顶点着色器中通过观察点在反射通道中绘制 actors
            viewportBuffer[i].cameraPos = _cameraReflection.position;
            // 4) 更新透视投影矩阵，在顶点着色器中使用透视投影矩阵来转换 actors 坐标
            viewportBuffer[i].viewProjectionMatrix = matrix_multiply (projectionMatrix, viewMatrix [i]);
        }
    }
    // 更新最终的视口： 着色器参数缓冲区+剔除工具
    {
        _cameraFinal.target   = SceneCenter;

        _cameraFinal.rotation = fmod ((_cameraFinal.rotation + CameraRotationSpeed), M_PI*2.f);
        matrix_float3x3 rotationMatrix = matrix3x3_rotation (_cameraFinal.rotation,  CameraRotationAxis);

        _cameraFinal.position = SceneCenter;
        _cameraFinal.position += matrix_multiply (rotationMatrix, CameraDistanceFromCenter);

        const matrix_float4x4 viewMatrix       = _cameraFinal.GetViewMatrix();
        const matrix_float4x4 projectionMatrix = _cameraFinal.GetProjectionMatrix_LH();

        culler_final.Reset_LH (viewMatrix, _cameraFinal);

        ViewportParams *viewportBuffer = (ViewportParams *)_viewportsParamsBuffers_final[_uniformBufferIndex].contents;
        viewportBuffer[0].cameraPos            = _cameraFinal.position;
        viewportBuffer[0].viewProjectionMatrix = matrix_multiply (projectionMatrix, viewMatrix);
    }
    // 更新着色器参数-帧常量:
    {
        const vector_float3 ambientLightColor         = {0.2, 0.2, 0.2};
        const vector_float3 directionalLightColor     = {.75, .75, .75};
        const vector_float3 directionalLightDirection = vector_normalize((vector_float3){1.0, -1.0, 1.0});

        FrameParams *frameParams =
            (FrameParams *) _frameParamsBuffers[_uniformBufferIndex].contents;
        frameParams[0].ambientLightColor            = ambientLightColor;
        frameParams[0].directionalLightInvDirection = -directionalLightDirection;
        frameParams[0].directionalLightColor        = directionalLightColor;
    }
    
    // 剔除视野之外的面，确定需要绘制的面
    {
        InstanceParams *instanceParams_reflection =
            (InstanceParams *)_instanceParamsBuffers_reflection [_uniformBufferIndex].contents;

        for (int actorIdx = 0; actorIdx < _actorData.count; actorIdx++) {
            if (_actorData[actorIdx].passFlags & EPassFlags::Render) {
                if (culler_final.Intersects (_actorData[actorIdx].modelPosition.xyz, _actorData[actorIdx].bSphere)) {
                    _actorData[actorIdx].visibleInFinal = YES;
                } else {
                    _actorData[actorIdx].visibleInFinal = NO;
                }
            }
            
            if (_actorData[actorIdx].passFlags & EPassFlags::Reflection) {
                int instanceCount = 0;
                for (int faceIdx = 0; faceIdx < 6; faceIdx++) {
                    // 检查 actor 是否在当前视野内
                    if (culler_probe [faceIdx].Intersects (_actorData[actorIdx].modelPosition.xyz, _actorData[actorIdx].bSphere)) {
                        // 如果在视野内，将这个面索引添加到这个actor的面列表中
                        InstanceParams instanceParams = {(ushort)faceIdx};
                        instanceParams_reflection [MaxVisibleFaces * actorIdx + instanceCount].viewportIndex = instanceParams.viewportIndex;
                        instanceCount++;
                    }
                }
                _actorData[actorIdx].instanceCountInReflection = instanceCount;
            }
        }
    }
}

/// 设置每个 actor 的图形渲染状态
/// actor 只有在主镜头可见时才被绘制，由 visibleVpCount 决定
/// 由于每个actor在最后一次循环中只绘制一次，所以 `instanceCount` 参数总是被设置为1，`baseInstance` 参数总是被设置为0
- (void)drawActors:(id<MTLRenderCommandEncoder>)renderEncoder pass:(EPassFlags)pass {
    id<MTLBuffer> viewportBuffer;
    id<MTLBuffer> visibleVpListPerActor;

    if(pass == EPassFlags::Render) {
        viewportBuffer        = _viewportsParamsBuffers_final[_uniformBufferIndex];
        visibleVpListPerActor = _instanceParamsBuffers_final[_uniformBufferIndex];
    } else {
        viewportBuffer        = _viewportsParamsBuffers_reflection[_uniformBufferIndex];
        visibleVpListPerActor = _instanceParamsBuffers_reflection[_uniformBufferIndex];
    }

    // 添加上下文信息到 GPU 帧捕获工具
    [renderEncoder pushDebugGroup:[NSString stringWithFormat:@"DrawActors %d", pass]];

    [renderEncoder setCullMode:MTLCullModeBack];
    [renderEncoder setDepthStencilState:_depthState];

    // 设置传入渲染管道的缓冲区

    [renderEncoder setFragmentBuffer: _frameParamsBuffers[_uniformBufferIndex]
                              offset: 0
                             atIndex: BufferIndexFrameParams];

    [renderEncoder setVertexBuffer: viewportBuffer
                            offset: 0
                           atIndex: BufferIndexViewportParams];

    [renderEncoder setFragmentBuffer: viewportBuffer
                              offset: 0
                             atIndex: BufferIndexViewportParams];

    [renderEncoder setVertexBuffer: visibleVpListPerActor
                            offset: 0
                           atIndex: BufferIndexInstanceParams];

    [renderEncoder setFragmentTexture: _reflectionCubeMap atIndex:TextureIndexCubeMap];

    for (int actorIdx = 0; actorIdx < _actorData.count; actorIdx++) {
        AAPLActorData* lActor = _actorData[actorIdx];

        if ((lActor.passFlags & pass) == 0) continue;

        uint32_t visibleVpCount;

        if(pass == EPassFlags::Render) {
            visibleVpCount = lActor.visibleInFinal;
        } else {
            visibleVpCount = lActor.instanceCountInReflection;
        }

        if (visibleVpCount == 0) continue;

        // per-actor parameters
        [renderEncoder setVertexBuffer: _actorsParamsBuffers[_uniformBufferIndex]
                                offset: actorIdx * Align<BufferOffsetAlign> (sizeof(ActorParams))
                               atIndex: BufferIndexActorParams];

        [renderEncoder setFragmentBuffer: _actorsParamsBuffers[_uniformBufferIndex]
                                  offset: actorIdx * Align<BufferOffsetAlign> (sizeof(ActorParams))
                                 atIndex: BufferIndexActorParams];

        [renderEncoder setRenderPipelineState:lActor.gpuProg];

        for (AAPLMesh *mesh in lActor.meshes) {
            MTKMesh *metalKitMesh = mesh.metalKitMesh;

            // 设置网格的顶点缓冲区数据
            for (NSUInteger bufferIndex = 0; bufferIndex < metalKitMesh.vertexBuffers.count; bufferIndex++) {
                MTKMeshBuffer *vertexBuffer = metalKitMesh.vertexBuffers[bufferIndex];
                if((NSNull*)vertexBuffer != [NSNull null]) {
                    [renderEncoder setVertexBuffer: vertexBuffer.buffer
                                            offset: vertexBuffer.offset
                                           atIndex: bufferIndex];
                }
            }

            //绘制网格的每个子网格
            for(AAPLSubmesh *submesh in mesh.submeshes) {
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

                [renderEncoder setFragmentTexture:_reflectionCubeMap atIndex:TextureIndexCubeMap];

                MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

                [renderEncoder drawIndexedPrimitives: metalKitSubmesh.primitiveType
                                          indexCount: metalKitSubmesh.indexCount
                                           indexType: metalKitSubmesh.indexType
                                         indexBuffer: metalKitSubmesh.indexBuffer.buffer
                                   indexBufferOffset: metalKitSubmesh.indexBuffer.offset
                                       instanceCount: visibleVpCount
                                          baseVertex: 0
                                        baseInstance: actorIdx * MaxVisibleFaces];
            }
        }
    }

    [renderEncoder popDebugGroup];
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    // 视场设置为65度，还需要转换为弧度
    static const float fovY_Half = radians_from_degrees(65.0 *.5);
    const float        aspect    = size.width / (float)size.height;
    
    _cameraFinal.aspectRatio  = aspect;
    _cameraFinal.fovVert_Half = fovY_Half;  /// 视场
    _cameraFinal.distanceNear = 50.f;       /// 近剪裁平面
    _cameraFinal.distanceFar  = 5000.f;     /// 远剪裁平面
}

/** 铬球上的动态反射，使用图层选择以两次渲染帧
 *  第一遍将环境渲染到立方体贴图上。
 *  第二遍将环境反射渲染到球体上；它渲染场景中的其他 actors；它呈现环境本身。
 */
- (void)drawInMTKView:(nonnull MTKView *)view {
    /// 渲染开始时，将信号量减 1，如果信号量低于 0，则 CPU 等待状态；否则唤醒 CPU 处理数据；
    /// 确保 GPU 可以处理新的一帧数据
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    /// 循环重用的缓冲池，拿到当前缓冲区的索引
    _uniformBufferIndex = (_uniformBufferIndex + 1) % MaxBuffersInFlight;
    [self updateGameState]; /// 更新当前缓冲区数据

    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"映射·命令缓冲区";

    {
        MTLRenderPassDescriptor* reflectionPassDesc = [MTLRenderPassDescriptor renderPassDescriptor];
        reflectionPassDesc.colorAttachments[0].clearColor = MTLClearColorMake (0.0, 0.0, 0.0, 1.0);
        reflectionPassDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
        reflectionPassDesc.depthAttachment.clearDepth     = 1.0;
        reflectionPassDesc.depthAttachment.loadAction     = MTLLoadActionClear;
        reflectionPassDesc.colorAttachments[0].texture    = _reflectionCubeMap;
        reflectionPassDesc.depthAttachment.texture        = _reflectionCubeMapDepth;
        reflectionPassDesc.renderTargetArrayLength        = 6;

        id<MTLRenderCommandEncoder> renderEncoder =
            [commandBuffer renderCommandEncoderWithDescriptor:reflectionPassDesc];
        renderEncoder.label = @"映射·命令编码器";

        [self drawActors:renderEncoder pass:EPassFlags::Reflection];

        [renderEncoder endEncoding];
    }

    /// 提交命令，先一步渲染
    [commandBuffer commit];

    commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"渲染·命令缓冲区";
    
    /// 注册该帧渲染完成的回调，当 GPU 完成 commandBuffer 的执行时立即调用 Block，表明这个缓冲区可以被回收或者被下一帧数据重用
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
         dispatch_semaphore_signal(block_sema);
     }];
    
    
    /// 优化：使用时再去获取 RenderPassDescriptor ，避免保留 drawable 数据太久，导致帧率的降低！
    ///      因为应用程序与GPU都会去竞争这些资源
    MTLRenderPassDescriptor* finalPassDescriptor = view.currentRenderPassDescriptor;
    if(finalPassDescriptor != nil) {
        finalPassDescriptor.renderTargetArrayLength = 1;
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:finalPassDescriptor];
        renderEncoder.label = @"渲染·命令编码器";
        [self drawActors:renderEncoder pass:EPassFlags::Render];
        [renderEncoder endEncoding];
    }
    
    if(view.currentDrawable) {
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    // 在这里完成渲染并将命令缓冲区推到GPU
    [commandBuffer commit];
}

@end
