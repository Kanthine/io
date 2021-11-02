//
//  CameraUtilities.c
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include "CameraUtilities.h"
#include "MatrixTransform.h"

#pragma mark - public func

matrix_float4x4 __attribute__((__overloadable__)) matrix_look_at_left_hand(float eyeX, float eyeY, float eyeZ,
                                                            float centerX, float centerY, float centerZ,
                                                            float upX, float upY, float upZ) {
    vector_float3 eye = (vector_float3){ eyeX, eyeY, eyeZ };
    vector_float3 center = (vector_float3){ centerX, centerY, centerZ };
    vector_float3 up = (vector_float3){ upX, upY, upZ };
    return matrix_look_at_left_hand(eye, center, up);
}

/**
 * 向量 a = (Xa, Ya, Za);
 * 向量 b = (Xb, Yb, Zb);
 *
 * 向量a与b的数量积 a·b = Xa·Xb + Ya·Yb + Za·Zb;
 * 向量a点乘向量b   a·b = Xa·Xb + Ya·Yb + Za·Zb;
 *
 * 向量积 ≠ 向量的积
 * 向量积，数学中又称外积、叉积，物理中称矢积、叉乘，运算结果是一个向量！
 *
 * 向量积的模长：共起点的前提下 θ 表示两向量之间的夹角（0°≤θ≤180°），它位于这两个矢量所定义的平面上
 *            a∧b = |a|·|b|·sin(θ)
 * 向量积的方向：向量a与向量b的向量积的方向与这两个向量所在平面垂直，且遵守右手定则：
 *            当右手的四指从a以不超过180度的转角转向b时，竖起的大拇指指向是c的方向。
 */

/** 构建一个观察矩阵
 *  摄像机的设置由三部分组成：摄像机位置，视线方向，以及摄像机顶端指向
 * @param eye 摄像机在世界坐标系的位置
 * @param target 摄像机镜头的指向，用一个点来确定；
 *               通过摄像机位置与观察点可以确定一个向量，此向量代表了摄像机镜头的指向；
 * @param up 摄像机顶端的指向
 *           向量 (upX, upY, upZ) 表示在 X、Y、Z 轴的分量；
 *
 * 摄像机的位置、朝向、up方向可以有很多种不同的组合
 *   如同样的位置可以有不同的朝向、不同的 up 方向；
 *     不同的位置可以有相同的朝向、相同的 up 方向；
 */
matrix_float4x4 __attribute__((__overloadable__)) matrix_look_at_left_hand(vector_float3 eye,
                                                            vector_float3 target,
                                                            vector_float3 up) {
    /// 观察坐标系的 Z 轴：通过观察点坐标 与 视线上某一物体 坐标，计算出视线方向
    vector_float3 z = vector_normalize(target - eye);
    /// 观察坐标系的 X 轴
    vector_float3 x = vector_normalize(vector_cross(up, z));
    /// 观察坐标系的 Y 轴
    vector_float3 y = vector_cross(z, x);
    /// 平移矩阵
    vector_float3 t = (vector_float3){ -vector_dot(x, eye), -vector_dot(y, eye), -vector_dot(z, eye) };
    
    return (matrix_float4x4){
        {
            { x.x, y.x, z.x, 0 },
            { x.y, y.y, z.y, 0 },
            { x.z, y.z, z.z, 0 },
            { t.x, t.y, t.z, 1 }
        }
    };
}

matrix_float4x4 __attribute__((__overloadable__))  matrix_perspective_left_hand(float fovy, float aspect, float nearZ, float farZ) {
    float f = tan(M_PI_2 - 0.5 * fovy);
    float zs = farZ / (farZ - nearZ);
    return (matrix_float4x4){
        {
            {f / aspect, 0,           0, 0},
            {         0, f,           0, 0},
            {         0, 0,          zs, 1},
            {         0, 0, -nearZ * zs, 0}
        }
    };
}

/// 物体的运动是相对的
matrix_float4x4 __attribute__((__overloadable__)) lookAt(float eyeX, float eyeY, float eyeZ,
                         float angleX, float angleY, float angleZ) {
    matrix_float4x4 matrix = matrix_multiply(matrix4x4_identity(), matrix4x4_translation(-eyeX, -eyeY, -eyeZ));
    matrix = matrix_multiply(matrix, matrix4x4_rotationX(-angleX));
    matrix = matrix_multiply(matrix, matrix4x4_rotationY(-angleY));
    matrix = matrix_multiply(matrix, matrix4x4_rotationZ(-angleZ));
    return matrix;
}

matrix_float4x4 __attribute__((__overloadable__)) matrix_perspective_right_hand(float fovy, float aspect, float nearZ, float farZ) {
    float f = tan(M_PI_2 - 0.5 * fovy);
    float zs = farZ / (nearZ - farZ);
    return (matrix_float4x4){
        {
            {f / aspect, 0,          0, 0},
            {         0, f,          0, 0},
            {         0, 0,         zs,-1},
            {         0, 0, nearZ * zs, 0}
        }
    };
}

/// 透视投影
matrix_float4x4 perspective(float fovy,
                            float aspect,
                            float zNear,
                            float zFar) {
    float f = tan(M_PI_2 - 0.5 * fovy);
    float zs = zFar / (zNear - zFar);

    return (matrix_float4x4){
        {
            {f / aspect, 0,                                   0,  0},
            {         0, f,                                   0,  0},
            {         0, 0,     (zNear + zFar) / (zNear - zFar), -1},
            {         0, 0, zNear * zFar * 2.0 / (zNear - zFar),  0}
        }
    };
}
