//
//  NSObject+IHFDB.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSObject+IHFDB.h"
#import "IHFRelationTable.h"
static const NSString *IHFDBPrimaryKey_ObjectIDKey                = @"objectIDKey_";
static const NSString *IHFDB_DirtyKey                             = @"dirtyKey_";
static const NSString *IHFDB_ParentObjectKey                      = @"ParentObejctKey_";


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
    return [self selectWithPredicate:predicate fromTable:nil inDataBase:nil];
}

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate isRecursive:(BOOL)recursive {
    return [self selectWithPredicate:predicate fromTable:nil inDataBase:nil isRecursive:recursive];
}

+ (NSArray *)selectAllWithRecursive:(BOOL)recursive {
    return [self selectAllFromTable:nil inDataBase:nil isRecursive:recursive];
}

+ (NSArray *)selectAll {
    return [self selectWithPredicate:nil];
}

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate
                     fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    return [self selectWithPredicate:predicate fromTable:tableName inDataBase:db isRecursive:YES];
}

+ (NSArray *)selectAllFromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    return [self selectWithPredicate:nil fromTable:tableName inDataBase:db];
}

+ (NSArray *)selectWithPredicate:(IHFPredicate *)predicate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute selectFromClass:self predicate:predicate customTableName:tableName inDataBase:db isRecursive:recursive];
}

+ (NSArray *)selectAllFromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive {
    return [self selectWithPredicate:nil fromTable:tableName inDataBase:db isRecursive:recursive];
}

#pragma mark - select count

+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate {
    return [self selectCountWithPredicate:predicate fromTable:nil inDataBase:nil];
}

+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute selectCountFromClass:self predicate:predicate customTableName:tableName inDataBase:db];
}

#pragma mark - Select by custom primary key

+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values {
    return [self selectWithCustomPrimaryKeyValues:values isRecursive:YES];
}

+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values isRecursive:(BOOL)recursive {
    return [self selectWithCustomPrimaryKeyValues:values isRecursive:recursive fromTable:nil inDataBase:nil];
}

+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    return [self selectWithCustomPrimaryKeyValues:values isRecursive:YES fromTable:tableName inDataBase:db];
}

+ (NSArray *)selectWithCustomPrimaryKeyValues:(NSArray <id>*)values isRecursive:(BOOL)recursive fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db  {
    
    NSArray *primaryKeys = [[self class] customPrimaryKeyLists];
    if (![primaryKeys count]) return nil;
    NSAssert([primaryKeys count], @"You have NOT set the custom primary keys for this Class");
    id childArray = [primaryKeys firstObject];
    if ([childArray count] != [values count]) {
        NSAssert(true != true, @"columns count is is different from values count ");
        return nil;
    }

    if (childArray && [childArray count]) {
        // It will fetch only one or not cache , so order by , desc and limit is nil
        IHFSQLStatement *stament = [[IHFSQLStatement alloc] initWithSql:[self selectSqlStatementWithColumns:childArray fromTable:tableName orderBy:nil isDesc:NO limitRange:NSMakeRange(0, 0)] arguments:values];
        IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
        return [execute executeQueryWithClass:self statement:stament inDataBase:db isRecursive:recursive];
    } else {
        NSAssert(true != true, @"customPrimarykey must be NSArray AND not nil");
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
    
    IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:self
                                                           destinationObject:[[theClass alloc] init]
                                                                relationName:property.propertyName
                                                                    relation:relation];
    table.sourceObjectID = self.objectID;
    return [table selectRelationsInDataBase:nil];
}

#pragma mark - insert

