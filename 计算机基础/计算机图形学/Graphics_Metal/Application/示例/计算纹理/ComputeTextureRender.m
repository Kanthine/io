//
//  ComputeTextureRender.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/10.
//

#import "ComputeTextureRender.h"
#import "ImageParser.h"
#import "ShaderTypes.h"

@interface ComputeTextureRender ()
{
    id<MTLDevice> _device;
    id<MTLRenderPipelineState> _renderPipeline;
    id<MTLComputePipelineState> _computePipeline;
    id<MTLCommandQueue> _commandQueue;
    vector_float2 _viewportSize;
    
    id<MTLTexture> _inputTexture;
    id<MTLTexture> _outputTexture;
    
    MTLSize _threadGroupSize;
    MTLSize _threadGroupCount;
}
@end

@implementation ComputeTextureRender

- (instancetype)initWithMTKView:(nonnull MTKView *)mtkview {
    self = [super init];
    if (self) {
        mtkview.delegate = self;
        mtkview.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        mtkview.device = MTLCreateSystemDefaultDevice();
        _device = mtkview.device;
        NSAssert(_device, @"设备创建失败");
        
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunc = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunc = [defaultLibrary newFunctionWithName:@"fragmentTextureShader"];
        id<MTLFunction> computeFunc = [defaultLibrary newFunctionWithName:@"grayscaleKernel"];
        
        NSError *error;
        _computePipeline = [_device newComputePipelineStateWithFunction:computeFunc error:&error];
        NSAssert(_computePipeline, @"计算管道创建失败 : %@",error);
        
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = @"计算纹理·渲染管道";
        descriptor.vertexFunction = vertexFunc;
        descriptor.fragmentFunction = fragmentFunc;
        descriptor.colorAttachments[0].pixelFormat = mtkview.colorPixelFormat;
        _renderPipeline = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        NSAssert(_renderPipeline, @"渲染管道创建失败 : %@",error);

        _commandQueue = [_device newCommandQueue];
        [self loadTexture];
        
        _threadGroupSize = MTLSizeMake(16, 16, 1); // 设置计算内核的线程组大小为16 x 16
        
        // 根据输入图像的大小，计算线程组的行数和列数。确保网格覆盖整个图像(或更多)。
        _threadGroupCount.width = (_inputTexture.width  + _threadGroupSize.width -  1) / _threadGroupSize.width;
        _threadGroupCount.height = (_inputTexture.height + _threadGroupSize.height - 1) / _threadGroupSize.height;
        _threadGroupCount.depth = 1; // 图像数据是2D的，所以设置depth为 1

    }
    return self;
}

- (void)loadTexture {
    
    NSURL *fileURL = [NSBundle.mainBundle URLForResource:@"ComputeTexture" withExtension:@"tga"];
    TagImageParser *image = [[TagImageParser alloc] initWithTGAFileAtLocation:fileURL];
    NSAssert(image, @"图片资源加载失败");
    
    MTLTextureDescriptor *descriptor = [[MTLTextureDescriptor alloc] init];
    descriptor.textureType = MTLTextureType2D;
    descriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.width = image.width;
    descriptor.height = image.height;
    descriptor.usage = MTLTextureUsageShaderRead;
    _inputTexture = [_device newTextureWithDescriptor:descriptor];
    descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    _outputTexture = [_device newTextureWithDescriptor:descriptor];
    MTLRegion region = {{ 0, 0, 0 }, {descriptor.width, descriptor.height, 1}};
    NSUInteger bytesPerRow = 4 * descriptor.width; /// 宽度范围内的纹理大小
    /// 将图片的像素数据复制到 _inputTexture
    [_inputTexture replaceRegion:region mipmapLevel:0 withBytes:image.data.bytes bytesPerRow:bytesPerRow];
    NSAssert(_inputTexture, @"创建 inputTexture 失败");
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    MTLRenderPassDescriptor *descriptor = view.currentRenderPassDescriptor;
    if (!descriptor) return;
    
    static const Vertex2D vertexDatas[] = {
        (Vertex2D){ {  250,  -250 }, { 0.0, 0.0, 0.0, 0.0}, { 1.f, 1.f } },
        (Vertex2D){ { -250,  -250 }, { 0.0, 0.0, 0.0, 0.0}, { 0.f, 1.f } },
        (Vertex2D){ { -250,   250 }, { 0.0, 0.0, 0.0, 0.0}, { 0.f, 0.f } },

        (Vertex2D){ {  250,  -250 }, { 0.0, 0.0, 0.0, 0.0}, { 1.f, 1.f } },
        (Vertex2D){ { -250,   250 }, { 0.0, 0.0, 0.0, 0.0}, { 0.f, 0.f } },
        (Vertex2D){ {  250,   250 }, { 0.0, 0.0, 0.0, 0.0}, { 1.f, 0.f } },
    };
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"命令缓冲区";
    
    // 处理输入图像
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    [computeEncoder setComputePipelineState:_computePipeline];
    [computeEncoder setTexture:_inputTexture atIndex:ShaderParamTypeTextureInput];
    [computeEncoder setTexture:_outputTexture atIndex:ShaderParamTypeTextureOutput];
    [computeEncoder dispatchThreadgroups:_threadGroupCount threadsPerThreadgroup:_threadGroupSize];
    [computeEncoder endEncoding];
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    renderEncoder.label = @"渲染命令编码器";
    
    [renderEncoder setRenderPipelineState:_renderPipeline];
    [renderEncoder setViewport:(MTLViewport){0, 0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
    
    [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:ShaderParamTypeViewport];
    [renderEncoder setVertexBytes:vertexDatas length:sizeof(vertexDatas) atIndex:ShaderParamTypeVertices];
    [renderEncoder setFragmentTexture:_outputTexture atIndex:ShaderParamTypeTextureOutput];
    
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
    [renderEncoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
