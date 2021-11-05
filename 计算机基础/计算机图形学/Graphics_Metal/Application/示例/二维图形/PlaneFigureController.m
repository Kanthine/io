//
//  PlaneFigureController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/29.
//

#import "PlaneFigureController.h"
#import "PlaneFigureRender.h"
#import "PlatformModule.h"

@interface PlaneFigureController ()
@property (nonatomic, strong) PlaneFigureRender *render;
@property (nonatomic, strong) NSMutableArray<YLSheetItem *> *itemsArray;
@end

@implementation PlaneFigureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _render = [[PlaneFigureRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    
#if defined (TARGET_IOS)
    self.navigationItem.title = @"2D图形";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"2D图形" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick)];
#elif defined(TARGET_MACOS)
    NSButton *buton = [[NSButton alloc] initWithFrame:NSMakeRect(kMacContentWidth - 100, kMacScreenHeight - 45, 100, 45)];
    [buton setTitle:@"2D图形"];
    [buton setTarget:self];
    [buton setAction:@selector(butonClick:)];
    [self.view addSubview:buton];
#endif
}


#if defined (TARGET_IOS)
- (void)rightBarButtonItemClick {
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"2D图形" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (YLSheetItem *item in self.itemsArray) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:item.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.render.figureType = item.type;
            self.navigationItem.title = item.name;
        }];
        [sheetController addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [sheetController addAction:cancelAction];
    [self presentViewController:sheetController animated:YES completion:nil];
}

#elif defined(TARGET_MACOS)

- (void)butonClick:(NSButton *)sender {
    
    [self.view addSubview:[YLAlert alertWithItems:self.itemsArray height:45 selectedHandler:^(YLSheetItem *item) {
            self.render.figureType = item.type;
            [sender setTitle:item.name];
    }]];
}

#endif


- (NSMutableArray<YLSheetItem *> *)itemsArray {
    if (_itemsArray == nil) {
        _itemsArray = [NSMutableArray array];
        [_itemsArray addObject:[YLSheetItem modelWithType:PlaneFigureTypeHello name:@"Hello"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:PlaneFigureTypeTriangle name:@"三角形"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:PlaneFigureTypeRhombus name:@"菱形"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:PlaneFigureTypeCircle name:@"圆形"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:PlaneFigureTypePolarCoordinate name:@"极坐标系"]];
    }
    return _itemsArray;
}

@end
