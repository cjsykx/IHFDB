//
//  IHFDBChain.m
//  IHFDB
//
//  Created by chenjiasong on 2017/4/18.
//  Copyright © 2017年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFDBChain.h"
#import <objc/runtime.h>
#import "NSObject+IHFDB.h"

typedef NS_ENUM(NSUInteger, IHFDBOperation) {
    // Select
    IHFDBOperationSelect                       = 0,
    IHFDBOperationSelectCount                  = 1,
    // Create table
    IHFDBOperationCreateTable                  = 4,
    // Insert
    IHFDBOperationInsert                       = 5,
    // Delete
    IHFDBOperationDelete                       = 6,
    IHFDBOperationDeleteModels                 = 7,
    IHFDBOperationDeleteDirtyData              = 8,

    // Update
    IHFDBOperationUpdate                       = 9,
    IHFDBOperationUpdateModels                 = 10,
};

typedef NS_ENUM(NSUInteger, IHFDBOperationMethod) {
    IHFDBOperationOperationMethodBySQL              = 0x00,
    IHFDBOperationOperationMethodByPrimaryKeyValues = 0x01,
    IHFDBOperationOperationMethodByColumns = 0x02,
    IHFDBOperationOperationMethodDeleteDirtyData = 0x03,

};


// Normal
#define IHFBlockPropertyImpl(_type_, _methodName_, _propName_)\
- (IHFDBChain *(^)(_type_ prop))_methodName_ {\
WeakObject(self);\
return ^IHFDBChain *(_type_ prop){\
StrongObject(self);\
self->_##_propName_ = prop;\
return self;\
};\
}

// Operation
#define IHFOperationBlockPropertyImpl(_type_, _methodName_, _propName_ , _operation_)\
- (IHFDBChain *(^)(_type_ prop))_methodName_ {\
WeakObject(self);\
return ^IHFDBChain *(_type_ prop){\
StrongObject(self);\
self->_##_propName_ = prop;\
self.operation = _operation_;\
return self;\
};\
}

// Operation method
#define IHFOperationMethodBlockPropertyImpl(_type_, _methodName_, _propName_ , _operationMethod_)\
- (IHFDBChain *(^)(_type_ prop))_methodName_ {\
WeakObject(self);\
return ^IHFDBChain *(_type_ prop){\
StrongObject(self);\
self->_##_propName_ = prop;\
self.operationMethod = _operationMethod_;\
return self;\
};\
}

// Format and Operation method
#define IHFFormatOperationMethodBlockPropertyImpl(_methodName_, _propName_ , _operationMethod_)\
- (IHFDBChain *(^)(NSString * ,...))_methodName_ {\
WeakObject(self);\
return ^IHFDBChain *(NSString *format, ...){\
StrongObject(self);\
NSString *formatStr = [format stringByReplacingOccurrencesOfString:@"%@" withString:@"'%@'"];\
va_list args;\
va_start(args, format);\
self->_##_propName_ = [[NSString alloc] initWithFormat:formatStr arguments:args];\
va_end(args);\
self.operationMethod = _operationMethod_;\
return self;\
};\
}

// Array
#define IHFOperationBlockForArrayImpl(_methodName_, _operation_)\
- (IHFDBChain *(^)(id))_methodName_ {\
WeakObject(self);\
return ^IHFDBChain *(id target){\
StrongObject(self);\
self.operation = _operation_;\
self->_cascade = YES;\
if ([target isKindOfClass:[NSArray class]]) {            \
self->_targetModels = target;                 \
}                                                       \
else {\
if (object_isClass(target)) {\
self->_targetClass = target;\
} else {\
self->_targetModels = [NSArray arrayWithObject:target];                 \
}\
}\
return self;\
};\
}

@interface IHFDBChain ()
@property (assign, nonatomic) IHFDBOperation operation;
@property (assign, nonatomic) IHFDBOperationMethod operationMethod;

@end


@implementation IHFDBChain

@synthesize targetClass = _targetClass;
@synthesize condition = _condition;
@synthesize desc = _desc;
@synthesize limitRange = _limitRange;
@synthesize orderBy = _orderBy;
@synthesize tableName = _tableName;
@synthesize db = _db;
@synthesize recursive = _recursive;
@synthesize primaryKeyValues = _primaryKeyValues;
@synthesize columnsValues = _columnsValues;
@synthesize targetModels = _targetModels;
@synthesize deleteDirtyDataCondition = _deleteDirtyDataCondition;
@synthesize cascade = _cascade;
@synthesize updateColumns = _updateColumns;
@synthesize updateValues = _updateValues;

