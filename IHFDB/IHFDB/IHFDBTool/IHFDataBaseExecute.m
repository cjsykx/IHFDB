//
//  IHFDataBaseExecute.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFDataBaseExecute.h"
#import "FMDB.h"

// sql statement

// create
static NSString *_createTable = @"create table if not exists";

static NSString *_primaryKey = @"ObjectID";

// select
static NSString *_select = @"SELECT * FROM";

// insert
static NSString *_insert = @"INSERT INTO";

// update
static NSString *_update = @"UPDATE";

// delete 
static NSString *_delete = @"DELETE FROM";


static FMDatabaseQueue *_queue; /**< main queue */

@implementation IHFDataBaseExecute

#pragma mark - init the sqlite name
-(instancetype)initWithSqliteName:(NSString *)SqliteName{
    self = [super init];
    
    if (self) {
        self.sqliteName = SqliteName;
    }
    return self;
}

+(instancetype)dataBaseWithSqliteName:(NSString *)SqliteName{
    return [[self alloc] initWithSqliteName:SqliteName];
}

-(void)setSqliteName:(NSString *)sqliteName{
    
    _sqliteName = sqliteName;
    
    // create FMDatabaseQueue
    NSString *dataBasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:sqliteName];
    
    NSLog(@"dataBasePath = %@",dataBasePath);
    
    _queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
}

#pragma mark - data base operation

// create
-(BOOL)createTableWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
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


-(NSString *)createSqlStatementWithClass:(Class)newClass customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    
    NSString *newTableName = NSStringFromClass(newClass);
    
    if (tableName) newTableName = tableName;
    
    // Judge the data base is exist the table
    if ([self isTableExistWithTableName:newTableName inDatabase:db]) return nil;
    
    NSMutableString *createTableSql = [NSMutableString stringWithFormat:@"%@ %@ ",_createTable,newTableName];
    
    // append primary Key
    NSString *primaryKeySql = [NSString stringWithFormat:@"(%@ integer primary key autoincrement,",_primaryKey];
    
    [createTableSql appendString:primaryKeySql];
    
    [newClass enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) { // deal with array
            
            // Fetch the model contained in the array , to create table
            
            if ([newClass respondsToSelector:@selector(relationshipDictForClassInArray)]) {
                NSDictionary *relationshipDict = [newClass relationshipDictForClassInArray];
                
                Class theClass = [relationshipDict objectForKey:property.propertyName];
                if ([NSStringFromClass(theClass) isEqualToString:newTableName]) return ;
                [self createTableWithClass:theClass customTableName:nil inDataBase:db completeBlock:nil];
            }
            
        }else if (property.type == IHFPropertyTypeModel){ // deal with model
            
            if ([property.typeString isEqualToString:newTableName]) return ;
            
             [self createTableWithClass:NSClassFromString(property.typeString) customTableName:nil inDataBase:db completeBlock:nil];

        }else{
            NSString *colum = [NSString stringWithFormat:@"%@ %@,",property.propertyName,[self sqlTypeNameWithTypeName:property.typeString]];
            [createTableSql appendString:colum];
        }
    }];
    
    // delete last ','
    [createTableSql deleteCharactersInRange:NSMakeRange(createTableSql.length - 1, 1)];
    [createTableSql appendString:@");"];
    return createTableSql;
}

-(void)createTableWithClass:(Class)newClass completeBlock:(IHFDBCompleteBlock)completion{
    [self createTableWithClass:newClass customTableName:nil inDataBase:nil completeBlock:completion];
}

// insert

-(NSArray<id<IHFDBObejctDataSource>> *)selectFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    
    NSString *newTableName = NSStringFromClass(newClass);
    
    if (tableName) newTableName = tableName;
    
    NSMutableString *selectSql = [NSMutableString stringWithFormat:@"%@ %@ ",_select,newTableName];
    
    if(predicate){
        if (predicate.predicateFormat) {
            [selectSql appendFormat:@"WHERE %@",predicate.predicateFormat];
        }
        
        if (predicate.orderBy) {
            [selectSql appendFormat:@"ORDER BY %@",predicate.orderBy];
        }
    }
    
    NSLog(@"predicate = %@",selectSql);
    return [self executeQueryWithClass:newClass sqlStatement:selectSql inDataBase:db];
}


