//
//  NSObject+IHFKeyValue.m
//  NurseV2
//
//  Created by CjSon on 16/6/7.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSObject+IHFKeyValue.h"

@implementation NSObject (IHFKeyValue)
-(NSMutableString *)keyAndValueString{
    
    __block NSMutableString *keyValueString = [NSMutableString string];

    Class clazz = [self class];
    NSArray *allowedPropertyNames = [clazz mj_totalAllowedPropertyNames];
    NSArray *ignoredPropertyNames = [clazz mj_totalIgnoredPropertyNames];
    
    
    [clazz mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        
        // 0.检测是否被忽略
        if (allowedPropertyNames.count && ![allowedPropertyNames containsObject:property.name]) return;
        if ([ignoredPropertyNames containsObject:property.name]) return;
        
        // 1.取出属性值
        id value = [property valueForObject:self];
        if (!value) return;
        
        // 2.如果是模型属性
        MJPropertyType *type = property.type;
        Class propertyClass = type.typeClass;
        if (!type.isFromFoundation && propertyClass) {
            value = @"";
        } else if ([value isKindOfClass:[NSArray class]]) {
            // 3.处理数组里面有模型的情况
        } else if (propertyClass == [NSURL class]) {
            value = [value absoluteString];
        }else if (propertyClass == [NSDate class]) {
            value = [self DateStringConvertWithdate:value];
        }else if (propertyClass == [NSNumber class] ) {
            value = [value stringValue];
        }else if (propertyClass == [NSNull class] ) {
            value = @"";
        }
        [keyValueString appendFormat:@"%@=%@",property.name,value];
    }];
    
    
    return keyValueString;
}

// use date for get stirng
-(NSString *)DateStringConvertWithdate:(NSDate *)date{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return  [dateFormat stringFromDate:date];
}


@end
