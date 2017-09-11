//
//  DataBase.m
//  SQL_Demo
//
//  Created by double on 2017/9/11.
//  Copyright © 2017年 double. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase {
    
    sqlite3 *_sqlite;  //全局sqlite对象
}

+ (DataBase *)shareInstance {
    static DataBase *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db = [[DataBase alloc] init];
    });
    return db;
}

//打开数据库
- (BOOL)openDBWithPath:(NSString *)path {
    
    int result = sqlite3_open([path UTF8String], &_sqlite);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    return NO;
}

//关闭数据库
- (BOOL)closeDB {
    
    int result = sqlite3_close(_sqlite);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    return NO;
}

//创建表
/*
 not null:
 unique:
 primary key:
 foreign key:
 check:
 default:
 index:
 */
- (BOOL)createTableWith:(NSString *)tableName columns:(NSString *)columns {
    
    NSString *sql = [NSString stringWithFormat:@"create table %@ (%@)",tableName,columns];
    NSLog(@"[Create SQL] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    return NO;
}

//删除表
- (BOOL)deleteTableWith:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"drop table '%@'",tableName];
    NSLog(@"[Delete SQL] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    return NO;
}

//增加列
- (BOOL)addColumn:(NSString *)column formTable:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@",tableName,column];
    NSLog(@"[Add Column] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    return NO;
}

//删除列 (sqlite暂不支持drop column的语法，暂时弃用，后面再选中一个其他途径实现)
- (BOOL)deleteColumn:(NSString *)column formTable:(NSString *)tableName {
    
    NSString *sql = [NSString stringWithFormat:@"alter table %@ drop column %@",tableName,column];
    NSLog(@"[Delete Column] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    return NO;
}

//增
- (BOOL)insertWithColumnName:(NSString *)columnName columnValue:(NSString *)columnValue tableName:(NSString *)tableName{
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",tableName,columnName,columnValue];
    NSLog(@"[Insert SQL] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    
    return NO;
}

//删
- (BOOL)deleteWithWhereStr:(NSString *)whereStr tableName:(NSString *)tableName{
    
    NSString *sql;
    
    if (whereStr) {
        sql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,whereStr];
    }else {
        sql = [NSString stringWithFormat:@"delete from %@",tableName];
    }
    
    NSLog(@"[Delete SQL] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    return NO;
}

//删除所有行
- (BOOL)deletcAllColumnsWith:(NSString *)tableName {
    
    return [self deleteWithWhereStr:nil tableName:tableName];
}

//改
- (BOOL)updateWithNewColumnKeysAndValues:(NSString *)newColumnKeysAndValues whereStr:(NSString *)whereStr tableName:(NSString *)tableName {
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName,newColumnKeysAndValues,whereStr];
    NSLog(@"[Update SQL] : %@",sql);
    
    char *err;
    int result = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"error: %s",err);
    return NO;
}

//查
- (sqlite3_stmt *)selectWithFindStr:(NSString *)findStr whereStr:(NSString *)whereStr orderBy:(NSString *)orderBy descend:(BOOL)descend limit:(int)limit tableName:(NSString *)tableName {
    
    NSString *sql;
    
    if (!findStr) {
        findStr = @"*";
    }
    
    if (orderBy) {
        sql = [NSString stringWithFormat:@"select %@ from %@ order by %@ %@ limit %d",findStr,tableName,orderBy,descend ? @"desc" : @"",limit];
    }else {
        sql = [NSString stringWithFormat:@"select %@ from %@ limit %d",findStr,tableName,limit];
    }
    
    NSLog(@"[Select SQL] : %@",sql);
    
    sqlite3_stmt *result;
    
    sqlite3_prepare_v2(_sqlite, [sql UTF8String], -1, &result, nil);
    
    return result;
}

//自定义命令
- (BOOL)customCommand:(NSString *)command{
    
    NSLog(@"[Custom SQL] : %@",command);
    
    char *err;
    if (sqlite3_exec(_sqlite, [command UTF8String], NULL, NULL, &err)) {
        return YES;
    }else {
        NSLog(@"err: %s",err);
        return NO;
    }
}

//启动事务
- (BOOL)beginTransaction {
    char *err;
    if (sqlite3_exec(_sqlite, [@"BEGIN" UTF8String], NULL, NULL, &err) == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"err: %s",err);
    return NO;
}

//提交事务
- (BOOL)commitTransaction {
    
    char *err;
    if (sqlite3_exec(_sqlite, [@"COMMIT" UTF8String], NULL, NULL, &err) == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"err: %s",err);
    
    //失败后回滚事务
    [self rollbackTransaction];
    
    return NO;
}

//回滚事务
- (BOOL)rollbackTransaction {
    
    char *err;
    if (sqlite3_exec(_sqlite, [@"ROLLBACK" UTF8String], NULL, NULL, &err) == SQLITE_OK) {
        return YES;
    }
    
    NSLog(@"err: %s",err);
    return NO;
}


@end
