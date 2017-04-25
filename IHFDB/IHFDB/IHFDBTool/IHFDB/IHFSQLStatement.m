//
//  IHFStatement.m
//  IHFDB
//
//  Created by chenjiasong on 16/8/12.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//
#import "IHFSQLStatement.h"
#import <UIKit/UIKit.h>
@implementation IHFSQLStatement

- (instancetype)initWithSql:(NSString *)sql arguments:(NSArray *)arguments {
    self = [super init];
    
    if (self) {
        _sql = sql;
        _arguments = [self formatArguments:arguments];
    }
    return self;
}

+ (instancetype)statementWithSql:(NSString *)sql arguments:(NSArray *)arguments {
    return [[self alloc] initWithSql:sql arguments:arguments];
}

// For save into DB in a format can be use IHFPredicate
- (NSArray *)formatArguments:(NSArray *)arguments {
    __block NSMutableArray *argumentsM = [NSMutableArray array];
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]) {
            obj = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        } else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSMutableDictionary class]]) {
            obj = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        } else if ([obj isKindOfClass:[NSDate class]]) {
            obj = [NSString stringWithFormat:@"%@",obj];
        } else if (!obj || [obj isKindOfClass:[NSNull class]]) {
            obj = [NSString stringWithFormat:@"%@",nil];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            obj = UIImageJPEGRepresentation(obj,0.5f);
        }/*else if (property.type == IHFPropertyTypeId) {
            if ([NSJSONSerialization isValidJSONObject:obj]) {
                obj = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
            }
        }*/
        [argumentsM addObject:obj];
    }];
    return argumentsM;
}

@end
