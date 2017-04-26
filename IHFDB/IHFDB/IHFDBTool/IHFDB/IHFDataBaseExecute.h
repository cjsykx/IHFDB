//
//  IHFDataBaseExecute.h
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHFDB.h"
#import "IHFSQLStatement.h"
#import "IHFDatabase.h"


@class IHFRelationTable;
@interface IHFDataBaseExecute : NSObject<IHFDBObejctDataSource>

@property (copy,nonatomic) NSString *sqliteName;

+  (instancetype)shareDataBaseExecute;

+ (instancetype)dataBaseWithSqliteName:(NSString *)sqliteName;
- (instancetype)initWithSqliteName:(NSString *)SqliteName;

typedef void(^IHFDBCompleteBlock)(BOOL success, IHFDatabase *db);
typedef void(^IHFDBUpdateCompleteBlock)(BOOL success,NSArray < IHFRelationTable *> *relationTables,IHFDatabase *db , BOOL *rollback);

// Create

/** Create table , the table name is custom table name .
 tableName : if nil , the table name is class name .
 db : if nil , will create IN CODE  */

- (BOOL)createTableWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

// Select

- (NSArray<id<IHFDBObejctDataSource>> *)selectFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive;

// Select count
- (NSInteger)selectCountFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db;

// Insert

//If you want to insert more models , you'd better use the method than -  (void)insertIntoClassWithModel:(id)newModel completeBlock:(IHFDBCompleteBlock)completion , because of it use intranstion , insert more fastly!

/** Insert the model into the table ,which the table name is defalut defalt is class name */

- (BOOL)insertIntoClassWithModel:(id)newModel fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** Insert the models into the table ,which the table name is defalut defalt is class name ,*/

- (BOOL)insertIntoClassWithModelArray:(NSArray *)ModelArray fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

// Update
- (BOOL)updateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade updateColumns:(NSArray *)columns updateValues:(NSArray *)values completeBlock:(IHFDBCompleteBlock)completion;

// Delete
- (BOOL)deleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// Delete dirty data
- (BOOL)deleteDirtyDataFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// SQLStatement by user
- (NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass statement:(IHFSQLStatement *)statement inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive;

- (BOOL)executeUpdateWithClass:(Class)newClass statements:(NSArray <IHFSQLStatement *>*)statements inDataBase:(IHFDatabase *)db useTransaction:(BOOL)useTransaction completeBlock:(IHFDBCompleteBlock)completion;

// Sql statement by user
- (NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive;

- (BOOL)executeUpdateWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion;

- (BOOL)executeUpdateWithClass:(Class)newClass sqlStatements:(NSArray <NSString *>*)sqlStatements completeBlock:(IHFDBCompleteBlock)completion useTransaction:(BOOL)useTransaction;

/** delete relation */
- (void)deleteRelationForModelArray:(NSArray<id <IHFDBObejctDataSource>> *)modelArray inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade;

/** judge is exist the table */

- (BOOL)isTableExistWithTableName:(NSString *)tableName inDatabase:(IHFDatabase *)db;

@end
