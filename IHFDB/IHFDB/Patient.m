//
//  Patient.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "Patient.h"

@implementation Patient
+ (NSDictionary *)relationshipDictForClassInArray{
    
    return @{
             @"drugs" : [Drug class],
             };
}

+ (NSString *)customPrimarykey{
    
    return @"patientID";
}

+ (NSDictionary *)propertyNameDictForMapper{
    return @{ @"mapperStr1" : @"mapperStr",
              @"mapperNumber1" :@"mapperNumber",
             
             };
}

@end
