//
//  IHFDataBaseExecute.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFDataBaseExecute.h"
// Sqlite name
static NSString *_kSqliteName = @"IHFDB.sqlite";

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

static FMDatabaseQueue *_queue; /**< main queue */

static NSMutableDictionary *_propertyNameDict;

@interface IHFDataBaseExecute ()
@end

@implementation IHFDataBaseExecute

// use single instance 
+ (instancetype)shareDataBaseExecute {
    
    static id shareDataBaseExecute;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shareDataBaseExecute = [[IHFDataBaseExecute alloc] initWithSqliteName:_kSqliteName];
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
    
    // create FMDatabaseQueue
    
    NSString *dataBasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:_sqliteName];
    
    NSLog(@"dataBasePath = %@",dataBasePath);
    _queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
}

//  data base operation

#pragma mark - create table
// create
- (BOOL)createTableWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    
    NSString *createTableSql = [self createSqlStatementWithClass:newClass customTableName:tableName inDataBase:db];
    
    // Judge the data base is exist the table
    if (!createTableSql) {
        if (completion) completion(YES);
        return YES;
    }
    
    if (db) {
        BOOL success = [db executeUpdate:createTableSql];
        if (completion) completion(success);
        return success;
    }
    
    // If not db , create db in _queue
    return [self executeUpdateWithClass:newClass sqlStatement:createTableSql completeBlock:completion];
}

