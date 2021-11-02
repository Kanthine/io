//
//  Shape2D.hpp
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#ifndef Shape2D_hpp
#define Shape2D_hpp

#include <stdio.h>
#include "ShaderTypes.h"
#import <simd/simd.h>

/// 三角形
Vertex2D *equilateralTriangle_2D(vector_float2 center,
                                 float lengthOfSide,
                                 int *size);

/// 矩形
Vertex2D *rect_2D(vector_float2 origin,
                  vector_float2 size,
                  int *vertexsSize);

/// 圆形
Vertex2D *circle_2D(vector_float2 center,
                    float radius,
                    int *size);

/// 极坐标系展示
Vertex2D *polarCoordinates_2D(vector_float2 center,
                              float maxRadius,
                              int *size);

/// 字母 F
Vertex2D *f_2D(vector_float2 origin,
               vector_float2 size,
               float thickness,
               int *count);

#endif
