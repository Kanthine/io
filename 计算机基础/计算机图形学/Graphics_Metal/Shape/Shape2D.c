//
//  Shape2D.c
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include "Shape2D.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

Vertex2D *equilateralTriangle_2D(float lengthOfSide,
                                 int *size) {
    *size = 3;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    array[0] = (Vertex2D){ { -0.5 * lengthOfSide, -0.5 * lengthOfSide},  { 1, 0, 0, 1 } };
    array[1] = (Vertex2D){ { 0.0 * lengthOfSide, 0.5 * lengthOfSide},  { 0, 1, 0, 1 } };
    array[2] = (Vertex2D){ { 0.5 * lengthOfSide, -0.5 * lengthOfSide},  { 0, 0, 1, 1 } };
    return array;
}

Vertex2D *rhombus_2D(float lengthOfSide,
                     int *size) {
    *size = 12;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    array[0] = (Vertex2D){ {0.0, lengthOfSide},{1,0,0,1}};
    array[1] = (Vertex2D){ {0.0, 0.0},{0,1,0,1}};
    array[2] = (Vertex2D){ {lengthOfSide, 0.0},{0,0,1,1}};
    
    array[3] = (Vertex2D){ {0.0, -lengthOfSide},{1,0,0,1}};
    array[4] = (Vertex2D){ {0.0, 0.0},{0,1,0,1}};
    array[5] = (Vertex2D){ {-lengthOfSide,0.0},{1,0,1,1}};
    
    array[6] = (Vertex2D){ {0.0, 0.0},{0,1,0,1}};
    array[7] = (Vertex2D){ {-lengthOfSide, 0.0},{1,0,1,1}};
    array[8] = (Vertex2D){ {0.0, lengthOfSide},{1,0,0,1}};
    
    array[9] = (Vertex2D){ {0.0, 0.0},{0,1,0,1}};
    array[10] = (Vertex2D){ {lengthOfSide, 0.0},{0,0,1,1}};
    array[11] = (Vertex2D){ {0.0, -lengthOfSide},{1,0,0,1}};
    return array;
}

Vertex2D *rect_2D(vector_float2 size,
                  int *vertexsSize) {
    *vertexsSize = 6;
    Vertex2D *array = calloc(*vertexsSize, sizeof(Vertex2D));
    
    array[0] = (Vertex2D){ { 0.0,  0.0 }, { 1, 0, 0, 1 } };
    array[1] = (Vertex2D){ { size.x, 0.0}, { 0, 1, 0, 1 } };
    array[2] = (Vertex2D){ { 0.0, -size.y }, { 0, 0, 1, 1 } };
    array[3] = (Vertex2D){ { 0.0, -size.y }, { 1, 0, 0, 1 } };
    array[4] = (Vertex2D){ { size.x, -size.y }, { 0, 1, 0, 1 } };
    array[5] = (Vertex2D){ { size.x, 0.0 }, { 0, 0, 1, 1 } };
    return array;
}

/**
 * 圆上的某一点 (x, y) = {radius * cos(angle), radius * sin(angle)}
 */
