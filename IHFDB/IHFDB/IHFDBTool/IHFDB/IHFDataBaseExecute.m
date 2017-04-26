//
//  IHFDataBaseExecute.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFDataBaseExecute.h"
#import <UIKit/UIKit.h>
#import "IHFSQLStatement.h"
#import "IHFRelationTable.h"
#import "IHFDatabaseQueue.h"
// sql statement

// create
static NSString *_createTable = @"create table if not exists";

// select
static NSString *_select = @"SELECT";

// insert
static NSString *_insert = @"INSERT INTO";

// update
static NSString *_update = @"UPDATE";

// delete 
static NSString *_delete = @"DELETE FROM";

static IHFDatabaseQueue *_queue; /**< main queue */

static NSMutableDictionary *_propertyNameDict;

@interface IHFDataBaseExecute ()
@end

@implementation IHFDataBaseExecute

// use single instance 
+ (instancetype)shareDataBaseExecute {
    static id shareDataBaseExecute;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDataBaseExecute = [[IHFDataBaseExecute alloc] initWithSqliteName:IHFDBSqliteName];
        _propertyNameDict = [NSMutableDictionary dictionary];
    });
    return shareDataBaseExecute;
}

#pragma mark - init the sqlite name
- (instancetype)initWithSqliteName:(NSString *)SqliteName {
    self = [super init];
    if (self) {
        self.sqliteName = SqliteName;
    }
    return self;
}

+ (instancetype)dataBaseWithSqliteName:(NSString *)SqliteName {
    return [[self alloc] initWithSqliteName:SqliteName];
}

- (void)setSqliteName:(NSString *)sqliteName {
    _sqliteName = sqliteName;
    
    // create IHFDatabaseQueue
    NSString *dataBasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:_sqliteName];
    NSLog(@"dataBasePath = %@",dataBasePath);
    _queue = [IHFDatabaseQueue databaseQueueWithPath:dataBasePath];
}

//  data base operation
#pragma mark - create table
// create
- (BOOL)createTableWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    
    NSString *createTableSql = [self createSqlStatementWithClass:newClass customTableName:tableName inDataBase:db];
    
    // Judge the data base is exist the table
    if (!createTableSql) {
        if (completion) completion(YES,db);
        return YES;
    }
    
    if (db) {
        BOOL success = [db executeUpdate:createTableSql];
        if (completion) completion(success,db);
        return success;
    }
    // If not db , create db in _queue
    return [self executeUpdateWithClass:newClass sqlStatement:createTableSql completeBlock:completion];
}

- (NSString *)createSqlStatementWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db {

    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    // Judge the data base is exist the table
    if ([self isTableExistWithTableName:newTableName inDatabase:db]) return nil;
    
    NSMutableString *createTableSql = [NSMutableString stringWithFormat:@"%@ %@ ",_createTable,newTableName];
    
    // append primary Key
    NSString *primaryKeySql = [NSString stringWithFormat:@"(%@ integer primary key autoincrement,",IHFDBPrimaryKey];
    [createTableSql appendString:primaryKeySql];
    
    NSString *dirtySql = [NSString stringWithFormat:@"%@ integer,",IHFDBDirtyKey];
    [createTableSql appendString:dirtySql];
    
    [newClass enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) { // deal with array
            
            // Fetch the model contained in the array , to create table
            
            if (property.objectClass) {
                // create relation table
                IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:[[newClass alloc] init] destinationObject:[[property.objectClass alloc] init] relationName:property.propertyName relation:IHFRelationOneToMany];
                
                [relationTable createInDataBase:db];
                
                if ([NSStringFromClass(property.objectClass) isEqualToString:newTableName]) return;
                [self createTableWithClass:property.objectClass
                           customTableName:nil inDataBase:db completeBlock:nil];
            } else { // Not contain object , to save directly ..
                NSString *colum = [NSString stringWithFormat:@"%@ %@,",property.propertyName,[self sqlTypeNameWithTypeName:property.typeString]];
                [createTableSql appendString:colum];
            }
        } else if (property.type == IHFPropertyTypeModel) { // deal with model
            
            // For create One-To-One relation , add a colunm for proprety name!
            NSString *colum = [NSString stringWithFormat:@"%@ interger,",property.propertyName];
            [createTableSql appendString:colum];

            if ([property.typeString isEqualToString:newTableName]) return ; // Void the one-to-one relation class is self
    
             [self createTableWithClass:property.objectClass customTableName:nil inDataBase:db completeBlock:nil];
        } else {
            NSString *colum = [NSString stringWithFormat:@"%@ %@,",property.propertyName,[self sqlTypeNameWithTypeName:property.typeString]];
            [createTableSql appendString:colum];
        }
    }];
    
    // delete last ','
    [createTableSql deleteCharactersInRange:NSMakeRange(createTableSql.length -  1, 1)];
    [createTableSql appendString:@");"];
    return createTableSql;
}

- (void)createTableWithClass:(Class)newClass completeBlock:(IHFDBCompleteBlock)completion {
    [self createTableWithClass:newClass customTableName:nil inDataBase:nil completeBlock:completion];
}

#pragma mark - select

- (NSArray<id<IHFDBObejctDataSource>> *)selectFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive {
    
    NSString *selectSql = [self selectSqlStatementWithClass:newClass predicate:predicate customTableName:tableName];
    return [self executeQueryWithClass:newClass sqlStatement:selectSql inDataBase:db isRecursive:recursive];
}

