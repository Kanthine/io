//
//  MetalMesh.h
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
// 

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>

//NS_ASSUME_NONNULL_BEGIN

// 特定的子网格类，包含绘制子网格的数据
@interface MetalSubmesh : NSObject

// 一个包含基本类型、索引缓冲区和索引计数的 MetalKit 子网格，用来绘制 AAPLMesh 的全部或部分
@property (nonatomic, readonly, nonnull) MTKSubmesh *metalKitSubmmesh;

// 材质纹理(索引 AAPLTextureIndex)在绘制子网格之前在渲染命令编码器中设置
@property (nonatomic, readonly, nonnull) NSArray<id<MTLTexture>> *textures;

@end

// 指定的网格类，包含描述网格的顶点数据和描述如何绘制网格部分的子网格对象
@interface MetalMesh : NSObject

+ (nullable NSArray<MetalMesh*> *)newMeshesFromObject:(nonnull MDLObject*)object
                              modelIOVertexDescriptor:(nonnull MDLVertexDescriptor*)vertexDescriptor
                                metalKitTextureLoader:(MTKTextureLoader*_Nullable)textureLoader
                                          metalDevice:(nonnull id<MTLDevice>)device
                                                error:(NSError * __nullable * __nullable)error;

// @param url 根据提供的文件构造网格数组，该URL以模型I/O支持的格式表示模型文件的位置，如OBJ、ABC或USD。
// @param mdlVertexDescriptor 定义布局模型I/O将用来安排顶点数据，而bufferAllocator提供分配的缓冲区来存储顶点和索引数据
+ (nullable NSArray<MetalMesh *> *)newMeshesFromUrl:(nonnull NSURL *)url
                            modelIOVertexDescriptor:(nonnull MDLVertexDescriptor *)vertexDescriptor
                                        metalDevice:(nonnull id<MTLDevice>)device
                                              error:(NSError * __nullable * __nullable)error
                                               aabb:(MDLAxisAlignedBoundingBox&)aabb;

// 包含顶点缓冲描述网格形状的 MetalKit 网格
@property (nonatomic, readonly, nonnull) MTKMesh *metalKitMesh;

// 子网格数组，包含缓冲区和数据，我们可以用它们来绘制调用和材质数据，在渲染命令编码器中设置绘制调用
@property (nonatomic, readonly, nonnull) NSArray<MetalSubmesh*> *submeshes;

@end

//NS_ASSUME_NONNULL_END
