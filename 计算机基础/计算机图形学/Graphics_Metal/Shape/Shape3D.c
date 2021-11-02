//
//  Shape3D.c
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include "Shape3D.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "MatrixTransform.h"

/** 3D 圆球
 * 如何描述球面上的一个点？
 * 1、这个点一定在半径上；
 * 2、默认球面的任意点初始位置都在极点上；
 *   通过旋转 x 轴 t1 个弧度，旋转 y 轴 t2 弧度，旋转到圆环上；
 * 3、球面坐标系 (r, t1, t2) 能确定球面的一个点
 *
 * t1 分成 n 份，每份为 x , t1 属于 [0, 2 PI]
 * t2 分成 m 份，每份为 y , t2 属于 [0,   PI]
 * m, n  越大，球面越光滑
 */
Vertex3D *sphere_3D_indexs(float radius,
                           int sliceCount,
                           int *vertexSize,
                           uint16_t **indexs,
                           int *indexSize) {
    
    int xCount = sliceCount * 2, yCount = sliceCount;
    
    *vertexSize = (yCount + 1) * (xCount + 1);
    int verticeIndex = 0;
    Vertex3D *vertices = calloc(*vertexSize, sizeof(Vertex3D)); /// 顶点
    
    for (int y = 0; y <= yCount; y++) {
        float v = y * 1.0 / yCount;
        for (int x = 0; x <= xCount; x++) {
            float u = x * 1.0 / xCount;
            
            float theta = u * M_PI * 2.0;
            float phi = v * M_PI;
            float py = radius * cos(phi);
            float px = radius * sin(phi) * cos(theta);
            float pz = radius * sin(phi) * sin(theta);
            vertices[verticeIndex++] = (Vertex3D){{px, py, pz, 1}, { random() % 255 / 255.0, random() % 255 / 255.0, random() % 255 / 255.0, 1 }, {1 - u, v}};
        }
    }
    
    *indexSize = yCount * xCount * 6;
    *indexs = calloc(*indexSize, sizeof(int16_t));
    int currentIndex = 0;
    
    for (int16_t x = 0; x < xCount; x++) {
        for (int16_t y = 0; y < yCount; y++) {
            // 穷举所有四边形的顶点
            (*indexs)[currentIndex++] = x + y * (xCount + 1);
            (*indexs)[currentIndex++] = (x + 1) + y * (xCount + 1);
            (*indexs)[currentIndex++] = x + (y + 1) * (xCount + 1);
            
            (*indexs)[currentIndex++] = (x + 1) + y * (xCount + 1);
            (*indexs)[currentIndex++] = x + (y + 1) * (xCount + 1);
            (*indexs)[currentIndex++] = (x + 1) + (y + 1) * (xCount + 1);
        }
    }
    return vertices;
}

Vertex3D *cube_3D(float lengthOfSide,
                  int *size) {
    
    *size = 24;
    Vertex3D *array = calloc(*size, sizeof(Vertex3D));
    
    array[0] = (Vertex3D){{ -lengthOfSide, -lengthOfSide, -lengthOfSide}, { 1, 0, 0, 1 } };
    array[1] = (Vertex3D){ {lengthOfSide, -lengthOfSide, -lengthOfSide}, { 0, 1, 0, 1 } };
    array[2] = (Vertex3D){ {lengthOfSide, lengthOfSide, -lengthOfSide}, { 0, 0, 1, 1 } };
    array[3] = (Vertex3D){ {- lengthOfSide, lengthOfSide, -lengthOfSide}, { 1, 0, 0, 1 } };
    
    array[4] = (Vertex3D){ {-lengthOfSide, lengthOfSide, lengthOfSide}, { 0, 1, 0, 1 } };
    array[5] = (Vertex3D){ {lengthOfSide, -lengthOfSide, lengthOfSide}, { 0, 0, 1, 1 } };
    array[6] = (Vertex3D){ {lengthOfSide, lengthOfSide, lengthOfSide}, { 1, 0, 0, 1 } };
    array[7] = (Vertex3D){ {-lengthOfSide, lengthOfSide, lengthOfSide}, { 0, 1, 0, 1 } };
    
    array[8] = (Vertex3D){ {-lengthOfSide, -lengthOfSide, -lengthOfSide}, { 0, 0, 1, 1 } };
    array[9] = (Vertex3D){ {-lengthOfSide, lengthOfSide, -lengthOfSide}, { 1, 0, 0, 1 } };
    array[10] = (Vertex3D){ {-lengthOfSide, lengthOfSide, lengthOfSide}, { 0, 1, 0, 1 } };
    array[11] = (Vertex3D){ {-lengthOfSide, -lengthOfSide, lengthOfSide}, { 0, 0, 1, 1 } };
    
    array[12] = (Vertex3D){ { lengthOfSide, -lengthOfSide, -lengthOfSide}, { 1, 0, 0, 1 } };
    array[13] = (Vertex3D){ { lengthOfSide, lengthOfSide, -lengthOfSide}, { 0, 1, 0, 1 } };
    array[14] = (Vertex3D){ { lengthOfSide, lengthOfSide, lengthOfSide}, { 0, 0, 1, 1 } };
    array[15] = (Vertex3D){ { lengthOfSide, -lengthOfSide, lengthOfSide}, { 1, 0, 0, 1 } };
    
    array[16] = (Vertex3D){ {-lengthOfSide, -lengthOfSide, -lengthOfSide}, { 0, 1, 0, 1 } };
    array[17] = (Vertex3D){ {-lengthOfSide, -lengthOfSide, lengthOfSide}, { 0, 0, 1, 1 } };
    array[18] = (Vertex3D){ { lengthOfSide, -lengthOfSide, lengthOfSide}, { 1, 0, 0, 1 } };
    array[19] = (Vertex3D){ { lengthOfSide, -lengthOfSide, -lengthOfSide}, { 0, 1, 0, 1 } };
    
    array[20] = (Vertex3D){ {-lengthOfSide, lengthOfSide, -lengthOfSide}, { 0, 0, 1, 1 } };
    array[21] = (Vertex3D){ {-lengthOfSide, lengthOfSide, lengthOfSide}, { 1, 0, 0, 1 } };
    array[22] = (Vertex3D){ { lengthOfSide, lengthOfSide, lengthOfSide}, { 0, 1, 0, 1 } };
    array[23] = (Vertex3D){ { lengthOfSide, lengthOfSide, -lengthOfSide}, { 0, 0, 1, 1 } };
    return array;
}


