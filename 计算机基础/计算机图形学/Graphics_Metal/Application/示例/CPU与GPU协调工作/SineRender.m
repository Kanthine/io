//
//  SineRender.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "SineRender.h"
#include "ShaderTypes.h"
@import simd;


@interface SineTriangle : NSObject
@property (nonatomic) vector_float2 position;
@property (nonatomic) vector_float4 color;

+ (const Vertex2D*)vertices;

+ (NSUInteger)vertexCount;

@end

@implementation SineTriangle

+ (const Vertex2D *)vertices {
    const float lengthOfSide = 150;
    static const Vertex2D triangleVertices[] =
    {
        { { -0.5 * lengthOfSide, -0.5 * lengthOfSide },  { 1, 1, 1, 1 } },
        { {  0.0 * lengthOfSide, +0.5 * lengthOfSide },  { 1, 1, 1, 1 } },
        { { +0.5 * lengthOfSide, -0.5 * lengthOfSide },  { 1, 1, 1, 1 } }
    };
    return triangleVertices;
}

/// 返回每个三角形的顶点数
+(const NSUInteger)vertexCount {
    return 3;
}

@end


static const NSUInteger kTriangleCount = 50;

@implementation SineRender

{
    dispatch_semaphore_t _inFlightSemaphore;
    id<MTLBuffer> _vertexBuffers[kMaxFrameBuffersSize];
    NSUInteger _currentBufferIndex;
    NSArray<SineTriangle *> *_triangleArray;
    NSUInteger _totalVertexs;
    float _wavePosition;
    
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
}

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if (self) {
        mtkView.delegate = self;
        mtkView.device = MTLCreateSystemDefaultDevice();
        _device = mtkView.device;
        NSAssert(_device, @"获取设备失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];

        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"sine·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        descriptor.sampleCount = mtkView.sampleCount; /// 每个片段中的样本数量
        /// 标记缓冲区不可变
        descriptor.vertexBuffers[ShaderParamTypeVertices].mutability = MTLMutabilityImmutable;
        
        NSError *error;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@", error);
        
        _commandQueue = [_device newCommandQueue];
        
        _inFlightSemaphore = dispatch_semaphore_create(kMaxFrameBuffersSize);
        [self creatTriangle];

        _totalVertexs = [SineTriangle vertexCount] * _triangleArray.count;
        const NSUInteger triangleBuffersSize = _totalVertexs * sizeof(Vertex2D);
        for (int i = 0; i < kMaxFrameBuffersSize; i++) {
            _vertexBuffers[i] = [_device newBufferWithLength:triangleBuffersSize options:MTLResourceStorageModeShared];
            _vertexBuffers[i].label = [NSString stringWithFormat:@"顶点缓冲区 - %d",i];
        }
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view { 
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    
    _currentBufferIndex = (_currentBufferIndex + 1) % kMaxFrameBuffersSize;
    [self updateTriangleCenter];
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"sine·命令缓冲区";
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    
    if (descriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"sine·命令编码器";
        
        [renderEncoder setRenderPipelineState:_renderPipeline];
        [renderEncoder setViewport:(MTLViewport){0, 0, _viewportSize.x, _viewportSize.y, 0, 1.0}];
        
        [renderEncoder setVertexBuffer:_vertexBuffers[_currentBufferIndex] offset:0 atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
        
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_totalVertexs];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    __block dispatch_semaphore_t semaphore_t = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
        dispatch_semaphore_signal(semaphore_t);
    }];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    [self creatTriangle];
    
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

#pragma mark - private method

- (void)creatTriangle {
    const vector_float4 Colors[] =
    {
        { 1.0, 0.0, 0.0, 1.0 },
        { 0.0, 1.0, 0.0, 1.0 },
        { 0.0, 0.0, 1.0, 1.0 },
        { 1.0, 0.0, 1.0, 1.0 },
        { 0.0, 1.0, 1.0, 1.0 },
        { 1.0, 1.0, 0.0, 1.0 },
    };
    const NSUInteger NumColors = sizeof(Colors) / sizeof(vector_float4);
    const float horizontalSpacing = 20;
    NSMutableArray<SineTriangle *> *triangles = [NSMutableArray arrayWithCapacity:kTriangleCount];
    for (int i = 0; i < kTriangleCount; i++) {
        vector_float2 centerTriangle;
        centerTriangle.x = (i - kTriangleCount / 2.0) * horizontalSpacing;
        centerTriangle.y = 0.0;
        
        SineTriangle *triangle = [[SineTriangle alloc] init];
        triangle.position = centerTriangle;
        triangle.color = Colors[i % NumColors];
        [triangles addObject:triangle];
    }
    _triangleArray = triangles.copy;
}

- (void)updateTriangleCenter {
    const float waveMagnitude = 150.0;
    const float waveSpeed = 0.05;
    _wavePosition += waveSpeed;
    
    const Vertex2D *vertexTriangle = [SineTriangle vertices];
    const NSUInteger triangleCount = [SineTriangle vertexCount];
    
    Vertex2D *currentBuffer = _vertexBuffers[_currentBufferIndex].contents;
    
    for (int i = 0; i < kTriangleCount; i++) {
        vector_float2 centerCurrentTriangle = _triangleArray[i].position;
        centerCurrentTriangle.y = sin(centerCurrentTriangle.x / waveMagnitude + _wavePosition) * waveMagnitude;
        _triangleArray[i].position = centerCurrentTriangle;
        
        for (int j = 0; j < triangleCount; j++) {
            NSUInteger currentVertex = j + i * triangleCount;
            currentBuffer[currentVertex].position = vertexTriangle[j].position + centerCurrentTriangle;
            currentBuffer[currentVertex].color = _triangleArray[i].color;
        }
    }
}

@end
