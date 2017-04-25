//
//  NSObject+IHFModelOperation.m
//  IHFDB
//
//  Created by CjSon on 16/6/15.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSObject+IHFModelOperation.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

static NSMutableDictionary *_allowedPropertyNamesDict;
static NSMutableDictionary *_ignoredPropertyNamesDict;
static NSMutableDictionary *_mappedPropertyNamesDict;
static NSMutableDictionary *_relationPropertyNamesDict;

// Primary key
static NSMutableDictionary *_customPrimaryKeyPropertyNamesDict;

static NSMutableDictionary *_TypeOfArrayPropertiesDict;
static NSMutableDictionary *_TypeOfModelPropertiesDict;

// Contain sql statement
static NSMutableDictionary *_insertSqlStatementsDict;
static NSMutableDictionary *_updateSqlStatementsDict;


static NSSet *IHFfoundationClasses;


@implementation NSObject (IHFModelOperation)

+ (void)load {
    _allowedPropertyNamesDict    =  [NSMutableDictionary dictionary];
    _TypeOfArrayPropertiesDict   =  [NSMutableDictionary dictionary];
    _TypeOfModelPropertiesDict   =  [NSMutableDictionary dictionary];
    _ignoredPropertyNamesDict    =  [NSMutableDictionary dictionary];
    _mappedPropertyNamesDict     =  [NSMutableDictionary dictionary];
    _relationPropertyNamesDict   =  [NSMutableDictionary dictionary];
    _customPrimaryKeyPropertyNamesDict =  [NSMutableDictionary dictionary];
    
    _insertSqlStatementsDict = [NSMutableDictionary dictionary];
    _updateSqlStatementsDict = [NSMutableDictionary dictionary];
}

- (void)setProperties:(id)properties forKey:(NSString *)key {
    [_allowedPropertyNamesDict setValue:properties forKey:key];
}

#pragma mark - run time get property

- (NSArray *)getAllPropertyName {
    return [[self class] getAllPropertyName];
}

+ (NSArray *)getAllPropertyName {
    __block NSMutableArray* nameArray = [NSMutableArray array];
    [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
        unsigned int count = 0;
        objc_property_t *property_t = class_copyPropertyList(c, &count);
        for (int i = 0; i<count; i++) {
            objc_property_t propert = property_t[i];
            const char * propertyName = property_getName(propert);
            [nameArray addObject:[NSString stringWithUTF8String:propertyName]];
        }
        free(property_t);
    }];
    return nameArray;
}

- (IHFProperty *)propertyWithName:(NSString *)propertyame {
    
    __block IHFProperty *theProperty;
    
    [[self class] enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
        [c enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            if ([property.propertyName isEqualToString:propertyame]) {
                theProperty = property;
                *stop = YES;
            }
        }];
    }];
    return theProperty;
}

+ (NSDictionary*)getAllPropertyNameAndType {
    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [[self class] enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
        unsigned int count = 0;
        objc_property_t *property_t = class_copyPropertyList(c, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t propert = property_t[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(propert)];
            NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(propert)];
            [dic setValue:objectType(propertyType) forKey:propertyName];
        }
        free(property_t);
    }];
    return dic;
}

- (NSDictionary *)getAllPropertyNameAndType {
    return [[self class] getAllPropertyNameAndType];
}

#pragma mark - set method

// create set sel
- (SEL)createSetSEL:(NSString*)propertyName {
    NSString* firstString = [propertyName substringToIndex:1].uppercaseString;
    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    propertyName = [NSString stringWithFormat:@"set%@:",propertyName];
    return NSSelectorFromString(propertyName);
}

