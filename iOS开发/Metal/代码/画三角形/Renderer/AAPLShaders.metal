/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used for this sample
*/

#include <metal_stdlib>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands.
#include "AAPLShaderTypes.h"

/// 顶点着色器输出，碎片着色器输入
struct RasterizerData {
    /// 经过顶点着色器处理之后，顶点的剪辑空间位置
    /// Metal 没有对结构中的字段命名有特定约定，需要开发者告诉 Metal 光栅化数据中的哪个字段提供位置数据
    /// 属性限定符 [[position]] 声明 position 字段保存输出位置
    /// 位置信息必须定义为 vector_float4
    float4 position [[position]];
    float4 color; /// 栅格化阶段处理之后，将该值传递到片段着色器
};

/**  使用关键字 vertex 声明顶点着色器
 * @param vertexID 使用属性限定符 [vertex_id]]，这是另一个 Metal 关键字；
 *        执行渲染命令时，GPU 会多次调用顶点函数，为每个顶点生成一个唯一值；
 * @param vertices 包含顶点数据的数组
 * @param viewportSizePointer 为了将传入位置转换为Metal的坐标，顶点函数需要计算三角形的视口大小(以像素为单位)，
 *                            计算结果被存储在 viewportSizePointer 参数中；
 * @return 返回结构体 RasterizerData
 * @note 默认情况下，Metal 自动在参数表中为每个参数分配 slots；
 *       参数 2 与参数 3 使用属性限定符 [[buffer(n)]]，显示指定 Metal 要使用哪个 slot ；
 *       显式指定 slot 可以使修改着色器更容易，而不需要改变程序代码；
 */
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant AAPLVertex *vertices [[buffer(AAPLVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(AAPLVertexInputIndexViewportSize)]])
{
    RasterizerData out; // 需要生位置与颜色两个字段

    // 根据索引 vertexID 获取当前顶点位置，单位为像素 (即值为100表示距离原点100个像素)
    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    // 获取 viewport 大小并转换为 vector_float2
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    /// 若要将像素空间中的位置转换为剪辑空间中的位置，需要像素坐标除以视口大小的一半
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);

    // 将输入的颜色直接传递给栅格化器
    out.color = vertices[vertexID].color;

    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]]) {
    return in.color; // 返回插入的颜色
}

