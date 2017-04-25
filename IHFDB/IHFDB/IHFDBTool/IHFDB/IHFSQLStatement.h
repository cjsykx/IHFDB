//
//  IHFStatement.h
//  IHFDB
//
//  Created by chenjiasong on 16/8/12.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHFSQLStatement : NSObject
@property (copy, nonatomic, readonly) NSString *sql;
@property (strong, nonatomic, readonly) NSArray *arguments;

- (instancetype)initWithSql:(NSString *)sql arguments:(NSArray *)arguments;
+ (instancetype)statementWithSql:(NSString *)sql arguments:(NSArray *)arguments;

@end
