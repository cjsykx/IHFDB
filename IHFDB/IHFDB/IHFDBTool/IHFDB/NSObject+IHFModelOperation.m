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
static NSMutableDictionary *_TypeOfArrayPropertiesDict;
static NSMutableDictionary *_TypeOfModelPropertiesDict;


@implementation NSObject (IHFModelOperation)

+ (void)load {
    _allowedPropertyNamesDict = [NSMutableDictionary dictionary];
    _TypeOfArrayPropertiesDict = [NSMutableDictionary dictionary];
    _TypeOfModelPropertiesDict = [NSMutableDictionary dictionary];
}

- (void)setProperties:(id)properties forKey:(NSString *)key {
    [_allowedPropertyNamesDict setValue:properties forKey:key];
}


+ (NSArray*)getAllPropertyName {
    NSMutableArray* nameArray = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *property_t = class_copyPropertyList(self, &count);
    for (int i=0; i<count; i++) {
        objc_property_t propert = property_t[i];
        const char * propertyName = property_getName(propert);
        [nameArray addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(property_t);
    return nameArray;
}

- (IHFProperty *)propertyWithName:(NSString *)propertyame {
    
    __block IHFProperty *theProperty;
    [[self class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        
        if ([property.propertyName isEqualToString:propertyame]) {
            theProperty = property;
        }
    }];
    return theProperty;
}

- (NSArray*)getAllPropertyName {
    NSMutableArray* nameArray = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *property_t = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        objc_property_t propert = property_t[i];
        const char * propertyName = property_getName(propert);
        [nameArray addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(property_t);
    return nameArray;
}

+ (NSDictionary*)getAllPropertyNameAndType {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t* property_t = class_copyPropertyList(self, &count);
    for (int i=0; i<count; i++) {
        objc_property_t propert = property_t[i];
        NSString* propertyName = [NSString stringWithUTF8String:property_getName(propert)];
        NSString* propertyType = [NSString stringWithUTF8String:property_getAttributes(propert)];
        [dic setValue:objectType(propertyType) forKey:propertyName];
    }
    free(property_t);
    return dic;
}

-(void)setValue:(id)aValue forProperty:(IHFProperty *)property {
    
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
            case IHFPropertyTypeInt  :
            case IHFPropertyTypeBOOL : {
                if ([aValue isKindOfClass:[NSNumber class]]) {
                    int value = [((NSNumber *)aValue) intValue];
                    void (*func) (id,SEL,int) = (void *)imp;
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
    SEL setSel = [self createSetSEL:name];
    if ([self respondsToSelector:setSel]) {
        if ([type isEqualToString:@"NSDate"]) {
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSDate*) = (void*)imp;
            func(self,setSel,(NSDate *)aValue);
        } else if ([type isEqualToString:@"i"]||[type isEqualToString:@"B"]) {
            if ([aValue isKindOfClass:[NSNumber class]]) {
                int value = [((NSNumber *)aValue) intValue];
                IMP imp = [self methodForSelector:setSel];
                void (*func) (id,SEL,int) = (void *)imp;
                func(self,setSel,value);
            }
        } else if ([type isEqualToString:@"d"]&&[aValue isKindOfClass:[NSNumber class]]) {
            double value = [((NSNumber *)aValue) doubleValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,double) = (void*)imp;
            func(self,setSel,value);
            
        } else if ([type isEqualToString:@"f"] && [aValue isKindOfClass:[NSNumber class]]) {
            float value = [((NSNumber *)aValue) floatValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,float) = (void*)imp;
            func(self,setSel,value);
            
        } else if ([type isEqualToString:@"q"]&&[aValue isKindOfClass:[NSNumber class]]) {
            long value = [((NSNumber*)aValue) longValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,long) = (void*)imp;
            func(self,setSel,value);
        } else if ([type isEqualToString:@"NSData"]) {
            NSData* value = (NSData *)aValue;
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSData*) = (void*)imp;
            func(self,setSel,value);
        } else if ([type isEqualToString:@"UIImage"]) {
            UIImage* value = [UIImage imageWithData:(NSData*)aValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,UIImage*) = (void*)imp;
            func(self,setSel,value);
        } else if ([type isEqualToString:@"NSNumber"]) {
            NSNumber *value;
            if ([aValue isKindOfClass:[NSNumber class]]) {
                value = (NSNumber *)aValue;
            }else if([aValue isKindOfClass:[NSString class]]) {
                NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
                value = [format numberFromString:(NSString *)aValue];
            }
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSNumber*) = (void*)imp;
            func(self,setSel,value);
        } else if ([type isEqualToString:@"NSArray"]) {
            
            if(![aValue isKindOfClass:[NSArray class]]) return;
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSArray*) = (void*)imp;
            func(self,setSel,(NSArray *)aValue);
        } else if ([type isEqualToString:@"NSDictionary"]) {
            NSError* error;
            NSData* data = [(NSString*)aValue dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* dic;
            if (!data) {
                dic = nil;
            } else
                dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSDictionary*) = (void*)imp;
            func(self,setSel,dic);
        } else {
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,id) = (void*)imp;
            func(self,setSel,aValue);
        }
    }
}

