//
//  PrimitiveTypeViewController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import "PrimitiveTypeViewController.h"
#import "PrimitiveTypeRender.h"
#import "PlatformModule.h"

@interface PrimitiveTypeViewController ()
@property (nonatomic ,strong) PrimitiveTypeRender *render;
@property (nonatomic, strong) NSMutableArray<YLSheetItem *> *itemsArray;
@end

@implementation PrimitiveTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if defined (TARGET_IOS)
    self.navigationItem.title = @"Point";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"改变图元类型" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick)];
#elif defined(TARGET_MACOS)
    NSButton *buton = [[NSButton alloc] initWithFrame:NSMakeRect(kMacContentWidth - 100, kMacScreenHeight - 45, 100, 45)];
    [buton setTitle:@"Point"];
    [buton setTarget:self];
    [buton setAction:@selector(butonClick:)];
    [self.view addSubview:buton];
#endif
    _render = [[PrimitiveTypeRender alloc] initWithMTKView:self.mtkView];
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}

#if defined (TARGET_IOS)
- (void)rightBarButtonItemClick {
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"改变图元类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (YLSheetItem *item in self.itemsArray) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:item.typeName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.render.primitiveType = item.type;
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
            self.render.primitiveType = item.type;
            [sender setTitle:item.name];
    }]];
}

#endif


- (NSMutableArray<YLSheetItem *> *)itemsArray {
    if (_itemsArray == nil) {
        _itemsArray = [NSMutableArray array];
        [_itemsArray addObject:[YLSheetItem modelWithType:MTLPrimitiveTypePoint typeName:@"MTLPrimitiveTypePoint" name:@"点"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:MTLPrimitiveTypeLine typeName:@"MTLPrimitiveTypeLine" name:@"线段"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:MTLPrimitiveTypeLineStrip typeName:@"MTLPrimitiveTypeLineStrip" name:@"连续线段"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:MTLPrimitiveTypeTriangle typeName:@"MTLPrimitiveTypeTriangle" name:@"三角形"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:MTLPrimitiveTypeTriangleStrip typeName:@"MTLPrimitiveTypeTriangleStrip" name:@"连续三角形"]];
    }
    return _itemsArray;
}

@end
