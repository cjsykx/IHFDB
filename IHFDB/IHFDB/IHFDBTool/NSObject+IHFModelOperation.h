//
//  NSObject+IHFModelOperation.h
//  IHFDB
//
//  Created by CjSon on 16/6/15.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHFProperty.h"
#import "IHFDBObjectDataSource.h"
@interface NSObject (IHFModelOperation)<IHFDBObejctDataSource>

// Model convert to dict
-(NSDictionary *)dictionaryBeConvertedFromModel;


// model Array convert to dict Array
-(NSArray <NSDictionary *> *)dictionaryArrayBeConvertedFromModelArray;

//字典转model
+(instancetype)modelBeConvertFromDictionary:(NSDictionary *)dict;

+(NSArray <id> *)modelArrayBeConvertFromDictionaryArray:(NSArray <NSDictionary *> *)dict;


/** return all property name */

+(NSArray *)getAllPropertyName;
-(NSArray *)getAllPropertyName;

/** return all property name and type */

+(NSDictionary *)getAllPropertyNameAndType;
-(NSDictionary *)getAllPropertyNameAndType;

-(NSString *)getTypeNameWith:(NSString *)propertyName;

-(void)setValue:(NSObject *)value propertyName:(NSString *)name propertyType:(NSString *)type;

/** return type name in sqlite with the type  */

-(NSString *)sqlTypeNameWithTypeName:(NSString *)TypeName;

/** Give the model assignment */

-(void)giveWithDict:(NSDictionary *)dic;

/** Get value with property name */

- (id)getValueWithPropertName:(NSString *)propertyName;

// Block
typedef void (^IHFPropertiesEnumeration)(IHFProperty *property,NSUInteger idx, BOOL *stop);

/** Enumerate the model's properties use block*/

+ (void)enumeratePropertiesUsingBlock:(IHFPropertiesEnumeration)enumeration;


@end
