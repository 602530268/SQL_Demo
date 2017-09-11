//
//  ViewController.m
//  SQL_Demo
//
//  Created by double on 2017/9/11.
//  Copyright © 2017年 double. All rights reserved.
//

#import "ViewController.h"
#import "DataBase.h"

static NSString *kTableViewCellIdentifier = @"kTableViewCellIdentifier";

@interface ViewController ()
{
    NSMutableArray *_datas;
}

@property (weak, nonatomic) IBOutlet UILabel *timerLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@",NSHomeDirectory());
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellIdentifier];
    
    NSArray *arr = @[
                     @"打开数据库",
                     @"关闭数据库",
                     @"创建表",
                     @"删除表",
                     @"增加列",
                     @"删除列",
                     @"增",
                     @"删",
                     @"改",
                     @"查",
                     @"大量数据的增加"
                     ];
    
    _datas = arr.mutableCopy;
    
    [self updateTimerLbl];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"mysqlite.sqlite"];
    
    [[DataBase shareInstance] openDBWithPath:path];
    
}

- (void)updateTimerLbl {
    static float time = 0;
    
    __weak UILabel *label = self.timerLbl;
    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSString *string = [NSString stringWithFormat:@"%.02f",time];
        time += 0.1;
        label.text = string;
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = _datas[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"mysqlite.sqlite"];
    
    switch (indexPath.row) {
        case 0:
            //打开数据库
            if ([[DataBase shareInstance] openDBWithPath:path]) {
                NSLog(@"打开数据库成功");
            }else {
                NSLog(@"打开数据库失败");
            }
            break;
        case 1:
            //关闭数据库
            if ([[DataBase shareInstance] closeDB]) {
                NSLog(@"关闭数据库成功");
            }else {
                NSLog(@"关闭数据库失败");
            }
            break;
        case 2:
            //创建表
            if ([[DataBase shareInstance] createTableWith:@"Table1" columns:@"c1,c2,c3 char,c4,c5"]) {
                NSLog(@"创建表成功");
            }else {
                NSLog(@"创建表失败");
            }
            break;
        case 3:
            //删除表
            if ([[DataBase shareInstance] deleteTableWith:@"Table1"]) {
                NSLog(@"删除表成功");
            }else {
                NSLog(@"删除表失败");
            }
            break;
        case 4:
            //增加列
            if ([[DataBase shareInstance] addColumn:@"c6 char" formTable:@"Table1"]) {
                NSLog(@"增加列成功");
            }else {
                NSLog(@"增加列失败");
            }
            break;
        case 5:
            //删除列
            if ([[DataBase shareInstance] deleteColumn:@"c3" formTable:@"Table1"]) {
                NSLog(@"删除列成功");
            }else {
                NSLog(@"删除列失败");
            }
            break;
        case 6:
            //增
            if ([[DataBase shareInstance] insertWithColumnName:@"c1,c2,c3,c4" columnValue:@"'a','b','c',''" tableName:@"Table1"]) {
                NSLog(@"插入数据成功");
            }else {
                NSLog(@"插入数据失败");
            }
            
            break;
        case 7:
            //删
            
            [[DataBase shareInstance] deletcAllColumnsWith:@"Table1"];    //删除所有数据
//
//            if ([[DataBase shareInstance] deleteWithWhereStr:@"c4='cccc'" tableName:@"Table1"]) {
//                NSLog(@"删除数据成功");
//            }else {
//                NSLog(@"删除数据失败");
//            }
            break;
        case 8:
            //改
            if ([[DataBase shareInstance] updateWithNewColumnKeysAndValues:@"c5=null" whereStr:@"c5='ccc'" tableName:@"Table1"]) {
                NSLog(@"更新数据成功");
            }else {
                NSLog(@"更新数据失败");
            }
            break;
        case 9:
            //查
        {
            sqlite3_stmt *result = [[DataBase shareInstance] selectWithFindStr:nil whereStr:@"c1='a'" orderBy:@"c4" descend:NO limit:-1 tableName:@"Table1"];
            while (sqlite3_step(result) == SQLITE_ROW) {
                
                char *c1 = (char *)sqlite3_column_text(result, 0);
                char *c4 = (char *)sqlite3_column_text(result, 1);
                
                NSString *c1Str = [NSString stringWithUTF8String:c1];
                NSString *c4Str = [NSString stringWithUTF8String:c4];
                
                NSLog(@"c1Str: %@,c4Str: %@",c1Str,c4Str);
            }
        }
            break;
        case 10:
            //大量数据的插入
            
            if ([[DataBase shareInstance] beginTransaction]) {
                NSLog(@"事务启动成功");
                
                for (int i = 0; i < 10000; i++) {
                    [[DataBase shareInstance] insertWithColumnName:@"c1,c2,c3,c4,c5" columnValue:@"1,2,3,4,5" tableName:@"Table1"];
                }
                
                if ([[DataBase shareInstance] commitTransaction]) {
                    NSLog(@"事务提交成功");
                }
            }
            
            break;
            
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
