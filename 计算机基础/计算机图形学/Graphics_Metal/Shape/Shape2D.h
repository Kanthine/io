//
//  Shape2D.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#ifndef Shape2D_h
#define Shape2D_h

#include <stdio.h>
#include "ShaderTypes.h"
#import <simd/simd.h>

/// 三角形
Vertex2D *equilateralTriangle_2D(float lengthOfSide,
                                 int *size);

/// 菱形
Vertex2D *rhombus_2D(float lengthOfSide,
                     int *size);


/// 矩形
Vertex2D *rect_2D(vector_float2 size,
                  int *vertexsSize);

/// 圆形
Vertex2D *circle_2D(float radius,
                    float borderWidth,
                    int *size);

/// 极坐标系展示
Vertex2D *polarCoordinates_2D(float maxRadius,
                              float borderWidth,
                              int *size);

/** 字母 F
 */
Vertex2D *f_2D(vector_float2 size,
               float boardWidth,
               int *count);

/** 字母 Hello
 */
Vertex2D *hello_2D(int *count);



#endif


