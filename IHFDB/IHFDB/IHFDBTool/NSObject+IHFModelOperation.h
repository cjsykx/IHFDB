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

///  *********** Model Model convert to Dict ****************

/** Model convert to dict */
- (NSDictionary *)dictionaryFromModel;

/** Model Array convert to dict Array */
- (NSArray <NSDictionary *> *)dictionaryArrayFromModelArray;
+ (NSArray <NSDictionary *> *)dictionaryArrayFromModelArray:(NSArray *)modelArray;


///  ***********  Dict convert to Model ****************

/** Dict convert to Model */
+ (instancetype)modelFromDictionary:(NSDictionary *)dict;

/** Dict Array convert to Model Array*/

+ (NSArray <id> *)modelArrayFromDictionaryArray:(NSArray <NSDictionary *> *)dict;


///  ***********  ******************* ****************

/** return all property name */

+ (NSArray *)getAllPropertyName;
- (NSArray *)getAllPropertyName;

/** return all property name and type */

+ (NSDictionary *)getAllPropertyNameAndType;
- (NSDictionary *)getAllPropertyNameAndType;


/** return type name in sqlite with the type  */

- (NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName;

// Block
typedef void (^IHFPropertiesEnumeration)(IHFProperty *property,NSUInteger idx, BOOL *stop);

/** Enumerate the model's properties use block*/

+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration;

// Create setter method
- (SEL)createSetSEL:(NSString *)propertyName;

/** Fetch the property with the its name */
- (IHFProperty *)propertyWithName:(NSString *)propertyame;

// set model
-(void)setValue:(id)aValue forProperty:(IHFProperty *)property;
- (void)setValue:(NSObject *)value propertyName:(NSString *)name propertyType:(NSString *)type;

// Get model value
/** Get value with property name */
- (instancetype)valueWithPropertName:(NSString *)propertyName;
- (instancetype)valueWithProperty:(IHFProperty *)property;

/**
 Get a Class All properties which type is array
 */
+ (NSArray <IHFProperty *>*)propertiesForTypeOfArray;

/**
 Get a Class All properties names which type is array
 */
+ (NSArray <IHFProperty *>*)propertiesForTypeOfModel;

@end