- (void)setValue:(id)aValue forProperty:(IHFProperty *)property {
    
    SEL setSel = property.setSel;
    
    if ([self respondsToSelector:setSel]) {
        
        IMP imp = property.imp;
        
        switch (property.type) {
            case IHFPropertyTypeArray: {
                //Fetch the model contained in the array , to select the relation table
                if(![aValue isKindOfClass:[NSArray class]]) return;
                void (*func) (id,SEL,NSArray*) = (void*)imp;
                func(self,setSel,(NSArray *)aValue);
            } break;
            case IHFPropertyTypeModel: {
                //Fetch the model contained in the array , to select the relation table
                void (*func) (id,SEL,id) = (void*)imp;
                func(self,setSel,aValue);
            } break;
            case IHFPropertyTypeDate: {
                void (*func) (id,SEL,NSDate*) = (void*)imp;
                func(self,setSel,(NSDate *)aValue);
            } break;
            case IHFPropertyTypeInt : {
                if ([aValue isKindOfClass:[NSNumber class]]) {
                    int value = [((NSNumber *)aValue) intValue];
                    void (*func) (id,SEL,int) = (void *)imp;
                    func(self,setSel,value);
                }
            } break;
            case IHFPropertyTypeBOOL : {
                if ([aValue isKindOfClass:[NSNumber class]]) {
                    BOOL value = [((NSNumber *)aValue) boolValue];
                    void (*func) (id,SEL,BOOL) = (void *)imp;
                    func(self,setSel,value);
                }
            } break;
            case IHFPropertyTypeLong : {
                long value = [((NSNumber*)aValue) longValue];
                void (*func) (id,SEL,long) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeDouble : {
                double value = [((NSNumber *)aValue) doubleValue];
                void (*func) (id,SEL,double) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeFloat : {
                float value = [((NSNumber *)aValue) floatValue];
                void (*func) (id,SEL,float) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeUnsignedLong : {
                unsigned long value = [((NSNumber *)aValue) unsignedLongValue];
                void (*func) (id,SEL,unsigned long) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeUnsignedLongLong : {
                unsigned long long value = [((NSNumber *)aValue) unsignedLongLongValue];
                void (*func) (id,SEL,unsigned long long) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeLongLong : {
                long long value = [((NSNumber *)aValue) longLongValue];
                void (*func) (id,SEL,long long) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeShort : {
                short value = [((NSNumber *)aValue) shortValue];
                void (*func) (id,SEL,short) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeUInteger : {
                NSUInteger value = [((NSNumber *)aValue) unsignedIntegerValue];
                void (*func) (id,SEL,NSUInteger) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeData :
            case IHFPropertyTypeImage : {
                NSData* value = (NSData *)aValue;
                void (*func) (id,SEL,NSData*) = (void*)imp;
                func(self,setSel,value);
            } break;
            case IHFPropertyTypeString : {
                void (*func) (id,SEL,NSString *) = (void *)imp;
                func(self,setSel,(NSString *)aValue);
            } break;
            case IHFPropertyTypeNumber : {
                NSNumber *value;
                if ([aValue isKindOfClass:[NSNumber class]]) {
                    value = (NSNumber *)aValue;
                } else if([aValue isKindOfClass:[NSString class]]){
                    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
                    value = [format numberFromString:(NSString *)aValue];
                }
                void (*func) (id,SEL,NSNumber*) = (void*)imp;
                func(self,setSel,value);
            } break;
            default: {
                void (*func) (id,SEL,id) = (void*)imp;
                func(self,setSel,aValue);
            } break;
        }
    }
}

- (void)setValue:(NSObject *)aValue propertyName:(NSString *)name propertyType:(NSString *)type {
    IHFProperty *property = [[IHFProperty alloc] initWithName:name typeString:type srcClass:nil];
    [self setValue:aValue forProperty:property];
}

#pragma mark - Get value

// create Get sel
- (SEL)createGetSelectorWith:(NSString*)propertyName {
    return NSSelectorFromString(propertyName);
}

-(instancetype)valueWithProperty:(IHFProperty *)property {
    SEL getSel = property.getSel;
    return [self valueWithGetSel:getSel];
}

-(instancetype)valueWithGetSel:(SEL)getSel {
    if ([self respondsToSelector:getSel]) {
        //获取类和方法签名
        NSMethodSignature* signature = [self methodSignatureForSelector:getSel];
        const char * returnType = [signature methodReturnType];
        //获取调用对象
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:getSel];
        [invocation invoke];
        if (!memcmp(returnType, "@", 1)) {
            NSObject *__unsafe_unretained returnValue = nil;
            [invocation getReturnValue:&returnValue];
            return returnValue;
        } else if (!memcmp(returnType, "i", 1)||!memcmp(returnType, "q", 1)||!memcmp(returnType, "Q", 1)||!memcmp(returnType, "B", 1)) {
            int returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithInt:returnValue];
        } else if (!memcmp(returnType, "q", 1)) {
            long long returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithLongLong:returnValue];
        } else if (!memcmp(returnType, "Q", 1)) {
            unsigned long long returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithUnsignedLongLong:returnValue];
        } else if(!memcmp(returnType, "s", 1) || !memcmp(returnType, "S", 1)) {
            short returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithShort:returnValue];
        } else if(!memcmp(returnType, "l", 1)) {
            long returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithLong:returnValue];
        } else if(!memcmp(returnType, "L", 1)) {
            unsigned long returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithUnsignedLong:returnValue];
        } else if(!memcmp(returnType, "f", 1)) {
            float returnValue = 0.0;
            [invocation getReturnValue:&returnValue];
            NSString *floatStr = [NSString stringWithFormat:@"%.3f",returnValue];
            return [NSNumber numberWithFloat:[floatStr floatValue]];
        } else if (!memcmp(returnType, "d", 1)) {
            double retureVaule = 0.0;
            [invocation getReturnValue:&retureVaule];
            return [NSNumber numberWithDouble:retureVaule];
        } else if (!memcmp(returnType, "I", 1)) {
            NSUInteger returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithUnsignedInteger:returnValue];
        } else if (!memcmp(returnType, "{", 1)) {
            // Struct not deal now ..
        } else if (!memcmp(returnType, "^", 1)) {
            // point not deal now ..
        } else {
            id __unsafe_unretained returnValue = nil;
            [invocation getReturnValue:&returnValue];
            return returnValue;
        }
    }
    return nil;
}

