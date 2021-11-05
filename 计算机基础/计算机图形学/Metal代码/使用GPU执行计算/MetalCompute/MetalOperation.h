//
//  MetalOperation.h
//  MetalCompute
//
//  Created by 苏沫离 on 2021/9/17.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalOperation : NSObject

/** 在 Metal 中，代价高昂的初始化任务最好运行一次，保存实例并重复使用
 */
- (instancetype)initWithDevice:(id<MTLDevice>) device;
- (void)prepareData;
- (void)sendComputeCommand;

@end

NS_ASSUME_NONNULL_END