- (NSString *)createSqlStatementWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    
    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    // Judge the data base is exist the table
    if ([self isTableExistWithTableName:newTableName inDatabase:db]) return nil;
    
    NSMutableString *createTableSql = [NSMutableString stringWithFormat:@"%@ %@ ",_createTable,newTableName];
    
    // append primary Key
    NSString *primaryKeySql = [NSString stringWithFormat:@"(%@ integer primary key autoincrement,",_primaryKey];
    [createTableSql appendString:primaryKeySql];
    
    NSString *dirtySql = [NSString stringWithFormat:@"%@ integer,",_dirtyKey];
    [createTableSql appendString:dirtySql];
    
    [newClass enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) { // deal with array
            
            // Fetch the model contained in the array , to create table
            
            if (property.objectClass) {
                
                // create relation table
                IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:[[newClass alloc] init] destinationObject:[[property.objectClass alloc] init] relationName:property.propertyName relation:IHFRelationOneToMany];
                
                [relationTable createInDataBase:db];
                
                if ([NSStringFromClass(property.objectClass) isEqualToString:newTableName]) return ;
                [self createTableWithClass:property.objectClass customTableName:nil inDataBase:db completeBlock:nil];
            }
        } else if (property.type == IHFPropertyTypeModel) { // deal with model
            
            // For create One-To-One relation , add a colunm for proprety name!
            // TODO:Custom primary be can be the colunm type!
            
            NSString *colum = [NSString stringWithFormat:@"%@ interger,",property.propertyName];
            [createTableSql appendString:colum];

            if ([property.typeString isEqualToString:newTableName]) return ; // Void the one=to- one relation class is self
            
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

- (NSArray<id<IHFDBObejctDataSource>> *)selectFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isRecursive:(BOOL)recursive {
    
    NSString *selectSql = [self selectSqlStatementWithClass:newClass predicate:predicate customTableName:tableName];
    return [self executeQueryWithClass:newClass sqlStatement:selectSql inDataBase:db isRecursive:recursive];
}

/** Return sql statement with system colunm , like object and dirty */

- (NSString *)selectSystemColunmSqlStatementWithClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName {
    
    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    NSMutableString *selectSql = [NSMutableString stringWithFormat:@"%@ %@,%@ from %@ ",_select,_primaryKey,_dirtyKey, newTableName];
    
    if(predicate) {
        
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

    if(predicate) {
        
        if (predicate.predicateFormat) {
            [selectSql appendFormat:@"WHERE %@ ",predicate.predicateFormat];
        }
        
        if (predicate.orderBy) {
            NSString *desc = @"ASC";
            if (predicate.isDesc) desc = @"DESC";
            [selectSql appendFormat:@"ORDER BY %@ %@ ",predicate.orderBy,desc];
        }
    
        if(!NSEqualRanges(predicate.limitRange, NSMakeRange(0, 0))) {
            NSRange limitRange = predicate.limitRange;
            [selectSql appendFormat:@"LIMIT %ld OFFSET %ld ",(long)limitRange.length,(long)limitRange.location];
        }
    }
    return selectSql;
}

-  (void)enumerateRelationTables:(NSArray <IHFRelationTable *> *)relationTables inDataBase:(FMDatabase *)db rollBack:(BOOL *)rollBack {
    
    // The blcok call back when a model insert success , and the block in order to create the relation table !
    // So when call back the block , table's destinationObject become source obejct !
    __block NSMutableString *inSqlStatement = [NSMutableString string];
    __weak typeof(self) weakSelf = self;

    if (![relationTables count]) return;
    
    Class srcClass  = [[relationTables firstObject].destinationObject class];
    
    if ([[srcClass propertiesForTypeOfArray] count]) { // If have array , so it need delete relation table
        
        [relationTables enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)  {
            
            [inSqlStatement appendFormat:@"%ld,",(long)obj.destinationObjectID];
        }];
        
        if ([inSqlStatement length])  {
            [inSqlStatement deleteCharactersInRange:NSMakeRange(inSqlStatement.length -  1, 1)];
            
            [self deleteRelationUseIn_SqlStatement:inSqlStatement forClass:srcClass inDataBase:db];
        }

    }
    
    [[srcClass propertiesForTypeOfArray] enumerateObjectsUsingBlock:^(IHFProperty * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *muModels = [NSMutableArray array];

        [relationTables enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull relation, NSUInteger idx, BOOL * _Nonnull stop) {
            
            id sourceObject = relation.destinationObject;
            id modelArray = [sourceObject valueWithProperty:property];
            
            [modelArray enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:sourceObject destinationObject:obj relationName:property.propertyName relation:IHFRelationOneToMany];
                relationTable.sourceObjectID = relation.destinationObjectID;
                
                [muModels addObject:relationTable];
                
            }];
        }];
        
        if ([muModels count]) { // For use 'in' statement
            [self executeUpdateWithModels:muModels useTransaction:YES inTableName:nil inDataBase:db rollback:rollBack updateCompletion:^(BOOL success,  NSArray  <IHFRelationTable *> *relationTables, FMDatabase *db, BOOL *rollback)  {
                
                [weakSelf enumerateRelationTables:relationTables inDataBase:db rollBack:rollBack];
            }];
        }
    }];
    
    
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
            [self executeUpdateWithModels:muModels useTransaction:YES inTableName:nil inDataBase:db rollback:rollBack updateCompletion:^(BOOL success,NSArray <IHFRelationTable *> *relationTables, FMDatabase *db, BOOL *rollback)  {
                
                [weakSelf enumerateRelationTables:relationTables inDataBase:db rollBack:rollBack];
            }];
        }
    }];

}

#pragma mark - insert

- (BOOL)insertIntoClassWithModel:(id)newModel inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    return [self insertIntoClassWithModelArray:[NSArray arrayWithObject:newModel] inTableName:tableName inDataBase:db completeBlock:completion];
}

- (BOOL)insertIntoClassWithModelArray:(NSArray *)ModelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    
    __block NSMutableArray *relationTableArray = [NSMutableArray array];
    
    // Model array change into relation table array
    [ModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)  {
        
        IHFRelationTable *relation = [[IHFRelationTable alloc] initWithSourceObject:nil destinationObject:obj relationName:nil relation:IHFRelationNone];
        [relationTableArray addObject:relation];
    }];
    
    BOOL rollBack = NO;
    
    // Execute insert or update
    BOOL result = [self executeUpdateWithModels:relationTableArray useTransaction:YES inTableName:tableName inDataBase:db rollback:&rollBack updateCompletion:^(BOOL success,NSArray  <IHFRelationTable *> *relationTables, FMDatabase *db, BOOL *rollback)  {
        
        // If success insert or update , enmumerate it relation to insert or update
        [self enumerateRelationTables:relationTables inDataBase:db rollBack:rollback];
    }];
    
    if (completion) completion(result);
    return result;
}

