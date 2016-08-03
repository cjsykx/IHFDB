//
//  IHFProperty.h
//  IHFDB
//
//  Created by CjSon on 16/6/21.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, IHFPropertyType) {

    IHFPropertyTypeModel               = 0x00,
    IHFPropertyTypeBOOL                = 0x01,
    IHFPropertyTypeNumber              = 0x02,
    IHFPropertyTypeInt                 = 0x03,
    IHFPropertyTypeArray               = 0x04,
    IHFPropertyTypeString              = 0x06,
    IHFPropertyTypeId                  = 0x07,
    IHFPropertyTypeURL                 = 0x08,
    IHFPropertyTypeData                = 0x09,
    IHFPropertyTypeError               = 0x0A,
    IHFPropertyTypeValue               = 0x0B,
    IHFPropertyTypeAttributedString    = 0x0C,
    IHFPropertyTypeDictionary          = 0x0D,
    IHFPropertyTypeFloat               = 0x0F,
    IHFPropertyTypeDouble              = 0x10,
    IHFPropertyTypeLong                = 0x11,
    IHFPropertyTypeImage               = 0x12, // UIImage
    IHFPropertyTypeDate                = 0x13, // NSDate
    IHFPropertyTypeAny                       ,

};

@interface IHFProperty : NSObject

@property (nonatomic, assign) objc_property_t property; /** Belong to */

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, assign) IHFPropertyType type;
@property (nonatomic, copy) NSString *typeString;


@property (nonatomic, assign) Class objectClass; /**< CLASS is contain in the Array OR the class is the relation class*/


@property (nonatomic, assign) NSNumber *typeOfFundation; /**< If the type from fundation , Object type ! such as 'NSString' */

@property (nonatomic, assign,readonly,getter=isTypeOfBasicData) BOOL typeOfBasicData; /**< Basic data types , not object,such as int ,bool */

- (IHFPropertyType)typeConvertFormString:(NSString *)aString;

@property (nonatomic, strong) NSSet *fundationTypes;
@property (nonatomic, strong) NSSet *basicDataTypes;

@end
