//
//  ComputeController.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "ComputeController.h"
#import "ComputeRender.h"
@import simd;

@implementation ComputeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    
    NSLog(@"-----------");
}

/** 转置矩阵
 *  矩阵 matrix_float4x4 的每一行，表示矩阵的每一列，类似于对原矩阵做了转置
 */
- (void)transposedMatrix {
    matrix_float4x4 matrix1 = (matrix_float4x4){
        {
            { 1, 2, 3, 4 },     // 这里的每一行都提供列数据
            { 2, 3, 4, 5 },
            { 3, 4, 5, 6 },
            { 4, 5, 6, 7 }
        }
    };
    
    matrix_float4x4 matrix2 = (matrix_float4x4){
        {
            { 1, 2, 3, 4 },     // 这里的每一行都提供列数据
            { 1, 2, 3, 4 },
            { 1, 2, 3, 4 },
            { 1, 2, 3, 4 }
        }
    };
    
    matrix_float4x4 matrix3 = matrix_multiply(matrix1, matrix2);
    
    vector_float4 vector1 = (vector_float4){1, 2, 3, 4};
    
    vector_float4 vector2 = matrix_multiply(matrix2, vector1);
}

@end