// Perform getter method
- (instancetype)valueWithPropertName:(NSString *)propertyName {
    SEL getSel = [self createGetSelectorWith:propertyName];
    return [self valueWithGetSel:getSel];
}

#pragma mark - support tool for sqlite

- (NSString *)typeNameWith:(NSString *)propertyName {
    NSString *typeStr = [[self getAllPropertyNameAndType] valueForKey:propertyName];
    
    if ([typeStr isEqualToString:@"i"] || [typeStr isEqualToString:@"I"] || [typeStr isEqualToString:@"s"] || [typeStr isEqualToString:@"S"]) {
        return @"INTEGER";
    } else if ([typeStr isEqualToString:@"f"]) {
        return @"FLOAT";
    } else if ([typeStr isEqualToString:@"b"] || [typeStr isEqualToString:@"c"]) {
        return @"BOOL";
    } else if ([typeStr isEqualToString:@"d"]) {
        return @"DOUBLE";
    } else if ([typeStr isEqualToString:@"q"] || [typeStr isEqualToString:@"Q"] || [typeStr isEqualToString:@"L"] || [typeStr isEqualToString:@"l"] ) {
        return @"LONG";
    } else if ([typeStr isEqualToString:@"NSData"] || [typeStr isEqualToString:@"UIImage"]) {
        return @"BLOB";
    } else if ([typeStr isEqualToString:@"NSNumber"]) {
        return @"NSNumber";
    } else if ([typeStr isEqualToString:@"NSDate"]) {
        return @"NSDate";
    } else
        return @"TEXT";
}