/** Return sql statement with system colunm , like object and dirty */

- (NSString *)selectSystemColumnsqlStatementWithClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName {
    
    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    NSMutableString *selectSql = [NSMutableString stringWithFormat:@"%@ %@,%@ from %@ ",_select,IHFDBPrimaryKey,IHFDBDirtyKey, newTableName];
    
    if (predicate) {
        if (predicate.predicateFormat) {
            [selectSql appendFormat:@"WHERE %@ ",predicate.predicateFormat];
        }
        
        if (predicate.orderBy) {
            NSString *desc = @"ASC";
            if (predicate.isDesc) desc = @"DESC";
            [selectSql appendFormat:@"ORDER BY %@ %@ ",predicate.orderBy,desc];
        }
        
        if (!NSEqualRanges(predicate.limitRange, NSMakeRange(0, 0))) {
            NSRange limitRange = predicate.limitRange;
            [selectSql appendFormat:@"LIMIT %ld OFFSET %ld ",(long)limitRange.length,(long)limitRange.location];
        }
    }
    return selectSql;

}

/** Return sql statement with all colonm */
- (NSString *)selectSqlStatementWithClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName {
    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    NSMutableString *selectSql = [NSMutableString stringWithFormat:@"%@ * FROM %@ ",_select,newTableName];
    if (predicate) {
        if (predicate.predicateFormat) {
            [selectSql appendFormat:@"WHERE %@ ",predicate.predicateFormat];
        }
        
        if (predicate.orderBy) {
            NSString *desc = @"ASC";
            if (predicate.isDesc) desc = @"DESC";
            [selectSql appendFormat:@"ORDER BY %@ %@ ",predicate.orderBy,desc];
        }
    
        if (!NSEqualRanges(predicate.limitRange, NSMakeRange(0, 0))) {
            NSRange limitRange = predicate.limitRange;
            [selectSql appendFormat:@"LIMIT %ld OFFSET %ld ",(long)limitRange.length,(long)limitRange.location];
        }
    }
    return selectSql;
}

- (void)enumerateRelationTables:(NSArray <IHFRelationTable *> *)relationTables inDataBase:(IHFDatabase *)db rollBack:(BOOL *)rollBack {
    
    // The blcok call back when a model insert success , and the block in order to create the relation table !
    // So when call back the block , table's destinationObject become source obejct !
    __block NSMutableString *inSqlStatement = [NSMutableString string];
    __weak typeof(self) weakSelf = self;

    if (![relationTables count]) return;
    
    Class srcClass = [[relationTables firstObject].destinationObject class];
    
    // Insert to-many relation need delete relation table value
    // It need delete relation first (void dirty) and then insert
    NSArray <IHFProperty *>* arrayProperties = [srcClass propertiesForTypeOfArray];
    [arrayProperties enumerateObjectsUsingBlock:^(IHFProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *muModels = [NSMutableArray array]; // For save
        [relationTables enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull table, NSUInteger idx, BOOL * _Nonnull stop)  {
            [inSqlStatement appendFormat:@"%ld,",(long)table.destinationObjectID];
            // After delete , begin save
            id sourceObject = table.destinationObject;
            id modelArray = [sourceObject valueWithProperty:property]; // Get value for bulid relation
            
            [modelArray enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // Table for update
                IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:sourceObject destinationObject:obj relationName:property.propertyName relation:IHFRelationOneToMany];
                relationTable.sourceObjectID = table.destinationObjectID;
                
                [muModels addObject:relationTable];
            }];
        }];
        
        // Begin delete
        if ([inSqlStatement length]) {
            [inSqlStatement deleteCharactersInRange:NSMakeRange(inSqlStatement.length -  1, 1)]; // delete ","
            NSString *tableName = [NSString stringWithFormat:@"%@_%@_Relation",NSStringFromClass(srcClass),property.propertyName];
            [weakSelf deleteRelationUseIn_SqlStatement:inSqlStatement forTableName:tableName inDataBase:db];
        }

        // After delete , begin save
        if ([muModels count]) { // For use 'in' statement
            [self executeUpdateWithModels:muModels useTransaction:YES fromTable:nil inDataBase:db rollback:rollBack updateCompletion:^(BOOL success,  NSArray  <IHFRelationTable *> *relationTables, IHFDatabase *db, BOOL *rollback)  {
                // To create relation table
                [weakSelf enumerateRelationTables:relationTables inDataBase:db rollBack:rollBack];
            }];
        }
    }];
    
    // For type of model , one-one
    [[srcClass propertiesForTypeOfModel] enumerateObjectsUsingBlock:^(IHFProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop)  {
        
        NSMutableArray *muModels = [NSMutableArray array];
        
        [relationTables enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull relation, NSUInteger idx, BOOL * _Nonnull stop) {
            
            id sourceObject = relation.destinationObject;
            id model = [sourceObject valueWithProperty:property];
            if (!model) return ;
            
            IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:sourceObject destinationObject:model relationName:property.propertyName relation:IHFRelationOneToOne];
            relationTable.sourceObjectID = relation.destinationObjectID;
            [muModels addObject:relationTable];
        }];
        
        if ([muModels count]) {
            [self executeUpdateWithModels:muModels useTransaction:YES fromTable:nil inDataBase:db rollback:rollBack updateCompletion:^(BOOL success,NSArray <IHFRelationTable *> *relationTables, IHFDatabase *db, BOOL *rollback)  {
                [weakSelf enumerateRelationTables:relationTables inDataBase:db rollBack:rollBack];
            }];
        }
    }];
}

