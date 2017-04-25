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

//@property (copy,nonatomic) NSString *tableName;  /**< Get table name */

- (NSString *)tableName;
- (instancetype)initWithSourceObject:(id<IHFDBObejctDataSource>)sourceObject destinationObject:(id<IHFDBObejctDataSource>)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation;
+ (instancetype)relationTableWithSourceObject:(id<IHFDBObejctDataSource>)sourceObject destinationObject:(id<IHFDBObejctDataSource>)destinationObject relationName:(NSString *)relationName relation:(IHFRelation)relation;;


/** Create relation table  */

- (void)createInDataBase:(IHFDatabase *)db;
- (void)createInDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** Insert relation */

- (void)saveInDataBase:(IHFDatabase *)db;
- (void)saveInDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(IHFDatabase *)db;
+ (void)saveModelArray:(NSArray *)modelArray inDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;

/** Select relation */
- (NSArray *)selectRelationsInDataBase:(IHFDatabase *)db;

/** delete relation */
- (void)deleteInDataBase:(IHFDatabase *)db completeBlock:(IHFDBCompleteBlock)completion;
@end