- (NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName {
    
    if ([TypeName isEqualToString:@"i"] || [TypeName isEqualToString:@"I"] || [TypeName isEqualToString:@"s"] || [TypeName isEqualToString:@"S"]) {
        return @"INTEGER";
    } else if ([TypeName isEqualToString:@"f"]) {
        return @"REAL";
    } else if ([TypeName isEqualToString:@"b"] || [TypeName isEqualToString:@"c"]) {
        return @"INTEGER";
    } else if ([TypeName isEqualToString:@"d"]) {
        return @"REAL";
    } else if ([TypeName isEqualToString:@"q"] || [TypeName isEqualToString:@"Q"] || [TypeName isEqualToString:@"L"] || [TypeName isEqualToString:@"l"]) {
        return @"REAL";
    } else if ([TypeName isEqualToString:@"NSData"] || [TypeName isEqualToString:@"UIImage"]) {
        return @"BLOB";
    } else if ([TypeName isEqualToString:@"NSNumber"]) {
        return @"REAL";
    } else if ([TypeName isEqualToString:@"NSArray"] || [TypeName isEqualToString:@"NSMutableArray"]) {
        return @"TEXT";  // TODO : if need insert Array or not (object in array)
    } else if ([TypeName isEqualToString:@"NSDictionary"] || [TypeName isEqualToString:@"NSMutableDictionary"]) {
        return @"BLOB";
    } else if ([TypeName isEqualToString:@"NSDate"]) {
        return @"TEXT";
    }else
        return @"TEXT";
}

#pragma mark - dict with model convert
- (NSMutableDictionary *)JSONObjectFromModel {
    NSArray *dicts = [[NSArray arrayWithObject:self] JSONObjectsFromModelArray];
    
    if (![dicts count]) return nil;
    return [dicts firstObject];
}

- (NSArray<NSMutableDictionary *> *)JSONObjectsFromModelArray {
    
    if (![self isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *dictArrayM = [NSMutableArray array];
    for (id model in (NSArray *)self) {
        id dict;
        Class theClass = [model class];
        if ([model isClassFromFoundation]) { // if IS foundation class
            dict = model;
        } else {
            dict = [NSMutableDictionary dictionary];
            [theClass enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
                NSString *key = property.propertyName;
                id value = [model valueWithPropertName:key];
                if (!value || value == [NSNull null]) return ;
                
                IHFPropertyType propertyType = property.type;
                
                if (propertyType == IHFPropertyTypeArray) { // deal with array
                    
                    // Fetch the model contained in the array , to create table
                    if ([value isKindOfClass:[NSArray class]] && [value count]) {
                        value = [value JSONObjectsFromModelArray];
                    }
                } else if (propertyType == IHFPropertyTypeModel) { // deal with model
                    value = [value JSONObjectFromModel];
                    [dict setValue:[value JSONObjectFromModel] forKey:property.propertyName];
                }
                // Key change to mapper
                if (property.propertyNameMapped) key = property.propertyNameMapped;
                if (!key) return;
                [dict setValue:value forKey:key];
            }];
        }
        BOOL checkResult = YES;
        if ([model respondsToSelector:@selector(doModelCustomConvertToJSONObject:)]) {
            checkResult = [model doModelCustomConvertToJSONObject:dict];
        }
        if (checkResult) [dictArrayM addObject:dict];
    }
    return dictArrayM;
}

+ (NSArray<NSMutableDictionary *> *)JSONObjectsFromModelArray:(NSArray *)modelArray {
    return [modelArray JSONObjectsFromModelArray];
}

+ (instancetype)modelFromJSONObject:(id)JSONObject {
    if ([JSONObject isKindOfClass:[NSString class]]) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:[((NSString *)JSONObject) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([JSONObject isKindOfClass:[NSData class]]) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:(NSData *)JSONObject options:kNilOptions error:nil];
    }
    
    if (!JSONObject) return nil;
    NSArray *models = [self modelsFromJSONObjectArray:[NSArray arrayWithObject:JSONObject]];
    if (![models count]) return nil;
    return [models firstObject];
}

+ (NSArray *)modelsFromJSONObjectArray:(NSArray<id> *)JSONObjects {
    __weak typeof(self) weakSelf = self;
    __block NSMutableArray *models = [NSMutableArray array];
    
    [JSONObjects enumerateObjectsUsingBlock:^(id _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]])) return ;
        id model = [[weakSelf alloc] init];
        [weakSelf enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            NSString *key = property.propertyName;
            if (property.propertyNameMapped) key = property.propertyNameMapped; // change to mapper
            if (!key) return ;
            id value = [dict objectForKey:key];
            if (!value || value == [NSNull null]) return ;
            IHFPropertyType propertyType = property.type;
            
            if (propertyType == IHFPropertyTypeArray) { // Deal with array
                
                // Fetch the model contained in the array , to create table
                if (property.objectClass) {
                    if ([value isKindOfClass:[NSArray class]]) {
                        value = [property.objectClass modelsFromJSONObjectArray:value];
                    }
                }
            } else if (propertyType == IHFPropertyTypeModel) { // Deal with model
                value = [property.objectClass modelFromJSONObject:value];
            }
            [model setValue:value forProperty:property]; 
        }];
        BOOL checkResult = YES;
        if ([model respondsToSelector:@selector(doModelCustomConvertFromJSONObject:)]) {
            checkResult = [model doModelCustomConvertFromJSONObject:dict];
        }
        if (checkResult) [models addObject:model];
    }];
    
    return models;
}

