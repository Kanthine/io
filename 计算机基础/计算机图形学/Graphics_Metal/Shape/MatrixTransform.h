//
//  MatrixTransform.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//
// 注意⚠️：图形引擎需要传入的矩阵做一次转置

#ifndef MatrixTransform_h
#define MatrixTransform_h

#include <stdio.h>
#import <simd/simd.h>

matrix_float3x3 rotate_2D(float angle);




/// 构造一个单位矩阵
matrix_float3x3 __attribute__((__overloadable__)) matrix3x3_identity(void);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_identity(void);

/// 根据给定的角度和轴构造一个旋转矩阵
/** 构造旋转矩阵
 * @param angle 旋转角度
 * @param axis 旋转轴；
 *             如{0, 1, 0} 绕 Y 轴旋转 angle 度
 */
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotation(float angle, vector_float3 axis);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotation(float angle, float x, float y, float z);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotationX(float angle);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotationY(float angle);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotationZ(float angle);

/// 构造一个缩放矩阵，使用给定的向量作为缩放因子数组。
matrix_float3x3 __attribute__((__overloadable__)) matrix3x3_scale(float sx, float sy);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_scale(float sx, float sy, float sz);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_scale(vector_float3 s);

/// 构造一个平移矩阵，平移向量(tx, ty, tz)
matrix_float3x3 __attribute__((__overloadable__)) matrix3x3_translation(float tx, float ty);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_translation(float tx, float ty, float tz);
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_translation(vector_float3 t);

/// 构造一个复合矩阵：由向量缩放因子 s 缩放，并由向量(t.x, t.y, t.z)平移。
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_scale_translation(vector_float3 s, vector_float3 t);

#endif /* MatrixTransform_h */


/**
 * 视口，即是屏幕指定的矩形区域
 * 一般情况下，需要保证近平面的宽高比于视口的宽高比相同，否则显示在屏幕上的图像会拉伸变形
 */
