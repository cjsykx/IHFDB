//
//  Person.m
//  IHFDB
//
//  Created by chenjiasong on 16/11/10.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "Person.h"

@implementation Person
+ (NSArray *)propertyNamesForIgnore {
    return @[@"idCard"];
}

+ (NSDictionary *)propertyNameDictForMapper {
    return @{ @"age" : @"age1",
              };
}

+ (NSDictionary *)propertyNameDictForClassInArray {
    return @{
             @"works" : [Bed class],
             };
}

#pragma mark - test
- (void)eat1 {
    NSLog(@"%s",__FUNCTION__);
}

- (void)sleep1 {
    NSLog(@"%s",__FUNCTION__);
}

- (Person *)eat2 {
    NSLog(@"%s",__FUNCTION__);
    return self;
}

- (Person *)sleep2 {
    NSLog(@"%s",__FUNCTION__);
    return self;
}

- (void (^)())eat3 {
    //定义block
    void (^eat3Block)() = ^ {
        NSLog(@"%s",__FUNCTION__);
    };
    return eat3Block;
}

- (void (^)())sleep3 {
    return ^ {
        NSLog(@"%s",__FUNCTION__);
    };;
}

- (Person *(^)())eat4 {
    Person *(^eat4Block)() = ^ {
        NSLog(@"%s",__FUNCTION__);
        return self;
    };
    return eat4Block;
}

- (Person *(^)())sleep4 {
    return ^{
        NSLog(@"%s",__FUNCTION__);
        return self;
    };
}

- (Person *(^)(NSString *))eat5 {
    Person * (^eat5Block)() = ^(NSString *food) {
        NSLog(@"吃: %@",food);
        return self;
    };
    return eat5Block;
}

- (Person *(^)(NSInteger))sleep5 {
    return ^(NSInteger hour) {
        NSLog(@"睡了%ld小时",(long)hour);
        return self;
    };
}


@end
