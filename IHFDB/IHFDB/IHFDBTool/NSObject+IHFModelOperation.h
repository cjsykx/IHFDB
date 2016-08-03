//
//  NSObject+IHFModelOperation.h
//  IHFDB
//
//  Created by CjSon on 16/6/15.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHFProperty.h"
#import "IHFDBObjectDataSource.h"

@interface NSObject (IHFModelOperation)<IHFDBObejctDataSource>

/** Model convert to dict */
- (NSDictionary *)dictionaryBeConvertedFromModel;

/** Model Array convert to dict Array */
- (NSArray <NSDictionary *> *)dictionaryArrayBeConvertedFromModelArray;

/** Dict convert to Model */
+ (instancetype)modelBeConvertFromDictionary:(NSDictionary *)dict;

/** Dict Array convert to Model Array*/

+ (NSArray <id> *)modelArrayBeConvertFromDictionaryArray:(NSArray <NSDictionary *> *)dict;


/** return all property name */

+ (NSArray *)getAllPropertyName;
- (NSArray *)getAllPropertyName;

/** return all property name and type */

+ (NSDictionary *)getAllPropertyNameAndType;
- (NSDictionary *)getAllPropertyNameAndType;

- (NSString *)getTypeNameWith:(NSString *)propertyName;

- (void)setValue:(NSObject *)value propertyName:(NSString *)name propertyType:(NSString *)type;

/** return type name in sqlite with the type  */

- (NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName;

/** Get value with property name */

- (instancetype)getValueWithPropertName:(NSString *)propertyName;

// Block
typedef void (^IHFPropertiesEnumeration)(IHFProperty *property,NSUInteger idx, BOOL *stop);

/** Enumerate the model's properties use block*/

+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration;

// Create setter method
- (SEL)createSetSEL:(NSString *)propertyName;

/** Fetch the property with the its name */
- (IHFProperty *)propertyWithName:(NSString *)propertyame;

@end