//IHFBlockPropertyImpl(NSString *, Where, condition)
IHFBlockPropertyImpl(NSString *, Order, orderBy)
IHFBlockPropertyImpl(NSString *, FromTable, tableName)

IHFBlockPropertyImpl(NSArray *, ColumnsValues, columnsValues)
IHFBlockPropertyImpl(NSArray *, UpdateColumns, updateColumns)
IHFBlockPropertyImpl(NSArray *, UpdateValues, updateValues)

IHFBlockPropertyImpl(BOOL, IsDesc, desc)
IHFBlockPropertyImpl(BOOL, IsRecursive, recursive)
IHFBlockPropertyImpl(BOOL, IsCascade, cascade)

IHFBlockPropertyImpl(IHFDatabase *, InDb, db)

// Operation
IHFOperationBlockPropertyImpl(Class, Select, targetClass, IHFDBOperationSelect)
IHFOperationBlockPropertyImpl(Class, SelectCount, targetClass, IHFDBOperationSelectCount)
IHFOperationBlockPropertyImpl(Class, CreateTable, targetClass, IHFDBOperationCreateTable)
IHFOperationBlockPropertyImpl(Class, Save, targetClass, IHFDBOperationInsert)


IHFOperationBlockPropertyImpl(Class, Delete, targetClass, IHFDBOperationDelete)
IHFOperationBlockPropertyImpl(Class, Update, targetClass, IHFDBOperationUpdate)

// Model Array
IHFOperationBlockForArrayImpl(SaveModels, IHFDBOperationInsert);
IHFOperationBlockForArrayImpl(DeleteModels, IHFDBOperationDeleteModels);
IHFOperationBlockForArrayImpl(UpdateModels, IHFDBOperationUpdateModels);

// Operation Method
IHFOperationMethodBlockPropertyImpl(NSArray *, WhereByPrimaryKeyValues, primaryKeyValues, IHFDBOperationOperationMethodByPrimaryKeyValues)
IHFOperationMethodBlockPropertyImpl(NSArray *, WhereByColumns, conditionColumns, IHFDBOperationOperationMethodByColumns)

// Format and Operation Method
IHFFormatOperationMethodBlockPropertyImpl(Where, condition, IHFDBOperationOperationMethodBySQL);
IHFFormatOperationMethodBlockPropertyImpl(DeleteDirtyDataWhere, deleteDirtyDataCondition, IHFDBOperationOperationMethodDeleteDirtyData);


- (instancetype)init {
    self = [super init];
    if (self) {
        self->_recursive = YES;
    }
    return self;
}

- (IHFDBChain *(^)(NSUInteger, NSUInteger))Limit {
    WeakObject(self);
    return ^IHFDBChain *(NSUInteger start, NSUInteger length) {
        StrongObject(self);
        self->_limitRange = NSMakeRange(start, length);
        return self;
    };
}

- (NSArray *)query {
    NSArray *caches;
    if (self.operation == IHFDBOperationSelect) {
        if (self.operationMethod == IHFDBOperationOperationMethodByPrimaryKeyValues) {
            caches = [self.targetClass selectWithCustomPrimaryKeyValues:self.primaryKeyValues isRecursive:self.recursive fromTable:self.tableName inDataBase:self.db];
        } else if (self.operationMethod == IHFDBOperationOperationMethodByColumns) {
            caches = [self.targetClass selectWithColumns:self.conditionColumns withValues:self.columnsValues isRecursive:self.recursive fromTable:self.tableName inDataBase:self.db orderBy:self.orderBy isDesc:self.desc limitRange:self.limitRange];
        } else {
            IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:self.condition OrderBy:self.orderBy];
            predicate.isDesc = self.desc;
            predicate.limitRange = self.limitRange;
            caches = [self.targetClass selectWithPredicate:predicate fromTable:self.tableName inDataBase:self.db isRecursive:self.recursive];
        }
    }
    return caches;
}

