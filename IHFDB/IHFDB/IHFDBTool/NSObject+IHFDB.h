//
//  NSObject+IHFDB.h
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHFPredicate.h"
#import "IHFDBObjectDataSource.h"
#import "IHFDB.h"
@interface NSObject (IHFDB)

typedef void(^IHFDBCompleteBlock)(BOOL success);

/** Create table with the Class
Table name is the class name
 DB: is create by Code!
 */

+(BOOL)createTable;
+(BOOL)createTableDidCompleteBlock:(IHFDBCompleteBlock)completion;

/** Create table with the Class ,Table name is the user custom name
 */

+(BOOL)createTableWithName:(NSString *)tableName CompleteBlock:(IHFDBCompleteBlock)completion;
+(BOOL)createTableWithName:(NSString *)tableName ;

+(BOOL)createTableWithName:(NSString *)tableName inDataBase:(FMDatabase *)db CompleteBlock:(IHFDBCompleteBlock)completion;
+(BOOL)createTableWithName:(NSString *)tableName inDataBase:(FMDatabase *)db;


/** Select */

+(NSArray *)selectWithPredicate:(IHFPredicate *)predicate;
+(NSArray *)selectAll;

+(NSArray *)selectWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db;
+(NSArray *)selectAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db;



/** Insert */

//  If you want to insert more models , you'd better use the method than -(void)insertIntoClassWithModel:(id)newModel completeBlock:(IHFDBCompleteBlock)completion , because of it use intranstion , insert more fastly!


/** Insert the models into the table ,which the table name is defalut defalt is class name ,*/

-(BOOL)save;
+(BOOL)saveModelArray:(NSArray *)modelArray;

-(BOOL)saveDidCompleteBlock:(IHFDBCompleteBlock)completion;
+(BOOL)saveModelArray:(NSArray *)modelArray completeBlock:(IHFDBCompleteBlock)completion;

/** Insert the models into the table ,which the table name is by user costom name ,*/

-(BOOL)saveWithTableName:(NSString *)tableName;
+(BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName;

-(BOOL)saveWithTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion;
+(BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion ;

// db
-(BOOL)saveWithTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;
+(BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion ;

/** Update */

- (void)updateWithPredicate:(IHFPredicate *)predicate;
- (void)updateWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion;

/** Cascade : Default yes , if you set it not , it means it only update the model , not change the model relation and relation table! */

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade;
- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db;
- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;


/** Delete */

+(void)deleteWithPredicate:(IHFPredicate *)predicate;
+(void)deleteAll;

+(void)deleteWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion;
+(void)deleteAllDidCompleteBlock:(IHFDBCompleteBlock)completion;

/** Cascade : Default yes , means not only delete the model with fit the predicate ,but also delete the all it relation model! */

+(void)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;
+(void)deleteAllWithCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

/** table name, db  */

+(void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;
+(void)deleteAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** table name, db and cascade */

+(void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;
+(void)deleteAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;

// Sql statement by user

// Select

// db is default
+(NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement ;
+(NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement inDataBase:(FMDatabase *)db;


// Update contain : update , delete , craete table and insert
+(void)executeUpdateWithSqlStatement:(NSString *)sqlStatement;
+(void)executeUpdateWithSqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion;

@end