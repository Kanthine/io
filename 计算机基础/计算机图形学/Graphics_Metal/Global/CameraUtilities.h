//
//  CameraUtilities.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#ifndef CameraUtilities_h
#define CameraUtilities_h

#include <stdio.h>
#import <simd/simd.h>

struct Camera {
    vector_float3 position;
    vector_float3 target;
    float rotation;
    float aspectRatio;      // width/height
    float fovVert_Half;     // 垂直视场的一半，以弧度表示
    float distanceNear;
    float distanceFar;
};

struct CameraProbe {
    vector_float3 position;
    float distanceNear;
    float distanceFar;
};



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
matrix_float4x4 __attribute__((__overloadable__))
matrix_look_at_left_hand(vector_float3 eye, vector_float3 target, vector_float3 up);
matrix_float4x4 __attribute__((__overloadable__))
matrix_look_at_left_hand(float eyeX, float eyeY, float eyeZ,
                         float centerX, float centerY, float centerZ,
                         float upX, float upY, float upZ);
matrix_float4x4 __attribute__((__overloadable__)) lookAt(float eyeX, float eyeY, float eyeZ,
                         float angleX, float angleY, float angleZ);

/** 透视投影：远小近大的效果
 * @param fovy 表示相机视场的角度
 * @param aspect 视口的宽高比（视口，即是屏幕指定的矩形区域）
 * @param zNear 相机与近平面距离
 * @param zFar 相机与远平面距离
 */
matrix_float4x4 perspective(float fovy,
                            float aspect,
                            float zNear,
                            float zFar);
matrix_float4x4 __attribute__((__overloadable__)) matrix_perspective_left_hand(float fovy, float aspect, float zNear, float zFar);
matrix_float4x4 __attribute__((__overloadable__)) matrix_perspective_right_hand(float fovy, float aspect, float zNear, float zFar);

#endif