- (BOOL)save {
    NSAssert(self, @"warning : Can not save the nil object into db");
    if (!self) return NO;
    return [self saveDidCompleteBlock:nil];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray {
    return [self saveModelArray:modelArray completeBlock:nil];
}

- (BOOL)saveDidCompleteBlock:(IHFDBCompleteBlock)completion {
    return [self saveWithTableName:nil completeBlock:completion];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray completeBlock:(IHFDBCompleteBlock)completion {
    return [self saveModelArray:modelArray fromTable:nil completeBlock:completion];
}

- (BOOL)saveWithTableName:(NSString *)tableName {
    return [self saveWithTableName:tableName completeBlock:nil];
}

- (BOOL)saveWithTableName:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion {
    return [self saveWithTableName:tableName inDataBase:nil completeBlock:completion];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray fromTable:(NSString *)tableName {
    return [self saveModelArray:modelArray fromTable:tableName completeBlock:nil];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray fromTable:(NSString *)tableName completeBlock:(IHFDBCompleteBlock)completion {
    return [self saveModelArray:modelArray fromTable:tableName inDataBase:nil completeBlock:completion];
}

- (BOOL)saveWithTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    NSArray *modelArray = [NSArray arrayWithObject:self];
    if ([self isKindOfClass:[NSArray class]]) modelArray = (NSArray *)self;
    if (![modelArray count]) return YES; // NOT models need save
    return [[self class] saveModelArray:modelArray fromTable:tableName inDataBase:db completeBlock:completion];
}

+ (BOOL)saveModelArray:(NSArray *)modelArray fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    [self createTable];
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute insertIntoClassWithModelArray:modelArray fromTable:tableName inDataBase:db completeBlock:completion];
}

#pragma marl - update
/**
 Update with values by custom primary keys , and the values orders is your custom primary keys orders. The cascade Default NO .
 Warning : (It noly take effect when you only set a primary key) , If you NOT set the Custom primary key for the model , the select will error .
 */
- (BOOL)updateFromTable {
    return [self updateFromTableWithIsCascade:YES];
}

- (BOOL)updateFromTableWithIsCascade:(BOOL)cascade {
    return [self updateFromTableWithIsCascade:cascade completeBlock:nil];
}

- (BOOL)updateFromTableWithIsCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateFromTable:nil inDataBase:nil isCascade:cascade completeBlock:completion];
}

- (BOOL)updateFromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *models = (NSArray *)self;
        __block BOOL result = NO;
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            result = [obj updateWithPredicate:[obj customPrimaryKeyPredicate] isCascade:cascade fromTable:tableName inDataBase:db completeBlock:completion];
            if (!result) {
                *stop = YES;
            }
        }];
        return result;
    } else {
        return [self updateWithPredicate:[self customPrimaryKeyPredicate] isCascade:cascade fromTable:tableName inDataBase:db completeBlock:completion];
    }
}

- (BOOL)updateWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
   return [self updateWithPredicate:predicate isCascade:YES fromTable:nil inDataBase:nil completeBlock:completion];
}

- (BOOL)updateWithPredicate:(IHFPredicate *)predicate {
   return [self updateWithPredicate:predicate completeBlock:nil];
}

- (BOOL)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade {
   return [self updateWithPredicate:predicate isCascade:cascade fromTable:nil inDataBase:nil completeBlock:nil];
}

- (BOOL)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
   return [self updateWithPredicate:predicate isCascade:cascade fromTable:nil inDataBase:nil completeBlock:completion];
}

- (BOOL)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    return [self updateWithPredicate:predicate isCascade:cascade fromTable:tableName inDataBase:db completeBlock:nil];
}

- (BOOL)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute updateModel:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade updateColumns:nil updateValues:nil completeBlock:completion];
}

#pragma mark - delete

- (BOOL)deleteFromTable {
    return [self deleteFromTableIsCascade:NO];
}

- (BOOL)deleteFromTableIsCascade:(BOOL)cascade {
    return [self deleteFromTableIsCascade:cascade completeBlock:nil];
}

- (BOOL)deleteFromTableIsCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteFromTable:nil inDataBase:nil IsCascade:cascade completeBlock:completion];
}

- (BOOL)deleteFromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db IsCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *modelArray = (NSArray *)self;
        __block BOOL result = NO;
        [modelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            result = [[obj class] deleteWithCustomPrimaryKeyValues:[obj customPrimarykeyValues] isCascade:cascade fromTable:tableName inDataBase:db completeBlock:completion];
            if (!result) {
                *stop = YES;
            }
        }];
        return result;
    } else {
        return [[self class] deleteWithCustomPrimaryKeyValues:[self customPrimarykeyValues] isCascade:cascade fromTable:tableName inDataBase:db completeBlock:completion];
    }
}

+ (BOOL)deleteWithPredicate:(IHFPredicate *)predicate {
    return [self deleteWithPredicate:predicate completeBlock:nil];
}

