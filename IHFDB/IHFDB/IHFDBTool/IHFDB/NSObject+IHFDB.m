//
//  NSObject+IHFDB.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSObject+IHFDB.h"

static const NSString *IHFDBPrimaryKey_ObjectIDKey                = @"objectIDKey_";
static const NSString *IHFDB_DirtyKey                             = @"dirtyKey_";
static const NSString *IHFDB_ParentObjectKey                            = @"ParentObejctKey_";


@implementation NSObject (IHFDB)

#pragma marl - create table

+ (BOOL)createTable {
    return [self createTableWithName:nil];
}

+ (BOOL)createTableDidCompleteBlock:(IHFDBCompleteBlock)completion {
   return [self createTableWithName:nil CompleteBlock:completion];
}

+ (BOOL)createTableWithName:(NSString *)tableName {
     return [self createTableWithName:tableName CompleteBlock:nil];
}

+ (BOOL)createTableWithName:(NSString *)tableName CompleteBlock:(IHFDBCompleteBlock)completion {
    return [self createTableWithName:tableName inDataBase:nil CompleteBlock:completion];
}

+ (BOOL)createTableWithName:(NSString *)tableName inDataBase:(id)db CompleteBlock:(IHFDBCompleteBlock)completion {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute createTableWithClass:self customTableName:tableName inDataBase:db completeBlock:completion];
}

+ (BOOL)createTableWithName:(NSString *)tableName inDataBase:(id)db  {
    return [self createTableWithName:tableName inDataBase:db CompleteBlock:nil];
}

#pragma marl - select by predicate

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate {
    return [self selectWithPredicate:predicate inTableName:nil inDataBase:nil];
}

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate isRecursive:(BOOL)recursive {
    return [self selectWithPredicate:predicate inTableName:nil inDataBase:nil isRecursive:recursive];
}

+ (NSArray *)selectAllWithRecursive:(BOOL)recursive {
    return [self selectAllInTableName:nil inDataBase:nil isRecursive:recursive];
}

+ (NSArray *)selectAll {
    return [self selectWithPredicate:nil];
}

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    return [self selectWithPredicate:predicate inTableName:tableName inDataBase:db isRecursive:YES];
}

+ (NSArray *)selectAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    return [self selectWithPredicate:nil inTableName:tableName inDataBase:db];
}

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isRecursive:(BOOL)recursive {
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute selectFromClass:self predicate:predicate customTableName:tableName inDataBase:db isRecursive:recursive];
}

+ (NSArray *)selectAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isRecursive:(BOOL)recursive {
    return [self selectWithPredicate:nil inTableName:tableName inDataBase:db isRecursive:recursive];
}

#pragma mark - select count

+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate {
    
    return [self selectCountWithPredicate:predicate inTableName:nil inDataBase:nil];
}

+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute selectCountFromClass:self predicate:predicate customTableName:tableName inDataBase:db];
}


#pragma mark - Select by custom primary key

+ (NSArray *)selectWithCustomPrimaryKeyValue:(id)value  {
    return [self selectWithCustomPrimaryKeyValue:value isRecursive:YES];
}

+ (NSArray *)selectWithCustomPrimaryKeyValue:(id)value isRecursive:(BOOL)recursive {
    return [self selectWithCustomPrimaryKeyValue:value inTableName:nil inDataBase:nil isRecursive:recursive];
}

+ (NSArray *)selectWithCustomPrimaryKeyValue:(id)value inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    return [self selectWithCustomPrimaryKeyValue:value inTableName:tableName inDataBase:db isRecursive:YES];
}

+ (NSArray *)selectWithCustomPrimaryKeyValue:(id)value inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isRecursive:(BOOL)recursive {
    
    NSArray *primaryKeys = [[self class] customPrimaryKeyLists];
    if (![primaryKeys count]) return nil;
    id childArray = [primaryKeys firstObject];
    if (childArray && [childArray count]) {
        
        NSAssert([childArray count] == 1, @"You set not only one primary key value , can not use the method , please use IHFPredicate instead");

        id primaryKey = [childArray firstObject];
        if (primaryKey && [primaryKey isKindOfClass:[NSString class]] ) {
            NSString *predicateStr = [NSString stringWithFormat:@"%@ = '%@'",primaryKey,value];
            IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];
            return [self selectWithPredicate:predicate inTableName:tableName inDataBase:db isRecursive:recursive];
        } else {
            NSAssert(true == true, @"customPrimarykey must be NSString AND not nil");
            return nil;
        }
    } else {
        NSAssert(true == true, @"customPrimarykey must be NSArray AND not nil");
        return nil;
    }
}

- (NSArray *)selectRelationModelWithPropertyName:(NSString *)propertyName {

    if(self.objectID == 0) return nil;  // If the the model not ObjectID , it may not come from data base
    
    IHFProperty *property = [self propertyWithName:propertyName];
    
    Class theClass = property.objectClass;
    IHFRelation relation = IHFRelationOneToMany;
    if (property.type == IHFPropertyTypeModel)  { // One-to-One
        relation = IHFRelationOneToOne;
    }

    IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:self destinationObject:[[theClass alloc] init] relationName:property.propertyName relation:relation];
    table.sourceObjectID = self.objectID;
    return [table selectRelationsInDataBase:nil];
}

#pragma marl - insert 

