//
//  Mesh.hpp
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#ifndef Mesh_hpp
#define Mesh_hpp

#include <stdio.h>
#import <simd/simd.h>

class Mesh {
    int dimension;
    vector_float4 color;
    vector_float4 *vertexs;
    int *indices;
public:
    Mesh(vector_float4 *vertexs,
         int *indices = NULL,
         int dimension = 3,
         vector_float4 color = {1, 1, 1, 1});
};

#endif /* Mesh_hpp */