-(void)enumerateSourceObject:(IHFRelationTable *)relation inDataBase:(FMDatabase *)db rollBack:(BOOL *)rollBack{
    
//    [relationTables enumerateObjectsUsingBlock:^(IHFRelationTable<IHFDBObejctDataSource> * _Nonnull relation, NSUInteger idx, BOOL * _Nonnull stop) {
    
        // The blcok call back when a model insert success , and the block in order to create the relation table !
        // So when call back the block , table's destinationObject become source obejct !
        id sourceObject = relation.destinationObject;
    
        [[sourceObject class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            if (property.type == IHFPropertyTypeArray) {
                
                id modelArray = [sourceObject getValueWithPropertName:property.propertyName];
                
                NSMutableArray *muModels = [NSMutableArray array];
                [modelArray enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:sourceObject destinationObject:obj relation:IHFRelationOneToMany];
                    relationTable.sourceObjectID = relation.destinationObjectID;
                
                    [muModels addObject:relationTable];
                }];
                
                [self executeUpdateWithModels:muModels useTransaction:YES inTableName:nil inDataBase:db rollback:rollBack updateCompletion:^(BOOL success, IHFRelationTable *relationTable, FMDatabase *db, BOOL *rollback) {
                    
                    [self enumerateSourceObject:relationTable inDataBase:db rollBack:rollBack];
                }];
                }else if (property.type == IHFPropertyTypeModel){
                
                id model = [sourceObject getValueWithPropertName:property.propertyName];
                if (!model) return ;
                
                IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:sourceObject destinationObject:model relation:IHFRelationOneToOne];

                relationTable.sourceObjectID = relation.destinationObjectID;
                
                [self executeUpdateWithModels:@[relationTable] useTransaction:YES inTableName:nil inDataBase:db rollback:rollBack updateCompletion:^(BOOL success, IHFRelationTable *relationTable, FMDatabase *db, BOOL *rollback) {
                    
                    [self enumerateSourceObject:relationTable inDataBase:db rollBack:rollBack];
                }];
            }
        }];
}


// insert

-(BOOL)insertIntoClassWithModel:(id)newModel inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    return [self insertIntoClassWithModelArray:[NSArray arrayWithObject:newModel] inTableName:tableName inDataBase:db completeBlock:completion];
}

-(BOOL)insertIntoClassWithModelArray:(NSArray *)ModelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    __block NSMutableArray *relationTableArray = [NSMutableArray array];
    
    // Model array change into relation table array
    [ModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        IHFRelationTable *relation = [[IHFRelationTable alloc] initWithSourceObject:nil destinationObject:obj relation:IHFRelationNone];
        [relationTableArray addObject:relation];
    }];
    
    BOOL rollBack = NO;
    
    return [self executeUpdateWithModels:relationTableArray useTransaction:YES inTableName:tableName inDataBase:db rollback:&rollBack updateCompletion:^(BOOL success, IHFRelationTable *relationTable, FMDatabase *db, BOOL *rollback) {
        
        [self enumerateSourceObject:relationTable inDataBase:db rollBack:rollback];
        
        if (completion) completion(success);
    }];
}

-(BOOL)executeUpdateModelArray:(NSArray<IHFRelationTable *> *)modelArray inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    
    // TODO: insert the ralation model!
    
    __block BOOL success = YES;
    [modelArray enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *sqlStatement = [self insertStatementWithModel:obj.destinationObject inTableName:tableName];

        BOOL success1 = [db executeUpdate:sqlStatement];
        
        if (!success1) {
            success = NO;
        }
    }];
    return success;
}

// For insert
-(BOOL)executeUpdateWithModels:(NSArray <IHFRelationTable *>*)newModels useTransaction:(BOOL)useTransaction inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db rollback:(BOOL *)rollBack updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion{
    
    __block BOOL result = YES;

    if (db) {
        
        result = [self insertModels:newModels inTableName:tableName inDataBase:db rollback:rollBack updateCompletion:updateCompletion];
    }else{
        
         [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            result = [self insertModels:newModels inTableName:tableName inDataBase:db rollback:rollBack updateCompletion:updateCompletion];
        }];
    }
    return result;
}

