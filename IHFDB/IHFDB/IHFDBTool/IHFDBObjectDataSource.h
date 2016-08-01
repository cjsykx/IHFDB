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

// ObjectID is primary key in sqlite !

/** set objectID */
- (void)setObjectID:(NSInteger)objectID;

/** get objectID ,witch is primary key in sqlite */
- (NSInteger)objectID;

// dirty !

/** set dirty */
- (void)setDirty:(NSInteger)dirty;

/** get dirty */
- (NSInteger)dirty;

/** Return the relationships which the class in array
 the relationships is one-To-Many */

+ (NSDictionary * _Nullable)relationshipDictForClassInArray;

///////////

/** Return the property names which tou want to ignore , so that it can't to be a column in table */
+ (NSArray * _Nullable)propertyNamesForIgnore;

/** Return the property names which tou want to change column name */
+ (NSDictionary * _Nullable)propertyNamesForWhiteList;

//TODO : May the custom primary key is array!

/**
 * Return custom primary key set by user 
   It will be use for judge if the data base exist the same data , so that not to insert ,instead of update!
 */
+ (NSString * _Nullable)customPrimarykey;


/**
 *  Return custom primary key value
 *  Can process the value to fit the data base value !
 */
- (id _Nullable)customPrimarykeyValue;

@end

#endif /* IHFDBObjectDataSource_h */
