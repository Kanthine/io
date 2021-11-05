//
//  PrimitiveTypeRender.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import "PrimitiveTypeRender.h"
#import "ShaderTypes.h"
@import simd;

@interface PrimitiveTypeRender ()

{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
}

@end


@implementation PrimitiveTypeRender

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if (self) {
        _primitiveType = MTLPrimitiveTypePoint;
        mtkView.device = MTLCreateSystemDefaultDevice();
        NSAssert(mtkView.device, @"Metal is not supported on this device");
        
        _device = mtkView.device;
        mtkView.delegate = self;
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> framentFunc = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"图元类型";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = framentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        NSError *error;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_pipelineState, @"Failed to create pipeline state: %@", error);
        
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    int vertexCount = 7;
    static const Vertex2D rectVertex[] = {
        {{0,0},{1,0,0,1}},
        {{0,-200},{0,1,0,1}},
        {{200,-200},{0,0,1,1}},
        {{200,0},{1,1,1,1}},
        {{100,100},{0,1,1,1}},
        {{0,0},{1,0,0,1}},
        {{200,-200},{0,0,1,1}},
    };
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"图元类型·命令缓冲池";
    
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (descriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
        renderEncoder.label = @"图元类型·命令编码器";
        
        [renderEncoder setViewport:(MTLViewport){0,0,_viewportSize.x,_viewportSize.y,0,1.0}];
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        [renderEncoder setVertexBytes:rectVertex length:sizeof(rectVertex) atIndex:ShaderParamTypeVertices];
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
        
        [renderEncoder drawPrimitives:_primitiveType vertexStart:0 vertexCount:vertexCount];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
