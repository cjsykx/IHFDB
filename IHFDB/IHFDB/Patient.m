//
//  Patient.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "Patient.h"

@implementation Patient
+ (NSDictionary *)propertyNameDictForClassInArray {
    
    return @{
             @"drugs" : [Drug class],
             @"patientImages" : [PatientImage class],
             };
}

+ (NSArray<NSString *> *)propertyNamesForCustomPrimarykeys {
    return @[@"patientID",@"hostipalID"];
}

+ (NSDictionary *)propertyNameDictForMapper {
    return @{ @"mapperStr1" : @"mapperStr",
              @"mapperNumber1" :@"mapperNumber",
             };
}

+ (NSArray *)propertyNamesForIgnore {
    return @[@"idCard",@"height"];
}

- (BOOL)doModelCustomConvertFromJSONObject:(NSDictionary *)JSONObject {
    NSRange range;
    range.length = [[JSONObject objectForKey:@"length"] integerValue];
    range.location = [[JSONObject objectForKey:@"location"] integerValue];
    self.range = range;
    return YES;
}

- (BOOL)doModelCustomConvertToJSONObject:(NSMutableDictionary *)JSONObject {
    [JSONObject setObject:@(self.range.length) forKey:@"length"];
    [JSONObject setObject:@(self.range.location) forKey:@"location"];
    return YES;
}
@end
