//
//  IHFDBChain.h
//  IHFDB
//
//  Created by chenjiasong on 2017/4/18.
//  Copyright © 2017年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHFDatabase.h"

#define WeakObject(object) __weak __typeof__(object) weak##_##object = object // Weak
#define StrongObject(object) __typeof__(object) object = weak##_##object // Strong

// Single Declare ..
#define IHFBlockPropertyDeclare(_ownership_, _name_, _paramType_, _paramName_) \
@property (nonatomic, _ownership_, readonly) _paramType_ _paramName_;\
@property (nonatomic, copy, readonly) IHFDBChain *(^_name_)(_paramType_ param);

// Range Declare
#define IHFRangeBlockPropertyDeclare(_ownership_, _name_, _paramType_, _paramName_) \
@property (nonatomic, _ownership_, readonly) _paramType_ _paramName_;\
@property (nonatomic, copy, readonly) IHFDBChain *(^_name_)(NSUInteger, NSUInteger);

// Format Declare
#define IHFFormatBlockPropertyDeclare(_ownership_, _name_, _paramType_, _paramName_) \
@property (nonatomic, _ownership_, readonly) _paramType_ _paramName_;\
@property (nonatomic, copy, readonly) IHFDBChain *(^_name_)(NSString *format, ...);


@interface IHFDBChain : NSObject

/////////////////////////////// Begin

#define Select(_Class_)           ([IHFDBChain new].Select([_Class_ class])) /// Select(Patient).Where(@"age < %d",50).Order(@"recordDate").IsRecursive(YES).Limit(0,5).query;

#define CreateTable(_Class_)      ([IHFDBChain new].CreateTable([_Class_ class]))

#define Save(_Class_)             ([IHFDBChain new].Save([_Class_ class])) // Warning : Need add models in chain , eg : Save(Patient).Models(patients).execute

#define SaveModels(_ModelOrModelArray_)  ([IHFDBChain new].SaveModels(_ModelOrModelArray_)) // eg: SaveModels(patients).execute

#define Delete(_Class_)      ([IHFDBChain new].Delete([_Class_ class])) /// eg : Delete(Patient).Where([NSString stringWithFormat:@"patientID < %d and hostipalID = '%@'",3,@1]).IsCascade(YES).execute;

#define DeleteModels(_ModelOrModelArray_)      ([IHFDBChain new].DeleteModels(_ModelOrModelArray_)) // Delete with models , and base on the model primary keys ..

#define DeleteDirtyData(_Class_)      ([IHFDBChain new].DeleteDirtyData([_Class_ class])) /// Delete dirty data , it can use in chain "save" as DeleteDirtyDataWhere , also can begin DeleteDirtyData ,  eg : DeleteDirtyData(Patient).DeleteDirtyDataWhere([NSString stringWithFormat:@"patientID < %d and hostipalID = '%@'",3,@1]).execute;


#define Update(_Class_)      ([IHFDBChain new].Update([_Class_ class])) /// Need set updateColomns and updateValues
#define UpdateModels(_ModelOrModelArray_)      ([IHFDBChain new].UpdateModels(_ModelOrModelArray_)) /// Need set updateColomns and updateValues


///////////////////////// Condition ...

IHFFormatBlockPropertyDeclare(copy, Where, NSString *, condition); /// Default operation By sql statement , If set nil , it will All ,,
IHFBlockPropertyDeclare(copy, Order, NSString *, orderBy);   /// Option , Default nil
IHFBlockPropertyDeclare(assign, IsDesc, BOOL, desc);  /// Option , Default NO
IHFBlockPropertyDeclare(copy, FromTable, NSString *, tableName); /// Option , default targetClass name
IHFBlockPropertyDeclare(strong, InDb, IHFDatabase *, db); /// Option , use default db
IHFBlockPropertyDeclare(assign, IsRecursive, BOOL, recursive); /// Option , For select , default YES
IHFBlockPropertyDeclare(assign, IsCascade, BOOL, cascade); /// Option , For (Delete AND update) , default YES

IHFRangeBlockPropertyDeclare(assign, Limit, NSRange, limitRange) /// Option , default NO range

IHFBlockPropertyDeclare(strong, WhereByPrimaryKeyValues, NSArray *, primaryKeyValues); /// Other operation ,  by primary key values instead of sql (Warning : you need set the primary keys)

IHFBlockPropertyDeclare(strong, WhereByColumns, NSArray *, conditionColumns); /// /// Other operation , by your columns and values instead of sql (Warning : you need set the values in the after chain) for example : Select(Patient).WhereByColumns(@(@"_id").values(@(@"1").query, like select * from patient the id = 1

IHFBlockPropertyDeclare(strong, ColumnsValues, NSArray *, columnsValues); /// ConditionColumns required set values , and the count need requal to columns ..

IHFBlockPropertyDeclare(strong, Models, NSArray *, targetModels); /// The target model for deal ..

IHFFormatBlockPropertyDeclare(copy, DeleteDirtyDataWhere, NSString *, deleteDirtyDataCondition); /// Set in chain Use for delete dirty data while 'insert' with the where condistion ..

IHFBlockPropertyDeclare(strong, UpdateColumns, NSArray *, updateColumns); /// If Update require , If UpdateModels , not Need!

IHFBlockPropertyDeclare(strong, UpdateValues, NSArray *, updateValues); /// If Update require , If UpdateModels , if not Need!


///////////////////////// end

/**
 Select call in the end

 @return : get the model array from the cache
 */
- (NSArray *)query;

/**
 Create table , inSert and delete or update call in the end
 
 @return : the result
 */
- (BOOL)execute;

typedef void(^IHFDBCompleteBlock)(BOOL success, IHFDatabase *db);
/**
 Create table , inSert and delete or update call in the end
 
 @return : the result
 */
- (BOOL)executeCompletion:(IHFDBCompleteBlock)completion;

/**
 Select count call in the end
 
 @return : the cache count you select
 */
- (NSInteger)count;

// Operation
@property (nonatomic, assign, readonly) Class targetClass;
@property (nonatomic, copy, readonly) NSString *whereCondition;

@property (nonatomic, copy, readonly) IHFDBChain *(^Select)(Class targetClass);
@property (nonatomic, copy, readonly) IHFDBChain *(^CreateTable)(Class targetClass);
@property (nonatomic, copy, readonly) IHFDBChain *(^Save)(Class targetClass);
@property (nonatomic, copy, readonly) IHFDBChain *(^SaveModels)(id targetModel);
@property (nonatomic, copy, readonly) IHFDBChain *(^Delete)(Class targetClass);
@property (nonatomic, copy, readonly) IHFDBChain *(^DeleteModels)(id targetModel);
@property (nonatomic, copy, readonly) IHFDBChain *(^DeleteDirtyData)(Class targetClass);
@property (nonatomic, copy, readonly) IHFDBChain *(^Update)(Class targetClass);
@property (nonatomic, copy, readonly) IHFDBChain *(^UpdateModels)(id targetModel);

@property (nonatomic, copy, readonly) IHFDBChain *(^Limit1)(NSString *format, ...);

@end