+ (BOOL)deleteAll {
    return [self deleteAllDidCompleteBlock:nil];
}

+ (BOOL)deleteWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:predicate fromTable:nil inDataBase:nil isCascade:NO completeBlock:completion];
}

+ (BOOL)deleteAllDidCompleteBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:nil completeBlock:completion];
}

+ (BOOL)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:predicate fromTable:nil inDataBase:nil isCascade:cascade completeBlock:completion];
}

+ (BOOL)deleteWithPredicate:(IHFPredicate *)predicate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db  completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:predicate fromTable:tableName inDataBase:db isCascade:NO completeBlock:completion];
}

+ (BOOL)deleteAllFromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:nil fromTable:tableName inDataBase:db completeBlock:completion];
}

+ (BOOL)deleteAllWithCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:nil completeBlock:completion];
}

+ (BOOL)deleteWithPredicate:(IHFPredicate *)predicate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute deleteFromClass:self predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}

+ (BOOL)deleteAllFromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithPredicate:nil fromTable:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}

// delete by custom keys 
+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray<id> *)values {
    return [self deleteWithCustomPrimaryKeyValues:values isCascade:NO];
}

+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray<id> *)values isCascade:(BOOL)cascade {
    return [self deleteWithCustomPrimaryKeyValues:values isCascade:cascade completeBlock:nil];
}

+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray<id> *)values isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithCustomPrimaryKeyValues:values isCascade:cascade fromTable:nil inDataBase:nil completeBlock:completion];
}

+ (BOOL)deleteWithCustomPrimaryKeyValues:(NSArray<id> *)values isCascade:(BOOL)cascade fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    // selected the models you will delete ! In order to fetch the Obejct ID for Delete Relation for one-to-many and foreign key for One-to-One !
    NSArray *modelArray = [self selectWithCustomPrimaryKeyValues:values isRecursive:NO];
    
    if ([modelArray count]) { // If not have the models you want to delete in the data base, not need to delete!
        
        NSArray *primaryKeys = [[self class] customPrimaryKeyLists];
        NSAssert([primaryKeys count], @"You have NOT set the custom primary keys for this Class");
        if (![primaryKeys count]) return NO;
        id childArray = [primaryKeys firstObject];
        if ([childArray count] != [values count]) {
            NSAssert(true != true, @"columns count is is different from values count ");
            return NO;
        }
        
        if (childArray && [childArray count]) {
            
            IHFSQLStatement *stament = [[IHFSQLStatement alloc] initWithSql:[self deleteSqlStatementWithColumns:childArray fromTable:tableName] arguments:values];
            IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
            BOOL success = [execute executeUpdateWithClass:self statements:@[stament] inDataBase:db useTransaction:YES completeBlock:^(BOOL success,IHFDatabase *db) {
                if (success) { // delete success ,delete ralation
                    [execute deleteRelationForModelArray:modelArray inDataBase:db isCascade:cascade];
                }
                if (completion) completion(success,db);
            }];
            return success;
        } else {
            NSAssert(true != true, @"customPrimarykey must be NSArray AND not nil");
            return NO;
        }
    } else {
        NSLog(@"warning : what you want to delete %@ not exist in the DB",NSStringFromClass(self));
        return YES;
    }
}

/// Update columns by primary key values
+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values customPrimaryKeyValues:(NSArray <id>*)primaryKeyValues {
    return [self updateColumns:columns setValues:values customPrimaryKeyValues:values];
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values customPrimaryKeyValues:(NSArray <id>*)primaryKeyValues completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateColumns:columns setValues:values customPrimaryKeyValues:primaryKeyValues fromTable:nil inDataBase:nil completeBlock:completion];
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values customPrimaryKeyValues:(NSArray <id>*)primaryKeyValues fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [[self class] updateColumns:columns setValues:values predicate:[self customPrimaryKeyPredicateWithValue:primaryKeyValues] fromTable:tableName inDataBase:db completeBlock:completion];
}

#pragma marl - Sql statement by user