static id objectType(NSString *typeString) {
    if ([typeString containsString:@"@"]) {
        NSArray* strArray = [typeString componentsSeparatedByString:@"\""];
        if (strArray.count > 1) {
            return strArray[1];
        } else if ([typeString containsString:@"@?"]) {
            return @"@?"; // block
        } else
            return @"@"; // Id Type
    } else if ([typeString containsString:@"{"]) {
        return @"{";
    } else if ([typeString containsString:@"^"]) {
        return @"^";
    }
    else return [typeString substringWithRange:NSMakeRange(1, 1)];
}

#pragma mark - eumer property
+ (NSArray<IHFProperty *> *)allowedPropertyNames {
    // Fetch the cache properties !
    NSMutableArray *allowProperties = [_allowedPropertyNamesDict objectForKey:NSStringFromClass(self)];
    
    if (!allowProperties) {
        allowProperties = [NSMutableArray array];
        
        // Ignore properties
        NSMutableArray *ignores = [NSMutableArray arrayWithObjects:@"hash",@"superclass", @"description",@"debugDescription",nil];
        [ignores addObjectsFromArray:[self ignoredPropertyNames]];
        
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c,BOOL *stop) {
            unsigned int count = 0;
            objc_property_t *property_t = class_copyPropertyList(c, &count);
            for (int i = 0; i < count; i++) {
                objc_property_t property = property_t[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                if (![ignores containsObject:propertyName]) {
                    
                    // Get type
                    NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(property)];
                    IHFProperty *theProperty = [[IHFProperty alloc] initWithName:propertyName typeString:objectType(propertyType) srcClass:self];
                    [allowProperties addObject:theProperty];
                }
            }
            free(property_t);
        }];
        [self setProperties:allowProperties forKey:NSStringFromClass(self)];
    }
    return allowProperties;
}

+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration {
    
    if (!enumeration) return;
    
    // Get the all
    NSArray *properties = [self allowedPropertyNames];
    
    BOOL stop = NO;
    int idx = 0;
    for (IHFProperty *property in properties) {
        enumeration(property, idx ,&stop);
        if (stop) break;
        idx++;
    }
}

+ (NSArray <IHFProperty *>*)propertiesForTypeOfArray {
    
    NSMutableArray *properties = [_TypeOfArrayPropertiesDict objectForKey:NSStringFromClass(self)];
    
    if (!properties) {
        properties = [NSMutableArray array];
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            [c enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
                if (property.type == IHFPropertyTypeArray && property.objectClass) {
                    [properties addObject:property];
                }
            }];
            [_TypeOfArrayPropertiesDict setObject:properties forKey:NSStringFromClass(self)];
        }];
    }
    return properties;
}

+ (NSArray <IHFProperty *>*)propertiesForTypeOfModel {
    
    NSMutableArray *properties = [_TypeOfModelPropertiesDict objectForKey:NSStringFromClass(self)];
    
    if(!properties) {
        properties = [NSMutableArray array];
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            [c enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
                if (property.type == IHFPropertyTypeModel) {
                    [properties addObject:property];
                }
            }];
            [_TypeOfModelPropertiesDict setObject:properties forKey:NSStringFromClass(self)];
        }];
    }
    return properties;
}


+ (void)enumerateAllClassesUsingBlock:(IHFClassesEnumeration)enumeration {
    if (enumeration == nil) return;
    BOOL stop = NO;
    
    Class c = self;
    
    while (c && !stop) {
        enumeration(c, &stop);
        c = class_getSuperclass(c);
        if ([self isClassFromFoundation:c]) break;
    }
}

+ (NSSet *)foundationClasses {
    if (IHFfoundationClasses == nil) {
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        IHFfoundationClasses = [NSSet setWithObjects:
                                [NSURL class],
                                [NSDate class],
                                [NSValue class],
                                [NSData class],
                                [NSError class],
                                [NSArray class],
                                [NSDictionary class],
                                [NSString class],
                                [NSAttributedString class], nil];
    }
    return IHFfoundationClasses;
}

