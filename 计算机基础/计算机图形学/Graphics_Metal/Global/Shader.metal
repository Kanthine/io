//
//  Shader.metal
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include <metal_stdlib>
using namespace metal;
#include "ShaderTypes.h"

typedef struct {
    /// 经过顶点着色器处理之后，顶点的剪辑空间位置
    /// Metal 没有对结构中的字段命名有特定约定，需要开发者告诉 Metal 光栅化数据中的哪个字段提供位置数据
    /// 属性限定符 [[position]] 声明 position 字段保存输出位置
    /// 位置信息必须定义为 vector_float4
    float4 position [[position]];
    float4 color; /// 栅格化阶段处理之后，将该值传递到片段着色器
    /// flat
    float2 textureCoordinate;
} YLShaderData;

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
vertex YLShaderData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex2D *vertices [[buffer(ShaderParamTypeVertices)]],
             constant vector_float2 *viewportSizePointer [[buffer(ShaderParamTypeViewport)]])
{
    YLShaderData out;
    
    // 根据索引 vertexID 获取当前顶点位置，单位为像素 (即值为100表示距离原点100个像素)
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    /// 若要将像素空间中的位置转换为剪辑空间中的位置，需要像素坐标除以视口大小的一半
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = 2.0 * pixelSpacePosition.xy / viewportSize;
    
    // 将输入的颜色直接传递给栅格化器
    out.color = vertices[vertexID].color;
    out.textureCoordinate = vertices[vertexID].texture;
    return out;
}

fragment float4 fragmentShader(YLShaderData in [[stage_in]]) {
    return in.color; // 返回插入的颜色
}

vertex YLShaderData
vertexShader_depth(uint vertexID [[ vertex_id ]],
                   const device Vertex3D *vertices [[buffer(ShaderParamTypeVertices)]],
                   constant vector_float2 &viewportSize [[buffer(ShaderParamTypeViewport)]]) {
    YLShaderData out;
    
    // 将原点为左上角的空间坐标转换为标准化的剪辑空间位置， 剪辑空间为[- 1,1]坐标范围
    float2 pixelPosition = float2(vertices[vertexID].position.xy);
    const vector_float2 floatViewport = vector_float2(viewportSize);
    const vector_float2 topDownClipSpacePosition = (pixelPosition.xy / (floatViewport.xy / 2.0)) - 1.0;
    
    // 世界 y 坐标自上而下，而剪辑空间坐标自下而上，所以需要对 y 坐标取反
    out.position.y = -1 * topDownClipSpacePosition.y;
    out.position.x = topDownClipSpacePosition.x;
    out.position.z = vertices[vertexID].position.z;
    out.position.w = 1.0;
    
    out.color = vertices[vertexID].color;
    return out;
}

/// 关于矩阵的计算有分为 CPU 计算和 GPU 计算两种。
/// 但是 GPU 有对矩阵的计算做了优化工作，所以我们尽量把矩阵的计算放到 GPU 上进行。
vertex YLShaderData
vertexRender_Transform_2D(const uint vertexID[[vertex_id]],
                       const device Vertex2D *vertexs[[buffer(ShaderParamTypeVertices)]],
                       const device Uniforms3x3 &uniforms[[buffer(ShaderParamTypeUniforms)]],
                       constant vector_float2 *viewportSize[[buffer(ShaderParamTypeViewport)]] ){
    YLShaderData out;
    float3 pixelSpacePosition = uniforms.worldMatrix * (vector_float3){vertexs[vertexID].position.x,vertexs[vertexID].position.y,1};
    out.position.xy = pixelSpacePosition.xy * 2.0 / (*viewportSize);
    out.position.z = 0.0;
    out.position.w = 1.0;
    out.color = vertexs[vertexID].color;
    return out;
};

vertex YLShaderData
vertexRender_Transform_3D(const uint vertexID[[vertex_id]],
                       const device Vertex3D *vertexs[[buffer(ShaderParamTypeVertices)]],
                       const device Uniforms &uniforms[[buffer(ShaderParamTypeUniforms)]]){
    YLShaderData out;
    float4 wordPosition = uniforms.worldMatrix * vertexs[vertexID].position;
    float4 seePosition = uniforms.viewMatrix * wordPosition;
    float4 projectionPosition = uniforms.projectionMatrix * seePosition;
    out.position = projectionPosition;
    out.color = vertexs[vertexID].color;
    out.textureCoordinate = vertexs[vertexID].texture;
    return out;
};

fragment float4 fragmentTextureShader(YLShaderData in [[stage_in]],
                                      texture2d<half> colorTexture[[texture(ShaderParamTypeTextureOutput)]]) {
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(colorSample);
}



// Rec. 709 为灰度图像转换的亮度值
constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

//灰度计算内核
kernel void
grayscaleKernel(texture2d<half, access::read>  inTexture  [[texture(ShaderParamTypeTextureInput)]],
                texture2d<half, access::write> outTexture [[texture(ShaderParamTypeTextureOutput)]],
                uint2                          gid        [[thread_position_in_grid]]) {
    
    //检查像素是否在输出纹理的边界内
    if((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height())) {
        return; //如果像素超出边界，则返回
    }

    half4 inColor  = inTexture.read(gid);
    half  gray     = dot(inColor.rgb, kRec709Luma);
    outTexture.write(half4(gray, gray, gray, 1.0), gid);
}