-(BOOL)insertModels:(NSArray <IHFRelationTable *>*)newModels inTableName:(NSString *)tableName inDataBase:(FMDatabase *)db rollback:(BOOL *)rollback updateCompletion:(IHFDBUpdateCompleteBlock)updateCompletion{
    
    __block BOOL result = YES;

    [newModels enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *sqlStatement ;
        
        if (!obj.sourceObject) { // The model on the front , create table
            [[obj.destinationObject class] createTableWithName:tableName inDataBase:db CompleteBlock:nil];
        }
        
        if (obj.destinationObject) {
            sqlStatement = [self insertStatementWithModel:obj.destinationObject inTableName:tableName];
        }
        
        // Insert the destinationObject!
        BOOL success = [db executeUpdate:sqlStatement];
        
        if (success) {
            
            NSString *selectTableName = NSStringFromClass([obj.destinationObject class]);
            
            if (!obj.sourceObject && tableName) {  // If is super model , else sub model insert table name still is its class name!
                selectTableName = tableName;
            }
            
            // Fetch maxID after the object insert success!
            obj.destinationObjectID = [self maxObjectIDIntableName:selectTableName inDataBase:db];
            
            updateCompletion(success,obj,db,rollback);

            if (obj.sourceObject) { // Have source , it need create relation table !
                
                [obj createInDataBase:db completeBlock:^(BOOL success) {
                    
                    if(success){
                        
                        // Insert ID in relation table
                        [obj saveInDataBase:db completeBlock:^(BOOL success) {
                            
                            if (!success) {
                                *rollback = YES;
                                *stop = YES;
                                result = NO;
                            }
                            
                        }];
                        
                    }else{
                        *rollback = YES;
                        *stop = YES;
                        result = NO;
                    }
                }];
            }
            
        }else{
            *rollback = YES;
            *stop = YES;
            result = NO;
        }
    }];

    return result;
    
}

// roll back reason .
-(NSArray <IHFRelationTable *>*)relationTableWithInsertIntoModelArray:(NSArray *)newModels InDataBase:(FMDatabase *)db inTableName:(NSString *)tableName{
    
//    [newModels enumerateObjectsUsingBlock:^(IHFRelationTable * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        NSString *sqlStatement ;
//
//        if (!obj.sourceObject) { // The model on the front , create table
//            [[obj.destinationObject class] createTableWithName:tableName inDataBase:db CompleteBlock:nil];
//        }
//        
//        if (obj.destinationObject) {
//            sqlStatement = [self insertStatementWithModel:obj.destinationObject inTableName:tableName];
//        }
//        
//        // Insert the destinationObject!
//        BOOL success = [db executeUpdate:sqlStatement];
//        
//        if (success) {
//            
//            NSString *selectTableName = NSStringFromClass([obj.destinationObject class]);
//            
//            if (!obj.sourceObject && tableName) {  // If is super model , else sub model insert table name still is its class name!
//                selectTableName = tableName;
//            }
//            
//            // Fetch maxID after the object insert success!
//            obj.destinationObjectID = [self maxObjectIDIntableName:selectTableName inDataBase:db];
//            
//            if (obj.sourceObject) { // Have source , it need create relation table !
//                NSLog(@"%@",@"need create relation table");
//                NSLog(@"sourceObjectID = %d",obj.sourceObjectID);
//                NSLog(@"%@",NSStringFromClass([obj.sourceObject class]));
//                NSLog(@"%@",NSStringFromClass([obj.destinationObject class]));
//                
//                [obj createInDataBase:db completeBlock:^(BOOL success) {
//                    
//                    if(success){
//                        
//                        // Insert ID in relation table
//                        [obj saveDidCompleteBlock:^(BOOL success) {
//                            
//                            if (!success) {
//                                *rollback = YES;
//                                *stop = YES;
//                                success = NO;
//                            }
//                        }];
//                        
//                    }else{
//                        *rollback = YES;
//                        *stop = YES;
//                        success = NO;
//                    }
//                }];
//            }
//            
//            [muModels addObject:obj];
//        }else{
//            *rollback = YES;
//            *stop = YES;
//            success = NO;
//        }
//    }];
//    
    return [NSArray array];

}

-(NSString *)insertStatementWithModel:(id)newModel inTableName:(NSString *)tableName{
    
    NSString *insertTableName = NSStringFromClass([newModel class]);
    if (tableName) insertTableName = tableName;
    
    NSMutableString *insertSql = [NSMutableString stringWithFormat:@"%@ %@ ",_insert,insertTableName];
    
    __block NSMutableString *keyStr = [NSMutableString string];
    __block NSMutableString *value = [NSMutableString string];
    
    [[newModel class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        // TODO: Will use transaction
        
        if (property.type == IHFPropertyTypeArray) return ;
        if (property.type == IHFPropertyTypeModel) return ;

        
        [keyStr appendFormat:@"%@,",property.propertyName];
            
        // According to property type , if is from fundation , then add '' to become text！
        NSString *format = property.isTypeOfFundation ? @"'%@',"  : @"%@,";
            
        [value appendFormat:format,[newModel getValueWithPropertName:property.propertyName]];
        
    }];
    
    if ([keyStr length]) {
        [insertSql appendFormat:@"(%@) VALUES (%@)",[keyStr substringToIndex:keyStr.length - 1],[value substringToIndex:value.length - 1]];
    }
    return insertSql;
}