#pragma mark - insert

- (BOOL)insertIntoClassWithModel:(id)newModel fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [self insertIntoClassWithModelArray:[NSArray arrayWithObject:newModel] fromTable:tableName inDataBase:db completeBlock:completion];
}

- (BOOL)insertIntoClassWithModelArray:(NSArray *)ModelArray fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    
    __block NSMutableArray *relationTableArray = [NSMutableArray array];
    
    // Model array change into relation table array
    [ModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IHFRelationTable *relation = [[IHFRelationTable alloc] initWithSourceObject:nil destinationObject:obj relationName:nil relation:IHFRelationNone];
        [relationTableArray addObject:relation];
    }];
    
    BOOL rollBack = NO;
    
    __weak typeof(self) weakSelf = self;
    // Execute insert or update
    // TODO: if need cascade .. 
    BOOL result = [self executeUpdateWithModels:relationTableArray useTransaction:YES fromTable:tableName inDataBase:db rollback:&rollBack updateCompletion:^(BOOL success,NSArray  <IHFRelationTable *> *relationTables, IHFDatabase *db, BOOL *rollback)  {
        // If success insert or update , enmumerate it relation to insert or update
        [weakSelf enumerateRelationTables:relationTables inDataBase:db rollBack:rollback];
    }];
    
    if (completion) completion(result,db);
    return result;
}

// For insert
- (BOOL)executeUpdateWithModels:(NSArray <IHFRelationTable *>*)newModels useTransaction:(BOOL)useTransaction fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db rollback:(BOOL *)rollBack updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion {
    __block BOOL result = YES;
    if (db) {
        result = [self insertModels:newModels fromTable:tableName inDataBase:db rollback:rollBack updateCompletion:updateCompletion];
    } else {
         [_queue inTransaction:^(IHFDatabase *db, BOOL *rollback)  {
            result = [self insertModels:newModels fromTable:tableName inDataBase:db rollback:rollBack updateCompletion:updateCompletion];
        }];
    }
    return result;
}

- (BOOL)insertModels:(NSArray <IHFRelationTable *>*)newModels fromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db rollback:(BOOL *)rollback updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion {
    __block BOOL result = YES;
    __block BOOL isUpdate = NO;

    __block IHFSQLStatement *statement;
    [newModels enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        id destinationObject = obj.destinationObject;
        IHFPredicate *predicate;
        NSInteger objectID = 0;
        
        if (destinationObject) {
            // If have the custom key , it judge the DB if have existed the data , if exist ,update , otherwise insert!
            NSArray *primaryKeys = [[destinationObject class] customPrimaryKeyLists];
            if ([primaryKeys count]) {
                NSArray *customPrimarykeys = [primaryKeys firstObject]; // Class prior than super
                
                __block NSMutableString *predicateStr = [NSMutableString string];
                [customPrimarykeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx != 0) {
                        [predicateStr appendString:@" AND "];
                    }
                    if ([obj isKindOfClass:[NSString class]]) {
                        id value = [destinationObject valueWithPropertName:obj];
                        [predicateStr appendFormat:@"%@ = '%@'",obj,value];
                    }
                }];

                predicate = [IHFPredicate predicateWithString:predicateStr];

                NSString *selectedStatment = [self selectSystemColumnsqlStatementWithClass:[destinationObject class] predicate:predicate customTableName:tableName];
                
                IHFResultSet *rs = [db executeQuery:selectedStatment];
                
                while (rs.next) {
                    // Record Object id enough!
                    objectID = [rs intForColumn:IHFDBPrimaryKey];
                }
                
                // If the objectID > 0 , mean it have exist in the data base
                isUpdate = objectID > 0 ? YES : NO;
            } else {
                // If NOT have the custom key , it only insert
                isUpdate = NO;
            }
        }
        if (isUpdate) {
            statement = [self updateStatementWithModel:obj.destinationObject
                                             predicate:predicate fromTable:tableName];
        } else { // Insert
            statement = [self insertStatementWithModel:obj.destinationObject fromTable:tableName];
        }

        // Insert the destinationObject!
        BOOL success = [db executeUpdate:statement.sql withArgumentsInArray:statement.arguments];
        if (success) {
            NSString *selectTableName = NSStringFromClass([obj.destinationObject class]);
            if (!obj.sourceObject && tableName)  {  // If is super model , else sub model insert table name still is its class name!
                selectTableName = tableName;
            }
            
            if (isUpdate) {
                obj.destinationObjectID = objectID;
                
            } else {
                // Fetch maxID after the object insert success!
                obj.destinationObjectID = [self maxObjectIDfromTable:selectTableName inDataBase:db];
            }
            
            if (obj.sourceObject) { // Have source , it need create relation table !
            
                if (obj.relation == IHFRelationOneToOne) { // Means the relation is One-To-One
                    
                    // Execute update
                    // It will cause a problem of can not use table name!
                    
                    NSString *updateTable = NSStringFromClass([obj.sourceObject class]);
                    NSString *updateValue = [NSString stringWithFormat:@"%@ = %ld",obj.relationName,(long)obj.destinationObjectID];
                    NSString *updateCondition = [NSString stringWithFormat:@"WHERE %@ = %ld",IHFDBPrimaryKey,(long)obj.sourceObjectID];
                    
                    NSString *updateSql = [NSString stringWithFormat:@"%@ %@ SET %@ %@",_update,updateTable,updateValue,updateCondition];
                    BOOL success = [db executeUpdate:updateSql];
                    
                    if (!success) {
                        *rollback = YES;
                        *stop = YES;
                        result = NO;
                    }
                    
                } else { // One-To-Many
                    // Insert ID in relation table
                    [obj saveInDataBase:db completeBlock:^(BOOL success,IHFDatabase *db) {
                        if (!success)  {
                            *rollback = YES;
                            *stop = YES;
                            result = NO;
                        }
                    }];
                }
            }
        } else { // Not success DO update or insert
            *rollback = YES;
            *stop = YES;
            result = NO;
        }
    }];

    updateCompletion(result,newModels,db,rollback);
    return result;
}

