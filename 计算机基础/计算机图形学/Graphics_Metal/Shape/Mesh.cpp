//
//  Mesh.cpp
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#include "Mesh.hpp"


Mesh::Mesh(vector_float4 *vertexs,
           int *indices,
           int dimension,
           vector_float4 color) {
    this -> color = color;
    this -> indices = indices;
    this -> dimension = dimension;
    this -> vertexs = vertexs;
}
