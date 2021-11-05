//
//  PlatformModule.m
//  Graphics
//
//  Created by 苏沫离 on 2020/9/25.
//

#import "PlatformModule.h"

@implementation PlatformViewController

@synthesize view = _view;

#pragma mark - setters and getters

#if defined(TARGET_IOS)
#elif defined(TARGET_MACOS)
- (NSView *)view {
    if (_view == nil) {
        _view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, kMacScreenWidth, kMacScreenHeight)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self viewDidLoad];
        });
    }
    return _view;
}

#endif

@end


@implementation PlatformView
@end


@implementation DemoItem
+ (instancetype)item:(NSString *)item
          controller:(NSString *)controller {
    DemoItem *model = [[DemoItem alloc] init];
    model.item = item;
    model.controller = controller;
    return model;
}
@end


@implementation YLSheetItem

+ (instancetype)modelWithType:(NSInteger)type name:(NSString *)name {
    return [YLSheetItem modelWithType:type typeName:nil name:name];
}

+ (instancetype)modelWithType:(NSInteger)type typeName:(NSString *)typeName name:(NSString *)name {
    YLSheetItem *model = [[YLSheetItem alloc] init];
    model.type = type;
    model.typeName = typeName;
    model.name = name;
    return model;
}
@end



static const double kPlatformSliderHeight = 30.0;
static const double kPlatformSliderWeight = 300.0;

@interface PlatformSlider ()
#if defined(TARGET_IOS)
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLabel;
#elif defined(TARGET_MACOS)
@property (nonatomic, strong) NSSlider *slider;
@property (nonatomic, strong) NSTextField *tipLabel;
@property (nonatomic, strong) NSTextField *valueLabel;
#endif
@end


@implementation PlatformSlider

+ (instancetype)item:(NSString *)item
            minValue:(float)minValue
            maxValue:(float)maxValue
        currentValue:(float)currentValue {
    return [[PlatformSlider alloc] initWithItem:item
                                       minValue:minValue
                                       maxValue:maxValue
                                   currentValue:currentValue];
}


- (instancetype)initWithItem:(NSString *)item
                    minValue:(float)minValue
                    maxValue:(float)maxValue
                currentValue:(float)currentValue {
    self = [super init];
    
    if (self) {
    
        
#if defined(TARGET_IOS)
   
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, kPlatformSliderHeight)];
        _tipLabel.text = item;
        [self addSubview:_tipLabel];

        _slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 0, 200, kPlatformSliderHeight)];
        _slider.value = currentValue;
        _slider.minimumValue = minValue;
        _slider.maximumValue = maxValue;
        [_slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slider];
    
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 50, kPlatformSliderHeight)];
        _valueLabel.text = [NSString stringWithFormat:@"%.2f",currentValue];
        [self addSubview:_valueLabel];
    
#elif defined(TARGET_MACOS)
    
        _tipLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 50, kPlatformSliderHeight)];
        _tipLabel.textColor = NSColor.whiteColor;
        _tipLabel.backgroundColor = NSColor.clearColor;
        _tipLabel.enabled = NO;
        _tipLabel.bordered = NO;
        _tipLabel.drawsBackground = NO;
        _tipLabel.stringValue = item;
        [self addSubview:_tipLabel];

        _slider = [NSSlider sliderWithValue:currentValue minValue:minValue maxValue:maxValue target:self action:@selector(sliderValueChange)];
        _slider.frame = NSMakeRect(50, 0, 200, kPlatformSliderHeight);
        _slider.trackFillColor = [NSColor.whiteColor colorWithAlphaComponent:0.5];
        [self addSubview:_slider];

        _valueLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(250, 0, 50, kPlatformSliderHeight)];
        _valueLabel.enabled = NO;
        _valueLabel.bordered = NO;
        _valueLabel.drawsBackground = NO;
        _valueLabel.textColor = NSColor.whiteColor;
        _valueLabel.backgroundColor = NSColor.clearColor;
        _valueLabel.stringValue = [NSString stringWithFormat:@"%.2f",currentValue];
        [self addSubview:_valueLabel];
#endif
    }
    return self;
}

- (void)sliderValueChange {
    if (self.sliderChangeHandle) {
#if defined(TARGET_IOS)
        self.valueLabel.text = [NSString stringWithFormat:@"%.2f",self.slider.value];
        self.sliderChangeHandle(self.slider.value);
#elif defined(TARGET_MACOS)
        self.valueLabel.stringValue = [NSString stringWithFormat:@"%.2f",self.slider.doubleValue];
        self.sliderChangeHandle(self.slider.doubleValue);
#endif
    }
}

@end




@implementation MatrixSetView

+ (instancetype)viewWithItems:(NSArray<PlatformSlider *> *)items {
#if defined(TARGET_IOS)
    MatrixSetView *view = [[MatrixSetView alloc] initWithFrame:CGRectMake(0, 0, kPlatformSliderWeight, kPlatformSliderHeight * items.count)];
    for (int i = 0; i < items.count; i++) {
        items[i].frame = CGRectMake(0, kPlatformSliderHeight * i, 300, kPlatformSliderHeight);
        [view addSubview:items[i]];
    }
    return view;
#elif defined(TARGET_MACOS)
    MatrixSetView *view = [[MatrixSetView alloc] initWithFrame:NSMakeRect(kMacContentWidth - kPlatformSliderWeight,
                                                                          kMacScreenHeight - kPlatformSliderHeight * items.count,
                                                                          kPlatformSliderWeight,
                                                                          kPlatformSliderHeight * items.count)];
    int location = (int)items.count - 1;
    for (int i = 0; i < items.count; i++) {
        items[i].frame = NSMakeRect(0, kPlatformSliderHeight * location, kPlatformSliderWeight, kPlatformSliderHeight);
        [view addSubview:items[i]];
        location--;
    }
    return view;
#endif
}

@end




#if defined(TARGET_IOS)

#elif defined(TARGET_MACOS)

#import <Cocoa/Cocoa.h>

@interface YLAlert ()

@property (nonatomic, strong) NSArray<YLSheetItem *> *items;
@property (nonatomic, copy) void(^selectedBlock)(YLSheetItem *item);
@end


@implementation YLAlert

+ (instancetype)alertWithItems:(NSArray<YLSheetItem *> *)items
                        height:(double)height
               selectedHandler:(void(^)(YLSheetItem *item))selectedBlock {
    
    double buttonHeight = 45.0;
    double contentHeight = items.count * buttonHeight;
    YLAlert *alert = [[YLAlert alloc] initWithFrame:NSMakeRect(kMacContentWidth - 100,
                                                               kMacScreenHeight - height - contentHeight,
                                                               100, contentHeight)];
    alert.items = items;
    alert.selectedBlock = selectedBlock;
    contentHeight -= buttonHeight;
    for (int i = 0; i < items.count; i++) {
        YLSheetItem *model = items[i];
        NSButton *buton = [[NSButton alloc] initWithFrame:NSMakeRect(0, contentHeight - buttonHeight * i, 100, buttonHeight)];
        buton.tag = 100 + i;
        [buton setTitle:model.typeName.length ? model.typeName : model.name];
        [buton setTarget:alert];
        [buton setAction:@selector(butonClick:)];
        [alert addSubview:buton];
    }
    return alert;
}

- (void)butonClick:(NSButton *)sender {
    if (self.selectedBlock) {
        self.selectedBlock(self.items[sender.tag - 100]);
    }
    [self removeFromSuperview];
}

@end

#endif

