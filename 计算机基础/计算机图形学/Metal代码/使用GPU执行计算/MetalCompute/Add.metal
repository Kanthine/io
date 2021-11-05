//
//  Add.metal
//  MetalCompute
//
//  Created by 苏沫离 on 2021/9/17.
//

#include <metal_stdlib>

using namespace metal;


kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]]) {
    result[index] = inA[index] + inB[index];
}