// update

-(void)updateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    
    if (db) {
        
        [self executeForUpdateModel:newModel predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
    }else{
        [self executeForUpdateModel:newModel predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];

    }
}

-(void)executeForUpdateModel:(id)newModel predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    
    if (cascade) {
        
        NSArray *selects = [[newModel class] selectWithPredicate:predicate inTableName:tableName inDataBase:db];
        
        // Delete all relation for reset relation
        [[newModel class] deleteWithPredicate:predicate inTableName:tableName inDataBase:db completeBlock:^(BOOL success) {
            
            // Reset model and relation
            [selects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [newModel saveWithTableName:tableName inDataBase:db completeBlock:completion];
            }];
        }];
        
    }else{ // Only uodate model , not update it's relation
        
        NSString *updateSql = [self updateStatementWithModel:newModel predicate:predicate inTableName:tableName];

        BOOL success = [db executeUpdate:updateSql];
        if (completion) completion(success);
    }
}

-(NSString *)updateStatementWithModel:(id)newModel predicate:(IHFPredicate *)predicate inTableName:(NSString *)tableName{
    
    NSString *newTableName = NSStringFromClass([newModel class]);
    
    if (tableName) newTableName = tableName;
    
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"%@ %@ SET ",_update,newTableName];
    
    __block NSMutableString *value = [NSMutableString string];
    
    [[newModel class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) return ;
        if (property.type == IHFPropertyTypeModel) return ;
        
        
        [value appendFormat:@"%@ = ",property.propertyName];
        
        // According to property type , if is from fundation , then add '' to become text！
        NSString *format = property.isTypeOfFundation ? @"'%@',"  : @"%@,";
        
        [value appendFormat:format,[newModel getValueWithPropertName:property.propertyName]];
    }];
    
    if ([value length]) {
        [updateSql appendFormat:@"%@",[value substringToIndex:value.length - 1]];
    }
    
    if(predicate){
        if (predicate.predicateFormat) {
            [updateSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    
    return updateSql;
}


-(void) updateModel:(id)newModel predicate:(IHFPredicate *)predicate completeBlock:(IHFDBCompleteBlock)completion{
    
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"%@ %@ SET ",_update,NSStringFromClass([newModel class])];
    
    __block NSMutableString *value = [NSMutableString string];
    
    [[newModel class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray) return ;
        if (property.type == IHFPropertyTypeModel) return ;

        
        [value appendFormat:@"%@ = ",property.propertyName];
        
        // According to property type , if is from fundation , then add '' to become text！
        NSString *format = property.isTypeOfFundation ? @"'%@',"  : @"%@,";
        
        [value appendFormat:format,[newModel getValueWithPropertName:property.propertyName]];
    }];
    
    if ([value length]) {
       [updateSql appendFormat:@"%@",[value substringToIndex:value.length - 1]];
    }
    
    if(predicate){
        if (predicate.predicateFormat) {
            [updateSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    
    [self executeUpdateWithClass:[newModel class] sqlStatement:updateSql completeBlock:completion];
}

-(NSString *)deleteStatementWithClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName{
    
    NSString *deleteTableName = NSStringFromClass(newClass);
    if (tableName) deleteTableName = tableName;
    
    
    NSMutableString *deleteSql = [NSMutableString stringWithFormat:@"%@ %@",_delete,deleteTableName];
    
    if(predicate){
        if (predicate.predicateFormat) {
            [deleteSql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    
    NSLog(@"deleteSql = %@",deleteSql);
    return deleteSql;
}

// delete
-(void)deleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    
    if (db) {
        [self executeDeleteFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
        
    }else{
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            [self executeDeleteFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db isCascade:cascade completeBlock:completion];
            
        }];
    }
}

-(void)executeDeleteFromClass:(Class)newClass predicate:(IHFPredicate *)predicate customTableName:(NSString *)tableName inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{
    
    NSString *deleteSql = [self deleteStatementWithClass:newClass predicate:predicate customTableName:tableName];
    
    // selected
    NSArray *modelArray = [self selectFromClass:newClass predicate:predicate customTableName:tableName inDataBase:db];
    
    if ([modelArray count]) {
        BOOL success = [db executeUpdate:deleteSql];
        
        if (success) { // delete success ,delete ralation
            [self deleteRelationForModelArray:modelArray inDataBase:db isCascade:cascade];
            
        }
        
        if (completion) completion(success);
    }
}

-(void)deleteRelationForModelArray:(NSArray<id <IHFDBObejctDataSource>> *)modelArray inDataBase:(FMDatabase *)db isCascade:(BOOL)cascade{
    
    [modelArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[obj class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {

            if (property.type == IHFPropertyTypeArray) { // deal with array

                if ([[obj class] respondsToSelector:@selector(relationshipDictForClassInArray)]) {
                    NSDictionary *relationshipDict = [[obj class] relationshipDictForClassInArray];

                    Class theClass = [relationshipDict objectForKey:property.propertyName];

                    IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:obj destinationObject:[[theClass alloc] init] relation:IHFRelationOneToMany];
                    id <IHFDBObejctDataSource> model = obj;
                    table.sourceObjectID = model.objectID;
                    NSArray *models = [table selectRelationsInDataBase:db];
                    
                    [table deleteInDataBase:db completeBlock:^(BOOL success) {

                        if (cascade) { // is cascade , Not noly delete the relation table , but also the table itself!

                            [models enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                                IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"ObjectID = %d",obj.objectID];
                                
                                [[obj class] deleteWithPredicate:predicate inTableName:nil inDataBase:db isCascade:YES completeBlock:nil];
                            }];
                            
                            // delete the relation of myselef use run loop
                            [self deleteRelationForModelArray:models inDataBase:db isCascade:cascade];
                        }
                    }];
                }
            }else if(property.type == IHFPropertyTypeModel){
                
                id model = [obj getValueWithPropertName:property.propertyName];
                if (!model) return ;
                
                IHFRelationTable *relationTable = [[IHFRelationTable alloc] initWithSourceObject:obj destinationObject:model relation:IHFRelationOneToOne];
                
                id <IHFDBObejctDataSource> model1 = obj;
                relationTable.sourceObjectID = model1.objectID;
                
                NSArray *models = [relationTable selectRelationsInDataBase:db];
                
                [relationTable deleteInDataBase:db completeBlock:^(BOOL success) {
                    
                    if (cascade) { // is cascade , Not noly delete the relation table , but also the table itself!
                        
                        [models enumerateObjectsUsingBlock:^(id <IHFDBObejctDataSource> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"ObjectID = %d",obj.objectID];
                            
                            [[obj class] deleteWithPredicate:predicate inTableName:nil inDataBase:db isCascade:YES completeBlock:nil];
                        }];
                        
                        // delete the relation of myselef use run loop
                        [self deleteRelationForModelArray:models inDataBase:db isCascade:cascade];
                    }
                }];


            }
        }];
    }];
}