// For insert
- (BOOL)executeUpdateWithModels:(NSArray <IHFRelationTable *>*)newModels useTransaction:(BOOL)useTransaction inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db rollback:(BOOL *)rollBack updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion {
    
    __block BOOL result = YES;

    if (db) {
        result = [self insertModels:newModels inTableName:tableName inDataBase:db rollback:rollBack updateCompletion:updateCompletion];
    } else {
        
         [_queue inTransaction:^(FMDatabase *db, BOOL *rollback)  {
            result = [self insertModels:newModels inTableName:tableName inDataBase:db rollback:rollBack updateCompletion:updateCompletion];
        }];
    }
    return result;
}

- (BOOL)insertModels:(NSArray <IHFRelationTable *>*)newModels inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db rollback:(BOOL *)rollback updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion {
    
    __block BOOL result = YES;
    __block BOOL isUpdate = NO;

    [newModels enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *sqlStatement;
        
        id destinationObject = obj.destinationObject;
        IHFPredicate *predicate;
        NSInteger objectID = 0;
        
        if (destinationObject) {
            
            if ([[destinationObject class] respondsToSelector:@selector(customPrimarykey)]) { // Have custom primary key
                
                // If have the custom key , it judge the DB if have existed the data , if exist ,update , otherwise insert!

                NSString *customPrimarykey = [[destinationObject class] customPrimarykey];
                NSAssert(customPrimarykey, @"costom primary key can not be nil");

                if(customPrimarykey) {
                    
                    id value = [destinationObject valueWithPropertName:customPrimarykey];
                    
                    // Warning:Custom primary key if use int , it will a BUG!
                    NSString *predicateStr = [NSString stringWithFormat:@"%@ = '%@'",customPrimarykey,value];
                    predicate = [IHFPredicate predicateWithString:predicateStr];
                    
                    NSString *selectedStatment = [self selectSystemColunmSqlStatementWithClass:[destinationObject class] predicate:predicate customTableName:tableName];
                    
                    FMResultSet *rs = [db executeQuery:selectedStatment];
                    
                    while (rs.next) {
                        
                        // Record Object id enough!
                        objectID = [rs intForColumn:_primaryKey];
                    }
                    
                    // If the objectID > 0 , mean it have exist in the data base
                    isUpdate = objectID > 0 ? YES : NO;
                }
            } else {
                // If NOT have the custom key , it only insert
                isUpdate = NO;
            }
        }
        
        if (isUpdate) {
            sqlStatement = [self updateStatementWithModel:obj.destinationObject predicate:predicate inTableName:tableName];

        }else { // Insert
            sqlStatement = [self insertStatementWithModel:obj.destinationObject inTableName:tableName];
        }

        // Insert the destinationObject!
        BOOL success = [db executeUpdate:sqlStatement];
        
        if (success) {
            
            NSString *selectTableName = NSStringFromClass([obj.destinationObject class]);
            
            if (!obj.sourceObject && tableName)  {  // If is super model , else sub model insert table name still is its class name!
                selectTableName = tableName;
            }
            
            if (isUpdate) {
                obj.destinationObjectID = objectID;
                
            }else {
                // Fetch maxID after the object insert success!
                obj.destinationObjectID = [self maxObjectIDIntableName:selectTableName inDataBase:db];
            }
            

            if (obj.sourceObject) { // Have source , it need create relation table !
            
                if(obj.relation == IHFRelationOneToOne) { // Means the relation is One-To-One
                    
                    // Execute update
                    // It will cause a problem of can not use table name!
                    
                    NSString *updateTable = NSStringFromClass([obj.sourceObject class]);
                    NSString *updateValue = [NSString stringWithFormat:@"%@ = %ld",obj.relationName,(long)obj.destinationObjectID];
                    NSString *updateCondition = [NSString stringWithFormat:@"WHERE %@ = %ld",_primaryKey,(long)obj.sourceObjectID];
                    
                    NSString *updateSql = [NSString stringWithFormat:@"%@ %@ SET %@ %@",_update,updateTable,updateValue,updateCondition];
                    BOOL success = [db executeUpdate:updateSql];
                    
                    if (!success) {
                        *rollback = YES;
                        *stop = YES;
                        result = NO;
                    }
                    
                } else { // One-To-Many
                    
                    // Insert ID in relation table
                    [obj saveInDataBase:db completeBlock:^(BOOL success) {
                        
                        if (!success)  {
                            *rollback = YES;
                            *stop = YES;
                            result = NO;
                        }
                    }];
                }
            }
            
        }else { // Not success DO update or insert
            *rollback = YES;
            *stop = YES;
            result = NO;
        }
    }];

    updateCompletion(result,newModels,db,rollback);
    return result;
}

