//
//  ItemsViewController.m
//  Graphics
//
//  Created by 苏莫离 on 2021/9/28.
//

#import "ItemsViewController.h"

@interface ItemsViewController ()
#if defined(TARGET_IOS)
<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
#elif defined(TARGET_MACOS)
<NSTableViewDelegate,NSTableViewDataSource>
{
    PlatformViewController *_prevController;
}
@property (nonatomic, strong) NSTableView *tableView;
@property (nonatomic, strong) NSView *contentView;
#endif
@property (nonatomic, strong) NSArray<DemoItem *> *dataArray;

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if defined(TARGET_IOS)
    [self.view addSubview:self.tableView];
#elif defined(TARGET_MACOS)
    
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    scrollView.hasVerticalScroller = YES;
    scrollView.frame = NSMakeRect(0, 0, kMacListWidth, kMacScreenHeight);
    [self.view addSubview:scrollView];
    _tableView = [[NSTableView alloc]initWithFrame:scrollView.bounds];
    _tableView.rowHeight = 26;
    NSTableColumn *column = [[NSTableColumn alloc]initWithIdentifier:@"Graphics"];
    [_tableView addTableColumn:column];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
    scrollView.contentView.documentView = _tableView;
    
    _contentView = [[NSView alloc] initWithFrame:NSMakeRect(kMacListWidth, 0, kMacContentWidth, kMacScreenHeight)];
    _contentView.layer.backgroundColor = NSColor.blackColor.CGColor;
    [self.view addSubview:_contentView];
#endif
}

- (PlatformViewController *)getControllerWithRow:(NSInteger)row {
    NSString *controllerName = self.dataArray[row].controller;
    return (PlatformViewController *)[[NSClassFromString(controllerName) alloc] init];
}

#if defined(TARGET_IOS)

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row].item;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlatformViewController *vc = [self getControllerWithRow:indexPath.row];
    vc.navigationItem.title = self.dataArray[indexPath.row].item;
    [self.navigationController pushViewController:vc animated:YES];
}

#elif defined(TARGET_MACOS)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return self.dataArray[row].item;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    [_prevController.view removeFromSuperview];
    [_prevController removeFromParentViewController];
    _prevController = [self getControllerWithRow:row];
    [self addChildViewController:_prevController];
    _prevController.view.frame = _contentView.bounds;
    [_contentView addSubview:_prevController.view];
    return YES;
}

#endif


#pragma mark - setters and getters

- (NSArray<DemoItem *> *)dataArray {
    if (_dataArray == nil) {
        _dataArray = @[
            [DemoItem item:@"计算" controller:@"ComputeController"],
            [DemoItem item:@"图元类型" controller:@"PrimitiveTypeViewController"],
            [DemoItem item:@"二维图形" controller:@"PlaneFigureController"],
            [DemoItem item:@"正弦轨迹" controller:@"SineViewController"],
            [DemoItem item:@"二维变换" controller:@"TwoDimensionTransformController"],
            [DemoItem item:@"深度测试" controller:@"DepthTestingController"],
            [DemoItem item:@"透视投影" controller:@"CubeViewController"],
            [DemoItem item:@"世界坐标系转观察坐标系" controller:@"WordToLookController"],
            [DemoItem item:@"地球纹理" controller:@"EarthViewController"],
            [DemoItem item:@"环绕脖子" controller:@"AroundNeckController"],
            [DemoItem item:@"计算纹理" controller:@"ComputeTextureController"],
            [DemoItem item:@"读取纹理像素" controller:@"ReadTexturePixelController"],
            [DemoItem item:@"离屏渲染" controller:@"OffscreenController"],
        ];
    }
    return _dataArray;
}

#if defined(TARGET_IOS)

- (UITableView *)tableView {
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 45;
        tableView.tableFooterView = UIView.new;
        [tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
        _tableView = tableView;
    }
    return _tableView;
}

#endif

@end
