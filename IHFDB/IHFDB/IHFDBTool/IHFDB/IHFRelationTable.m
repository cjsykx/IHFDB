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

+ (instancetype)relationTableWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation {
    return [[self alloc] initWithSourceObject:sourceObject destinationObject:destinationObject relationName:relationName relation:relation];
}

- (NSString *)tableName {
    if (self.sourceObject && self.relationName) {
        return [NSString stringWithFormat:@"%@_%@_Relation",NSStringFromClass([self.sourceObject class]),self.relationName];
    }
    return nil;
}

+ (NSArray *)propertyNamesForIgnore {
    return @[@"sourceObject",@"destinationObject",@"relationName",@"relation"];
}

// create
- (void)createInDataBase:(IHFDatabase *)db {
    [self createInDataBase:db completeBlock:nil];
}

- (void)createInDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    [[self class] createTableWithName:[self tableName] inDataBase:db CompleteBlock:completion];
}

- (void)saveInDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    [[self class] saveModelArray:[NSArray arrayWithObject:self] inDataBase:db];
}

- (void)saveInDataBase:(IHFDatabase *)db {
    [self saveInDataBase:db completeBlock:nil];
}

+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    if (![modelArray count]) return;
    
    id relationTable = [modelArray firstObject];
    if (![relationTable isKindOfClass:[IHFRelationTable class]]) return;
    IHFRelationTable *table = relationTable;
    // select to judge if exist in db , void insert the same relation
    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld AND destinationObjectID = %ld",(long)table.sourceObjectID,(long)table.destinationObjectID];
    NSArray *relations = [[self class] selectWithPredicate:predicate fromTable:[table tableName] inDataBase:db];

    if (![relations count]) {
        [[IHFDataBaseExecute shareDataBaseExecute] insertIntoClassWithModelArray:modelArray fromTable:[relationTable tableName] inDataBase:db completeBlock:completion];
    }
}

+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(IHFDatabase *)db {
    [self saveModelArray:modelArray inDataBase:db completeBlock:nil];
}

// Fetch the relation models
- (NSArray *)selectRelationsInDataBase:(IHFDatabase *)db {
    
    __block NSMutableArray *selectArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    if (self.relation == IHFRelationOneToOne) {
        NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",IHFDBPrimaryKey,(long)self.destinationObjectID];
        IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];
        
        NSArray *relationModels = [[weakSelf.destinationObject class] selectWithPredicate:predicate fromTable:nil inDataBase:db];
        if ([relationModels count]) { // If have count , because predicate is ObjectID , so there is only one object!
            NSObject *object = [relationModels lastObject];
            if (self.sourceObject) {
                [object setParentObject:self.sourceObject];
            }
            [selectArray addObject:object];
        }
    } else if (self.relation == IHFRelationOneToMany) {
        // Fetch the Object ID in relation table
        IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld",(long)self.sourceObjectID];
        NSArray *relations = [[self class] selectWithPredicate:predicate fromTable:[self tableName] inDataBase:db];
        [relations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (![obj isKindOfClass:[IHFRelationTable class]]) return ;
            
            IHFRelationTable *table = obj;
            NSString *predicateStr = [NSString stringWithFormat:@"%@ = %ld",IHFDBPrimaryKey,(long)table.destinationObjectID];
            IHFPredicate *predicate = [IHFPredicate predicateWithString:predicateStr];

            // run loop!
            NSArray *relationModels = [[weakSelf.destinationObject class] selectWithPredicate:predicate fromTable:nil inDataBase:db];
            if ([relationModels count]) { // If have count , because predicate is ObjectID , so there is only one object!
                NSObject *object = [relationModels lastObject];
                if (self.sourceObject) {
                    [object setParentObject:self.sourceObject];
                }
                [selectArray addObject:object];
            }
        }];
    }
    return selectArray;
}

- (void)deleteInDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion {
    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld",(long)self.sourceObjectID];
    [[self class] deleteWithPredicate:predicate fromTable:[self tableName] inDataBase:db completeBlock:^(BOOL success,IHFDatabase *db) {
        if(completion) completion(success,db);
    }];
}
@end
