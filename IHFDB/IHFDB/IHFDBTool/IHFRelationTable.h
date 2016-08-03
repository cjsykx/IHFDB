//
//  IHFRelationTable.h
//  IHFDB
//
//  Created by CjSon on 16/6/27.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHFDBObjectDataSource.h"
#import "NSObject+IHFDB.h"
#import "NSObject+IHFModelOperation.h"
#import "IHFDataBaseExecute.h"
#import "FMDB.h"

typedef NS_OPTIONS(NSUInteger, IHFRelation) {
    
    IHFRelationOneToOne                 = 0x00,
    IHFRelationOneToMany                = 0x01,
    IHFRelationNone                     = 0x02,

};

@interface IHFRelationTable : NSObject<IHFDBObejctDataSource>

@property (strong,nonatomic) id <IHFDBObejctDataSource>sourceObject;
@property (assign,nonatomic) NSInteger sourceObjectID;

@property (strong,nonatomic) id <IHFDBObejctDataSource>destinationObject;
@property (assign,nonatomic) NSInteger destinationObjectID;

@property (copy,nonatomic) NSString *relationName;  /**< Is the Model's property name*/

@property (assign,nonatomic) IHFRelation relation;

typedef void(^IHFDBCompleteBlock)(BOOL success);

/** Get table name */

- (NSString *)tableName;

- (instancetype)initWithSourceObject:(id<IHFDBObejctDataSource>)sourceObject destinationObject:(id<IHFDBObejctDataSource>)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation;
+ (instancetype)relationTableWithSourceObject:(id<IHFDBObejctDataSource>)sourceObject destinationObject:(id<IHFDBObejctDataSource>)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation;;


/** Create relation table  */

- (void)createInDataBase:(FMDatabase *)db;
- (void)createInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** Insert relation */

- (void)saveInDataBase:(FMDatabase *)db;
- (void)saveInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(FMDatabase *)db;
+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** Select relation */
- (NSArray *)selectRelationsInDataBase:(FMDatabase *)db;

/** delete relation */
- (void)deleteInDataBase:(FMDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;
@end