- (NSDictionary *)getAllPropertyNameAndType {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t* property_t = class_copyPropertyList([self class], &count);
    for (int i=0; i<count; i++) {
        objc_property_t propert = property_t[i];
        NSString* propertyName = [NSString stringWithUTF8String:property_getName(propert)];
        NSString* propertyType = [NSString stringWithUTF8String:property_getAttributes(propert)];
        [dic setValue:objectType(propertyType) forKey:propertyName];
    }
    free(property_t);
    return dic;
}

//创建get方法
- (SEL)createGetSelectorWith:(NSString*)propertyName {
    return NSSelectorFromString(propertyName);
}
//创建set方法
- (SEL)createSetSEL:(NSString*)propertyName {
    NSString* firstString = [propertyName substringToIndex:1].uppercaseString;
    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    propertyName = [NSString stringWithFormat:@"set%@:",propertyName];
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
        } else if(!memcmp(returnType, "f", 1)) {
            float returnValue = 0.0;
            [invocation getReturnValue:&returnValue];
            NSString* floatStr = [NSString stringWithFormat:@"%.3f",returnValue];
            return [NSDecimalNumber decimalNumberWithString:floatStr];
            return [NSNumber numberWithFloat:[floatStr floatValue]];
        }else if (!memcmp(returnType, "d", 1)) {
            double retureVaule = 0.0;
            [invocation getReturnValue:&retureVaule];
            return [NSNumber numberWithDouble:retureVaule];
        }
    }
    return nil;
}

// Perform getter method
- (instancetype)valueWithPropertName:(NSString *)propertyName {
    
    SEL getSel = [self createGetSelectorWith:propertyName];
    return [self valueWithGetSel:getSel];
}


- (NSString *)typeNameWith:(NSString *)propertyName {
    NSString* typeStr = [[self getAllPropertyNameAndType] valueForKey:propertyName];
    
    if ([typeStr isEqualToString:@"i"]) {
        return @"INTEGER";
    } else if ([typeStr isEqualToString:@"f"]) {
        return @"FLOAT";
    } else if ([typeStr isEqualToString:@"B"]) {
        return @"BOOL";
    } else if ([typeStr isEqualToString:@"d"]) {
        return @"DOUBLE";
    } else if ([typeStr isEqualToString:@"q"]) {
        return @"LONG";
    } else if ([typeStr isEqualToString:@"NSData"] || [typeStr isEqualToString:@"UIImage"]) {
        return @"BLOB";
    } else if ([typeStr isEqualToString:@"NSNumber"]) {
        return @"NSNumber";
    } else if ([typeStr isEqualToString:@"NSDate"] ){
        return @"NSDate";
    } else
        return @"TEXT";
}