// Execute sql statment by user
-(NSArray<id<IHFDBObejctDataSource>> *)executeQueryWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement inDataBase:(FMDatabase *)db{
    
    __block NSArray *modelArray = [NSArray array];
    __weak typeof(self) weakSelf = self;

    if (db) {
        
        FMResultSet *rs = [db executeQuery:sqlStatement];
        modelArray = [self modelsWithClass:newClass FMResultSet:rs inDataBase:db];
        
    }else{
        [_queue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *rs = [db executeQuery:sqlStatement];
            modelArray = [weakSelf modelsWithClass:newClass FMResultSet:rs inDataBase:db];
        }];

    }
    
    return modelArray;
}

-(NSArray *)modelsWithClass:(Class)newClass FMResultSet:(FMResultSet *)rs inDataBase:(FMDatabase *)db{
    
    NSMutableArray *models = [NSMutableArray array];
    
    while (rs.next) {
        
        NSObject <IHFDBObejctDataSource> *model = [[newClass alloc] init];
        
        [model setObjectID:[rs intForColumn:@"ObjectID"]];
        
        [[newClass class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            IHFPropertyType type = property.type;
            NSString *key = property.propertyName;
            
            if (type == IHFPropertyTypeString || type == IHFPropertyTypeNumber) {
                
                [model setValue:[rs stringForColumn:key] propertyName:property.propertyName propertyType:property.typeString];
                
            }else if (property.type == IHFPropertyTypeInt || property.type == IHFPropertyTypeBOOL || property.type == IHFPropertyTypeLong){
                
                [model setValue:@([rs intForColumn:key]) propertyName:property.propertyName propertyType:property.typeString];
                
            }else if (property.type == IHFPropertyTypeFloat){
                
                [model setValue:@([rs doubleForColumn:key]) propertyName:property.propertyName propertyType:property.typeString];
                
            }else if (property.type == IHFPropertyTypeDouble){
                
                [model setValue:@([rs doubleForColumn:key]) propertyName:property.propertyName propertyType:property.typeString];
            }else if (property.type == IHFPropertyTypeData || property.type == IHFPropertyTypeImage){
                
                [model setValue:[rs dataForColumn:key] propertyName:property.propertyName propertyType:property.typeString];
                
            }else if (type == IHFPropertyTypeDate){
                NSString *dateString = [rs stringForColumn:key];
                if(dateString && [dateString length] >= 19){
                    NSString *dateStr = [[rs stringForColumn:key] substringToIndex:19];
                    [model setValue:[[self convertDateString:dateStr] dateByAddingTimeInterval:8 * 60 * 60] propertyName:property.propertyName propertyType:property.typeString];
                }
            }else if (property.type == IHFPropertyTypeArray) { // deal with array
                
                // Fetch the model contained in the array , to select the relation table
                
                if ([newClass respondsToSelector:@selector(relationshipDictForClassInArray)]) {
                    NSDictionary *relationshipDict = [newClass relationshipDictForClassInArray];
                    
                    Class theClass = [relationshipDict objectForKey:property.propertyName];
                    
                    IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:model destinationObject:[[theClass alloc] init] relation:IHFRelationOneToMany];
                    table.sourceObjectID = model.objectID;
                    NSArray *models = [table selectRelationsInDataBase:db];
                    
                    [model setValue:models propertyName:property.propertyName propertyType:property.typeString];
                }
                
            }else if (property.type == IHFPropertyTypeModel){ // deal with model
                
                Class theClass = NSClassFromString(property.typeString);
                IHFRelationTable *table = [[IHFRelationTable alloc] initWithSourceObject:model destinationObject:[[theClass alloc] init]relation:IHFRelationOneToOne];
                table.sourceObjectID = model.objectID;
                NSArray *models = [table selectRelationsInDataBase:db];
                
                if ([models count]) {
                    [model setValue:[models firstObject] propertyName:property.propertyName propertyType:property.typeString];
                }
            }
            
        }];
        
        [models addObject:model];
    }

    return models;
}

