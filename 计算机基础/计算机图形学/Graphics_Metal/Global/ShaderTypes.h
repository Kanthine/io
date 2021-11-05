//
//  ShaderTypes.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum ShaderParamType {
    ShaderParamTypeVertices = 0,
    ShaderParamTypeViewport,
    ShaderParamTypeTextureInput,
    ShaderParamTypeTextureOutput,
    ShaderParamTypeUniforms,
} ShaderParamType;

typedef struct {
    vector_float2 position;
    vector_float4 color;
    vector_float2 texture;
} Vertex2D;

typedef struct {
    vector_float4 position;
    vector_float4 color;
    vector_float2 texture;
} Vertex3D;

/// 保存常量数据
typedef struct {
    matrix_float4x4 worldMatrix; /// 模型从模型坐标转换到世界坐标：平移、旋转、缩放等最终形成的复合变换
    matrix_float4x4 viewMatrix; ///  世界坐标到相机坐标上的转换：两个坐标系的切换
    matrix_float4x4 projectionMatrix; /// 透视投影：使得在平面上产生物体近大远小的效果
} Uniforms;

typedef struct {
    matrix_float3x3 worldMatrix; /// 模型从模型坐标转换到世界坐标：平移、旋转、缩放等最终形成的复合变换
    matrix_float3x3 viewMatrix; ///  世界坐标到相机坐标上的转换：两个坐标系的切换
    matrix_float3x3 projectionMatrix; /// 透视投影：使得在平面上产生物体近大远小的效果
} Uniforms3x3;


typedef struct {
    uint8_t blue;
    uint8_t green;
    uint8_t red;
    uint8_t alpha;
} PixelBGRA8Unorm;

#define uniforms_default (Uniforms){ \
    (matrix_float4x4){ \
        { \
            {1, 0, 0, 0}, \
            {0, 1, 0, 0}, \
            {0, 0, 1, 0}, \
            {0, 0, 0, 1}  \
        } \
    }, \
    (matrix_float4x4){ \
        { \
            {1, 0, 0, 0}, \
            {0, 1, 0, 0}, \
            {0, 0, 1, 0}, \
            {0, 0, 0, 1} \
        } \
    }, \
    (matrix_float4x4){ \
        { \
            {1, 0, 0, 0}, \
            {0, 1, 0, 0}, \
            {0, 0, 1, 0}, \
            {0, 0, 0, 1} \
        } \
    } \
}; \

 

#endif
