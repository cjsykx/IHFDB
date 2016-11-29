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

@protocol IHFDBObejctDataSource <NSObject>

@optional
//----------------------------------------------------------------------------------
//************************  Sqlite and (model with dict) All set
//----------------------------------------------------------------------------------
/**
 Set the relationships which the class or object in array .
 the relationships is one-To-Many
 */
+ (NSDictionary * _Nullable)relationshipDictForClassInArray;

///////////

/**
 Set the property names which tou want to ignore , so that it can't to be a column in table
 */
+ (NSArray * _Nullable)propertyNamesForIgnore;

/**
 Set the property names which tou want to map
 */
+ (NSDictionary * _Nullable)propertyNameDictForMapper;


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
+ (NSArray <NSString *>* _Nullable)customPrimarykeys;

/**
 Returns custom primary key value dictionary , the dictionary key is one of the custom primarykey ..
 */
- (NSMutableDictionary * _Nullable)customPrimarykeyValues;
@end

#endif /* IHFDBObjectDataSource_h */
