//
//  IHFProperty.m
//  IHFDB
//
//  Created by CjSon on 16/6/21.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFProperty.h"

@implementation IHFProperty

-(IHFPropertyType)typeConvertFormString:(NSString *)aString{
    
    IHFPropertyType type = IHFPropertyTypeModel; // Model type
    if ([aString isEqualToString:@"NSString"]) {
        type = IHFPropertyTypeString;
    }else if ([aString isEqualToString:@"NSNumber"]) {
        type = IHFPropertyTypeNumber;
    }else if ([aString isEqualToString:@"NSDate"]) {
        type = IHFPropertyTypeDate;
    }else if ([aString isEqualToString:@"NSArray"]) {
        type = IHFPropertyTypeArray;
    }else if ([aString isEqualToString:@"NSURL"]) {
        type = IHFPropertyTypeURL;
    }else if ([aString isEqualToString:@"NSValue"]) {
        type = IHFPropertyTypeValue;
    }else if ([aString isEqualToString:@"NSError"]) {
        type = IHFPropertyTypeError;
    }else if ([aString isEqualToString:@"NSDictionary"]) {
        type = IHFPropertyTypeDictionary;
    }else if ([aString isEqualToString:@"NSAttributedString"]) {
        type = IHFPropertyTypeAttributedString;
    }else if ([aString isEqualToString:@"B"]) {
        type = IHFPropertyTypeBOOL;
    }else if ([aString isEqualToString:@"f"]) {
        type = IHFPropertyTypeFloat;
    }else if ([aString isEqualToString:@"q"]) {
        type = IHFPropertyTypeLong;
    }else if ([aString isEqualToString:@"UIImage"]) {
        type = IHFPropertyTypeImage;
    }else if ([aString isEqualToString:@"d"]) {
        type = IHFPropertyTypeDouble;
    }else if ([aString isEqualToString:@"i"]) {
        type = IHFPropertyTypeInt;
    }

    return type;
}

-(IHFPropertyType)type{
    return [self typeConvertFormString:self.typeString];
}

-(BOOL)isTypeOfFundation{
    
    if ([self.fundationTypes containsObject:@(self.type)]) return YES;
    return NO;
}

-(BOOL)isTypeOfBasicData{
    
    if ([self.basicDataTypes containsObject:@(self.type)]) return YES;
    return NO;
}

-(NSSet *)fundationTypes{
    if (_fundationTypes == nil) {
        _fundationTypes = [NSSet setWithObjects:
                             @(IHFPropertyTypeNumber),
                             @(IHFPropertyTypeDate),
                             @(IHFPropertyTypeData),
                             @(IHFPropertyTypeError),
                             @(IHFPropertyTypeDictionary),
                             @(IHFPropertyTypeString),
                             @(IHFPropertyTypeAttributedString),
                             @(IHFPropertyTypeURL),
                             @(IHFPropertyTypeValue),nil];
    }
    return _fundationTypes;
}

-(NSSet *)basicDataTypes{

    if (_fundationTypes == nil) {
        _fundationTypes = [NSSet setWithObjects:
                           @(IHFPropertyTypeInt),
                           @(IHFPropertyTypeBOOL),
                           @(IHFPropertyTypeDouble),
                           @(IHFPropertyTypeFloat),
                           @(IHFPropertyTypeDictionary),
                           @(IHFPropertyTypeLong),nil];
    }
    return _fundationTypes;
}


@end
