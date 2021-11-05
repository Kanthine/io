//
//  MatrixTransform.c
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include "MatrixTransform.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

matrix_float3x3 rotate_2D(float angle) {
    return (matrix_float3x3){
        {
            { cos(angle), sin(angle), 0},
            {-sin(angle), cos(angle), 0},
            {          0,          0, 1}
        }
    };
}






/// 构造一个单位矩阵
matrix_float3x3 __attribute__((__overloadable__)) matrix3x3_identity(void){
    return (matrix_float3x3){
        {
            {1.0, 0, 0},
            {0, 1.0, 0},
            {0, 0, 1.0}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__))  matrix4x4_identity(void) {
    return (matrix_float4x4){
        {
            {1.0, 0, 0, 0},
            {0, 1.0, 0, 0},
            {0, 0, 1.0, 0},
            {0, 0, 0, 1.0}
        }
    };
}

/// 构造一个缩放矩阵，使用给定的向量作为缩放因子数组。
matrix_float3x3 __attribute__((__overloadable__)) matrix3x3_scale(float sx, float sy){
    return (matrix_float3x3){
        {
            {sx, 0, 0},
            {0, sy, 0},
            {0, 0, 1}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_scale(float sx, float sy, float sz) {
    return (matrix_float4x4){
        {
            {sx, 0, 0, 0},
            {0, sy, 0, 0},
            {0, 0, sz, 0},
            {0, 0, 0, 1}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_scale(vector_float3 s) {
    return (matrix_float4x4){
        {
            {s.x, 0, 0, 0},
            {0, s.y, 0, 0},
            {0, 0, s.z, 0},
            {0, 0, 0, 1}
        }
    };
}


/// 根据给定的角度和轴构造一个旋转矩阵
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotation(float angle, vector_float3 axis){
    axis = vector_normalize(axis);
    float ct = cosf(angle);
    float st = sinf(angle);
    float ci = 1 - ct;
    float x = axis.x, y = axis.y, z = axis.z;
    return (matrix_float4x4){
        {
            {    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0},
            {x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0},
            {x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0},
            {                  0,                   0,                   0, 1}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotation(float radians, float x, float y, float z) {
    return matrix4x4_rotation(radians, (vector_float3){x, y, z});
}

/** 3D 旋转（逆时针旋转 angle 度）
 * 以 X 轴旋转，是 YZ 组成的 2D 坐标系在旋转，x 值不变
 * 以 Y 轴旋转，是 XZ 组成的 2D 坐标系在旋转，y 值不变
 * 以 Z 轴旋转，是 XY 组成的 2D 坐标系在旋转，z 值不变
 */
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotationX(float angle) {
    return (matrix_float4x4){
        {
            {1,           0,          0, 0},
            {0,  cos(angle), sin(angle), 0},
            {0, -sin(angle), cos(angle), 0},
            {0,           0,          0, 1}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotationY(float angle) {
    return (matrix_float4x4){
        {
            {cos(angle), 0, -sin(angle), 0},
            {         0, 1,           0, 0},
            {sin(angle), 0,  cos(angle), 0},
            {         0, 0,           0, 1}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_rotationZ(float angle) {
    return (matrix_float4x4){
        {
            { cos(angle), sin(angle), 0, 0},
            {-sin(angle), cos(angle), 0, 0},
            {          0,          0, 1, 0,},
            {          0,          0, 0, 1}
        }
    };
}


matrix_float3x3 __attribute__((__overloadable__)) matrix3x3_translation(float tx, float ty){
    return (matrix_float3x3){
        {
            { 1,  0, 0},
            { 0,  1, 0},
            {tx, ty, 1}
        }
    };
}

/// 构造一个平移矩阵，平移向量(tx, ty, tz)
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_translation(float tx, float ty, float tz) {
    return (matrix_float4x4){
        {
            { 1,  0,  0, 0},
            { 0,  1,  0, 0},
            { 0,  0,  1, 0},
            {tx, ty, tz, 1}
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_translation(vector_float3 t){
    return (matrix_float4x4){
        {
            {  1,   0,   0, 0},
            {  0,   1,   0, 0},
            {  0,   0,   1, 0},
            {t.x, t.y, t.z, 1}
        }
    };
}

/// 构造一个复合矩阵：由向量缩放因子 s 缩放，并由向量(t.x, t.y, t.z)平移。
matrix_float4x4 __attribute__((__overloadable__)) matrix4x4_scale_translation(vector_float3 s, vector_float3 t) {
    return (matrix_float4x4){
        {
            {s.x,   0,   0, 0},
            {  0, s.y,   0, 0},
            {  0,   0, s.z, 0},
            {t.x, t.y, t.z, 1}
        }
    };
}