- (NSString *)insertStatementWithModel:(id)newModel inTableName:(NSString *)tableName {
    
    NSString *insertTableName = NSStringFromClass([newModel class]);
    if (tableName) insertTableName = tableName;
    
    NSMutableString *insertSql = [NSMutableString stringWithFormat:@"%@ %@ ",_insert,insertTableName];
    
    __block NSMutableString *keyStr = [NSMutableString string];
    __block NSMutableString *value = [NSMutableString string];
    
    [[newModel class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) return ;
        if (property.type == IHFPropertyTypeModel) return ;

        [keyStr appendFormat:@"%@,",property.propertyName];
            
        // According to property type , if is from fundation , then add '' to become text！
        NSString *format = [property.typeOfFundation boolValue] ? @"'%@',"  : @"%@,";
        
        [value appendFormat:format,[newModel valueWithProperty:property]];
    }];
    
    // if insert , the data is not dirty
    [keyStr appendFormat:@"%@,",_dirtyKey];
    [value appendString:@"1,"];
    
    [insertSql appendFormat:@"(%@) VALUES (%@)",[keyStr substringToIndex:keyStr.length -  1],[value substringToIndex:value.length -  1]];
    
    return insertSql;
}

#pragma mark - update

- (void)updateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    if (db) {
        
        [self executeForUpdateModel:newModel predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
    }else {
        
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {

            [self executeForUpdateModel:newModel predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
        }];
    }
}

- (void)executeForUpdateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    if (cascade) {
        
        NSArray *selects = [[newModel class] selectWithPredicate:predicate inTableName:tableName inDataBase:db];
        
        // Delete all relation for reset relation
        [[newModel class] deleteWithPredicate:predicate inTableName:tableName inDataBase:db completeBlock:^(BOOL success)  {
            
            // Reset model and relation
            [selects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)  {
                [newModel saveWithTableName:tableName inDataBase:db completeBlock:completion];
            }];
        }];
        
    } else { // Only update model , not update it's relation
        
        NSString *updateSql = [self updateStatementWithModel:newModel predicate:predicate inTableName:tableName];

        BOOL success = [db executeUpdate:updateSql];
        if (completion) completion(success);
    }
}

