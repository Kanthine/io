//
//  MeshShader.metal
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include <metal_stdlib>
using namespace metal;
#include "ShaderTypes.h"


struct Vertex {
    float3 position  [[attribute(VertexAttributePosition)]];
    float2 texCoord  [[attribute(VertexAttributeTexcoord)]];
    half3  normal    [[attribute(VertexAttributeNormal)]];
    half3  tangent   [[attribute(VertexAttributeTangent)]];
    half3  bitangent [[attribute(VertexAttributeBitangent)]];
};

struct ColorInOut {
    float4 position [[position]];
    float2 texCoord;
    
    float4  worldPos;
    half3  tangent;
    half3  bitangent;
    float4  normal;
};

// Vertex function
vertex ColorInOut vertexTransform_mesh(const Vertex in [[ stage_in ]]) {
    ColorInOut out;
    float4 position = vector_float4(in.position/500.0f + float3(0,-0.3,0), 1.0);
    out.position = position;
    out.texCoord = in.texCoord;
    return out;
}

// Vertex function
vertex ColorInOut vertexTransform_Uniform(const Vertex in [[ stage_in ]],
                                     const device Uniforms &uniforms[[buffer(ShaderParamTypeUniforms)]]) {
    ColorInOut out;
    
    float4 position = vector_float4(in.position/500.0f + float3(0,-0.3,0), 1.0);
    float4 wordPosition = uniforms.worldMatrix * position;
    float4 seePosition = uniforms.viewMatrix * wordPosition;
    float4 projectionPosition = uniforms.projectionMatrix * seePosition;
    out.position = projectionPosition;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentGround_mesh( ColorInOut in [[ stage_in ]]) {
    float onEdge;
    {
        float2 onEdge2d = fract(float2(in.worldPos.xz)/500.f);
        // If onEdge2d is negative, we want 1. Otherwise, we want zero (independent for each axis).
        float2 offset2d = sign(onEdge2d) * -0.5 + 0.5;
        onEdge2d += offset2d;
        onEdge2d = step (0.03, onEdge2d);

        onEdge = min(onEdge2d.x, onEdge2d.y);
    }

    float3 neutralColor = float3 (0.9, 0.9, 0.9);
    float3 edgeColor = neutralColor * 0.2;
    float3 groundColor = mix (edgeColor, neutralColor, onEdge);

    return float4 (groundColor, 1.0);
}

fragment half4 fragmentChromeLighting ( ColorInOut        in             [[ stage_in ]],
                                        texture2d<half> baseColorMap [[ texture (TextureIndexBaseColor) ]] ) {
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
    half4 color_sample  = baseColorMap.sample(linearSampler,in.texCoord.xy);
    return color_sample;
}


vertex ColorInOut vertexTransform_Uniform_3(const Vertex in [[ stage_in ]],
                                     const device Uniforms &uniforms[[buffer(ShaderParamTypeUniforms)]]) {
    ColorInOut out;
    
    float4 position = vector_float4(in.position/500.0f + float3(0,-0.3,0), 1.0);
    float4 wordPosition = uniforms.worldMatrix * position;
    float4 seePosition = uniforms.viewMatrix * wordPosition;
    float4 projectionPosition = uniforms.projectionMatrix * seePosition;
    out.position = projectionPosition;
    out.texCoord = in.texCoord;
    out.normal = normalize(uniforms.worldMatrix * float4((float3)in.normal,0));
    return out;
}

fragment half4 fragmentChromeLighting_3(ColorInOut in [[ stage_in ]],
                              constant Uniforms & uniforms [[ buffer(ShaderParamTypeUniforms) ]],
                              texture2d<half> baseColorMap [[ texture(0) ]])
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
    
    half4 color_sample  = baseColorMap.sample(linearSampler,in.texCoord.xy);

    float3 N = float3(in.normal.xyz);
    float3 L = normalize(-uniforms.directionalLightDirection);
    
    // Lambert diffuse
    float diffuse = uniforms.IL * uniforms.Kd * max(dot(N,L),0.0);
    
    float3 out = float3(uniforms.directionalLightColor) * float3(color_sample.xyz) * diffuse;
    
    return half4(half3(out.xyz),1.0f);
}



fragment half4 fragmentChromeLighting_4(ColorInOut in [[ stage_in ]],
                              constant Uniforms & uniforms [[ buffer(ShaderParamTypeUniforms) ]],
                              texture2d<half> baseColorMap [[ texture(0) ]])
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
    
    half4 color_sample  = baseColorMap.sample(linearSampler,in.texCoord.xy);
    
    // 法线
    float3 N = in.normal.xyz;
    // 入射光方向
    float3 L = - normalize(uniforms.directionalLightDirection);
    // 视线方向
    float3 V = normalize(uniforms.cameraPos - in.worldPos.xyz);
    // 反射光方向
    float3 R = normalize(2 * fmax(dot(N, L), 0) * N - L);
    
    // Lambert diffuse
    float diffuse = uniforms.IL * uniforms.Kd * max(dot(float3(in.normal.xyz),L),0.0);
    
    // Specular
    float specular = uniforms.IL * uniforms.Ks * pow(fmax(dot(V, R), 0), uniforms.shininess);
    
    // Phong Model
    float3 out = float3(uniforms.directionalLightColor) * float3(color_sample.xyz) * (diffuse + specular);
    
    return half4(half3(out.xyz),1.0f);
}



fragment half4 fragmentChromeLighting_5(ColorInOut in [[ stage_in ]],
                              constant Uniforms & uniforms [[ buffer(ShaderParamTypeUniforms) ]],
                              texture2d<half> baseColorMap [[ texture(0) ]])
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
    
    half4 color_sample  = baseColorMap.sample(linearSampler,in.texCoord.xy);
    
    // 法线
    float3 N = in.normal.xyz;
    // 入射光方向
    float3 L = - normalize(uniforms.directionalLightDirection);
    // 视线方向
    float3 V = normalize(uniforms.cameraPos - in.worldPos.xyz);
    // 反射光方向
    float3 R = normalize(2 * fmax(dot(N, L), 0) * N - L);
    
    // Lambert diffuse
    float diffuse = uniforms.IL * uniforms.Kd * max(dot(float3(in.normal.xyz),L),0.0);
    
    // Specular
    float specular = uniforms.IL * uniforms.Ks * pow(fmax(dot(V, R), 0), uniforms.shininess);
    
    // Ambient Glow
    float ambient = uniforms.Ia * uniforms.Ka;
    
    float3 out = float3(uniforms.directionalLightColor) * float3(color_sample.xyz) * (diffuse + specular + ambient);
    
    return half4(half3(out.xyz),1.0f);
}