Vertex3D *cylinder_3D(float radius,
                      float height,
                      int *vertexSize,
                      uint16_t **indexs,
                      int *indexSize) {
    
    int xCount = 200, yCount = 100;
    
    *vertexSize = (yCount + 1) * (xCount + 1);
    int verticeIndex = 0;
    Vertex3D *vertices = calloc(*vertexSize, sizeof(Vertex3D)); /// 顶点
    
    for (int y = 0; y <= yCount; y++) {
        float v = y * height / yCount;
        for (int x = 0; x <= xCount; x++) {
            float u = x * 1.0 / xCount;
            float theta = u * M_PI * 2.0;
            float py = v;
            float px = radius * cos(theta);
            float pz = radius * sin(theta);
            vertices[verticeIndex++] = (Vertex3D){{px, py, pz, 1}, {0.5, 0.5, 0.5, 1}, {1 - u, v}};
        }
    }
    
    *indexSize = yCount * xCount * 6;
    *indexs = calloc(*indexSize, sizeof(int16_t));
    int currentIndex = 0;
    
    for (int16_t x = 0; x < xCount; x++) {
        for (int16_t y = 0; y < yCount; y++) {
            // 穷举所有四边形的顶点
            (*indexs)[currentIndex++] = x + y * (xCount + 1);
            (*indexs)[currentIndex++] = (x + 1) + y * (xCount + 1);
            (*indexs)[currentIndex++] = x + (y + 1) * (xCount + 1);
            
            (*indexs)[currentIndex++] = (x + 1) + y * (xCount + 1);
            (*indexs)[currentIndex++] = x + (y + 1) * (xCount + 1);
            (*indexs)[currentIndex++] = (x + 1) + (y + 1) * (xCount + 1);
        }
    }
    return vertices;
}


