//
//  DataBase.h
//  SQL_Demo
//
//  Created by double on 2017/9/11.
//  Copyright © 2017年 double. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> //这个库需要在工程中->targets->General->Linked Frameworks and Libraries中添加libsqlite3.0.tbd后才能正常使用

@interface DataBase : NSObject

+ (DataBase *)shareInstance;

//打开数据库
- (BOOL)openDBWithPath:(NSString *)path;

//关闭数据库
- (BOOL)closeDB;

/*
 创建表
 tbaleName:表名
 columns:多个字段
 */
- (BOOL)createTableWith:(NSString *)tableName columns:(NSString *)columns;

/*
 删除表
 tableName:表名
 */
- (BOOL)deleteTableWith:(NSString *)tableName;

/*
 增加列
 column:字段
 tableName:表名
 */
- (BOOL)addColumn:(NSString *)column formTable:(NSString *)tableName;

//删除列 (sqlite暂不支持drop column的语法，暂时弃用，后面再选中一个其他途径实现)
- (BOOL)deleteColumn:(NSString *)column formTable:(NSString *)tableName;

/*
 增
 columnName:字段
 columnValue:值,字符要用 '' 包含
 tableName:表名
 */
- (BOOL)insertWithColumnName:(NSString *)columnName columnValue:(NSString *)columnValue tableName:(NSString *)tableName;

/*
 删
 whereStr:条件语句
 tableName:表名
 tip:(删除值为null的值时语法为 columnName is null)
 */
- (BOOL)deleteWithWhereStr:(NSString *)whereStr tableName:(NSString *)tableName;
//删除所有行
- (BOOL)deletcAllColumnsWith:(NSString *)tableName;

/*
 改
 newColumnKeysAndValues:要更新的字段及新值，如值为字符需要用 '' 包含
 whereStr:条件语句
 tableName:表名
 tip:(更改值为null时的语法为 columnName=null)
 */
- (BOOL)updateWithNewColumnKeysAndValues:(NSString *)newColumnKeysAndValues whereStr:(NSString *)whereStr tableName:(NSString *)tableName;

/*
 查
 findStr:要查找的字段，为空时则搜索所有
 whereStr:条件语句
 orderBy:排序筛选语句,默认为升序，为空时descend无意义
 descend:降序排序，orderBy为空时无意义
 limit:查找个数，-1即小于0时为所有
 tableName:表名
 */
- (sqlite3_stmt *)selectWithFindStr:(NSString *)findStr whereStr:(NSString *)whereStr orderBy:(NSString *)orderBy descend:(BOOL)descend limit:(int)limit tableName:(NSString *)tableName;

/*
 自定义命令
 */
- (BOOL)customCommand:(NSString *)command;

/*
 当数据库的操作量大的时候，应该使用数据库的事务进行优化
 */
//启动事务
- (BOOL)beginTransaction;

//提交事务
- (BOOL)commitTransaction;

//回滚事务
- (BOOL)rollbackTransaction;


@end
