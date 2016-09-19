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

- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString srcClass:(Class)srcClass;
+ (instancetype)propertyWithName:(NSString *)name typeString:(NSString *)typeString srcClass:(Class)srcClass;


@property (nonatomic, assign) objc_property_t property; /** Belong to */

@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, copy, readonly) NSString *propertyNameMapped; /**< the property Name which is mapped */

@property (nonatomic, assign,readonly) IHFPropertyType type;
@property (nonatomic, copy,readonly) NSString *typeString;

@property (nonatomic, assign,readonly) SEL setSel; /**< Setter method  */
@property (nonatomic, assign,readonly) IMP imp;   /**< Method From SetSel */

@property (nonatomic, assign,readonly) SEL getSel; /**< get method  */


@property (nonatomic, assign) Class objectClass; /**< CLASS is contain in the Array OR the class is the relation class*/

@property (nonatomic, assign,readonly) Class srcClass; /**< Source Class*/

@property (nonatomic, assign) NSNumber *typeOfFundation; /**< If the type from fundation , Object type ! such as 'NSString' */

@property (nonatomic, assign,readonly,getter=isTypeOfBasicData) BOOL typeOfBasicData; /**< Basic data types , not object,such as int ,bool */

- (IHFPropertyType)typeConvertFormString:(NSString *)aString;

@property (nonatomic, strong) NSSet *fundationTypes;
@property (nonatomic, strong) NSSet *basicDataTypes;

@end
