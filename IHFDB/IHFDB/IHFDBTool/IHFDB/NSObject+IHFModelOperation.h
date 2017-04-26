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
#import "IHFPredicate.h"

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
 
 @param JSONObjects : is array usually contains dictionary , but may be JSON string or JSON data
 */
+ (NSArray *)modelsFromJSONObjectArray:(NSArray <id>*)JSONObjects;

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
 Returns a Class All properties which type is array and the array contain object (Include super class)
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

// Set model value
-(void)setValue:(id)aValue forProperty:(IHFProperty *)property;

- (void)setValue:(NSObject *)value
    propertyName:(NSString *)name
    propertyType:(NSString *)type;

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


// *********** statement ********** //

/**
 Returns sqlStatement With Column names
 */
+ (NSString *)selectSqlStatementWithColumns:(NSArray <NSString *>*)columns
                                    fromTable:(NSString *)tableName
                                    orderBy:(NSString *)orderBy
                                     isDesc:(BOOL)isDesc
                                 limitRange:(NSRange)limitRange;

/**
 Returns class arguments insert Sql Statement
 */
+ (NSString *)insertSqlStatement;

/**
 Returns class arguments update Sql Statement for all class property
 */
+ (NSString *)updateSqlStatement;

/**
 Returns class arguments update Sql Statement with given columns
 */
+ (NSString *)updateSqlStatementWithColumns:(NSArray <NSString *>*)columns
                              withPredicate:(IHFPredicate *)predicate
                                  fromTable:(NSString *)tableName;


/**
 Returns delete sqlStatement With Column names
 */
+ (NSString *)deleteSqlStatementWithColumns:(NSArray <NSString *>*)columns
                                  fromTable:(NSString *)tableName;

/**
 Returns priamry key Predicate by customPrimaryKey ..
 */
- (IHFPredicate *)customPrimaryKeyPredicate;

/**
 Returns priamry key Predicate by customPrimaryKey and given values..
 */
+ (IHFPredicate *)customPrimaryKeyPredicateWithValue:(NSArray *)values;

/**
 Returns Predicate by given columns and values..
 */
+ (IHFPredicate *)predicateWithColumns:(NSArray *)columns Value:(NSArray *)values;

/**
 Returns model arguments with given colunms
 */
- (NSArray *)argumentsForStatementWithColumns:(NSArray <NSString *>*)columns ;

/**
 Returns model arguments
 */
- (NSArray *)argumentsForStatement;
@end
