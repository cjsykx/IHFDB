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
 Return JSON Object convert from model (self) ...
 */
- (NSMutableDictionary *)JSONObjectFromModel;

/**
 Return JSON Object array convert from model array (self) ...
 
 Instance method
 */
- (NSArray <NSMutableDictionary *> *)JSONObjectsFromModelArray;

/**
 Return JSON Object array convert from model array ..
 
 Class method
 */
+ (NSArray <NSMutableDictionary *> *)JSONObjectsFromModelArray:(NSArray *)modelArray;


/**
 Do your like to do when model convert to JSON Object and check if need the JSON obejct ..
 
 @param JSONObject : The JSON object , always come from network ..
 
 @return : If NO , the you will NOT get the JSON Object which will convert from model ..
 */
- (BOOL)doModelCustomConvertToJSONObject:(NSMutableDictionary *)JSONObject;

//-----------------------------------------------------------------------------
///  ***********  Dict convert to Model ****************
//-----------------------------------------------------------------------------

/**
 Returns model convert from JSON object

 @param JSONObject : It usually is dictionary , but may be JSON string or JSON data
 */
+ (instancetype)modelFromJSONObject:(id)JSONObject;

/**
 Returns model convert from JSON object
 
 @param JSONObject : It usually is dictionary , but may be JSON string or JSON data
 */
+ (NSArray *)modelsFromJSONObjectArray:(NSArray <id>*)JSONObjects;


/**
 Do your like to do when model convert from JSON Object and check if need the model

 @param JSONObject : The JSON object , always come from network ..

 @return : If NO , the you will NOT get the model which will convert from JSON object ..
 */
- (BOOL)doModelCustomConvertFromJSONObject:(NSDictionary *)JSONObject;

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

/**
 Returns the class or super class custom primary keys
 */
+ (NSArray <NSString *>*)customPrimaryKeyLists ;

// Block
typedef void (^IHFPropertiesEnumeration)(IHFProperty *property,NSUInteger idx, BOOL *stop);

/**
 Enumerate the model's properties use block
 */
+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration;

/**
 Enumerate the model's class and super class  block
 */
typedef void (^IHFClassesEnumeration)(Class c, BOOL *stop);

/**
 Enumerate the model's class and super class block
 */
+ (void)enumerateAllClassesUsingBlock:(IHFClassesEnumeration)enumeration;

/**
 Get a Class All properties which type is array (Include super class)
 */
+ (NSArray <IHFProperty *>*)propertiesForTypeOfArray;

/**
 Get a Class All properties names which type is model (Include super class)
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
 returns value with given property name
 */
- (instancetype)valueWithPropertName:(NSString *)propertyName;

/**
 returns value with given property
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