- (NSString *)updateStatementWithModel:(id)newModel predicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName {
    
    NSString *newTableName = NSStringFromClass([newModel class]);
    
    if (tableName) newTableName = tableName;
    
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"%@ %@ SET ",_update,newTableName];
    
    __block NSMutableString *value = [NSMutableString string];
    
    [[newModel class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) return ;
        if (property.type == IHFPropertyTypeModel) return ;
        
        [value appendFormat:@"%@ = ",property.propertyName];
        
        // According to property type , if is from fundation , then add '' to become text！
        NSString *format = [property.typeOfFundation boolValue] ? @"'%@',"  : @"%@,";
        [value appendFormat:format,[newModel valueWithProperty:property]];
    }];
    
    [value appendFormat:@"%@ = %d",_dirtyKey,1];
    [updateSql appendString:value];
    
    if(predicate) {
        if (predicate.predicateFormat)  {
            [updateSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    
    return updateSql;
}


- (void)updateModel:(id)newModel predicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion {
    
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"%@ %@ SET ",_update,NSStringFromClass([newModel class])];
    
    __block NSMutableString *value = [NSMutableString string];
    
    [[newModel class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) return ;
        if (property.type == IHFPropertyTypeModel) return ;
        
        [value appendFormat:@"%@ = ",property.propertyName];
        
        // According to property type , if is from fundation , then add '' to become text！
        NSString *format = [property.typeOfFundation boolValue] ? @"'%@',"  : @"%@,";
        
        [value appendFormat:format,[newModel valueWithProperty:property]];
    }];
    
    if ([value length]) {
       [updateSql appendFormat:@"%@",[value substringToIndex:value.length -  1]];
    }
    
    if(predicate) {
        if (predicate.predicateFormat) {
            [updateSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    
    [self executeUpdateWithClass:[newModel class] sqlStatement:updateSql completeBlock:completion];
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

- (void)deleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    if (db)  {
        [self executeDeleteFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
    } else {
        
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [self executeDeleteFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
        }];
    }
}

- (void)executeDeleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
    
    // selected the models you will delete ! In order to fetch the Obejct ID for Delete Relation for one-to-many and foreign key for One-to-One !
    NSArray *modelArray = [self selectFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isRecursive:NO];
    
    if ([modelArray count]) { // If not have the models you want to delete in the data base, not need to delete!
        
        NSString *deleteSql = [self deleteStatementWithClass:newClass predicate:predicate customTableName:tableName];

        BOOL success = [db executeUpdate:deleteSql];
        if (success) { // delete success ,delete ralation
            [self deleteRelationForModelArray:modelArray inDataBase:db isCascade:cascade];
        }
        if (completion) completion(success);
    }
}

// in_SqlStatement like (1,2)
- (void)deleteRelationUseIn_SqlStatement:(NSString *)in_SqlStatement forClass:(Class)aClass inDataBase:(FMDatabase *)db {
    
    NSArray <IHFProperty *>*properies = [aClass propertiesForTypeOfArray];
    __block NSString *deleteStament ;
    
    [properies enumerateObjectsUsingBlock:^(IHFProperty *_Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *tableName = [NSString stringWithFormat:@"%@_%@_Relation",NSStringFromClass(aClass),property.propertyName];
        
        deleteStament = [NSString stringWithFormat:@"delete from %@ where %@ in (%@)",tableName,@"sourceObjectID",in_SqlStatement];
        [db executeUpdate:deleteStament];
    }];
}

- (void)deleteRelationForModelArray:(NSArray<id <IHFDBObejctDataSource>> *)modelArray inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade {
    
    [modelArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[obj class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {

            if (property.type == IHFPropertyTypeArray) { // deal with array

                if (property.objectClass) {
                    
                    IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:obj destinationObject:[[property.objectClass alloc] init] relationName:property.propertyName relation:IHFRelationOneToMany];
                    id <IHFDBObejctDataSource> model = obj;
                    table.sourceObjectID = model.objectID;
                    
                    NSArray *models;
                    
                    if (cascade) { // Is cascade , get the relation models !
                        models = [table selectRelationsInDataBase:db];
                    }
                    
                    [table deleteInDataBase:db completeBlock:^(BOOL success)  { // delete relation table

                        if (cascade) { // Is cascade , Not noly delete the relation table , but also the table itself!

                            [models enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                
                                NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",_primaryKey,(long)obj.objectID];
                                IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];

                                [[obj class] deleteWithPredicate:predicate inTableName:nil inDataBase:db isCascade:YES completeBlock:nil];
                            }];
                        }
                    }];
                }
            }else if(property.type == IHFPropertyTypeModel) {
                
                if (cascade) {
                    id value = [obj valueWithProperty:property];
                    
                    NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",_primaryKey,(long)value];
                    IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];
                    [property.objectClass deleteWithPredicate:predicate inTableName:nil inDataBase:db isCascade:YES completeBlock:nil];
                }
            }
        }];
    }];
}

