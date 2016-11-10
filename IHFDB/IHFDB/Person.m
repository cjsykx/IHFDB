//
//  Person.m
//  IHFDB
//
//  Created by chenjiasong on 16/11/10.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "Person.h"

@implementation Person
+ (NSArray *)propertyNamesForIgnore{
    return @[@"idCard"];
}

+ (NSDictionary *)propertyNameDictForMapper{
    return @{ @"age" : @"age1",
              };
}

+ (NSDictionary *)relationshipDictForClassInArray{
    
    return @{
             @"works" : [Bed class],
             };
}

@end
