//
//  IHFProperty.m
//  IHFDB
//
//  Created by CjSon on 16/6/21.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFProperty.h"
#import "IHFDBObjectDataSource.h"
#import "NSObject+IHFModelOperation.h"
@implementation IHFProperty

// TODO: NSSet may equal to NSArray ,
- (IHFPropertyType)typeConvertFormString:(NSString *)aString {
    
    // If not equal to , it will be a model type !
    IHFPropertyType type = IHFPropertyTypeModel; // Model type

    if ([aString isEqualToString:@"NSString"] || [aString isEqualToString:@"NSMutableString"]) {
        type = IHFPropertyTypeString;
    } else if ([aString isEqualToString:@"NSNumber"]) {
        type = IHFPropertyTypeNumber;
    } else if ([aString isEqualToString:@"NSDate"]) {
        type = IHFPropertyTypeDate;
    } else if ([aString isEqualToString:@"NSArray"] || [aString isEqualToString:@"NSMutableArray"]) {
        type = IHFPropertyTypeArray;
    } else if ([aString isEqualToString:@"NSURL"]) {
        type = IHFPropertyTypeURL;
    } else if ([aString isEqualToString:@"NSValue"]) {
        type = IHFPropertyTypeValue;
    } else if ([aString isEqualToString:@"NSError"]) {
        type = IHFPropertyTypeError;
    } else if ([aString isEqualToString:@"NSDictionary"] || [aString isEqualToString:@"NSMutableDictionary"]) {
        type = IHFPropertyTypeDictionary;
    } else if ([aString isEqualToString:@"NSAttributedString"]) {
        type = IHFPropertyTypeAttributedString;
    } else if ([aString isEqualToString:@"c"] || [aString isEqualToString:@"C"] || [aString isEqualToString:@"b"]) {
        type = IHFPropertyTypeBOOL;
    } else if ([aString isEqualToString:@"f"]) {
        type = IHFPropertyTypeFloat;
    } else if ([aString isEqualToString:@"l"]) {
        type = IHFPropertyTypeLong;
    } else if ([aString isEqualToString:@"L"]) {
        type = IHFPropertyTypeUnsignedLong;
    } else if ([aString isEqualToString:@"UIImage"]) {
        type = IHFPropertyTypeImage;
    } else if ([aString isEqualToString:@"d"]) {
        type = IHFPropertyTypeDouble;
    } else if ([aString isEqualToString:@"i"]) {
        type = IHFPropertyTypeInt;
    } else if ([aString isEqualToString:@"I"]) {
        type = IHFPropertyTypeUInteger;
    } else if ([aString isEqualToString:@"NSData"] || [aString isEqualToString:@"NSMutableData"]) {
        type = IHFPropertyTypeData;
    } else if ([aString isEqualToString:@"@"]) { // The type such as id , block ...
        type = IHFPropertyTypeId;
    } else if ([aString isEqualToString:@"s"]) {
        type = IHFPropertyTypeShort;
    } else if ([aString isEqualToString:@"q"]) {
        type = IHFPropertyTypeLongLong;
    } else if ([aString isEqualToString:@"Q"]) {
        type = IHFPropertyTypeUnsignedLongLong;
    }

    return type;
}

- (NSNumber *)typeOfFundation {
    
    if (!_typeOfFundation) {
        return ([self.fundationTypes containsObject:@(self.type)]) ? @(YES) : @(NO);
    }
    return _typeOfFundation;
}

- (BOOL)isTypeOfBasicData {
    
    if ([self.basicDataTypes containsObject:@(self.type)]) return YES;
    return NO;
}

- (NSSet *)fundationTypes {
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

- (NSSet *)basicDataTypes {

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

- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString srcClass:(__unsafe_unretained Class)srcClass {
    
    self = [super init];
    if (self) {
        _propertyName = name;
        _typeString = typeString;
        _type = [self typeConvertFormString:_typeString];
        _setSel = [self createSetSELWithPropertyName:name];
        _imp = [[[srcClass alloc] init] methodForSelector:_setSel];
        _srcClass = srcClass;
        _getSel = [self createGetSELWithPropertyName:name];
        
        if (_type == IHFPropertyTypeArray) {
            if ([[srcClass relationPropertyNameDicts] count]) {
                [[srcClass relationPropertyNameDicts] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    id object = [obj objectForKey:name];
                    if (object) {
                        // according to user returns the relation dict !
                        if ([object isKindOfClass:[NSString class]]) {
                            _objectClass = NSClassFromString(object);
                        } else {
                            _objectClass = [[srcClass relationshipDictForClassInArray] objectForKey:name];
                        }
                        *stop = YES; // Let child first
                    }
                }];
            }
        } else if (_type == IHFPropertyTypeModel) {
            _objectClass = NSClassFromString(typeString);
        }
        
        if ([[srcClass mappedPropertyNameDicts] count]) {
            [[srcClass mappedPropertyNameDicts] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                _propertyNameMapped = [obj objectForKey:name];
                if (_propertyNameMapped) *stop = YES; // Let child first
            }];
        }
    }
    return self;
}

+ (instancetype)propertyWithName:(NSString *)name typeString:(NSString *)typeString srcClass:(__unsafe_unretained Class)srcClass {
    return [[self alloc] initWithName:name typeString:typeString srcClass:srcClass];
}

// create Setter method
- (SEL)createSetSELWithPropertyName:(NSString *)propertyName {
    NSString* firstString = [propertyName substringToIndex:1].uppercaseString;
    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    propertyName = [NSString stringWithFormat:@"set%@:",propertyName];
    return NSSelectorFromString(propertyName);
}

// create Getter method
- (SEL)createGetSELWithPropertyName:(NSString*)propertyName {
    return NSSelectorFromString(propertyName);
}

@end
