//
//  Vertex2D.cpp
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include "Vertex2D.hpp"
#include <stdlib.h>
#include <string.h>
#include <math.h>

Vertex2D *equilateralTriangle_2D(vector_float2 center,
                                 float lengthOfSide,
                                 int *size) {
    *size = 3;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    array[0] = (Vertex2D){ { center.x - 0.5 * lengthOfSide, center.y - 0.5 * lengthOfSide},  { 1, 0, 0, 1 } };
    array[1] = (Vertex2D){ { center.x + 0.0 * lengthOfSide, center.y + 0.5 * lengthOfSide},  { 0, 1, 0, 1 } };
    array[2] = (Vertex2D){ { center.x + 0.5 * lengthOfSide, center.y - 0.5 * lengthOfSide},  { 0, 0, 1, 1 } };
    return array;
}

/// 返回二维 F
Vertex2D *f_2D(vector_float2 origin,
               vector_float2 size,
               float thickness,
               int *count) {
    *count = 18;
    Vertex2D *array = calloc(*count, sizeof(Vertex2D));
    
    // left column
    array[0] = (Vertex2D){{  origin.x,  origin.y }, { 1, 0, 0, 1 } };
    array[1] = (Vertex2D){ { origin.x + thickness, origin.y }, { 0, 1, 0, 1 } };
    array[2] = (Vertex2D){ { origin.x, origin.y - size.y }, { 0, 0, 1, 1 } };
    array[3] = (Vertex2D){ { origin.x, origin.y - size.y }, { 1, 0, 0, 1 } };
    array[4] = (Vertex2D){ { origin.x + thickness, origin.y }, { 0, 1, 0, 1 } };
    array[5] = (Vertex2D){ { origin.x + thickness, origin.y - size.y}, { 0, 0, 1, 1 } };
    
    // top rung
    array[6] = (Vertex2D){ {  origin.x + thickness, origin.y }, { 1, 0, 0, 1 } };
    array[7] = (Vertex2D){ {  origin.x + size.x, origin.y}, { 0, 1, 0, 1 } };
    array[8] = (Vertex2D){ {  origin.x + thickness, origin.y - thickness}, { 0, 0, 1, 1 } };
    array[9] = (Vertex2D){ {  origin.x + thickness, origin.y - thickness}, { 1, 0, 0, 1 } };
    array[10] = (Vertex2D){ {  origin.x + size.x, origin.y}, { 0, 1, 0, 1 } };
    array[11] = (Vertex2D){ {  origin.x + size.x, origin.y - thickness}, { 0, 0, 1, 1 } };
    
    // middle rung
    array[12] = (Vertex2D){ {  origin.x + thickness, origin.y - thickness * 2}, { 1, 0, 0, 1 } };
    array[13] = (Vertex2D){ {  origin.x + size.x * 2 / 3.0, origin.y - thickness * 2}, { 0, 1, 0, 1 } };
    array[14] = (Vertex2D){ {  origin.x + thickness, origin.y - thickness * 3}, { 0, 0, 1, 1 } };
    array[15] = (Vertex2D){ {  origin.x + thickness, origin.y - thickness * 3}, { 1, 0, 0, 1 } };
    array[16] = (Vertex2D){ {  origin.x + size.x * 2 / 3.0, origin.y - thickness * 2}, { 0, 1, 0, 1 } };
    array[17] = (Vertex2D){ {  origin.x + size.x * 2 / 3.0, origin.y - thickness * 3}, { 0, 0, 1, 1 } };
    return array;
}

Vertex2D *rect_2D(vector_float2 origin,
                  vector_float2 size,
                  int *vertexsSize) {
    *vertexsSize = 6;
    Vertex2D *array = calloc(*vertexsSize, sizeof(Vertex2D));
    
    array[0] = (Vertex2D){{  origin.x,  origin.y }, { 1, 0, 0, 1 } };
    array[1] = (Vertex2D){ {origin.x + size.x, origin.y }, { 0, 1, 0, 1 } };
    array[2] = (Vertex2D){ { origin.x, origin.y - size.y }, { 0, 0, 1, 1 } };
    array[3] = (Vertex2D){ { origin.x, origin.y - size.y }, { 1, 0, 0, 1 } };
    array[4] = (Vertex2D){ { origin.x + size.x, origin.y - size.y }, { 0, 1, 0, 1 } };
    array[5] = (Vertex2D){ { origin.x + size.x, origin.y }, { 0, 0, 1, 1 } };
    return array;
}

/**
 * 圆上的某一点 (x, y) = {radius * cos(angle), radius * sin(angle)}
 */
Vertex2D *circle_2D(vector_float2 center,
                    float radius,
                    int *size) {
    *size = 720;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    double angle = 0.0;
    int index = 0;
    while (angle <= M_PI * 2.0) {
        float x = center.x + radius * cos(angle);
        float y = center.y + radius * sin(angle);
        array[index++] = (Vertex2D){{x, y}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        angle += M_PI_2 / 180.0;
    }
    return array;
}


Vertex2D *polarCoordinates_2D(vector_float2 center,
                              float maxRadius,
                              int *size) {
    *size = maxRadius * 100;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    
    double radius = 0.0, angle = 0.0;
    int index = 0;
    while (radius <= maxRadius) {
        float x = center.x + radius * cos(angle);
        float y = center.y + radius * sin(angle);
        array[index++] = (Vertex2D){{x * 20, y * 20}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        radius += 0.01;
        angle += 0.02;
    }
    return array;
}
