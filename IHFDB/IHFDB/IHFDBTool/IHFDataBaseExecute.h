//
//  IHFDataBaseExecute.h
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "IHFPredicate.h"
#import "NSObject+IHFModelOperation.h"
#import "NSObject+IHFDB.h"
#import "IHFDBObjectDataSource.h"
#import "IHFRelationTable.h"
@class IHFRelationTable;
@interface IHFDataBaseExecute : NSObject<IHFDBObejctDataSource>

@property (copy,nonatomic) NSString *sqliteName;

+ (instancetype)shareDataBaseExecute;

+(instancetype)dataBaseWithSqliteName:(NSString *)sqliteName;
-(instancetype)initWithSqliteName:(NSString *)SqliteName;

typedef void(^IHFDBCompleteBlock)(BOOL success);
typedef void(^IHFDBUpdateCompleteBlock)(BOOL success,IHFRelationTable *relationTable,FMDatabase *db , BOOL *rollback);

// Create

/** Create table , the table name is custom table name .
 tableName : if nil , the table name is class name .
 db : if nil , will create IN CODE  */

-(BOOL)createTableWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

// Select

-(NSArray<id<IHFDBObejctDataSource>> *)selectFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db;


// Insert

//If you want to insert more models , you'd better use the method than -(void)insertIntoClassWithModel:(id)newModel completeBlock:(IHFDBCompleteBlock)completion , because of it use intranstion , insert more fastly!

/** Insert the model into the table ,which the table name is defalut defalt is class name */

-(BOOL) insertIntoClassWithModel:(id)newModel inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** Insert the models into the table ,which the table name is defalut defalt is class name ,*/

-(BOOL) insertIntoClassWithModelArray:(NSArray *)ModelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

// Update
-(void) updateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// Delete
-(void) deleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// Sql statement by user
-(NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement inDataBase:(FMDatabase *)db;

-(BOOL)executeUpdateWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion;

-(BOOL)executeUpdateWithClass:(Class)newClass sqlStatements:(NSArray <NSString *>*)sqlStatements completeBlock:(IHFDBCompleteBlock)completion useTransaction:(BOOL)useTransaction;


// For insert to execute update
//-(BOOL)executeUpdateWithModels:(NSArray<IHFRelationTable *> *)newModels useTransaction:(BOOL)useTransaction inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion;

/** judge is exist the table */

-(BOOL)isTableExistWithTableName:(NSString *)tableName inDatabase:(FMDatabase *)db;
@end
