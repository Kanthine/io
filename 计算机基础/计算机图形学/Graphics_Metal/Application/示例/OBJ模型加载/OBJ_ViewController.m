//
//  OBJ_ViewController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import "OBJ_ViewController.h"
#import "OBJ_Render_1.h"
#import "OBJ_Render_2.h"
#import "OBJ_Render_3.h"
#import "OBJ_Render_4.h"
#import "OBJ_Render_5.h"
#import "OBJ_Render.h"
#import "PlatformModule.h"

@interface OBJ_ViewController ()
@property (nonatomic ,strong) OBJ_Render *render;
@property (nonatomic, strong) NSMutableArray<YLSheetItem *> *itemsArray;
@end

@implementation OBJ_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    NSAssert(self.mtkView.device, @"获取设备失败");
    
#if defined (TARGET_IOS)
    self.navigationItem.title = @"OBJ进度";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OBJ学习进度" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick)];
#elif defined(TARGET_MACOS)
    NSButton *buton = [[NSButton alloc] initWithFrame:NSMakeRect(kMacContentWidth - 100, kMacScreenHeight - 45, 100, 45)];
    [buton setTitle:@"OBJ进度"];
    [buton setTarget:self];
    [buton setAction:@selector(butonClick:)];
    [self.view addSubview:buton];
#endif
    
    
    _render = [[OBJ_Render_5 alloc] initWithMTKView:self.mtkView];
    self.mtkView.delegate = _render;
    [_render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
}

#if defined (TARGET_IOS)
- (void)rightBarButtonItemClick {
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"OBJ学习进度" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (YLSheetItem *item in self.itemsArray) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:item.typeName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            switch (item.type) {
                case 1:{
                    self.render = [[OBJ_Render_1 alloc] initWithMTKView:self.mtkView];
                    self.mtkView.delegate = self.render;
                    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
                }break;
                case 2:{
                    self.render = [[OBJ_Render_2 alloc] initWithMTKView:self.mtkView];
                    self.mtkView.delegate = self.render;
                    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
                }break;
                case 3:{
                    self.render = [[OBJ_Render_3 alloc] initWithMTKView:self.mtkView];
                    self.mtkView.delegate = self.render;
                    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
                }break;
                case 4:{
                    self.render = [[OBJ_Render_4 alloc] initWithMTKView:self.mtkView];
                    self.mtkView.delegate = self.render;
                    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
                }break;
                case 5:{
                    self.render = [[OBJ_Render_5 alloc] initWithMTKView:self.mtkView];
                    self.mtkView.delegate = self.render;
                    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
                }break;
                default:{
                    self.render = [[OBJ_Render alloc] initWithMTKView:self.mtkView];
                    self.mtkView.delegate = self.render;
                    [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
                }break;
            }
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
        
        switch (item.type) {
            case 1:{
                self.render = [[OBJ_Render_1 alloc] initWithMTKView:self.mtkView];
                self.mtkView.delegate = self.render;
                [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
            }break;
            case 2:{
                self.render = [[OBJ_Render_2 alloc] initWithMTKView:self.mtkView];
                self.mtkView.delegate = self.render;
                [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
            }break;
            case 3:{
                self.render = [[OBJ_Render_3 alloc] initWithMTKView:self.mtkView];
                self.mtkView.delegate = self.render;
                [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
            }break;
            case 4:{
                self.render = [[OBJ_Render_4 alloc] initWithMTKView:self.mtkView];
                self.mtkView.delegate = self.render;
                [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
            }break;
            case 5:{
                self.render = [[OBJ_Render_5 alloc] initWithMTKView:self.mtkView];
                self.mtkView.delegate = self.render;
                [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
            }break;
            default:{
                self.render = [[OBJ_Render alloc] initWithMTKView:self.mtkView];
                self.mtkView.delegate = self.render;
                [self.render mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
            }break;
        }
        [sender setTitle:item.name];
    }]];
}

#endif


- (NSMutableArray<YLSheetItem *> *)itemsArray {
    if (_itemsArray == nil) {
        _itemsArray = [NSMutableArray array];
        [_itemsArray addObject:[YLSheetItem modelWithType:1 name:@"二维模型渲染"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:2 name:@"三维空间观察"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:3 name:@"漫反射"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:4 name:@"镜面反射"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:5 name:@"环境光"]];
        [_itemsArray addObject:[YLSheetItem modelWithType:1000 name:@"渲染与反射"]];
    }
    return _itemsArray;
}

@end