/// 三维 F
Vertex3D *f_3D(int *size) {
    
    Vertex3D vertexDatas[96] = {
        
        // left column front
        (Vertex3D){{0, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 150, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        
        // top rung front
        (Vertex3D){{30, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{100, 30, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},

        // middle rung front
        (Vertex3D){{30, 60, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{67, 90, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},

        // left column back
        (Vertex3D){{0, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},

        // top rung back
        (Vertex3D){{30, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},

        // middle rung back
        (Vertex3D){{30, 60, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},

        // top
        (Vertex3D){{0, 0, 0, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{0, 0, 0, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{0, 0, 30, 1}, {0.2745, 0.7843, 0.8235, 1}},

        // top rung right
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 30, 0, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.7843, 0.7843, 0.2745, 1}},

        // under top rung
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{100, 30, 0, 1}, {0.8235, 0.3922, 0.2745, 1}},

        // between top rung and middle
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 60, 30, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 60, 0, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 60, 30, 1}, {0.8235, 0.6275, 0.2745, 1}},

        // top of middle rung
        (Vertex3D){{30, 60, 0, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{30, 60, 30, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{30, 60, 0, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.2745, 0.7059, 0.8235, 1}},

        // right of middle rung
        (Vertex3D){{67, 60, 0, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 90, 0, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.3922, 0.2745, 0.8235, 1}},

        // bottom of middle rung.
        (Vertex3D){{30, 90, 0, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{67, 90, 0, 1}, {0.2980, 0.8235, 0.3922, 1}},

        // right of bottom
        (Vertex3D){{30, 90, 0, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 150, 0, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.5490, 0.8235, 0.3137, 1}},

        // bottom
        (Vertex3D){{0, 150, 0, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{30, 150, 0, 1}, {0.3529, 0.5098, 0.4314, 1}},

        // left side
        (Vertex3D){{0, 0, 0, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 0, 30, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 0, 0, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.6275, 0.6275, 0.8627, 1}},
    };
    
    *size = 96;
    Vertex3D *vertices = calloc(*size, sizeof(Vertex3D));
    for (int i = 0; i < 96; i++) {
        vertices[i] = vertexDatas[i];
    }
    return vertices;
}

Vertex3D *fMore_3D(const int count, int *size) {
    const int unitCount = 96;
    Vertex3D vertexDatas[unitCount] = {
        
        // left column front
        (Vertex3D){{0, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 150, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        
        // top rung front
        (Vertex3D){{30, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{100, 30, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},

        // middle rung front
        (Vertex3D){{30, 60, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{67, 90, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.7843, 0.2745, 0.4706, 1}},

        // left column back
        (Vertex3D){{0, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},

        // top rung back
        (Vertex3D){{30, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},

        // middle rung back
        (Vertex3D){{30, 60, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.3137, 0.2745, 0.7843, 1}},

        // top
        (Vertex3D){{0, 0, 0, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{0, 0, 0, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.2745, 0.7843, 0.8235, 1}},
        (Vertex3D){{0, 0, 30, 1}, {0.2745, 0.7843, 0.8235, 1}},

        // top rung right
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 30, 0, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 0, 0, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.7843, 0.7843, 0.2745, 1}},
        (Vertex3D){{100, 0, 30, 1}, {0.7843, 0.7843, 0.2745, 1}},

        // under top rung
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{100, 30, 30, 1}, {0.8235, 0.3922, 0.2745, 1}},
        (Vertex3D){{100, 30, 0, 1}, {0.8235, 0.3922, 0.2745, 1}},

        // between top rung and middle
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 60, 30, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 30, 30, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 30, 0, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 60, 0, 1}, {0.8235, 0.6275, 0.2745, 1}},
        (Vertex3D){{30, 60, 30, 1}, {0.8235, 0.6275, 0.2745, 1}},

        // top of middle rung
        (Vertex3D){{30, 60, 0, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{30, 60, 30, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{30, 60, 0, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.2745, 0.7059, 0.8235, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.2745, 0.7059, 0.8235, 1}},

        // right of middle rung
        (Vertex3D){{67, 60, 0, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 60, 30, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 60, 0, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 90, 0, 1}, {0.3922, 0.2745, 0.8235, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.3922, 0.2745, 0.8235, 1}},

        // bottom of middle rung.
        (Vertex3D){{30, 90, 0, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{67, 90, 30, 1}, {0.2980, 0.8235, 0.3922, 1}},
        (Vertex3D){{67, 90, 0, 1}, {0.2980, 0.8235, 0.3922, 1}},

        // right of bottom
        (Vertex3D){{30, 90, 0, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 90, 30, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 90, 0, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 150, 0, 1}, {0.5490, 0.8235, 0.3137, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.5490, 0.8235, 0.3137, 1}},

        // bottom
        (Vertex3D){{0, 150, 0, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{30, 150, 30, 1}, {0.3529, 0.5098, 0.4314, 1}},
        (Vertex3D){{30, 150, 0, 1}, {0.3529, 0.5098, 0.4314, 1}},

        // left side
        (Vertex3D){{0, 0, 0, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 0, 30, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 0, 0, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 150, 30, 1}, {0.6275, 0.6275, 0.8627, 1}},
        (Vertex3D){{0, 150, 0, 1}, {0.6275, 0.6275, 0.8627, 1}},
    };
    
    *size = unitCount * count;
    Vertex3D *vertices = calloc(*size, sizeof(Vertex3D));
    int index = 0;
    for (int i = 0; i < count; i++) {
        float angle = i * (M_PI * 2.0 / count);
        matrix_float4x4 matrix = matrix4x4_identity();
        matrix = matrix_multiply(matrix, matrix4x4_rotationY(angle));
        matrix = matrix_multiply(matrix, matrix4x4_translation(0, 0, -250));

        for (int j = 0; j < 96; j++) {
            Vertex3D theVertex = vertexDatas[j];
            theVertex.position = matrix_multiply(matrix, theVertex.position);
            theVertex.position.w = 1.0;
            vertices[index++] = theVertex;
        }
    }
    return vertices;
}