- (BOOL)save {
    return [self saveDidCompleteBlock:nil];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray {
    return [self saveModelArray:modelArray completeBlock:nil];
}

- (BOOL)saveDidCompleteBlock:(IHFDBCompleteBlock)completion {
    return [self saveWithTableName:nil completeBlock:completion];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray completeBlock:(IHFDBCompleteBlock)completion {
    return [self saveModelArray:modelArray inTableName:nil completeBlock:completion];
}

- (BOOL)saveWithTableName:(NSString *)tableName {
    return [self saveWithTableName:tableName completeBlock:nil];
}

- (BOOL)saveWithTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion {
    return [self saveWithTableName:tableName inDataBase:nil completeBlock:completion];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName {
    return [self saveModelArray:modelArray inTableName:tableName completeBlock:nil];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion {
    return [self saveModelArray:modelArray inTableName:tableName inDataBase:nil completeBlock:completion];
}

- (BOOL)saveWithTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [[self class] saveModelArray:[NSArray arrayWithObject:self] inTableName:tableName inDataBase:db completeBlock:completion];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    [self createTable];
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute insertIntoClassWithModelArray:modelArray inTableName:tableName inDataBase:db completeBlock:completion];
}

#pragma marl - update

- (void)updateWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
    
    [self updateWithPredicate:predicate isCascade:YES inTableName:nil inDataBase:nil completeBlock:completion];
}

- (void)updateWithPredicate:(IHFPredicate *)predicate {
    [self updateWithPredicate:predicate completeBlock:nil];
}

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade {
    [self updateWithPredicate:predicate isCascade:cascade inTableName:nil inDataBase:nil completeBlock:nil];
}

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
       [self updateWithPredicate:predicate isCascade:cascade inTableName:nil inDataBase:nil completeBlock:completion];
}

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    [self updateWithPredicate:predicate isCascade:cascade inTableName:tableName inDataBase:db completeBlock:nil];
}

- (void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    [execute updateModel:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion ];
}

#pragma marl - delete

+ (void)deleteWithPredicate:(IHFPredicate *)predicate {
    [self deleteWithPredicate:predicate completeBlock:nil];
}

+ (void)deleteAll {
    [self deleteAllDidCompleteBlock:nil];
}

+ (void)deleteWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
    
    [self deleteWithPredicate:predicate inTableName:nil inDataBase:nil isCascade:YES completeBlock:completion];
}

+ (void)deleteAllDidCompleteBlock:(IHFDBCompleteBlock)completion {
    [self deleteWithPredicate:nil completeBlock:completion];
}

+ (void)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    [self deleteWithPredicate:predicate inTableName:nil inDataBase:nil isCascade:cascade completeBlock:completion];
}

+ (void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db  completeBlock:(IHFDBCompleteBlock)completion {
    [self deleteWithPredicate:predicate inTableName:tableName inDataBase:db isCascade:YES completeBlock:completion];
}

+ (void)deleteAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    [self deleteWithPredicate:nil inTableName:tableName inDataBase:db completeBlock:completion];
}

+ (void)deleteAllWithCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    [self deleteWithPredicate:nil completeBlock:completion];
}

+ (void)deleteWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    [execute deleteFromClass:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}

+ (void)deleteAllInTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    [self deleteWithPredicate:nil inTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}

#pragma marl - Sql statement by user

// Select
+ (NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement {
    return [self executeQueryWithSqlStatement:sqlStatement inDataBase:nil];
}

+ (NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement inDataBase:(FMDatabase *)db {
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute executeQueryWithClass:self sqlStatement:sqlStatement inDataBase:db isRecursive:YES];
}

// Update contain : update , delete and insert
+ (void)executeUpdateWithSqlStatement:(NSString *)sqlStatement {
    [self executeUpdateWithSqlStatement:sqlStatement completeBlock:nil];
}

+ (void)executeUpdateWithSqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion {
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    [execute executeUpdateWithClass:self sqlStatement:sqlStatement completeBlock:completion];
}

#pragma mark -  delete dirty data
+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate {
    [self deleteDirtyDataWithPredicate:predicate completeBlock:nil];
}

+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
    [self deleteDirtyDataWithPredicate:predicate isCascade:YES completeBlock:completion];
}

+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    [self deleteDirtyDataWithPredicate:predicate inTableName:nil inDataBase:nil isCascade:YES completeBlock:completion];
}

+ (void)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    [execute deleteDirtyDataFromClass:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];

}

#pragma mark -  protocol method

- (void)setObjectID:(NSInteger)objectID {
    objc_setAssociatedObject(self, &IHFDBPrimaryKey_ObjectIDKey, @(objectID), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)objectID {
    id objectID = objc_getAssociatedObject(self, &IHFDBPrimaryKey_ObjectIDKey);
    if ([objectID isKindOfClass:[NSNumber class]]) {
        return [objectID integerValue];
    }
    return 0;
}

- (void)setDirty:(NSInteger)dirty {
    objc_setAssociatedObject(self, &IHFDB_DirtyKey, @(dirty), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)dirty {
    id dirty = objc_getAssociatedObject(self, &IHFDB_DirtyKey);
    
    if ([dirty isKindOfClass:[NSNumber class]]) {
        return [dirty integerValue];
    }
    return 0;
}

- (void)setParentObject:(NSObject *)parentObejct {
    objc_setAssociatedObject(self, &IHFDB_ParentObjectKey, parentObejct, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (instancetype)parentObject {
    return objc_getAssociatedObject(self, &IHFDB_ParentObjectKey);
}

- (NSMutableDictionary *)customPrimarykeyValues {
    NSArray *primaryKeys = [[self class] customPrimaryKeyLists];
    if (![primaryKeys count]) return nil;
    id childArray = [primaryKeys firstObject];
    if (childArray && [childArray count]) {
        __block NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
        [childArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                id value = [self valueWithPropertName:obj];
                if (!value) value = @"";
                [keyValues setObject:[self valueWithPropertName:obj] forKey:obj];
            }
        }];
        return keyValues;
    } else {
        NSAssert(true == true, @"customPrimarykey must be NSArray AND not nil");
        return nil;
    }
}
@end
