//
//  IHFRelationTable.m
//  IHFDB
//
//  Created by CjSon on 16/6/27.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFRelationTable.h"
#import <objc/runtime.h>

@implementation IHFRelationTable

- (instancetype)initWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation{
    self = [super init];
    if (self) {
        self.sourceObject = sourceObject;
        self.destinationObject = destinationObject;
        self.relationName = relationName;
        self.relation = relation;
    }
    return self;
}

+ (instancetype)relationTableWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation{
    return [[self alloc] initWithSourceObject:sourceObject destinationObject:destinationObject relationName:relationName relation:relation];
}

- (NSString *)tableName{
    
    if (self.sourceObject && self.destinationObject) {
        
        return [NSString stringWithFormat:@"%@_%@_Relation",NSStringFromClass([self.sourceObject class]),self.relationName];
    }
    return nil;
}

+ (NSArray *)propertyNamesForIgnore{
    return @[@"sourceObject",@"destinationObject",@"relationName",@"relation"];
}

// create
- (void)createInDataBase:(FMDatabase *)db{
    [self createInDataBase:db completeBlock:nil];
}

- (void)createInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    [[self class] createTableWithName:[self tableName] inDataBase:db CompleteBlock:completion];
}

- (void)saveInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    [self saveWithTableName:[self tableName] inDataBase:db completeBlock:completion];
}
- (void)saveInDataBase:(FMDatabase *)db{
    [self saveInDataBase:db completeBlock:nil];
}

+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    if (![modelArray count]) return;
    
    id relationTable = [modelArray firstObject];
    if (![relationTable isKindOfClass:[IHFRelationTable class]]) return;
    
    [self saveModelArray:modelArray inTableName:[relationTable tableName] inDataBase:db completeBlock:completion];
}

+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(FMDatabase *)db{
    [self saveModelArray:modelArray inDataBase:db completeBlock:nil];
}

// Fetch the relation models
- (NSArray *)selectRelationsInDataBase:(FMDatabase *)db{
    
    __block NSMutableArray *selectArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    if (self.relation == IHFRelationOneToOne) {
    
        NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",_primaryKey,(long)self.destinationObjectID];
        IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];
        
        NSArray *relationModels = [[weakSelf.destinationObject class] selectWithPredicate:predicate inTableName:nil inDataBase:db];
        if ([relationModels count]) { // If have count , because predicate is ObjectID , so there is only one object!
            [selectArray addObject:[relationModels lastObject]];
        }
    }else if(self.relation == IHFRelationOneToMany){
    
        // Fetch the Object ID in relation table
        IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld",(long)self.sourceObjectID];
        NSArray *relations = [[self class] selectWithPredicate:predicate inTableName:[self tableName] inDataBase:db];
        
        [relations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (![obj isKindOfClass:[IHFRelationTable class]]) return ;
            
            IHFRelationTable *table = obj;
            NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",_primaryKey,(long)table.destinationObjectID];
            IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];

            // run loop!
            NSArray *relationModels = [[weakSelf.destinationObject class] selectWithPredicate:predicate inTableName:nil inDataBase:db];
            if ([relationModels count]) { // If have count , because predicate is ObjectID , so there is only one object!
                [selectArray addObject:[relationModels lastObject]];
            }
        }];
    }
    
    return selectArray;
}

- (void)deleteInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld",(long)self.sourceObjectID];
    
    [[self class] deleteWithPredicate:predicate inTableName:[self tableName] inDataBase:db completeBlock:^(BOOL success) {
        if(completion) completion(success);
    }];
}
@end
