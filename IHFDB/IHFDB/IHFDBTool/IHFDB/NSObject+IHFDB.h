//
//  NSObject+IHFDB.h
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

// warning : Table Name is now not fit the model have relation .

#import <Foundation/Foundation.h>
#import "IHFPredicate.h"
#import "IHFDBObjectDataSource.h"
#import "IHFSQLStatement.h"
#import "IHFDatabase.h"
/**
 The NSObject catagory for object to do CURL in the sqlite !
 
 1. If you want to use default db , like create table
 [Object createTable];
 
 2.if you want use the db create by you
 
 create queue first
 
 NSString *dataBasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:IHFDBSqliteName];
 IHFDataBaseQueue *queue = [IHFDatabaseQueue databaseQueueWithPath:dataBasePath];
 
 Then use it like so:
 
 [queue inTransaction:^(IHFDatabase *db, BOOL *rollback) {
 // If name is nil , it will be create table for object name !
 [Object createTableWithName:nil inDataBase:db];
 }];
 
 3. Not use object name. like
 [Object createTableWithName:@"customName" inDataBase:nil];
 
 
 */

@interface NSObject (IHFDB)

typedef void(^IHFDBCompleteBlock)(BOOL result,IHFDatabase *db);

/** Create table with the Class
Table name is the class name
 DB: is create by Code!
 */

+ (BOOL)createTable;
+ (BOOL)createTableDidCompleteBlock:(IHFDBCompleteBlock)completion;

/** Create table with the Class ,Table name is the user custom name
 */

+ (BOOL)createTableWithName:(NSString *)tableName CompleteBlock:(IHFDBCompleteBlock)completion;
+ (BOOL)createTableWithName:(NSString *)tableName ;

+ (BOOL)createTableWithName:(NSString *)tableName inDataBase:(IHFDatabase *)db CompleteBlock:(IHFDBCompleteBlock)completion;
+ (BOOL)createTableWithName:(NSString *)tableName inDataBase:(IHFDatabase *)db;

// **********************************************************************
// ****************** CURL main by IHFPredicate *************************
// **********************************************************************

/////
// Select
// If you set recursive -> NO ! You can use the following method to find it relation model

/** Select with predicate
 recursive : Default -> YES . If is not , it only fetch the basic property , not the relation!
 */

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate;
+ (NSArray *)selectAll;

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate isRecursive:(BOOL)recursive;
+ (NSArray *)selectAllWithRecursive:(BOOL)recursive;

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive;
+ (NSArray *)selectAllInTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive;

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db;
+ (NSArray *)selectAllInTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db;


/**  Fetch the model's relation models Using the property name */

- (NSArray *)selectRelationModelWithPropertyName:(NSString *)propertyName;

/** Select Count for your predicate */

+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate;
+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db;


//////////////////////
/** ------ Insert */

//  If you want to insert more models , you'd better use the method than - (void)insertIntoClassWithModel:(id)newModel completeBlock:(IHFDBCompleteBlock)completion , because of it use intranstion , insert more fastly!


/** Insert the models into the table ,which the table name is defalut defalt is class name ,*/

- (BOOL)save;
+ (BOOL)saveModelArray:(NSArray *)modelArray;

- (BOOL)saveDidCompleteBlock:(IHFDBCompleteBlock)completion;
+ (BOOL)saveModelArray:(NSArray *)modelArray completeBlock:(IHFDBCompleteBlock)completion;

/** Insert the models into the table ,which the table name is by user costom name ,*/

- (BOOL)saveWithTableName:(NSString *)tableName;
+ (BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName;

- (BOOL)saveWithTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion;
+ (BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion ;

// db
- (BOOL)saveWithTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;
+ (BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion ;

/** Update */

/**
 Update with values by custom primary keys , and the values orders is your custom primary keys orders. The cascade Default NO .
 Warning : (It noly take effect when you only set a primary key) , If you NOT set the Custom primary key for the model , the select will error .
 */
- (void)updateInTable;
- (void)updateInTableWithIsCascade:(BOOL)cascade;
- (void)updateInTableWithIsCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

/**
 Update with predicate ..
 */
- (void)updateWithPredicate:(IHFPredicate *)predicate;
- (void)updateWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion;

/** Cascade : Default yes , if you set it not , it means it only update the model , not change the model relation and relation table! */

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade;
- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db;
- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;


/** Delete */

+ (void)deleteWithPredicate:(IHFPredicate *)predicate;
+ (void)deleteAll;

+ (void)deleteWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion;
+ (void)deleteAllDidCompleteBlock:(IHFDBCompleteBlock)completion;

/**
 Delete self from table , it will use this custom primary keys , if NOT set , it will delete fail..
 */
- (BOOL)deleteFromTable;
- (BOOL)deleteFromTableIsCascade:(BOOL)cascade;
- (BOOL)deleteFromTableIsCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

/** Cascade : Default yes , means not only delete the model with fit the predicate ,but also delete the all it relation model! */

+ (void)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;
+ (void)deleteAllWithCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

/** table name, db  */

+ (void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;
+ (void)deleteAllInTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** table name, db and cascade */

+ (void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;
+ (void)deleteAllInTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// **********************************************************************
// ****************** CURL main by Primary keys *************************
// **********************************************************************
/**
 Select with values by custom primary keys , and the values orders is your custom primary keys orders. recursive Default YES .
 Warning : (It noly take effect when you only set a primary key) , If you NOT set the Custom primary key for the model , the select will error .
 */

+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values;
+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values isRecursive:(BOOL)recursive;
+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db;
+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive;

/**
 Delete with values by custom primary keys , and the values orders is your custom primary keys orders. The cascade Default NO .
 Warning : (It noly take effect when you only set a primary key) , If you NOT set the Custom primary key for the model , the select will error .
 */

+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray <id>*)values;
+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray <id>*)values isCascade:(BOOL)cascade;
+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray <id>*)values isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// **********************************************************************
// ****************** CURL main by column your set **********************
// **********************************************************************
+ (NSArray *)selectWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values;
+ (NSArray *)selectWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isRecursive:(BOOL)recursive;
+ (NSArray *)selectWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isRecursive:(BOOL)recursive completeBlock:(IHFDBCompleteBlock)completion;

+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values;
+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isCascade:(BOOL)cascade;
+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

/** Update data and set value for given columns , and the preciate come for his custom primary keys ..
 
 @prama values : values get can from self ..
 Warning : (It noly take effect when you only set a primary key) , If you NOT set the Custom primary key for the model , the select will error .
 */
- (BOOL)updateColumns:(NSArray <NSString *>*)columns;
- (BOOL)updateColumns:(NSArray <NSString *>*)columns setValues:(NSArray <id>*)values;
+ (BOOL)updateColumns:(NSArray <NSString *>*)columns setValues:(NSArray <id>*)values predicate:(IHFPredicate *)preciate;

// **********************************************************************
// Delete dirty data
// **********************************************************************

/** Delete dirty data which is the network not but your sqlite have with predicate , if the colunm Dirty is 0 , it will be delete!
 Warning : If data update or insert in DB , it will change the dirty is 1! But if call the method , it will reset it 0! So you'd better call the method after network request success and DO update or insert ,it will help you to delete the dirty data。
 */

+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate;
+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion;

+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;


// Sql statement by user
// Select
// db is default
+ (NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement;
+ (NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement inDataBase:(IHFDatabase *)db;

// Update contain : update , delete , craete table and insert
+ (void)executeUpdateWithSqlStatement:(NSString *)sqlStatement;
+ (void)executeUpdateWithSqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion;

@end
