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
    
    IHFPropertyTypeModel               = 0x00, // Default , It not predicate!
    IHFPropertyTypeBOOL                = 0x01, // int 8,  c
    IHFPropertyTypeNumber              = 0x02,
    IHFPropertyTypeInt                 = 0x03, // integer , i , int 32
    IHFPropertyTypeArray               = 0x04,
    IHFPropertyTypeString              = 0x06,
    IHFPropertyTypeId                  = 0x07,
    IHFPropertyTypeURL                 = 0x08,
    IHFPropertyTypeData                = 0x09,
    IHFPropertyTypeError               = 0x0A,
    IHFPropertyTypeValue               = 0x0B,
    IHFPropertyTypeAttributedString    = 0x0C,
    IHFPropertyTypeDictionaryI         = 0x0D,
    IHFPropertyTypeDictionaryM         = 0x0E,
    IHFPropertyTypeFloat               = 0x0F, // f
    IHFPropertyTypeDouble              = 0x10, // d
    IHFPropertyTypeLong                = 0x11, // l ,int 64
    IHFPropertyTypeUnsignedLong        = 0x12, // L
    IHFPropertyTypeImage               = 0x13, // UIImage
    IHFPropertyTypeDate                = 0x14, // NSDate
    IHFPropertyTypeUInteger            = 0x15, // I
    IHFPropertyTypeLongLong            = 0x16, // q
    IHFPropertyTypeUnsignedLongLong    = 0x17, // Q
    IHFPropertyTypeShort               = 0x18, // int 16, s
    IHFPropertyTypeClass               = 0x19,
    IHFPropertyTypeStruct              = 0x20,
    IHFPropertyTypePointer             = 0x21,
    IHFPropertyTypeBlock               = 0x22,

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

@property (nonatomic, strong) NSNumber *typeOfFundation; /**< If the type from fundation , Object type ! such as 'NSString' , 'NSObject'*/

@property (nonatomic, assign, readonly, getter=isTypeOfBasicData) BOOL typeOfBasicData; /**< Basic data types , not object,such as int ,bool */

- (IHFPropertyType)typeConvertFormString:(NSString *)aString;

@property (nonatomic, strong) NSSet *fundationTypes;
@property (nonatomic, strong) NSSet *basicDataTypes;

@end
