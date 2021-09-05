# 

[CIContext](https://developer.apple.com/documentation/coreimage/cicontext?changes=latest_minor)
 用于渲染图像处理结果和执行图像分析的评估上下文。
 
 CIContext类为使用Quartz 2D，Metal或OpenGL的Core Image处理提供评估上下文。可以将CIContext对象与其他Core Image类（如CIFilter，CIImage和CIColor）结合使用，以使用Core Image过滤器处理图像。还可以使用Core Image上下文与CIDetector类来分析图像:如，检测人脸或条形码。
 
 CIContext和CIImage对象是不可变的，因此多个线程可以使用相同的CIContext对象来呈现CIImage对象。但是，CIFilter对象是可变的，因此无法在线程之间安全地共享。每个线程必须创建自己的CIFilter对象，但是可以在线程之间传递CIFilter的不可变输入和输出CIImage对象。
 
 
 Creating a Context Without Specifying a Destination
 1、在不指定目标的情况下创建上下文
 
 
 
 Creating a Context for CPU-Based Rendering
 2、为基于CPU的渲染创建上下文
 
 
 
 
 Creating a Context for GPU-Based Rendering with OpenGL
 3、使用OpenGL为基于GPU的渲染创建上下文
 
 
 
 Creating a Context for GPU-Based Rendering with Metal
 4、使用Metal创建基于GPU的渲染的上下文
 
 
 
 Rendering Images
 5、渲染图像
 
 

 
 Drawing Images
 6、绘图图像
 
 
 
 Determining the Allowed Extents for Images Used by a Context
 7、确定上下文使用的映像的允许范围
 
 
 
 
 
 Managing Resources
8、管理资源
 
 
 
 
 Rendering Images for Data or File Export
9、渲染数据或文件导出的图像
 
 
 
 Constants
 10、常量
 
 
 
 
 
 Customizing Render Destination
11、自定义渲染目标
 
 
 
 
 Instance Methods
 12、实例方法