+ (BOOL)isClassFromFoundation:(Class)aClass {
    if (aClass == [NSObject class]) return YES;
    
    __block BOOL result = NO;
    [[self foundationClasses] enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([aClass isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)isClassFromFoundation {
    return [[self class] isClassFromFoundation:[self class]];
}

#pragma mark - ignore property names

- (NSDictionary *)dictWithIgnoredPropertyNames {
    
    NSArray *ignoresPropertyNames = [[self class] ignoredPropertyNames];
    __weak typeof(self) weakSelf = self;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [ignoresPropertyNames enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSString class]]) {
            id value = [weakSelf valueWithPropertName:obj];
            if (!value) value = @"";
            [dict setObject:value forKey:obj];
        }
    }];
    return dict;
}

+ (NSArray *)ignoredPropertyNames {
    NSMutableArray *ignoresPropertyNames = [_ignoredPropertyNamesDict objectForKey:NSStringFromClass(self)];
    if (!ignoresPropertyNames) {
        ignoresPropertyNames = [NSMutableArray array];
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            if ([c respondsToSelector:@selector(propertyNamesForIgnore)]) {
                [ignoresPropertyNames addObjectsFromArray:[c propertyNamesForIgnore]];
            }
        }];
        [_ignoredPropertyNamesDict setObject:ignoresPropertyNames forKey:NSStringFromClass(self)];
    }
    return ignoresPropertyNames;
}

#pragma mark - mapper property

+ (NSArray<NSDictionary *> *)mappedPropertyNameDicts {
    NSMutableArray *mappedPropertyNames = [_mappedPropertyNamesDict objectForKey:NSStringFromClass(self)];
    if (!mappedPropertyNames) {
        mappedPropertyNames = [NSMutableArray array];
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            if ([c respondsToSelector:@selector(propertyNameDictForMapper)]) {
                [mappedPropertyNames addObject:[c propertyNameDictForMapper]];
            }
        }];
        [_mappedPropertyNamesDict setObject:mappedPropertyNames forKey:NSStringFromClass(self)];
    }
    return mappedPropertyNames;
}

#pragma mark - relation

+ (NSArray <NSDictionary *>*)relationPropertyNameDicts {
    NSMutableArray *relationPropertyNames = [_relationPropertyNamesDict objectForKey:NSStringFromClass(self)];
    if (!relationPropertyNames) {
        relationPropertyNames = [NSMutableArray array];
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            if ([c respondsToSelector:@selector(propertyNameDictForClassInArray)]) {
                [relationPropertyNames addObject:[c propertyNameDictForClassInArray]];
            }
        }];
        [_relationPropertyNamesDict setObject:relationPropertyNames forKey:NSStringFromClass(self)];
    }
    return relationPropertyNames;
}

#pragma mark - custom primary key
+ (NSArray<NSString *> *)customPrimaryKeyLists {
    NSMutableArray *primaryKeys = [_customPrimaryKeyPropertyNamesDict objectForKey:NSStringFromClass(self)];
    if (!primaryKeys) {
        primaryKeys = [NSMutableArray array];
        [self enumerateAllClassesUsingBlock:^(__unsafe_unretained Class c, BOOL *stop) {
            if ([c respondsToSelector:@selector(propertyNamesForCustomPrimarykeys)]) {
                id key = [c propertyNamesForCustomPrimarykeys];
                if (key && [key isKindOfClass:[NSArray class]]) {
                    [primaryKeys addObject:key];
                } else {
                    NSAssert(true != true, @"primary key can not nil or not a NSString class");
                    *stop = YES;
                }
            }
        }];
        [_customPrimaryKeyPropertyNamesDict setObject:primaryKeys forKey:NSStringFromClass(self)];
    }
    return primaryKeys;
}

#pragma mark -  statement

+ (NSString *)insertSqlStatement {
    
    NSString *sql = [_insertSqlStatementsDict objectForKey:NSStringFromClass(self)];
    if (!sql) {
        
        __block NSMutableString *keyStr = [NSMutableString string];
        __block NSMutableString *value = [NSMutableString string];
        
        [self enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            if (property.type == IHFPropertyTypeModel) return ;
            if (property.type == IHFPropertyTypeArray && property.objectClass) return ;
            
            [keyStr appendFormat:@"%@,",property.propertyName];
            [value appendString:@"?,"];
        }];
        
        // if insert , the data is not dirty
        [keyStr appendFormat:@"%@",IHFDBDirtyKey];
        [value appendString:@"1"];
        
        sql = [NSString stringWithFormat:@"(%@) VALUES (%@)",keyStr,value];
        [_insertSqlStatementsDict setObject:sql forKey:NSStringFromClass(self)];
    }
    return sql;
}