#pragma mark -  Execute sql statment by user

- (NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement inDataBase:(FMDatabase *)db isRecursive:(BOOL)recursive {
    
    __block NSArray *modelArray = [NSArray array];
    __weak typeof(self) weakSelf = self;
    if (db) {
        FMResultSet *rs = [db executeQuery:sqlStatement];
        modelArray = [self modelsWithClass:newClass FMResultSet:rs inDataBase:db isRecursive:recursive];
    } else {
        [_queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:sqlStatement];
            modelArray = [weakSelf modelsWithClass:newClass FMResultSet:rs inDataBase:db isRecursive:recursive];
        }];
    }
    return modelArray;
}

- (NSArray *)modelsWithClass:(Class)newClass FMResultSet:(FMResultSet *)rs inDataBase:(FMDatabase *)db isRecursive:(BOOL)recursive {
    
    NSMutableArray *models = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    while (rs.next) {
        
        NSObject <IHFDBObejctDataSource> *model = [[newClass alloc] init];
        
        // Model get the object ID and Dirty
        [model setObjectID:[rs intForColumn:_primaryKey]];
        [model setDirty:[rs intForColumn:_dirtyKey]];
        
        [[newClass class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop)  {
            
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

- (NSInteger)selectCountFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    
    NSString *selectSql = [self selectSystemColunmSqlStatementWithClass:newClass predicate:predicate customTableName:tableName];
    
    if (db) {
        FMResultSet *rs = [db executeQuery:selectSql];
        return [self countWithresultSet:rs];
    }else {
        __weak typeof(self) weakSelf = self;
        __block NSInteger count;
        [_queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:selectSql];
            count =  [weakSelf countWithresultSet:rs];
        }];
        return count;
    }
}

-(NSInteger)countWithresultSet:(FMResultSet *)rs {
    
    NSInteger count = 0;
    while (rs.next)  { count++; }
    return count;
}


- (void)setValueWithFMResult:(FMResultSet *)rs forModel:(NSObject <IHFDBObejctDataSource> *)model property:(IHFProperty *)property isRecursive:(BOOL)recursive inDataBase:(FMDatabase *)db {
    
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
                        void (*func) (id,SEL,NSArray*) = (void*)imp;
                        func(model,setSel,(NSArray *)models);
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
            case IHFPropertyTypeBOOL : {
                void (*func) (id,SEL,int) = (void *)imp;
                func(model,setSel,[rs intForColumn:key]);
            } break;
            case IHFPropertyTypeLong : {
                void (*func) (id,SEL,long) = (void *)imp;
                func(model,setSel,[rs intForColumn:key]);
            } break;
            case IHFPropertyTypeDouble : {
                void (*func) (id,SEL,double) = (void *)imp;
                func(model,setSel,[rs doubleForColumn:key]);
            } break;
            case IHFPropertyTypeFloat : {
                void (*func) (id,SEL,float) = (void *)imp;
                func(model,setSel,[rs doubleForColumn:key]);
            } break;
            case IHFPropertyTypeData :
            case IHFPropertyTypeImage : {
                void (*func) (id,SEL,NSData *) = (void *)imp;
                func(model,setSel,[rs dataForColumn:key]);
            } break;
            case IHFPropertyTypeString : {
                void (*func) (id,SEL,NSString *) = (void *)imp;
                func(model,setSel,[rs stringForColumn:key]);
            } break;
            case IHFPropertyTypeNumber : {
                NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
                NSNumber *value = [format numberFromString:(NSString *)[rs stringForColumn:key]];
    
                void (*func) (id,SEL,NSNumber*) = (void*)imp;
                func(model,setSel,value);
            } break;
                
            default:
                break;
        }
    }
}