-(NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName{
    
    if ([TypeName isEqualToString:@"i"]) {
        return @"INTEGER";
    } else if ([TypeName isEqualToString:@"f"]) {
        return @"REAL";
    } else if ([TypeName isEqualToString:@"B"]) {
        return @"INTEGER";
    } else if ([TypeName isEqualToString:@"d"]) {
        return @"REAL";
    } else if ([TypeName isEqualToString:@"q"]) {
        return @"INTEGER";
    } else if ([TypeName isEqualToString:@"NSData"] || [TypeName isEqualToString:@"UIImage"]) {
        return @"BLOB";
    } else if ([TypeName isEqualToString:@"NSNumber"]){
        return @"REAL";
    } else if ([TypeName isEqualToString:@"NSArray"]){
        return @"";
    } else if ([TypeName isEqualToString:@"NSDate"]){
        return @"DATETIME";
    } else
        return @"TEXT";
}

- (NSDictionary *)dictionaryFromModel {
    
    NSArray *dicts = [[NSArray arrayWithObject:self] dictionaryArrayFromModelArray];
    
    if (![dicts count]) return nil;
    return [dicts firstObject];
}

- (NSArray<NSDictionary *> *)dictionaryArrayFromModelArray {
    
    if (![self isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    for (id model in (NSArray *)self) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        Class theClass = [model class];
        
        [theClass enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            id value = [model valueWithPropertName:property.propertyName];
            if(!value || value == [NSNull null]) return ;
            
            IHFPropertyType propertyType = property.type;

            if (propertyType == IHFPropertyTypeArray) { // deal with array
                
                // Fetch the model contained in the array , to create table
                
                if (property.objectClass) {
                    if([value isKindOfClass:[NSArray class]] && [value count]) {
                        value = [value dictionaryArrayFromModelArray];
                    }
                }
            }else if (propertyType == IHFPropertyTypeModel) { // deal with model
                value = [value dictionaryFromModel];
                [dict setValue:[value dictionaryFromModel] forKey:property.propertyName];
            }
            // Key change to mapper
            NSString *key = property.propertyName;
            if (property.propertyNameMapped) key = property.propertyNameMapped;
            [dict setValue:value forKey:key];
        }];

        [modelArray addObject:dict];
    }
    
    return modelArray;
}

+ (NSArray<NSDictionary *> *)dictionaryArrayFromModelArray:(NSArray *)modelArray {
    return [modelArray dictionaryArrayFromModelArray];
}

+ (instancetype)modelFromJsonString:(NSString *)jsonString {
    if(!jsonString) return nil;
    id object = [NSJSONSerialization JSONObjectWithData:[((NSString *)jsonString) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    return [self modelFromDictionary:object];
}

+ (instancetype)modelFromJsonData:(NSData *)jsonData {
    if(!jsonData) return nil;
    id object = [NSJSONSerialization JSONObjectWithData:(NSData *)jsonData options:kNilOptions error:nil];
    return [self modelFromDictionary:object];
}

+ (instancetype)modelFromDictionary:(NSDictionary *)dict {
    
    if (!dict) return nil;
    NSArray *models = [self modelArrayFromDictionaryArray:[NSArray arrayWithObject:dict]];
    if (![models count]) return nil;
    return [models firstObject];
}

+ (NSArray <id> *)modelArrayFromDictionaryArray:(NSArray<NSDictionary *> *)dictArray {
    
    __weak typeof(self) weakSelf = self;
    __block NSMutableArray *models = [NSMutableArray array];
    
    [dictArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id model = [[weakSelf alloc] init];
        
        [weakSelf enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            NSString *key = property.propertyName;
            if (property.propertyNameMapped) key = property.propertyNameMapped; // change to mapper
            
            id value = [dict objectForKey:key];
            if (!value || value == [NSNull null]) return ;
            IHFPropertyType propertyType = property.type;

            if (propertyType == IHFPropertyTypeArray) { // Deal with array
                
                // Fetch the model contained in the array , to create table
                
                if (property.objectClass) {
                                        
                    if ([value isKindOfClass:[NSArray class]]) {
                        [model setValue:[property.objectClass modelArrayFromDictionaryArray:value] forProperty:property];
                    }
                }
            } else if (propertyType == IHFPropertyTypeModel) { // Deal with model
                [model setValue:[property.objectClass modelFromDictionary:value] forProperty:property];
            } else {
                [model setValue:value forProperty:property];
            }
        }];

        [models addObject:model];
    }];

    return models;
}

static id objectType(NSString *typeString) {
    if ([typeString containsString:@"@"]) {
        NSArray* strArray = [typeString componentsSeparatedByString:@"\""];
        if (strArray.count >= 1) {
            return strArray[1];
            
        } else
            return nil;
    } else
        return [typeString substringWithRange:NSMakeRange(1, 1)];
}

+ (NSArray *)propertys {
    
    // Fetch the cache properties !
    NSMutableArray *allowProperties = [_allowedPropertyNamesDict objectForKey:NSStringFromClass(self)];
    
    if(!allowProperties) {
        allowProperties = [NSMutableArray array];
        
        unsigned int count = 0;
        objc_property_t *property_t = class_copyPropertyList(self, &count);
        
        NSMutableArray *ignores = [NSMutableArray arrayWithObjects:@"hash",@"superclass", @"description",@"debugDescription",nil];
        if ([self respondsToSelector:@selector(propertyNamesForIgnore)]) {
            [ignores addObjectsFromArray:[self propertyNamesForIgnore]];
        }

        for (int i = 0; i < count; i++) {
            objc_property_t property = property_t[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            if (![ignores containsObject:propertyName]) {
                
                // Get type
                NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(property)];

                IHFProperty *theProperty = [[IHFProperty alloc] initWithName:propertyName typeString:objectType(propertyType) srcClass:self];
                
//                theProperty.property = property;
                             
                [allowProperties addObject:theProperty];
            }
        }
        free(property_t);
        [self setProperties:allowProperties forKey:NSStringFromClass(self)];
    }

    return allowProperties;
}

+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration {
    
    if (!enumeration) return;
    
    // Get the all
    NSArray *properties = [self propertys];

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
        [self enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            if (property.type == IHFPropertyTypeArray) {
                [properties addObject:property];
            }
        }];
        
        [_TypeOfArrayPropertiesDict setObject:properties forKey:NSStringFromClass(self)];
    }
    return properties;
}

+ (NSArray <IHFProperty *>*)propertiesForTypeOfModel {
    
    NSMutableArray *properties = [_TypeOfModelPropertiesDict objectForKey:NSStringFromClass(self)];
    
    if(!properties) {
        
        properties = [NSMutableArray array];
        [self enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
            
            if(property.type == IHFPropertyTypeModel) {
                [properties addObject:property];
            }
        }];
        
        [_TypeOfModelPropertiesDict setObject:properties forKey:NSStringFromClass(self)];
    }
    return properties;
}

- (NSDictionary *)dictWithIgnoredPropertyNames {
    
    NSArray *ignoresPropertyNames;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([[self class] respondsToSelector:@selector(propertyNamesForIgnore)]) {
        ignoresPropertyNames = [[self class] propertyNamesForIgnore];
    }
    
    [ignoresPropertyNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSString class]]) {
            [dict setObject:[self valueWithPropertName:obj] forKey:obj];
        }
    }];
    return dict;
}

@end