+ (NSString *)updateSqlStatement {
    
    NSMutableString *sql = [_updateSqlStatementsDict objectForKey:NSStringFromClass(self)];
    if (!sql) {
        sql = [NSMutableString string];
        [self enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            if (property.type == IHFPropertyTypeArray && property.objectClass) return ;
            if (property.type == IHFPropertyTypeModel) return ;
            
            [sql appendFormat:@"%@ = ?,",property.propertyName];
        }];
        
        [sql appendFormat:@"%@ = %d",IHFDBDirtyKey,1];
        [_updateSqlStatementsDict setObject:sql forKey:NSStringFromClass(self)];
    }
    return sql;
}

+ (NSString *)updateSqlStatementWithColumns:(NSArray<NSString *> *)columns withPredicate:(IHFPredicate *)predicate {
    if (!columns && ![columns count]) return nil;
    __block NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set ",NSStringFromClass([self class])];
    [columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[NSString class]]) {
            [sql appendFormat:@"%@ = ?",obj];
            
            if (idx != [columns count] - 1) {
                [sql appendFormat:@", "];
            }
        }
    }];
    if (predicate) {
        if (predicate.predicateFormat) {
            [sql appendFormat:@" WHERE %@",predicate.predicateFormat];
        }
    }
    return sql;
}

+ (NSString *)selectSqlStatementWithColumns:(NSArray <NSString *>*)columns {
    if (!columns && ![columns count]) return nil;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where ",NSStringFromClass([self class])];
    [columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[NSString class]]) {
            [sql appendFormat:@"%@ = ? ",obj];
            
            if (idx != [columns count] - 1) {
                [sql appendFormat:@"AND "];
            }
        } else {
            NSAssert(true != true, @"column can NOT contain nil or not string class object");
        }
    }];
    return sql;
}

+ (NSString *)deleteSqlStatementWithColumns:(NSArray <NSString *>*)columns {
    if (!columns && ![columns count]) return nil;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ where ",NSStringFromClass([self class])];
    [columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[NSString class]]) {
            [sql appendFormat:@"%@ = ? ",obj];
            
            if (idx != [columns count] - 1) {
                [sql appendFormat:@"AND "];
            }
        } else {
            NSAssert(true != true, @"columnNames can NOT contain nil or not string class object");
        }
    }];
    return [sql substringToIndex:[sql length] - 1];
}

- (IHFPredicate *)customPrimaryKeyPredicate {
    NSArray *primaryKeys = [[self class] customPrimaryKeyLists];
    NSAssert([primaryKeys count], @"You have NOT set the custom primary keys for this Class");
    if (![primaryKeys count]) return nil;
    id childArray = [primaryKeys firstObject];
    if (childArray && [childArray count]) {
        __block NSMutableString *precicate = [[NSMutableString alloc] init];
        [childArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && [obj isKindOfClass:[NSString class]]) {
                [precicate appendFormat:@"%@ = %@ ",obj,[self valueWithPropertName:obj]];
                if (idx != [childArray count] - 1) {
                    [precicate appendString:@"AND "];
                }
            }
        }];
        return [IHFPredicate predicateWithString:precicate];
    } else {
        NSAssert(true != true, @"customPrimarykey must be NSArray AND not nil");
        return nil;
    }
}

- (NSArray *)argumentsForStatementWithColumns:(NSArray <NSString *>*)columns {
    if (!columns && ![columns count]) return nil;
    __block NSMutableArray *arguments = [NSMutableArray array];
    [columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[NSString class]]) {
            id value = [self valueWithPropertName:obj];
            if (!value) {
                [arguments addObject:[NSNull null]];
            } else {
                [arguments addObject:value];
            }
        }
    }];
    return arguments;
}

- (NSArray *)argumentsForStatement {
    
    __block NSMutableArray *arguments = [NSMutableArray array];
    
    [[self class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if (property.type == IHFPropertyTypeArray && property.objectClass) return ;
        if (property.type == IHFPropertyTypeModel) return ;
        
        id value = [self valueWithProperty:property];
        if (!value) {
            [arguments addObject:[NSNull null]];
        } else {
            [arguments addObject:value];
        }
    }];
    return arguments;
}

@end