// Select
+ (NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement {
    return [self executeQueryWithSqlStatement:sqlStatement inDataBase:nil];
}

+ (NSArray *)executeQueryWithSqlStatement:(NSString *)sqlStatement inDataBase:(IHFDatabase *)db {
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


#pragma mark - opertion by custom colunm
// select
+ (NSArray *)selectWithColumns:(NSArray<NSString *> *)columns withValues:(NSArray<id> *)values {
    return [self selectWithColumns:columns withValues:values isRecursive:YES];
}

+ (NSArray *)selectWithColumns:(NSArray<NSString *> *)columns withValues:(NSArray<id> *)values isRecursive:(BOOL)recursive {
    return [self selectWithColumns:columns withValues:values isRecursive:recursive fromTable:nil inDataBase:nil];
}

+ (NSArray *)selectWithColumns:(NSArray<NSString *> *)columns withValues:(NSArray<id> *)values isRecursive:(BOOL)recursive fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    return [self selectWithColumns:columns withValues:values isRecursive:recursive fromTable:tableName inDataBase:db orderBy:nil isDesc:NO limitRange:NSMakeRange(0, 0)];
}

+ (NSArray *)selectWithColumns:(NSArray<NSString *> *)columns withValues:(NSArray<id> *)values isRecursive:(BOOL)recursive fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db orderBy:(NSString *)orderBy isDesc:(BOOL)isDesc limitRange:(NSRange)limitRange {
    if (!columns && ![columns count] && !values && ![values count]) {
        NSAssert(true != true, @"You can NOT set nil or count = 0 for the columns or values ");
        return nil;
    } else if ([columns count] != [values count]) {
        NSAssert(true != true, @"columns count is is different from values count ");
        return nil;
    }
    IHFSQLStatement *stament = [[IHFSQLStatement alloc] initWithSql:[self selectSqlStatementWithColumns:columns fromTable:tableName orderBy:orderBy isDesc:isDesc limitRange:limitRange] arguments:values];
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute executeQueryWithClass:self statement:stament inDataBase:db isRecursive:recursive];
}

// delete
+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values {
    return [self deleteWithColumns:columns withValues:values isCascade:NO];
}

+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isCascade:(BOOL)cascade {
    return [self deleteWithColumns:columns withValues:values isCascade:NO completeBlock:nil];
}

+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteWithCustomPrimaryKeyValues:values isCascade:cascade fromTable:nil inDataBase:nil completeBlock:completion];
}

+ (BOOL)deleteWithColumns:(NSArray <NSString *>*)columns withValues:(NSArray <id>*)values isCascade:(BOOL)cascade fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    if (!columns && ![columns count] && !values && ![values count]) {
        NSAssert(true != true, @"You can NOT set nil or count = 0 for the columns or values ");
        return NO;
    } else if ([columns count] != [values count]) {
        NSAssert(true != true, @"columns count is is different from values count ");
        return NO;
    }
    IHFSQLStatement *stament = [[IHFSQLStatement alloc] initWithSql:[self deleteSqlStatementWithColumns:columns fromTable:tableName] arguments:values];
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute executeUpdateWithClass:self statements:@[stament] inDataBase:db useTransaction:YES completeBlock:completion];
}

// update
- (BOOL)updateColumns:(NSArray<NSString *> *)columns {
    return [self updateColumns:columns isCascade:YES];
}

- (BOOL)updateColumns:(NSArray<NSString *> *)columns isCascade:(BOOL)cascade {
    return [self updateColumns:columns fromTable:nil inDataBase:nil isCascade:cascade completeBlock:nil];
}

- (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values {
    return [self updateColumns:columns setValues:values completeBlock:nil];
}

- (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateColumns:columns setValues:values fromTable:nil inDataBase:nil isCascade:YES completeBlock:completion];
}

- (BOOL)updateColumns:(NSArray<NSString *> *)columns fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateColumns:columns fromTable:tableName inDataBase:db isCascade:YES completeBlock:completion];
}

- (BOOL)updateColumns:(NSArray<NSString *> *)columns fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateColumns:columns setValues:nil fromTable:tableName inDataBase:db isCascade:cascade completeBlock:completion];
}

