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
 * Set custom primary key , to void dirty data insert ..
 
 @ It will be use for judge if the data base exist the same data , so that not to insert ,instead of update!
 @ Warning : It will be a BUG if you custom primary key type is INT , if is INT , you'd better use NSNumer!
 */
+ (NSString * _Nullable)customPrimarykey;


/**
 Return custom primary key value
 */
- (id _Nullable)customPrimarykeyValue;
@end

#endif /* IHFDBObjectDataSource_h */