// for all
- (BOOL)executeUpdateWithClass:(Class)newClass sqlStatements:(NSArray <NSString *>*)sqlStatements completeBlock:(IHFDBCompleteBlock)completion useTransaction:(BOOL)useTransaction {
    
    __block BOOL result = YES;

    if(useTransaction) { // If execute update fail , it will be roll back
        
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            [sqlStatements enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BOOL success = [db executeUpdate:obj];
                
                if (!success)  {
                    if(completion) completion(success);
                    result = NO;
                    *stop = YES;
                    *rollback = YES; // roll back
                }
            }];
            
            if (result) {
                if(completion) completion(YES);
            }
         }];
    } else {
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            [sqlStatements enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BOOL success = [db executeUpdate:obj];
                
                if (!success) {
                    if(completion) completion(success);
                    result = NO;
                    *stop = YES;
                }
            }];
            
            if (result) {
                if(completion) completion(YES);
            }
        }];
    }
    
    return result;
}

#pragma mark -  delete dirty data
- (void)deleteDirtyDataFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion {
        
    // To get resetDirtySql first!
    NSString *resetDirtySql = [self resetDirtySqlStatementWithClass:newClass customTableName:tableName predicate:predicate];
    
    NSString *dirtyStr = [NSString stringWithFormat:@"%@ = 0",_dirtyKey];
    IHFPredicate *dirtyPredicate = [IHFPredicate predicateWithString:dirtyStr];
    [predicate appendAnd_Predicate:dirtyPredicate];
    
    // select sql where dirty = 0
    NSString *selectedStatment = [self selectSystemColunmSqlStatementWithClass:newClass predicate:predicate customTableName:tableName];

    if (db) {
    
        FMResultSet *rs = [db executeQuery:selectedStatment];
        
        NSMutableString *inSqlStatement = [NSMutableString string];
        
        while (rs.next) {
            [inSqlStatement appendFormat:@"%ld,",(long)[rs intForColumn:_primaryKey]];
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
            [db executeUpdate:resetDirtySql];
        }
        
    } else {
        __weak typeof(self) weakSelf = self;
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            FMResultSet *rs = [db executeQuery:selectedStatment];
            
            NSMutableString *inSqlStatement = [NSMutableString string];
            while (rs.next) {
                [inSqlStatement appendFormat:@"%ld,",(long)[rs intForColumn:_primaryKey]];
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
                [db executeUpdate:resetDirtySql];
            }
        }];
    }
}

- (NSString *)resetDirtySqlStatementWithClass:(Class)newClass customTableName:(NSString *)tableName predicate:(IHFPredicate *)predicate {

    NSString *newTableName = NSStringFromClass(newClass);
    if (tableName) newTableName = tableName;
    
    // Reset dirty data
    NSMutableString *resetDirtySqlStatement = [NSMutableString stringWithFormat:@"%@ %@ SET %@ = 0" ,_update,newTableName,_dirtyKey];
    
    if(predicate) {
        if (predicate.predicateFormat) {
            [resetDirtySqlStatement appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    return resetDirtySqlStatement;
}


#pragma mark -  support tool


- (BOOL)isTableExistWithTableName:(NSString *)tableName inDatabase:(FMDatabase *)db {

    if (db) return [db tableExists:tableName];

    __block BOOL isExist ;

    [_queue inDatabase:^(FMDatabase *db) {
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

- (NSInteger)maxObjectIDIntableName:(NSString *)tableName inDataBase:(FMDatabase *)db {
    
    NSInteger maxObjectID = 0;
    NSString *selectMaxIDSQL =  [NSString stringWithFormat:@"Select seq From sqlite_sequence Where name = '%@'",tableName];
    
    FMResultSet *rs = [db executeQuery:selectMaxIDSQL];
    
    while (rs.next) {
        maxObjectID = [rs intForColumnIndex:0];
    }
    return maxObjectID;
}
@end