- (IHFSQLStatement *)insertStatementWithModel:(id)newModel
                           fromTable:(NSString *)tableName {

    NSString *insertTableName = NSStringFromClass([newModel class]);
    if (tableName) insertTableName = tableName;
    
    NSMutableString *insertSql = [NSMutableString stringWithFormat:@"%@ %@ ",_insert,insertTableName];
    [insertSql appendString:[[newModel class] insertSqlStatement]];
    return [[IHFSQLStatement alloc] initWithSql:insertSql arguments:[newModel argumentsForStatement]];
}

#pragma mark - update

- (BOOL)updateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade updateColumns:(NSArray *)columns updateValues:(NSArray *)values completeBlock:(IHFDBCompleteBlock)completion {
    // Model must NOT array ...
    if ([newModel isKindOfClass:[NSArray class]]) {
        NSAssert(true != true, @"Can NOT update array use predicate");
        return NO;
    }
    
    __block BOOL result = NO;
    __weak typeof(self) weakSelf = self;
    if (db) {
        result = [self executeForUpdateModel:newModel
                          predicate:predicate
                    customTableName:tableName
                         inDataBase:db
                          isCascade:cascade
                      updateColumns:columns
                        updateValues:values
                      completeBlock:completion];
    } else {
        [_queue inTransaction:^(IHFDatabase *db, BOOL *rollback) {
            result = [weakSelf executeForUpdateModel:newModel
                                       predicate:predicate
                                 customTableName:tableName
                                      inDataBase:db
                                       isCascade:cascade
                                   updateColumns:columns
                                    updateValues:values
                                   completeBlock:completion];
        }];
    }
    return result;
}

- (BOOL)executeForUpdateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade updateColumns:(NSArray *)columns updateValues:(NSArray *)values completeBlock:(IHFDBCompleteBlock)completion {
    // Need cascade Or not
    __block BOOL result = NO;
    Class targetClass = [newModel class];
 
    if (!columns) {
        IHFSQLStatement *statement = [self updateStatementWithModel:newModel
                                                          predicate:predicate
                                                          fromTable:tableName];
        result = [db executeUpdate:statement.sql withArgumentsInArray:statement.arguments];
    } else { // have update columns
        IHFSQLStatement *stament = [[IHFSQLStatement alloc] initWithSql:[targetClass updateSqlStatementWithColumns:columns withPredicate:predicate fromTable:tableName] arguments:values];
        result = [self executeUpdateWithClass:targetClass statements:@[stament] inDataBase:db useTransaction:NO completeBlock:nil];
    }
    
    if (cascade) { // Delete relation and reset ..
        BOOL rollBack = NO;
        __block NSMutableArray *relationTableArray = [NSMutableArray array];
        IHFRelationTable *relation = [[IHFRelationTable alloc] initWithSourceObject:nil destinationObject:newModel relationName:nil relation:IHFRelationNone];
        [relationTableArray addObject:relation];
        [self enumerateRelationTables:relationTableArray inDataBase:db rollBack:&rollBack];
    }
    if (completion) completion(result,db);
    return result;
}

- (BOOL)resetAllWithModels:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade {
    __block BOOL result = NO;
    Class targetClass = [newModel class];
    NSArray *selects = [targetClass selectWithPredicate:predicate fromTable:tableName inDataBase:db];
    // Delete all relation for reset relation
    [targetClass deleteWithPredicate:predicate fromTable:tableName inDataBase:db completeBlock:^(BOOL success,IHFDatabase *db)  {
        // Reset model and relation
        __weak typeof(self) weakSelf = self;
        [selects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)  {
            result = [weakSelf insertIntoClassWithModel:newModel fromTable:tableName inDataBase:db completeBlock:nil];
        }];
    }];
    return result;
}

