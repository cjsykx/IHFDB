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

-(instancetype)initWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject relation:(IHFRelation)relation{
    self = [super init];
    if (self) {
        self.sourceObject = sourceObject;
        self.destinationObject = destinationObject;
        self.relation = relation;
    }
    return self;
}

+(instancetype)relationTableWithSourceObject:(id)sourceObject destinationObject:(id)destinationObject relation:(IHFRelation)relation{
    return [[self alloc] initWithSourceObject:sourceObject destinationObject:destinationObject relation:relation];
}

-(NSString *)tableName{
    
    if (self.sourceObject && self.destinationObject) {
        
        NSString *relation = @"toOne";
        
        if (self.relation == IHFRelationOneToMany) {
            relation = @"toMany";
        }
        
        return [NSString stringWithFormat:@"%@_%@_%@",NSStringFromClass([self.sourceObject class]),NSStringFromClass([self.destinationObject class]),relation];
    }
    return nil;
}

+(NSArray *)propertyNamesForIgnore{
    return @[@"sourceObject",@"destinationObject",@"relation"];
}

// create
-(void)createInDataBase:(FMDatabase *)db{
    [self createInDataBase:db completeBlock:nil];
}

-(void)createInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    [[self class] createTableWithName:[self tableName] inDataBase:db CompleteBlock:completion];
}

-(void)saveInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    [self saveWithTableName:[self tableName] inDataBase:db completeBlock:completion];
}
-(void)saveInDataBase:(FMDatabase *)db{
    [self saveInDataBase:db completeBlock:nil];
}

+(void)saveModelArray:(NSArray *)modelArray inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    if (![modelArray count]) return;
    
    id relationTable = [modelArray firstObject];
    if (![relationTable isKindOfClass:[IHFRelationTable class]]) return;
    
    [self saveModelArray:modelArray inTableName:[relationTable tableName] inDataBase:db completeBlock:completion];
}

+(void)saveModelArray:(NSArray *)modelArray inDataBase:(FMDatabase *)db{
    [self saveModelArray:modelArray inDataBase:db completeBlock:nil];
}

-(NSArray *)selectRelationsInDataBase:(FMDatabase *)db{
    
    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld",(long)self.sourceObjectID];
    
    NSArray *relations = [[self class] selectWithPredicate:predicate inTableName:[self tableName] inDataBase:db];
    
    __block NSMutableArray *selectArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    [relations enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![obj isKindOfClass:[IHFRelationTable class]]) return ;
        
        IHFRelationTable *table = obj;
        
        IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"ObjectID = %ld",(long)table.destinationObjectID];

        NSArray *relationModels = [[weakSelf.destinationObject class] selectWithPredicate:predicate inTableName:nil inDataBase:db];
        
        if ([relationModels count]) { // If have count , because predicate is ObjectID , so there is only one object!
            [selectArray addObject:[relationModels lastObject]];
        }
    }];
    
    return selectArray;
}

-(void)deleteInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion{
    
    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"sourceObjectID = %ld",(long)self.sourceObjectID];
    
    [[self class]deleteWithPredicate:predicate inTableName:[self tableName] inDataBase:db completeBlock:^(BOOL success) {
        if(completion) completion(success);
    }];
}
@end
