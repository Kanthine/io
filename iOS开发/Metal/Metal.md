# Metal

* 图形处理器 (GPU) 旨在快速渲染图形并执行数据并行计算。
* 可以使用 [Metal](https://developer.apple.com/documentation/metal) 框架，与设备上可用的 GPU 直接通信。

# 1、使用 Metal 查找 GPU 并对其进行计算

[使用 Metal 查找 GPU 并对其进行计算](https://developer.apple.com/documentation/metal/basic_tasks_and_concepts/performing_calculations_on_a_gpu)

```
/// C 语言编写的两个数组元素相加
void add_arrays(const float* inA,
                const float* inB,
                float* result,
                int length) {
    for (int index = 0; index < length ; index++) {
        result[index] = inA[index] + inB[index];
    }
}
```

* 要在 GPU 上执行计算，需要使用 `Metal Shading Language` (MSL) 重写上述任务函数；
* MSL 是 C++ 的一种变体，专为 GPU 编程而设计；
* 在 Metal 中，在 GPU 上运行的代码称为 __着色器__，因为历史上它们首先用于计算 3D 图形中的颜色；

```
/** for循环被替换为一个线程集合，每个线程都调用这个函数
 * @param index Metal应该为每个线程计算一个唯一的索引，并在这个参数中传递该索引
 */
kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]]) {
    result[index] = inA[index] + inB[index];
}
```

`MSL` 函数使用了  `kernel` 来修饰：
* 关键字 `kernel` 声明一个函数为 `public GPU` 函数；
* 该 `public` 函数在应用程序中是唯一的；不能被其它 `MSL` 函数调用；

## 1.1、寻找 GPU

设备中可以有多个 `GPU`，Metal 需要选择其中一个可用的 `GPU` :

```
/// MTLDevice 是对 GPU 的抽象类，可以使用它与 GPU 进行通信。
/// 使用下述函数获取一个默认 GPU 
id<MTLDevice> device = MTLCreateSystemDefaultDevice();
```

## 1.2、做一些准备工作

### 1.2.1、获取 Metal 函数的引用

编译程序时，Xcode 会编译 `.metal` 文件中的函数并将其嵌入到  `Metal` 的默认库中；
因此我们需要拿到 默认库 实例，再获取  MSL 函数对象。


```
/// 创建一个默认库对象，此时会加载工程中扩展名为.metal的 shader 文件
id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
if (defaultLibrary == nil) {
    NSLog(@"Failed to find the default library.");
    return nil;
}

// 向默认库请求 MSL 函数的对象
id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
if (addFunction == nil)  {
    NSLog(@"Failed to find the adder function.");
    return nil;
}
```

### 1.2.2、获取 Metal 函数的可执行代码

`MSL` 函数对象仅仅作为代理，而非可执行代码；因此还需要创建一个 `Metal` 管道，将 `MSL` 代理转为可执行代码；
* 在 Metal 中，管道由 `MTLComputePipelineState` 实例表示；
* 创建 `MTLComputePipelineState` 实例时，`MTLDevice` 对象将为该 GPU 完成函数的编译；
* 注意：MTLDevice 对函数的编译是一个耗时操作，所以尽量异步创建 Metal 管道；

```
/// 同步创建一个 MTLComputePipelineState 对象
id<MTLComputePipelineState> mAddFunctionPSO = [device newComputePipelineStateWithFunction:addFunction error:&error];
if (mAddFunctionPSO == nil) {
    // 使用Xcode debug 程序时，默认开启 Metal API 验证，这样可以获取详细的出错信息
    NSLog(@"Failed to created pipeline state object, error %@.", error);
    return nil;
}
```

### 1.2.3、创建一个命令队列

Metal 通过对命令队列的调度将任务发送到 GPU。

```
/// 通过 MTLDevice 实例来创建一个命令队列 
id<MTLCommandQueue> mCommandQueue = [device newCommandQueue];
if (mCommandQueue == nil){
    NSLog(@"Failed to find the command queue.");
    return nil;
}
```

完成准备工作后，需要提供数据供 GPU 执行。

## 1.3、准备数据


* GPU 可以拥有自己的专用内存，也可以与操作系统共享内存。
* Metal 和操作系统内核需要执行额外的工作，将数据存储在内存中供 GPU 使用。
* Metal 使用 `MTLResource` 抽象了这种内存管理， 是 GPU 在运行命令时可以访问的内存分配。
* 使用 `MTLDevice` 为其 GPU 创建 `MTLBuffer`  实例，`MTLBuffer` 是没有预定义格式的内存分配；
* Metal 将每个缓冲区作为一个不透明的字节集合进行管理；
* 如果在着色器中使用缓冲区时指定数据格式，那么着色器和程序需要保持数据格式一致；
* `MTLResourceOptions` ： CPU 或 GPU 是否可以访问该存储区的一种存储模式；
* `MTLResourceStorageModeShared` ：共享内存， CPU 或 GPU 都可以访问；

```
const unsigned int arrayLength = 1 << 24;
const unsigned int bufferSize = arrayLength * sizeof(float);

{
    id<MTLBuffer> mBufferA = [device newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    id<MTLBuffer> mBufferB = [device newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    
    /// 不妨使用随机数据填充前两个缓冲区
    [self generateRandomFloatData:mBufferA];
    [self generateRandomFloatData:mBufferB];
    
    /// 缓存 GPU 的运算结果
    id<MTLBuffer> mBufferResult = [device newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
}

/// 使用随机数填充缓冲区，完成测试
- (void)generateRandomFloatData:(id<MTLBuffer>) buffer {
    float* dataPtr = buffer.contents;
    for (unsigned long index = 0; index < arrayLength; index++) {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}
```

## 1.4、调度任务


### 1.4.1、为队列创建一个命令缓冲区

```
id<MTLCommandBuffer> commandBuffer = [mCommandQueue commandBuffer];
assert(commandBuffer != nil);
```

### 1.4.2、创建命令编码器

要将命令写入命令​​缓冲区，还需要对命令编码。
创建命令编码器，它对计算通道进行编码。
计算通道包含执行计算管道的命令列表。
每个计算命令都会使 GPU 创建一个线程网格以在 GPU 上执行。

```
/// 计算命令编码器对计算通道进行编码。计算通道包含执行计算管道的命令列表。
/// 每个计算命令都会使 GPU 创建一个线程网格以在 GPU 上执行
id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
assert(computeEncoder != nil);
```

要对命令进行编码，您需要对编码器进行一系列方法调用。一些方法设置状态信息，例如管道状态对象 (PSO) 或要传递给管道的参数。进行这些状态更改后，您可以对命令进行编码以执行管道。编码器将所有状态变化和命令参数写入命令缓冲区。