- (NSInteger)count {
    NSArray *caches;
    if (self.operation == IHFDBOperationSelect) {
        if (self.operationMethod == IHFDBOperationOperationMethodByPrimaryKeyValues) {
            caches = [self.targetClass selectWithCustomPrimaryKeyValues:self.primaryKeyValues isRecursive:self.recursive fromTable:self.tableName inDataBase:self.db];
        } else if (self.operationMethod == IHFDBOperationOperationMethodByColumns) {
            caches = [self.targetClass selectWithColumns:self.conditionColumns withValues:self.columnsValues isRecursive:self.recursive fromTable:self.tableName inDataBase:self.db orderBy:self.orderBy isDesc:self.desc limitRange:self.limitRange];
        } else {
            IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:self.condition];
            return [self.targetClass selectCountWithPredicate:predicate fromTable:self.tableName inDataBase:self.db];
        }
    }
    return [caches count];
}

- (BOOL)execute {
    return [self executeCompletion:nil];
}

- (BOOL)executeCompletion:(IHFDBCompleteBlock)completion {
    BOOL result = YES;
    if (self.operation == IHFDBOperationCreateTable) { // Create table
        result = [self.targetClass createTableWithName:self.tableName inDataBase:self.db CompleteBlock:completion];
    } else if (self.operation == IHFDBOperationInsert) {
        if (![self.targetModels count]) return YES;
        result = [self.targetModels saveWithTableName:self.tableName inDataBase:self.db completeBlock:^(BOOL result, IHFDatabase *db) {
            if (self.operationMethod == IHFDBOperationOperationMethodDeleteDirtyData) {
                if (!self.targetClass) {
                    self->_targetClass = [[self.targetModels firstObject] class];
                    IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:self.deleteDirtyDataCondition];
                    result = [self->_targetClass deleteDirtyDataWithPredicate:predicate fromTable:self.tableName inDataBase:self.db completeBlock:completion];
                }
            } else {
                if (completion) {
                    completion(result,db);
                }
            }
        }];
    } else if (self.operation == IHFDBOperationDelete) { // Delete
        if (self.operationMethod == IHFDBOperationOperationMethodByPrimaryKeyValues) {
            result = [self.targetClass deleteWithCustomPrimaryKeyValues:self.primaryKeyValues isCascade:self.cascade fromTable:self.tableName inDataBase:self.db completeBlock:completion];
        } else if (self.operationMethod == IHFDBOperationOperationMethodByColumns) {
            result = [self.targetClass deleteWithColumns:self.conditionColumns withValues:self.columnsValues isCascade:self.cascade fromTable:self.tableName inDataBase:self.db completeBlock:completion];
        } else { // IHFDBOperationOperationMethodBySQL
            IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:self.condition];
            result = [self.targetClass deleteWithPredicate:predicate fromTable:self.tableName inDataBase:self.db isCascade:self.cascade completeBlock:completion];
        }
    } else if (self.operation == IHFDBOperationDeleteModels) { // Delete models
        result = [self.targetModels deleteFromTable:self.tableName inDataBase:self.db IsCascade:self.cascade completeBlock:completion];
    } else if (self.operation == IHFDBOperationDeleteDirtyData) { // Delete dirty data
        IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:self.deleteDirtyDataCondition];
        result = [self->_targetClass deleteDirtyDataWithPredicate:predicate fromTable:self.tableName inDataBase:self.db completeBlock:completion];
    } else if (self.operation == IHFDBOperationUpdate) { // Delete
        if (self.operationMethod == IHFDBOperationOperationMethodByPrimaryKeyValues) {
            result = [self.targetClass updateColumns:self.updateColumns setValues:self.updateValues customPrimaryKeyValues:self.primaryKeyValues fromTable:self.tableName inDataBase:self.db completeBlock:completion];
        } else if (self.operationMethod == IHFDBOperationOperationMethodByColumns) {
            result = [self.targetClass updateColumns:self.updateColumns setValues:self.updateValues conditionColumns:self.conditionColumns conditionValues:self.columnsValues fromTable:self.tableName inDataBase:self.db completeBlock:completion];
        } else { // IHFDBOperationOperationMethodBySQL
            IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:self.condition];
            result = [self.targetClass updateColumns:self.updateColumns setValues:self.updateValues predicate:predicate fromTable:self.tableName inDataBase:self.db completeBlock:completion];
        }
    } else if (self.operation == IHFDBOperationUpdateModels) { // Delete
        result = [self.targetModels updateColumns:self.updateColumns setValues:self.updateValues fromTable:self.tableName inDataBase:self.db isCascade:self.cascade completeBlock:completion];
    }
    return result;
}

@end
