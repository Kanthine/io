//
//  PlatformModule.h
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//


#if defined(TARGET_IOS)
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlatformViewController : UIViewController

@end

@interface PlatformView : UIView

@end

#elif defined(TARGET_MACOS)

#import <Cocoa/Cocoa.h>

@interface PlatformViewController : NSViewController

@end

@interface PlatformView : NSView

@end



#endif


@interface DemoItem : NSObject
@property (nonatomic, copy) NSString *item;
@property (nonatomic, copy) NSString *controller;

+ (instancetype)item:(NSString *)item
          controller:(NSString *)controller;
@end




@interface YLSheetItem : NSObject
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) id data;
+ (instancetype)modelWithType:(NSInteger)type name:(NSString *)name;
+ (instancetype)modelWithType:(NSInteger)type typeName:(NSString *)typeName name:(NSString *)name;
@end




@interface PlatformSlider : PlatformView
@property (nonatomic, copy) NSString *item;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign) float maxValue;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, copy) void(^sliderChangeHandle)(double value);

+ (instancetype)item:(NSString *)item
            minValue:(float)minValue
            maxValue:(float)maxValue
        currentValue:(float)currentValue;
@end


@interface MatrixSetView : PlatformView
+ (instancetype)viewWithItems:(NSArray<PlatformSlider *> *)items;
@end




#if defined(TARGET_IOS)

#elif defined(TARGET_MACOS)

#import <Cocoa/Cocoa.h>

@interface YLAlert : NSView
+ (instancetype)alertWithItems:(NSArray<YLSheetItem *> *)items
                        height:(double)height
               selectedHandler:(void(^)(YLSheetItem *item))selectedBlock;
@end

#endif