- (IHFSQLStatement *)updateStatementWithModel:(id)newModel predicate:(IHFPredicate *)predicate fromTable:(NSString *)tableName {
    
    NSString *newTableName = NSStringFromClass([newModel class]);
    if (tableName) newTableName = tableName;
    
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"%@ %@ SET ",_update,newTableName];
    
    [updateSql appendString:[[newModel class] updateSqlStatement]];
    
    if (predicate) {
        if (predicate.predicateFormat) {
            [updateSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    return [[IHFSQLStatement alloc] initWithSql:updateSql
                                      arguments:[newModel argumentsForStatement]];
}

#pragma mark - delete

- (NSString *)deleteStatementWithClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName {
    
    NSString *deleteTableName = NSStringFromClass(newClass);
    if (tableName) deleteTableName = tableName;
    
    NSMutableString *deleteSql = [NSMutableString stringWithFormat:@"%@ %@",_delete,deleteTableName];
    
    if (predicate) {
        if (predicate.predicateFormat) {
            [deleteSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    return deleteSql;
}

- (BOOL)deleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    // Do in given db , if not db , it need Transaction to do ...
    __block BOOL result;
    if (db) {
        result = [self executeDeleteFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
    } else {
        [_queue inTransaction:^(IHFDatabase *db, BOOL *rollback) {
            result = [self executeDeleteFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
        }];
    }
    return result;
}

- (BOOL)executeDeleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    // selected the models you will delete ! In order to fetch the Obejct ID for Delete Relation for one-to-many and foreign key for One-to-One !
    NSArray *modelArray = [self selectFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isRecursive:NO];
    
    if ([modelArray count]) { // If not have the models you want to delete in the data base, not need to delete!
        
        NSString *deleteSql = [self deleteStatementWithClass:newClass
                                                   predicate:predicate
                                             customTableName:tableName];

        BOOL success = [db executeUpdate:deleteSql];
        if (success) { // delete success ,delete ralation
            [self deleteRelationForModelArray:modelArray
                                   inDataBase:db isCascade:cascade];
        }
        if (completion) completion(success,db);
        return success;
    } else {
        NSLog(@"What you want to delete %@ data not exist in the DB",NSStringFromClass(newClass));
        return YES;
    }
}

/// Delete in_SqlStatement like (1,2) , USE class ..
- (void)deleteRelationUseIn_SqlStatement:(NSString *)in_SqlStatement
                                forClass:(Class)aClass inDataBase:(IHFDatabase *)db {
    __weak typeof(self) weakSelf = self;
    NSArray <IHFProperty *>*properies = [aClass propertiesForTypeOfArray];
    [properies enumerateObjectsUsingBlock:^(IHFProperty *_Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tableName = [NSString stringWithFormat:@"%@_%@_Relation",NSStringFromClass(aClass),property.propertyName];
        [weakSelf deleteRelationUseIn_SqlStatement:in_SqlStatement forTableName:tableName inDataBase:db];
    }];
}

/// Delete in_SqlStatement like (1,2) , use tableName ..
- (void)deleteRelationUseIn_SqlStatement:(NSString *)in_SqlStatement forTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    if (!in_SqlStatement && !tableName && ![in_SqlStatement length] && ![tableName length]) return;
    NSString *deleteStament = [NSString stringWithFormat:@"delete from %@ where %@ in (%@)",tableName,@"sourceObjectID",in_SqlStatement];
    [db executeUpdate:deleteStament];
}

- (void)deleteRelationForModelArray:(NSArray<id <IHFDBObejctDataSource>> *)modelArray inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade {
    // Delete relation ...
    [modelArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[obj class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            // Judge Array or model
            if (property.type == IHFPropertyTypeArray) { // deal with array
                if (property.objectClass) {
                    IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:obj
                                                                           destinationObject:[[property.objectClass alloc] init]
                                                                                relationName:property.propertyName
                                                                                    relation:IHFRelationOneToMany];
                    id <IHFDBObejctDataSource> model = obj;
                    table.sourceObjectID = model.objectID;
                    NSArray *models;
                    
                    if (cascade) { // Is cascade , get the relation models !
                        models = [table selectRelationsInDataBase:db];
                    }
                    [table deleteInDataBase:db completeBlock:^(BOOL success,IHFDatabase *db) { // delete relation table
                        if (cascade) { // Is cascade , Not noly delete the relation table , but also the table itself!
                            [models enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",IHFDBPrimaryKey,(long)obj.objectID];
                                IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];
                                [[obj class] deleteWithPredicate:predicate fromTable:nil inDataBase:db isCascade:YES completeBlock:nil];
                            }];
                        }
                    }];
                }
            } else if (property.type == IHFPropertyTypeModel) {
                if (cascade) {
                    id value = [obj valueWithProperty:property];
                    NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",IHFDBPrimaryKey,(long)value];
                    IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];
                    [property.objectClass deleteWithPredicate:predicate fromTable:nil inDataBase:db isCascade:YES completeBlock:nil];
                }
            }
        }];
    }];
}

#pragma mark -  Execute sql statment by user

