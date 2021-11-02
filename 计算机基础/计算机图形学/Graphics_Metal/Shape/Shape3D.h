//
//  Shape3D.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#ifndef Shape3D_h
#define Shape3D_h

#include <stdio.h>
#include "ShaderTypes.h"
#import <simd/simd.h>

/** 3D 球体
 * @param radius 半径
 * @param sliceCount 微分数量（分割的越细腻，球体表面越光滑）
 * @param vertexSize 顶点数组的长度
 * @param indexs 索引数据
 * @param indexSize 索引数据的长度
 */
Vertex3D *sphere_3D_indexs(float radius,
                           int sliceCount,
                           int *vertexSize,
                           uint16_t **indexs,
                           int *indexSize);

/// 立方体
Vertex3D *cube_3D(float lengthOfSide,
                  int *size);

/** 圆柱体
 * @param radius 半径
 * @param height 高度
 * @param indexs 索引数据
 * @param indexSize 索引数据的长度
 */
Vertex3D *cylinder_3D(float radius,
                      float height,
                      int *vertexSize,
                      uint16_t **indexs,
                      int *indexSize);

/// 三维 F
Vertex3D *f_3D(int *size);
Vertex3D *fMore_3D(const int count, int *size);

#endif
