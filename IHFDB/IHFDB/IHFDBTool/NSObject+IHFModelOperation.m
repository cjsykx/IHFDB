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

@implementation NSObject (IHFModelOperation)
+ (NSArray*)getAllPropertyName
{
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

- (NSArray*)getAllPropertyName
{
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

+ (NSDictionary*)getAllPropertyNameAndType
{
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


- (void)setValue:(NSObject *)aValue propertyName:(NSString *)name propertyType:(NSString *)type
{
    SEL setSel = [self createSetSEL:name];
    if ([self respondsToSelector:setSel]) {
        if ([type isEqualToString:@"NSDate"]) {
            
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSDate*) = (void*)imp;
            func(self,setSel,(NSDate *)aValue);
            
        }else if ([type isEqualToString:@"i"]||[type isEqualToString:@"B"]){
            if ([aValue isKindOfClass:[NSNumber class]]) {
                int value = [((NSNumber *)aValue) intValue];
                IMP imp = [self methodForSelector:setSel];
                void (*func) (id,SEL,int) = (void *)imp;
                func(self,setSel,value);
            }
        }else if ([type isEqualToString:@"d"]&&[aValue isKindOfClass:[NSNumber class]]) {
            double value = [((NSNumber *)aValue) doubleValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,double) = (void*)imp;
            func(self,setSel,value);
            
        }else if ([type isEqualToString:@"f"] && [aValue isKindOfClass:[NSNumber class]]) {
            float value = [((NSNumber *)aValue) floatValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,float) = (void*)imp;
            func(self,setSel,value);
            
        }else if ([type isEqualToString:@"q"]&&[aValue isKindOfClass:[NSNumber class]]) {
            long value = [((NSNumber*)aValue) longValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,long) = (void*)imp;
            func(self,setSel,value);
        }else if ([type isEqualToString:@"NSData"]) {
            NSData* value = (NSData *)aValue;
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSData*) = (void*)imp;
            func(self,setSel,value);
            
        }else if ([type isEqualToString:@"UIImage"]) {
            UIImage* value = [UIImage imageWithData:(NSData*)aValue];
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,UIImage*) = (void*)imp;
            func(self,setSel,value);
            
        }else if ([type isEqualToString:@"NSNumber"]) {
            
            NSNumber *value;
            if ([aValue isKindOfClass:[NSNumber class]]) {
                value = (NSNumber *)aValue;
            }else if([aValue isKindOfClass:[NSString class]]){
                
                NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
                value = [format numberFromString:(NSString *)aValue];
            }

            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSNumber*) = (void*)imp;
            func(self,setSel,value);
        }
        else if ([type isEqualToString:@"NSArray"]){
            
            if(![aValue isKindOfClass:[NSArray class]]) return;
            IMP imp = [self methodForSelector:setSel];
            void (*func) (id,SEL,NSArray*) = (void*)imp;
            func(self,setSel,(NSArray *)aValue);
        }else if ([type isEqualToString:@"NSDictionary"]) {
            NSError* error;
            NSData* data = [(NSString*)aValue dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* dic;
            if (!data) {
                dic = nil;
            }else
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

-(NSDictionary *)getAllPropertyNameAndType{
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
- (SEL)createGetSelectorWith:(NSString*)propertyName
{
    return NSSelectorFromString(propertyName);
}
//创建set方法
- (SEL)createSetSEL:(NSString*)propertyName
{
    NSString* firstString = [propertyName substringToIndex:1].uppercaseString;
    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    propertyName = [NSString stringWithFormat:@"set%@:",propertyName];
    return NSSelectorFromString(propertyName);
}

// Perform getter method
- (id)getValueWithPropertName:(NSString *)propertyName{
    
    SEL getSel = [self createGetSelectorWith:propertyName];
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
        }else if (!memcmp(returnType, "i", 1)||!memcmp(returnType, "q", 1)||!memcmp(returnType, "Q", 1)||!memcmp(returnType, "B", 1)){
            int returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithInt:returnValue];
        }else if(!memcmp(returnType, "f", 1)){
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

//执行get方法
- (id)getResultWithPropertName:(NSString*)propertyName
{
    SEL getSel = [self createGetSelectorWith:propertyName];
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
        }else if (!memcmp(returnType, "i", 1)||!memcmp(returnType, "q", 1)||!memcmp(returnType, "Q", 1)||!memcmp(returnType, "B", 1)){
            int returnValue = 0;
            [invocation getReturnValue:&returnValue];
            return [NSNumber numberWithInt:returnValue];
        }else if(!memcmp(returnType, "f", 1)){
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

- (NSString*)getTypeNameWith:(NSString*)propertyName
{
    NSString* typeStr = [[self getAllPropertyNameAndType]valueForKey:propertyName];
    
    if ([typeStr isEqualToString:@"i"]) {
        return @"INTEGER";
    }else if ([typeStr isEqualToString:@"f"]) {
        return @"FLOAT";
    }else if ([typeStr isEqualToString:@"B"]) {
        return @"BOOL";
    }else if ([typeStr isEqualToString:@"d"]) {
        return @"DOUBLE";
    }else if ([typeStr isEqualToString:@"q"]) {
        return @"LONG";
    }else if ([typeStr isEqualToString:@"NSData"]||[typeStr isEqualToString:@"UIImage"]) {
        return @"BLOB";
    }else if ([typeStr isEqualToString:@"NSNumber"]){
        return @"NSNumber";
    }else if ([typeStr isEqualToString:@"NSDate"]){
        return @"NSDate";
    } else
        return @"TEXT";
}

-(NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName{
    
    if ([TypeName isEqualToString:@"i"]) {
        return @"INTEGER";
    }else if ([TypeName isEqualToString:@"f"]) {
        return @"REAL";
    }else if ([TypeName isEqualToString:@"B"]) {
        return @"INTEGER";
    }else if ([TypeName isEqualToString:@"d"]) {
        return @"REAL";
    }else if ([TypeName isEqualToString:@"q"]) {
        return @"INTEGER";
    }else if ([TypeName isEqualToString:@"NSData"] || [TypeName isEqualToString:@"UIImage"]) {
        return @"BLOB";
    }else if ([TypeName isEqualToString:@"NSNumber"]){
        return @"REAL";
    }
    else if ([TypeName isEqualToString:@"NSArray"]){
        return @"";
    }
    else if ([TypeName isEqualToString:@"NSDate"]){
        return @"DATETIME";
    }else
        return @"TEXT";
}

//mode转字典
- (NSDictionary *)getDictionary{
    NSArray *nameArray = [self getAllPropertyName];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *propertyName in nameArray) {
        id value = [self getResultWithPropertName:propertyName];
        [dict setValue:value forKey:propertyName];
    }
    return dict;
}

//字典转model
+ (id)modelWithDictionary:(NSDictionary *)dict{
    id model = [[self alloc] init];
    NSArray* nameArray = dict.allKeys;
    for (int i=0; i < nameArray.count; i++) {
        SEL setSel = [model createSetSEL:nameArray[i]];
        if ([model respondsToSelector:setSel]) {
            
            NSMethodSignature* signature = [model methodSignatureForSelector:setSel];
            const char* c = [signature getArgumentTypeAtIndex:2];
            if (!memcmp(c, "@", 1)) {
                IMP imp = [model methodForSelector:setSel];
                void (*func) (id,SEL,id) = (void*)imp;
                func(model, setSel,dict[nameArray[i]]);
            }else if (!memcmp(c, "i", 1)||!memcmp(c, "q", 1)||!memcmp(c, "Q", 1)){
                int value = [dict[nameArray[i]] intValue];
                IMP imp = [model methodForSelector:setSel];
                void (*func) (id,SEL,int) = (void*)imp;
                func(model, setSel,value);
            }else if(!memcmp(c, "f", 1)){
                float value = [dict[nameArray[i]] floatValue];
                IMP imp = [model methodForSelector:setSel];
                void (*func) (id,SEL,float) = (void*)imp;
                func(model, setSel,value);
            }else if (!memcmp(c, "d", 1)) {
                double value = [dict[nameArray[i]] doubleValue];
                IMP imp = [model methodForSelector:setSel];
                void (*func) (id,SEL,double) = (void*)imp;
                func(model, setSel,value);
            }
        }
    }
    return model;
}


// Give model assignment
-(void)giveWithDict:(NSDictionary *)dic{
    
    NSArray* nameArray = dic.allKeys;
    for (int i=0; i < nameArray.count; i++) {
        SEL setSel = [self createSetSEL:nameArray[i]];
        if ([self respondsToSelector:setSel]) {
            
            NSMethodSignature* signature = [self methodSignatureForSelector:setSel];
            const char* c = [signature getArgumentTypeAtIndex:2];
            if (!memcmp(c, "@", 1)) {
                IMP imp = [self methodForSelector:setSel];
                void (*func) (id,SEL,id) = (void*)imp;
                func(self, setSel,dic[nameArray[i]]);
            }else if (!memcmp(c, "i", 1)||!memcmp(c, "q", 1)||!memcmp(c, "Q", 1)){
                int value = [dic[nameArray[i]] intValue];
                IMP imp = [self methodForSelector:setSel];
                void (*func) (id,SEL,int) = (void*)imp;
                func(self, setSel,value);
            }else if(!memcmp(c, "f", 1)){
                float value = [dic[nameArray[i]] floatValue];
                IMP imp = [self methodForSelector:setSel];
                void (*func) (id,SEL,float) = (void*)imp;
                func(self, setSel,value);
            }else if (!memcmp(c, "d", 1)) {
                double value = [dic[nameArray[i]] doubleValue];
                IMP imp = [self methodForSelector:setSel];
                void (*func) (id,SEL,double) = (void*)imp;
                func(self, setSel,value);
            }
        }
    }
}

static id objectType(NSString *typeString)
{
    if ([typeString containsString:@"@"]) {
        NSArray* strArray = [typeString componentsSeparatedByString:@"\""];
        if (strArray.count >= 1) {
            return strArray[1];
        }else
            return nil;
    }else
        return [typeString substringWithRange:NSMakeRange(1, 1)];
}

+(NSArray *)propertys{
    
    NSMutableArray * muPropertys = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *property_t = class_copyPropertyList(self, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = property_t[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        NSMutableArray *ignores = [NSMutableArray arrayWithObjects:@"hash",@"superclass", @"description",@"debugDescription",nil];
        
        if ([self respondsToSelector:@selector(propertyNamesForIgnore)]) {
            [ignores addObjectsFromArray:[self propertyNamesForIgnore]];
        }
        
        if (![ignores containsObject:propertyName]) {
            
            IHFProperty *theProperty = [[IHFProperty alloc] init];
            theProperty.property = property;
            theProperty.propertyName = propertyName;
            theProperty.typeString = objectType(propertyType);
            
            [muPropertys addObject:theProperty];
        }
    }
    free(property_t);
    return muPropertys;
}

+(void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration{
    
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

@end
