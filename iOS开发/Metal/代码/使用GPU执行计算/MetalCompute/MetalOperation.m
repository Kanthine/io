//
//  MetalOperation.m
//  MetalCompute
//
//  Created by 苏沫离 on 2021/9/17.
//

#import "MetalOperation.h"

// 数组长度
const unsigned int arrayLength = 1 << 24;
// 数组大小
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation MetalOperation {
    id<MTLDevice> _mDevice;
    
    // 计算管道
    id<MTLComputePipelineState> _mAddFunctionPSO;

    // 命令队列：向 GPU 传送命令
    id<MTLCommandQueue> _mCommandQueue;

    // 数据缓冲区
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;
}

- (instancetype)initWithDevice: (id<MTLDevice>) device {
    self = [super init];
    if (self) {
        _mDevice = device;
        NSError* error = nil;

        /*** 1、获取 Metal 函数的引用 ***/
        // 1.1、创建一个默认库对象
        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if (defaultLibrary == nil) {
            NSLog(@"Failed to find the default library.");
            return nil;
        }
        // 1.2、向默认库请求 MSL 函数的对象
        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
        if (addFunction == nil)  {
            NSLog(@"Failed to find the adder function.");
            return nil;
        }
        
        /// 2、准备 Metal 管道：同步创建一个 MTLComputePipelineState 对象
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:addFunction error:&error];
        if (_mAddFunctionPSO == nil) {
            // 使用Xcode debug 程序时，默认开启 Metal API 验证，这样可以获取详细的出错信息
            NSLog(@"Failed to created pipeline state object, error %@.", error);
            return nil;
        }
        
        /// 3、 Metal 使用命令队列来调度任务：通过 MTLDevice 实例来创建一个命令队列；
        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil){
            NSLog(@"Failed to find the command queue.");
            return nil;
        }
    }
    return self;
}

/// 创建数据缓冲区并加载数据
- (void)prepareData {
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

    /// 使用随机数据填充前两个缓冲区
    [self generateRandomFloatData:_mBufferA];
    [self generateRandomFloatData:_mBufferB];
}

/// 调度任务
- (void)sendComputeCommand {
    /// 为队列创建一个命令缓冲区
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);
    
    /// 创建命令编码器 : 要将命令写入命令​​缓冲区，还需要对命令编码
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);
    
    [self encodeAddCommand:computeEncoder];
    
    /// 当没有更多命令添加到计算通道时，结束编码过程以关闭计算通道
    [computeEncoder endEncoding];
    
    /// 通过将命令缓冲区提交到队列来运行命令缓冲区中的命令
    [commandBuffer commit];
    
    /// 等待计算完成
    [commandBuffer waitUntilCompleted];
    
    /// 从缓冲区读取结果
    [self verifyResults];
}

/// 设置管道状态和参数数据
- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {
    
    /// 为每个参数指定一个偏移量，偏移量0表示命令将从缓冲区的开头访问数据；
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];

    /// Metal 可以创建 1D、2D 或 3D 网格；该函数使用一维数组
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    
    /// 指定线程组大小：线程组中允许的最大线程数
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > arrayLength) {
        threadGroupSize = arrayLength;
    }
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
    
    /// 对计算命令进行编码以调度线程网格
    [computeEncoder dispatchThreads:gridSize
              threadsPerThreadgroup:threadgroupSize];
}

/// 使用随机数填充缓冲区
- (void)generateRandomFloatData:(id<MTLBuffer>) buffer {
    float* dataPtr = buffer.contents;
    for (unsigned long index = 0; index < arrayLength; index++) {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}

/// 从缓冲区读取结果
- (void)verifyResults {
    float* a = _mBufferA.contents;
    float* b = _mBufferB.contents;
    float* result = _mBufferResult.contents;
    
    /// 验证 CPU 和 GPU 计算结果是否相同
    for (unsigned long index = 0; index < arrayLength; index++) {
        if (result[index] != (a[index] + b[index])) {
            printf("计算差异: index=%lu result=%g vs %g=a+b\n",
                   index, result[index], a[index] + b[index]);
            assert(result[index] == (a[index] + b[index]));
        }
    }
    printf("计算结果符合预期 \n");
}

@end