-(BOOL)executeUpdateWithClass:(Class)newClass sqlStatement:(NSString *)sqlStatement completeBlock:(IHFDBCompleteBlock)completion{
    // update a single sqlStatement not need useTransaction!
    return [self executeUpdateWithClass:newClass sqlStatements:[NSArray arrayWithObject:sqlStatement] completeBlock:completion useTransaction:NO];
}


// for all
-(BOOL)executeUpdateWithClass:(Class)newClass sqlStatements:(NSArray <NSString *>*)sqlStatements completeBlock:(IHFDBCompleteBlock)completion useTransaction:(BOOL)useTransaction{
    
    __block BOOL result = YES;

    if(useTransaction){ // If execute update fail , it will be roll back
        
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            [sqlStatements enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BOOL success = [db executeUpdate:obj];
                
                if (!success) {
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
    }else{
        
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

#pragma mark - support tool


-(BOOL)isTableExistWithTableName:(NSString *)tableName inDatabase:(FMDatabase *)db{

    if (db) return [db tableExists:tableName];

    __block BOOL isExist ;

    [_queue inDatabase:^(FMDatabase *db) {
        isExist = [db tableExists:tableName];
    }];
    
    return isExist;
}


-(NSString *)convertDate:(NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return  [dateFormat stringFromDate:date];
}

-(NSDate *)convertDateString:(NSString *)dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat dateFromString:dateString];
}


-(NSInteger)maxObjectIDIntableName:(NSString *)tableName inDataBase:(FMDatabase *)db{
    
    NSInteger maxObjectID = 0;
    
    NSString *selectMaxIDSQL =  [NSString stringWithFormat:@"Select seq From sqlite_sequence Where name = '%@'",tableName];
    
    FMResultSet *rs = [db executeQuery:selectMaxIDSQL];
    
    while (rs.next) {
        maxObjectID = [rs intForColumnIndex:0];
    }
    return maxObjectID;
}

@end
