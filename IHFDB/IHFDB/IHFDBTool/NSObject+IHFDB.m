//
//  NSObject+IHFDB.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSObject+IHFDB.h"
#import "IHFDataBaseExecute.h"

#define sqliteName @"IHFDB.sqlite"

const NSString *IHFDBPrimaryKey_ObjectIDKey                = @"objectIDKey";

@implementation NSObject (IHFDB)

// create

+(BOOL)createTable{
    return [self createTableWithName:nil];
}

+(BOOL)createTableDidCompleteBlock:(IHFDBCompleteBlock)completion{
   return [self createTableWithName:nil CompleteBlock:completion];
}

+(BOOL)createTableWithName:(NSString *)tableName{
     return [self createTableWithName:tableName CompleteBlock:nil];
}

+(BOOL)createTableWithName:(NSString *)tableName CompleteBlock:(IHFDBCompleteBlock)completion{
    return [self createTableWithName:tableName inDataBase:nil CompleteBlock:completion];
}

+(BOOL)createTableWithName:(NSString *)tableName inDataBase:(id)db CompleteBlock:(IHFDBCompleteBlock)completion{
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    return [execute createTableWithClass:self customTableName:tableName inDataBase:db completeBlock:completion];
}

+(BOOL)createTableWithName:(NSString *)tableName inDataBase:(id)db {
    return [self createTableWithName:tableName inDataBase:db CompleteBlock:nil];
}



// select

+(NSArray *)selectWithPredicate:(IHFPredicate *)predicate{
    
    return [self selectWithPredicate:predicate inTableName:nil inDataBase:nil];
}

+(NSArray *)selectAll{
    return [self selectWithPredicate:nil];
}

+(NSArray *)selectWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    return [execute selectFromClass:self predicate:predicate customTableName:tableName inDataBase:db];

}
+(NSArray *)selectAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    return [self selectWithPredicate:nil inTableName:tableName inDataBase:db];
}


// insert
-(BOOL)save{
    return [self saveDidCompleteBlock:nil];
}

+(BOOL)saveModelArray:(NSArray *)modelArray{
    return [self saveModelArray:modelArray completeBlock:nil];
}

-(BOOL)saveDidCompleteBlock:(IHFDBCompleteBlock)completion{
    return [self saveWithTableName:nil completeBlock:completion];
}

+(BOOL)saveModelArray:(NSArray *)modelArray completeBlock:(IHFDBCompleteBlock)completion{
    return [self saveModelArray:modelArray inTableName:nil completeBlock:completion];
}

-(BOOL)saveWithTableName:(NSString *)tableName{
    return [self saveWithTableName:tableName completeBlock:nil];
}

-(BOOL)saveWithTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion{
    return [self saveWithTableName:tableName inDataBase:nil completeBlock:completion];
}

+(BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName{
    return [self saveModelArray:modelArray inTableName:tableName completeBlock:nil];
}

+(BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion{
    return [self saveModelArray:modelArray inTableName:tableName inDataBase:nil completeBlock:completion];
}

-(BOOL)saveWithTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    return [[self class] saveModelArray:[NSArray arrayWithObject:self] inTableName:tableName inDataBase:db completeBlock:completion];
}

+(BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    return [execute insertIntoClassWithModelArray:modelArray inTableName:tableName inDataBase:db completeBlock:completion];
}

// update
- (void)updateWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion{
    
    [self updateWithPredicate:predicate isCascade:YES inTableName:nil inDataBase:nil completeBlock:completion];
}

-(void)updateWithPredicate:(IHFPredicate *)predicate{
    [self updateWithPredicate:predicate completeBlock:nil];
}

-(void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade{
    [self updateWithPredicate:predicate isCascade:cascade inTableName:nil inDataBase:nil completeBlock:nil];
}

-(void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
       [self updateWithPredicate:predicate isCascade:cascade inTableName:nil inDataBase:nil completeBlock:completion];
}

-(void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    [self updateWithPredicate:predicate isCascade:cascade inTableName:tableName inDataBase:db completeBlock:nil];
}

-(void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    [execute updateModel:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion ];
}

// delete

+(void)deleteWithPredicate:(IHFPredicate *)predicate{
    [self deleteWithPredicate:predicate completeBlock:nil];
}

+(void)deleteAll{
    [self deleteAllDidCompleteBlock:nil];
}

+(void)deleteWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion{
    
    [self deleteWithPredicate:predicate inTableName:nil inDataBase:nil isCascade:YES completeBlock:completion];
}

+(void)deleteAllDidCompleteBlock:(IHFDBCompleteBlock)completion{
    [self deleteWithPredicate:nil completeBlock:completion];
}

+(void)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    
    [self deleteWithPredicate:predicate inTableName:nil inDataBase:nil isCascade:cascade completeBlock:completion];
}

+(void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db  completeBlock:(IHFDBCompleteBlock)completion{
    [self deleteWithPredicate:predicate inTableName:tableName inDataBase:db isCascade:YES completeBlock:completion];
}

+(void)deleteAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    [self deleteWithPredicate:nil inTableName:tableName inDataBase:db completeBlock:completion];
}

+(void)deleteAllWithCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    [self deleteWithPredicate:nil completeBlock:completion];
}

+(void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    [execute deleteFromClass:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}

+(void)deleteAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    [self deleteWithPredicate:nil inTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}


// Sql statement by user

// Select
+(NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement{
    return [self executeQueryWithSqlStatement:sqlStatement inDataBase:nil];
}

+(NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement inDataBase:(FMDatabase *)db{
    
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    return [execute executeQueryWithClass:self sqlStatement:sqlStatement inDataBase:db];
}



// Update contain : update , delete and insert
+(void)executeUpdateWithSqlStatement:(NSString *)sqlStatement{
    [self executeUpdateWithSqlStatement:sqlStatement completeBlock:nil];
}

+(void)executeUpdateWithSqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion{
    
    IHFDataBaseExecute *execute = [[IHFDataBaseExecute alloc] initWithSqliteName:sqliteName];
    [execute executeUpdateWithClass:self sqlStatement:sqlStatement completeBlock:completion];
}

#pragma mark - protocol method

-(void)setObjectID:(NSInteger)objectID{
    
    objc_setAssociatedObject(self, &IHFDBPrimaryKey_ObjectIDKey, @(objectID), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSInteger)objectID{
    id objectID = objc_getAssociatedObject(self, &IHFDBPrimaryKey_ObjectIDKey);
    
    if ([objectID isKindOfClass:[NSNumber class]]) {
        return [objectID integerValue];
    }
    return 0;
}


@end