- (NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive {
    __block NSArray *modelArray = [NSArray array];
    __weak typeof(self) weakSelf = self;
    if (db) {
        IHFResultSet *rs = [db executeQuery:sqlStatement];
        modelArray = [self modelsWithClass:newClass IHFResultSet:rs inDataBase:db isRecursive:recursive];
    } else {
        [_queue inDatabase:^(IHFDatabase *db) {
            IHFResultSet *rs = [db executeQuery:sqlStatement];
            modelArray = [weakSelf modelsWithClass:newClass IHFResultSet:rs inDataBase:db isRecursive:recursive];
        }];
    }
    return modelArray;
}

- (NSArray *)modelsWithClass:(Class)newClass IHFResultSet:(IHFResultSet *)rs inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive {
    NSMutableArray *models = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    while (rs.next) {
        NSObject <IHFDBObejctDataSource> *model = [[newClass alloc] init];
    
        // Model get the object ID and Dirty
        [model setObjectID:[rs intForColumn:IHFDBPrimaryKey]];
        [model setDirty:[rs intForColumn:IHFDBDirtyKey]];
        
        [[newClass class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            [weakSelf setValueWithFMResult:rs forModel:model property:property isRecursive:recursive inDataBase:db];
        }];
        [models addObject:model];
    }
    return models;
}

- (BOOL)executeUpdateWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion {
    // update a single sqlStatement not need useTransaction!
    return [self executeUpdateWithClass:newClass sqlStatements:[NSArray arrayWithObject:sqlStatement] completeBlock:completion useTransaction:NO];
}

#pragma mark -  select count

- (NSInteger)selectCountFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    NSString *selectSql = [self selectSystemColumnsqlStatementWithClass:newClass predicate:predicate customTableName:tableName];
    if (db) {
        IHFResultSet *rs = [db executeQuery:selectSql];
        return [self countWithResultSet:rs];
    } else {
        __weak typeof(self) weakSelf = self;
        __block NSInteger count;
        [_queue inDatabase:^(IHFDatabase *db) {
            IHFResultSet *rs = [db executeQuery:selectSql];
            count =  [weakSelf countWithResultSet:rs];
        }];
        return count;
    }
}

- (NSInteger)countWithResultSet:(IHFResultSet *)rs {
    NSInteger count = 0;
    while (rs.next)  { count++; }
    return count;
}

- (void)setValueWithFMResult:(IHFResultSet *)rs forModel:(NSObject <IHFDBObejctDataSource> *)model property:(IHFProperty *)property isRecursive:(BOOL)recursive inDataBase:(IHFDatabase *)db {
    
    SEL setSel = property.setSel;
    if ([model respondsToSelector:setSel]) {
        IMP imp = property.imp;
        NSString *key = property.propertyName;
        switch (property.type)  {
            case IHFPropertyTypeArray: {
                //Fetch the model contained in the array , to select the relation table
                if (recursive) {
                    if (property.objectClass)  {
                        IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:model destinationObject:[[property.objectClass alloc] init] relationName:property.propertyName relation:IHFRelationOneToMany];
                        table.sourceObjectID = model.objectID;
                        NSArray *models = [table selectRelationsInDataBase:db];
                        void (*func) (id,SEL,NSMutableArray *) = (void*)imp;
                        func(model,setSel,(NSMutableArray *)models);
                    } else {
                        void (*func) (id,SEL,NSMutableArray *) = (void*)imp;
                        if ([rs dataForColumn:key] || ![[rs stringForColumn:key] isEqualToString:@"(null)"])
                        func(model,setSel,[NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[rs dataForColumn:key] options:kNilOptions error:nil]]);
                    }
                }
            } break;
            case IHFPropertyTypeModel: {
                //Fetch the model contained in the array , to select the relation table
                if (recursive) {
                    int destinationObjectID = [rs intForColumn:property.propertyName];
                    if (destinationObjectID != 0) {
                        IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:model destinationObject:[[property.objectClass alloc] init] relationName:property.propertyName relation:IHFRelationOneToOne];
                        table.destinationObjectID = destinationObjectID;
                        NSArray *models = [table selectRelationsInDataBase:db];
                        if ([models count]) {
                            void (*func) (id,SEL,id) = (void*)imp;
                            func(model,setSel,[models firstObject]);
                        }
                    }
                }
            } break;
            case IHFPropertyTypeDate: {
                NSString *dateString = [rs stringForColumn:key];
                if (dateString && [dateString length] >= 19) {
                NSString *dateStr = [[rs stringForColumn:key] substringToIndex:19];
                void (*func) (id,SEL,NSDate*) = (void*)imp;
                    func(model,setSel,(NSDate *)[[self convertDateString:dateStr] dateByAddingTimeInterval:8 * 60 * 60]);
                   }
            } break;
            case IHFPropertyTypeInt  :
            case IHFPropertyTypeShort :
            case IHFPropertyTypeUInteger :
            case IHFPropertyTypeBOOL : {
                void (*func) (id,SEL,int) = (void *)imp;
                func(model,setSel,[rs intForColumn:key]);
            } break;
            case IHFPropertyTypeUnsignedLongLong : {
                void (*func) (id,SEL,unsigned long long) = (void *)imp;
                func(model,setSel,[rs unsignedLongLongIntForColumn:key]);
                
            } break;
            case IHFPropertyTypeLongLong :{
                void (*func) (id,SEL,long long) = (void *)imp;
                func(model,setSel,[rs longLongIntForColumn:key]);
            } break;
            case IHFPropertyTypeLong :
            case IHFPropertyTypeUnsignedLong : {
                void (*func) (id,SEL,long) = (void *)imp;
                func(model,setSel,[rs longForColumn:key]);
            } break;
            case IHFPropertyTypeDouble : {
                void (*func) (id,SEL,double) = (void *)imp;
                func(model,setSel,[rs doubleForColumn:key]);
            } break;
            case IHFPropertyTypeFloat : {
                void (*func) (id,SEL,float) = (void *)imp;
                func(model,setSel,[rs doubleForColumn:key]);
            } break;
            case IHFPropertyTypeData : {
                void (*func) (id,SEL,NSData *) = (void *)imp;
                id obj = [rs objectForColumnName:key];
                if (!obj) return;
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([obj isEqualToString:@"(null)"]) return;
                }
                func(model,setSel,obj);
            } break;
            case IHFPropertyTypeImage : {
                void (*func) (id,SEL,UIImage *) = (void *)imp;
                func(model,setSel,[UIImage imageWithData:[rs dataForColumn:key]]);
            } break;
            case IHFPropertyTypeString : {
                void (*func) (id,SEL,NSString *) = (void *)imp;
                id obj = [rs stringForColumn:key];
                if ([obj isEqualToString:@"(null)"]) return;
                func(model,setSel,obj);
            } break;
            case IHFPropertyTypeNumber : {
                NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
                id obj = [rs stringForColumn:key];
                if ([obj isEqualToString:@"(null)"]) return;
                NSNumber *value = [format numberFromString:(NSString *)obj];
                void (*func) (id,SEL,NSNumber *) = (void*)imp;
                func(model,setSel,value);
            } break;
            case IHFPropertyTypeDictionaryM : {
                void (*func) (id,SEL,NSMutableDictionary *) = (void*)imp;
                id obj = [rs objectForColumnName:key];
                if (!obj) return;
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([obj isEqualToString:@"(null)"]) return;
                }
                func(model,setSel,[NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:nil]]);
            } break;
            case IHFPropertyTypeDictionaryI : {
                void (*func) (id,SEL,NSDictionary *) = (void*)imp;
                id obj = [rs objectForColumnName:key];
                if (!obj) return;
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([obj isEqualToString:@"(null)"]) return;
                }
                func(model,setSel,[NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:nil]);
            } break;
            case IHFPropertyTypeClass : {
                NSString *obj = [rs stringForColumn:key];
                if (obj || ![obj isEqualToString:@"(null)"]) {
                    void (*func) (id,SEL,Class) = (void*)imp;
                    func(model,setSel,NSClassFromString(obj));
                }
            } break;
            case IHFPropertyTypeId : {
                void (*func) (id,SEL,id) = (void*)imp;
                
                id obj = [rs objectForColumnName:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([obj isEqualToString:@"(null)"]) return;
                }
                if ([obj isKindOfClass:[NSData class]]) {
                    func(model,setSel,[NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:nil]);
                } else {
                    func(model,setSel,obj);
                }
            } break;
            case IHFPropertyTypeBlock : {
                // What to do ?
            } break;

            default: {
                void (*func) (id,SEL,id) = (void*)imp;
                id obj = [rs objectForColumnName:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([obj isEqualToString:@"(null)"]) return;
                }
                func(model,setSel,obj);
            }
                break;
        }
    }
}

