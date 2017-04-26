//
//  Request.m
//  IHFDB
//
//  Created by chenjiasong on 2017/4/20.
//  Copyright © 2017年 IHEFE CO., LIMITED. All rights reserved.
//

#import "Request.h"

@implementation Request
+ (NSArray<NSString *> *)propertyNamesForCustomPrimarykeys {
    return @[@"requestId"];
}

@end