- (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    if ([self isKindOfClass:[NSArray class]]) {
        __block BOOL result = NO;
        __block NSArray *valuesFromModels = values;
        NSArray *models = (NSArray *)self;
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!values) {
                valuesFromModels = [obj argumentsForStatementWithColumns:columns];
            }
            result = [[obj class] updateColumns:columns setValues:valuesFromModels forModel:obj predicate:[obj customPrimaryKeyPredicate] fromTable:tableName inDataBase:db isCascade:cascade completeBlock:completion];
            if (!result) {
                *stop = YES;
            }
        }];
        return result;
    } else {
        if (!values) values = [self argumentsForStatementWithColumns:columns];
        return [[self class] updateColumns:columns setValues:values forModel:self predicate:[self customPrimaryKeyPredicate] fromTable:tableName inDataBase:db isCascade:cascade completeBlock:completion];
    }
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values predicate:(IHFPredicate *)preciate {
    return [self updateColumns:columns setValues:values predicate:preciate completeBlock:nil];
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values predicate:(IHFPredicate *)preciate completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateColumns:columns setValues:values predicate:preciate fromTable:nil inDataBase:nil completeBlock:nil];
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values predicate:(IHFPredicate *)preciate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    // Warning : self is Class ..
    return [self updateColumns:columns setValues:values forModel:nil predicate:preciate fromTable:tableName inDataBase:db isCascade:NO completeBlock:completion];
}

// private
+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values forModel:(id)model predicate:(IHFPredicate *)preciate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    if ([columns count] != [values count]) {
        NSAssert(true != true, @"columns count is is different from values count ");
        return NO;
    }
    
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    if (!model) { // If is class , not cascade , do ..
        IHFSQLStatement *stament = [[IHFSQLStatement alloc] initWithSql:[[self class] updateSqlStatementWithColumns:columns withPredicate:preciate fromTable:tableName] arguments:values];
        return [execute executeUpdateWithClass:[self class] statements:@[stament] inDataBase:db useTransaction:NO completeBlock:completion];
    } else {
        return [execute updateModel:model predicate:preciate customTableName:tableName inDataBase:db isCascade:cascade updateColumns:columns updateValues:values completeBlock:completion];
    }
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values conditionColumns:(NSArray *)conditionColumns conditionValues:(NSArray *)conditionValues {
    return [self updateColumns:columns setValues:values conditionColumns:conditionColumns conditionValues:conditionValues completeBlock:nil];
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values conditionColumns:(NSArray *)conditionColumns conditionValues:(NSArray *)conditionValues completeBlock:(IHFDBCompleteBlock)completion {
    return [self updateColumns:columns setValues:values conditionColumns:conditionColumns conditionValues:conditionValues fromTable:nil inDataBase:nil completeBlock:nil];
}

+ (BOOL)updateColumns:(NSArray<NSString *> *)columns setValues:(NSArray<id> *)values conditionColumns:(NSArray *)conditionColumns conditionValues:(NSArray *)conditionValues fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [[self class] updateColumns:columns setValues:values predicate:[self predicateWithColumns:conditionColumns Value:conditionValues] fromTable:tableName inDataBase:db completeBlock:completion];
}

#pragma mark -  delete dirty data
+ (BOOL)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate {
    return [self deleteDirtyDataWithPredicate:predicate completeBlock:nil];
}

+ (BOOL)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
    return [self deleteDirtyDataWithPredicate:predicate fromTable:nil inDataBase:nil completeBlock:completion];
}

+ (BOOL)deleteDirtyDataWithPredicate:(IHFPredicate *)predicate fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    IHFDataBaseExecute *execute = [IHFDataBaseExecute shareDataBaseExecute];
    return [execute deleteDirtyDataFromClass:self predicate:predicate customTableName:tableName inDataBase:db isCascade:NO completeBlock:completion];
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

- (NSMutableArray *)customPrimarykeyValues {
    NSArray *primaryKeys = [[self class] customPrimaryKeyLists];
    if (![primaryKeys count]) return nil;
    id childArray = [primaryKeys firstObject];
    if (childArray && [childArray count]) {
        __block NSMutableArray *values = [NSMutableArray array];
        [childArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && [obj isKindOfClass:[NSString class]]) {
                id value = [self valueWithPropertName:obj];
                if (!value) value = @"";
                [values addObject:value];
            }
        }];
        return values;
    } else {
        NSAssert(true != true, @"customPrimarykey must be NSArray AND not nil");
        return nil;
    }
}
@end
