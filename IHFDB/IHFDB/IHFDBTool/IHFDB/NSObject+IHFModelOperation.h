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

//-----------------------------------------------------------------------------
//*************** Model Model convert to Dict ****************
//-----------------------------------------------------------------------------

/**
 Model convert to dict
 */
- (NSDictionary *)dictionaryFromModel;

/**
 Model Array convert to dict Array
 */
- (NSArray <NSDictionary *> *)dictionaryArrayFromModelArray;
+ (NSArray <NSDictionary *> *)dictionaryArrayFromModelArray:(NSArray *)modelArray;

//-----------------------------------------------------------------------------
///  ***********  Dict convert to Model ****************
//-----------------------------------------------------------------------------

/**
 Dict convert to Model
 */
+ (instancetype)modelFromDictionary:(NSDictionary *)dict;

/**
 Dict Array convert to Model Array
 */

+ (NSArray <id> *)modelArrayFromDictionaryArray:(NSArray <NSDictionary *> *)dict;

/**
 JsonString convert to Model
 */
+ (instancetype)modelFromJsonString:(NSString *)jsonString;

/**
 JsonData convert to Model
 */
+ (instancetype)modelFromJsonData:(NSData *)jsonData;

//-----------------------------------------------------------------------------
///  ************* Run time to property and Class ****************
//-----------------------------------------------------------------------------
/** Return all property name */

+ (NSArray *)getAllPropertyName;
- (NSArray *)getAllPropertyName;

/** Return all property name and type */

+ (NSDictionary *)getAllPropertyNameAndType;
- (NSDictionary *)getAllPropertyNameAndType;

/**
 Returns the class and super class ignore property names
 */
+ (NSArray *)ignoredPropertyNames ;

/**
 Return a dictionary : key is Ignored property names , and value is the ignoredKey_Value.
 */
- (NSDictionary *)dictWithIgnoredPropertyNames;

/**
 Returns the class and super class allowed (NOT Ignore) property names
 */
+ (NSArray <IHFProperty *>*)allowedPropertyNames;

/**
 Returns array contain the class and super class map key-value
 */
+ (NSArray <NSDictionary *>*)mappedPropertyNameDicts;

/**
 Returns array contain the class and super class relation key-value (Class in array)
 */
+ (NSArray <NSDictionary *>*)relationPropertyNameDicts;

// Block
typedef void (^IHFPropertiesEnumeration)(IHFProperty *property,NSUInteger idx, BOOL *stop);

/** Enumerate the model's properties use block*/

+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration;

/** Enumerate the model's class and super class  block */
typedef void (^IHFClassesEnumeration)(Class c, BOOL *stop);

/**
 Enumerate the model's class and super class block
 */
+ (void)enumerateAllClassesUsingBlock:(IHFClassesEnumeration)enumeration;

/**
 Get a Class All properties which type is array
 */
+ (NSArray <IHFProperty *>*)propertiesForTypeOfArray;

/**
 Get a Class All properties names which type is array
 */
+ (NSArray <IHFProperty *>*)propertiesForTypeOfModel;


//-----------------------------------------------------------------------------
///  ************* property Value getter and setter ****************
//-----------------------------------------------------------------------------

// Create setter method
- (SEL)createSetSEL:(NSString *)propertyName;

/** Fetch the property with the its name */
- (IHFProperty *)propertyWithName:(NSString *)propertyame;

// set model value
-(void)setValue:(id)aValue forProperty:(IHFProperty *)property;
- (void)setValue:(NSObject *)value propertyName:(NSString *)name propertyType:(NSString *)type;

/**
 Get value with property name
 */
- (instancetype)valueWithPropertName:(NSString *)propertyName;

/**
 Get value with property name
 */

- (instancetype)valueWithProperty:(IHFProperty *)property;

/**
 Returns if the class is from fundation , such as NSObject , NSString ...

 @return : If yes , is from fundation ,
 */
+ (BOOL)isClassFromFoundation:(Class)aClass;

/** Return type name in sqlite with the type  */
- (NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName;

@end
