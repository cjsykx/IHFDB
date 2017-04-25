//
//  IHFDBObjectDataSource.h
//  IHFDB
//
//  Created by CjSon on 16/6/23.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef IHFDBObjectDataSource_h
#define IHFDBObjectDataSource_h

NS_ASSUME_NONNULL_BEGIN

/**
 IHFSqliteName use for create dataBaseQueue
 */
static NSString *_Nullable IHFDBSqliteName = @"IHFDB.sqlite";
static NSString *_Nullable IHFDBPrimaryKey = @"IHFDB_ObjectID";
static NSString *_Nullable IHFDBDirtyKey   = @"IHFDB_Dirty";

@protocol IHFDBObejctDataSource <NSObject>
@optional
//----------------------------------------------------------------------------------
//************************  Sqlite and (model and dictionary) All set
//----------------------------------------------------------------------------------
/**
 Set the relationships which the class or object in array .
 the relationships is one-To-Many
 */
+ (NSDictionary *)propertyNameDictForClassInArray;

///////////

/**
 Set the property names which tou want to ignore , so that it can't to be a column in table
 */
+ (NSArray <NSString *>*)propertyNamesForIgnore;

/**
 Set the property names which tou want to map
 */
+ (NSDictionary *)propertyNameDictForMapper;

/**
 Do your like to do when model convert to JSON Object and check if need the JSON obejct ..
 
 @param JSONObject : The JSON object , always come from network ..
 
 @return : If NO , the you will NOT get the JSON Object which will convert from model ..
 */
- (BOOL)doModelCustomConvertToJSONObject:(NSMutableDictionary *)JSONObject;


/**
 Do your like to do when model convert from JSON Object and check if need the model
 
 @param JSONObject : The JSON object , always come from network ..
 
 @return : If NO , the you will NOT get the model which will convert from JSON object ..
 */
- (BOOL)doModelCustomConvertFromJSONObject:(NSDictionary *)JSONObject;


//----------------------------------------------------------------------------------
//************************  Sqlite set
//----------------------------------------------------------------------------------
// ObjectID is primary key in sqlite !

/** Set objectID */
- (void)setObjectID:(NSInteger)objectID;

/** get objectID ,witch is primary key in sqlite */
- (NSInteger)objectID;

// dirty data!

/**
 Set dirty
 */
- (void)setDirty:(NSInteger)dirty;

/** get dirty */
- (NSInteger)dirty;

// ParentObject

/**
 Set parent object ..
 */
- (void)setParentObject:(NSObject * _Nullable)parentObejct;

/**
 Get parent obejct if the model have
 */
- (instancetype _Nullable)parentObject;

/**
 * Set custom primary keys , to void dirty data insert ..
 
 @ It will be use for judge if the data base exist the same data , so that not to insert ,instead of update!
 @ returns Array : for the local data sometimes can not use the only one property to judge the data is only one ..
 */
+ (NSArray <NSString *>*)propertyNamesForCustomPrimarykeys;

/**
 Returns custom primary key value dictionary , the dictionary key is one of the custom primarykey ..
 */
- (NSMutableArray <id> *)customPrimarykeyValues;
@end

NS_ASSUME_NONNULL_END

#endif /* IHFDBObjectDataSource_h */
