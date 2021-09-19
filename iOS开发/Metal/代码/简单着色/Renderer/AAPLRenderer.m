@import simd;
@import MetalKit;

#import "AAPLRenderer.h"

// 执行渲染
@implementation AAPLRenderer {
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView {
    self = [super init];
    if(self) {
        _device = mtkView.device;
        _commandQueue = [_device newCommandQueue]; // 命令队列
    }
    return self;
}

#pragma mark - MTKViewDelegate

/** 当视图更新内容,需要渲染时调用
 * 在该方法中，创建一个命令缓冲区，告诉 GPU 绘制什么以及何时对命令进行编码，并将该命令缓冲区排入队列以供 GPU 执行。
 * 每秒可以绘制许多帧；
 */
- (void)drawInMTKView:(nonnull MTKView *)view {
    
    /**
     * 绘图时 GPU 将计算结果存储到纹理中，纹理是包含图像数据并可被 GPU 访问的内存块。
     * 在该示例中，MTKView 创建了需要绘制到视图中的所有纹理；它创建多个纹理，以便在渲染到另一个纹理时显示一个纹理的内容。
     *
     * 对于绘制，需要创建一个渲染通道，它是绘制到一组纹理中的一系列渲染命令。
     * 在渲染过程中使用时，纹理也称为渲染目标。
     * 要创建渲染通道，需要一个渲染通道描述符 MTLRenderPassDescriptor.
     * 在这个示例中，不需要配置渲染通道描述符，而是让 MetalKit 视图创建一个
     *
     * 渲染通道描述符描述了一组渲染目标，以及它们在渲染通道开始和结束时应如何处理。
     * 渲染通道还定义了不属于此示例的渲染的一些其他方面。
     * 视图返回一个带有指向视图纹理之一的单一颜色附件的渲染通道描述符，否则根据视图的属性配置渲染通道。
     * 默认情况下，这意味着在渲染通道开始时，渲染目标被擦除为与视图属性匹配的纯色，并且在渲染通道结束时，所有更改都存储回纹理。
     * clearColor
     * 因为视图的渲染过程描述符可能是nil，所以nil在创建渲染过程之前，您应该测试以确保渲染过程描述符对象是非。
     */
    /// 渲染通道描述符引用Metal应该绘制的纹理
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil) {
        return;
    }
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    /** 创建渲染通道
     * 您可以通过使用对象将其编码到命令缓冲区来创建渲染通道 。调用命令缓冲区的方法并传入渲染通道描述符。MTLRenderCommandEncodermakeRenderCommandEncoder(descriptor:)
     * 在此示例中，您没有对任何绘图命令进行编码，因此渲染通道所做的唯一事情就是擦除纹理。调用编码器的方法以指示传递完成。endEncoding
     */
    // 创建一个渲染通道并立即结束编码，使可绘制对象被清除
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [commandEncoder endEncoding];
    
    /// 向屏幕呈现可绘制对象
    /**
     * 绘制到纹理不会自动在屏幕上显示新内容。实际上，屏幕上只能呈现一些纹理。
     * 在 Metal 中，可以在屏幕上显示的纹理由可绘制对象管理，并且要显示内容，您可以呈现可绘制对象。
     * MTKView 自动创建可绘制对象来管理其纹理。读取属性以获取拥有作为渲染通道目标纹理的可绘制对象。
     * 视图返回一个对象，一个连接到 Core Animation 的对象
     */
    id<MTLDrawable> drawable = view.currentDrawable;
    // 一旦绘制完成，传入可绘制对象
    /**
     * 该方法告诉M​​etal，当命令缓冲区被调度执行时，Metal 应该与Core Animation 协调以在渲染完成后显示纹理。
     * 当 Core Animation 呈现纹理时，它成为视图的新内容。
     * 在此示例中，这意味着擦除的纹理成为视图的新背景。
     * 这一变化与 Core Animation 为屏幕用户界面元素所做的任何其他视觉更新一起发生。
     */
    [commandBuffer presentDrawable:drawable];
    
    [commandBuffer commit];
}

/// 当视图改变方向或调整大小时调用
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