// for all
- (BOOL)executeUpdateWithClass:(Class)newClass sqlStatements:(NSArray <NSString *>*)sqlStatements completeBlock:(IHFDBCompleteBlock)completion useTransaction:(BOOL)useTransaction {
    
    __block BOOL result = YES;
    if (useTransaction) { // If execute update fail , it will be roll back
        
        [_queue inTransaction:^(IHFDatabase *db, BOOL *rollback) {
            
            [sqlStatements enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL success = [db executeUpdate:obj];
                if (!success)  {
                    if (completion) completion(success,db);
                    result = NO;
                    *stop = YES;
                    *rollback = YES; // roll back
                }
            }];
            if (result) {
                if(completion) completion(YES,db);
            }
         }];
    } else {
        
        [_queue inDatabase:^(IHFDatabase *db) {
            [sqlStatements enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BOOL success = [db executeUpdate:obj];
                
                if (!success) {
                    if(completion) completion(success,db);
                    result = NO;
                    *stop = YES;
                }
            }];
            if (result) {
                if(completion) completion(YES,db);
            }
        }];
    }
    return result;
}

#pragma mark - by SQLStatemnt 
- (NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass statement:(IHFSQLStatement *)statement inDataBase:(IHFDatabase *)db isRecursive:(BOOL)recursive {
    __block NSArray *modelArray = [NSArray array];
    __weak typeof(self) weakSelf = self;
    if (db) {
        IHFResultSet *rs = [db executeQuery:statement.sql withArgumentsInArray:statement.arguments];
        modelArray = [self modelsWithClass:newClass IHFResultSet:rs inDataBase:db isRecursive:recursive];
    } else {
        [_queue inDatabase:^(IHFDatabase *db) {
            IHFResultSet *rs = [db executeQuery:statement.sql withArgumentsInArray:statement.arguments];
            modelArray = [weakSelf modelsWithClass:newClass IHFResultSet:rs inDataBase:db isRecursive:recursive];
        }];
    }
    return modelArray;
}

- (BOOL)executeUpdateWithClass:(Class)newClass statements:(NSArray<IHFSQLStatement *> *)statements inDataBase:(IHFDatabase *)db useTransaction:(BOOL)useTransaction completeBlock:(IHFDBCompleteBlock)completion {
    __block BOOL result = YES;
    __block IHFDatabase *newDb = db;
    
    if (db) {
        [statements enumerateObjectsUsingBlock:^(IHFSQLStatement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            result = [db executeUpdate:obj.sql withArgumentsInArray:obj.arguments];
            if (!result)  {
                *stop = YES;
            }
        }];
    } else {
        if (useTransaction) { // If execute update fail , it will be roll back
            [_queue inTransaction:^(IHFDatabase *db, BOOL *rollback) {
                newDb = db;
                [statements enumerateObjectsUsingBlock:^(IHFSQLStatement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    result = [db executeUpdate:obj.sql withArgumentsInArray:obj.arguments];
                    if (!result)  {
                        *stop = YES;
                        *rollback = YES; // roll back
                    }
                }];
            }];
        } else {
            [_queue inDatabase:^(IHFDatabase *db) {
                newDb = db;
                [statements enumerateObjectsUsingBlock:^(IHFSQLStatement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    result = [db executeUpdate:obj.sql withArgumentsInArray:obj.arguments];
                    if (!result) {
                        *stop = YES;
                    }
                }];
            }];
        }
    }
    if (completion) completion(result,newDb);
    return result;
}

#pragma mark -  delete dirty data
- (BOOL)deleteDirtyDataFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(IHFDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    __block BOOL result = NO;
    // To get resetDirtySql first!
    NSString *resetDirtySql = [self resetDirtySqlStatementWithClass:newClass customTableName:tableName predicate:predicate];
    
    NSString *dirtyStr = [NSString stringWithFormat:@"%@ = 0",IHFDBDirtyKey];
    IHFPredicate *dirtyPredicate = [IHFPredicate predicateWithString:dirtyStr];
    [predicate appendAnd_Predicate:dirtyPredicate];
    
    // select sql where dirty = 0
    NSString *selectedStatment = [self selectSystemColumnsqlStatementWithClass:newClass predicate:predicate customTableName:tableName];

    if (db) {
        IHFResultSet *rs = [db executeQuery:selectedStatment];
        NSMutableString *inSqlStatement = [NSMutableString string];

        while (rs.next) {
            [inSqlStatement appendFormat:@"%ld,",(long)[rs intForColumn:IHFDBPrimaryKey]];
        }

        if ([inSqlStatement length]) {
            [inSqlStatement deleteCharactersInRange:NSMakeRange(inSqlStatement.length -  1, 1)];
        }
        // delete dirty is 0
        NSString *deleteSql = [self deleteStatementWithClass:newClass predicate:predicate customTableName:tableName];
        BOOL success = [db executeUpdate:deleteSql];
        if (success) {
            // delete Model dirty is 0 relation table!
            if ([inSqlStatement length])  {
                [self deleteRelationUseIn_SqlStatement:inSqlStatement forClass:newClass inDataBase:db];
            }
            // reset dirty is 1
            result = [db executeUpdate:resetDirtySql];
        }
        if (completion) {
            completion(result,db);
        }
    } else {
        __weak typeof(self) weakSelf = self;
        [_queue inTransaction:^(IHFDatabase *db, BOOL *rollback) {
            IHFResultSet *rs = [db executeQuery:selectedStatment];
            
            NSMutableString *inSqlStatement = [NSMutableString string];
            while (rs.next) {
                [inSqlStatement appendFormat:@"%ld,",(long)[rs intForColumn:IHFDBPrimaryKey]];
            }
            
            if ([inSqlStatement length]) {
                [inSqlStatement deleteCharactersInRange:NSMakeRange(inSqlStatement.length - 1,1)];
            }
            
            // delete dirty is 0
            NSString *deleteSql = [weakSelf deleteStatementWithClass:newClass predicate:predicate customTableName:tableName];
            BOOL success = [db executeUpdate:deleteSql];
            
            if (success) {
                // use in sql stament to delete
                if ([inSqlStatement length]) {
                    [self deleteRelationUseIn_SqlStatement:inSqlStatement forClass:newClass inDataBase:db];
                }
                // reset dirty is 1
                result = [db executeUpdate:resetDirtySql];
            }
            if (completion) {
                completion(result,db); 
            }
        }];
    }
    return result;
}

- (NSString *)resetDirtySqlStatementWithClass:(Class)newClass customTableName:(NSString *)tableName predicate:(IHFPredicate *)predicate {

    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    // Reset dirty data
    NSMutableString *resetDirtySqlStatement = [NSMutableString stringWithFormat:@"%@ %@ SET %@ = 0" ,_update,newTableName,IHFDBDirtyKey];
    
    if (predicate) {
        if (predicate.predicateFormat) {
            [resetDirtySqlStatement appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    return resetDirtySqlStatement;
}

#pragma mark -  support tool

- (BOOL)isTableExistWithTableName:(NSString *)tableName inDatabase:(IHFDatabase *)db {
    if (db) return [db tableExists:tableName];
    __block BOOL isExist ;
    [_queue inDatabase:^(IHFDatabase *db) {
        isExist = [db tableExists:tableName];
    }];

    return isExist;
}

- (NSString *)convertDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return  [dateFormat stringFromDate:date];
}

- (NSDate *)convertDateString:(NSString *)dateString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat dateFromString:dateString];
}

- (NSInteger)maxObjectIDfromTable:(NSString *)tableName inDataBase:(IHFDatabase *)db {
    NSInteger maxObjectID = 0;
    NSString *selectMaxIDSQL =  [NSString stringWithFormat:@"Select seq From sqlite_sequence Where name = '%@'",tableName];
    
    IHFResultSet *rs = [db executeQuery:selectMaxIDSQL];
    
    while (rs.next) {
        maxObjectID = [rs intForColumnIndex:0];
    }
    return maxObjectID;
}
@end