Vertex2D *circle_2D(float radius,
                    float borderWidth,
                    int *size) {
    *size = 720 * 6;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    double angle = 0.0, dif = M_PI * 2.0 / 720.0;
    double bigRadius = radius + borderWidth / 2.0,
           smallRadius = radius - borderWidth / 2.0;
    
    int index = 0;
    while (angle <= M_PI * 2.0) {
        float x1 = smallRadius * cos(angle);
        float y1 = smallRadius * sin(angle);
        float x2 = bigRadius * cos(angle);
        float y2 = bigRadius * sin(angle);
        float x3 = smallRadius * cos(angle + dif);
        float y3 = smallRadius * sin(angle + dif);
        float x4 = bigRadius * cos(angle + dif);
        float y4 = bigRadius * sin(angle + dif);
        
        Vertex2D vertex1 = (Vertex2D){{x1, y1}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        Vertex2D vertex2 = (Vertex2D){{x2, y2}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        Vertex2D vertex3 = (Vertex2D){{x3, y3}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        Vertex2D vertex4 = (Vertex2D){{x4, y4}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };

        array[index++] = vertex1;
        array[index++] = vertex2;
        array[index++] = vertex3;
        array[index++] = vertex2;
        array[index++] = vertex3;
        array[index++] = vertex4;
        angle += dif;
    }
    return array;
}

/// 极坐标系展示
Vertex2D *polarCoordinates_2D(float maxRadius,
                              float borderWidth,
                              int *size) {
    *size = maxRadius * 100 * 6.0;
    Vertex2D *array = calloc(*size, sizeof(Vertex2D));
    
    double radius = 0.0, angle = 0.0, dif = 0.02;
    int index = 0;
    while (radius <= maxRadius) {
        double bigRadius = radius + borderWidth / 2.0,
               smallRadius = radius - borderWidth / 2.0;
        
        float x1 = smallRadius * cos(angle);
        float y1 = smallRadius * sin(angle);
        float x2 = bigRadius * cos(angle);
        float y2 = bigRadius * sin(angle);
        float x3 = smallRadius * cos(angle + dif);
        float y3 = smallRadius * sin(angle + dif);
        float x4 = bigRadius * cos(angle + dif);
        float y4 = bigRadius * sin(angle + dif);
        
        Vertex2D vertex1 = (Vertex2D){{x1 * 20, y1 * 20}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        Vertex2D vertex2 = (Vertex2D){{x2 * 20, y2 * 20}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        Vertex2D vertex3 = (Vertex2D){{x3 * 20, y3 * 20}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        Vertex2D vertex4 = (Vertex2D){{x4 * 20, y4 * 20}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 } };
        
        array[index++] = vertex1;
        array[index++] = vertex2;
        array[index++] = vertex3;
        array[index++] = vertex2;
        array[index++] = vertex3;
        array[index++] = vertex4;
        
        radius += 0.01;
        angle += dif;
    }
    return array;
}


/// 返回二维 F
Vertex2D *f_2D(vector_float2 size,
               float boardWidth,
               int *count) {
    *count = 18;
    Vertex2D *array = calloc(*count, sizeof(Vertex2D));
    
    // left column
    array[0] = (Vertex2D){ { 0.0,  0.0 }, { 1, 0, 0, 1 } };
    array[1] = (Vertex2D){ { boardWidth, 0.0 }, { 0, 1, 0, 1 } };
    array[2] = (Vertex2D){ { 0.0, -size.y }, { 0, 0, 1, 1 } };
    array[3] = (Vertex2D){ { 0.0, -size.y }, { 1, 0, 0, 1 } };
    array[4] = (Vertex2D){ { boardWidth, 0.0}, { 0, 1, 0, 1 } };
    array[5] = (Vertex2D){ { boardWidth, -size.y}, { 0, 0, 1, 1 } };
    
    // top rung
    array[6] = (Vertex2D){ {  boardWidth, 0.0}, { 1, 0, 0, 1 } };
    array[7] = (Vertex2D){ {  size.x, 0.0}, { 0, 1, 0, 1 } };
    array[8] = (Vertex2D){ {  boardWidth, -boardWidth}, { 0, 0, 1, 1 } };
    array[9] = (Vertex2D){ {  boardWidth, -boardWidth}, { 1, 0, 0, 1 } };
    array[10] = (Vertex2D){ { size.x, 0.0}, { 0, 1, 0, 1 } };
    array[11] = (Vertex2D){ { size.x, -boardWidth}, { 0, 0, 1, 1 } };
    
    // middle rung
    array[12] = (Vertex2D){ { boardWidth, -boardWidth * 2}, { 1, 0, 0, 1 } };
    array[13] = (Vertex2D){ { size.x * 2 / 3.0, -boardWidth * 2}, { 0, 1, 0, 1 } };
    array[14] = (Vertex2D){ { boardWidth, -boardWidth * 3}, { 0, 0, 1, 1 } };
    array[15] = (Vertex2D){ { boardWidth, -boardWidth * 3}, { 1, 0, 0, 1 } };
    array[16] = (Vertex2D){ { size.x * 2 / 3.0, -boardWidth * 2}, { 0, 1, 0, 1 } };
    array[17] = (Vertex2D){ { size.x * 2 / 3.0, -boardWidth * 3}, { 0, 0, 1, 1 } };
    return array;
}


Vertex2D *hello_2D(int *count) {
    Vertex2D vertexDatas[] = {
        {{-1000,-1},{0,0,1,1}},
        {{1000,-1},{0,0,1,1}},
        {{1000,1},{0,0,1,1}},
        {{1000,1},{0,0,1,1}},
        {{-1000,1},{0,0,1,1}},
        {{-1000,-1},{0,0,1,1}},

        {{-1,-1000},{0,0,1,1}},
        {{-1,1000},{0,0,1,1}},
        {{1,1000},{0,0,1,1}},
        {{1,1000},{0,0,1,1}},
        {{-1,1000},{0,0,1,1}},
        {{-1,-1000},{0,0,1,1}},

        /// H
        {{-250,90},{1,0,0,1}},
        {{-250,-90},{1,0,0,1}},
        {{-240,-90},{1,0,0,1}},
        {{-240,-90},{1,0,0,1}},
        {{-240,90},{1,0,0,1}},
        {{-250,90},{1,0,0,1}},
        
        {{-240,-6},{1,0,0,1}},
        {{-160,-6},{1,0,0,1}},
        {{-160,6},{1,0,0,1}},
        {{-160,6},{1,0,0,1}},
        {{-240,6},{1,0,0,1}},
        {{-240,-6},{1,0,0,1}},
        
        {{-160,90},{1,0,0,1}},
        {{-160,-90},{1,0,0,1}},
        {{-150,-90},{1,0,0,1}},
        {{-150,-90},{1,0,0,1}},
        {{-150,90},{1,0,0,1}},
        {{-160,90},{1,0,0,1}},
        
        /// E
        {{-100,90},{1,0,0,1}},
        {{-20,90},{1,0,0,1}},
        {{-20,80},{1,0,0,1}},
        {{-20,80},{1,0,0,1}},
        {{-100,80},{1,0,0,1}},
        {{-100,90},{1,0,0,1}},
        
        {{-100,80},{1,0,0,1}},
        {{-100,-80},{1,0,0,1}},
        {{-90,-80},{1,0,0,1}},
        {{-90,-80},{1,0,0,1}},
        {{-90,80},{1,0,0,1}},
        {{-100,80},{1,0,0,1}},
        
        {{-100,-90},{1,0,0,1}},
        {{-10,-90},{1,0,0,1}},
        {{-10,-80},{1,0,0,1}},
        {{-10,-80},{1,0,0,1}},
        {{-100,-80},{1,0,0,1}},
        {{-100,-90},{1,0,0,1}},
        
        {{-100,-6},{1,0,0,1}},
        {{-24,-6},{1,0,0,1}},
        {{-24,6},{1,0,0,1}},
        {{-24,6},{1,0,0,1}},
        {{-100,6},{1,0,0,1}},
        {{-100,-6},{1,0,0,1}},
        
        /// L
        {{30,90},{1,0,0,1}},
        {{30,-90},{1,0,0,1}},
        {{40,-90},{1,0,0,1}},
        {{40,-90},{1,0,0,1}},
        {{40,90},{1,0,0,1}},
        {{30,90},{1,0,0,1}},
        
        {{40,-90},{1,0,0,1}},
        {{100,-90},{1,0,0,1}},
        {{100,-80},{1,0,0,1}},
        {{100,-80},{1,0,0,1}},
        {{40,-80},{1,0,0,1}},
        {{40,-90},{1,0,0,1}},
        
        /// L
        {{150,90},{1,0,0,1}},
        {{150,-90},{1,0,0,1}},
        {{160,-90},{1,0,0,1}},
        {{160,-90},{1,0,0,1}},
        {{160,90},{1,0,0,1}},
        {{150,90},{1,0,0,1}},
        
        {{160,-90},{1,0,0,1}},
        {{220,-90},{1,0,0,1}},
        {{220,-80},{1,0,0,1}},
        {{220,-80},{1,0,0,1}},
        {{160,-80},{1,0,0,1}},
        {{160,-90},{1,0,0,1}},
        
        /// O
        {{270,90},{1,0,0,1}},
        {{270,-90},{1,0,0,1}},
        {{280,-90},{1,0,0,1}},
        {{280,-90},{1,0,0,1}},
        {{280,90},{1,0,0,1}},
        {{270,90},{1,0,0,1}},
        
        {{280,90},{1,0,0,1}},
        {{340,90},{1,0,0,1}},
        {{340,80},{1,0,0,1}},
        {{340,80},{1,0,0,1}},
        {{280,80},{1,0,0,1}},
        {{280,90},{1,0,0,1}},
        
        {{340,90},{1,0,0,1}},
        {{340,-90},{1,0,0,1}},
        {{350,-90},{1,0,0,1}},
        {{350,-90},{1,0,0,1}},
        {{350,90},{1,0,0,1}},
        {{340,90},{1,0,0,1}},
        
        {{280,-90},{1,0,0,1}},
        {{340,-90},{1,0,0,1}},
        {{340,-80},{1,0,0,1}},
        {{340,-80},{1,0,0,1}},
        {{280,-80},{1,0,0,1}},
        {{280,-90},{1,0,0,1}},
    };
    *count = sizeof(vertexDatas) / sizeof(Vertex2D);
    Vertex2D *array = calloc(*count, sizeof(Vertex2D));
    for (int i = 0; i < *count; i++) {
        array[i] = vertexDatas[i];
    }
    return array;
}

