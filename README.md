# IHFDB

IHFDB是基于FMDB上的一层封装，通过直接函数调用而不用关心sql代码的实现。
GitHub上下载地址：https://github.com/cjsykx/IHFDB.git

关键说明：
1.通过NSObject+IHFDB.h 中的方法对数据进行CURL操作，将数据存入sqlite数据库中。并且可以根据自定义主键防止重复插入，使用deleteDirtyDataWithPredicate对网络中的脏数据进行删除。

>注意：在方法中都有预留IHFDBCompleteBlock(回调),tableName(操作的表),db(哪个库)，基本上都不用设置，用最简单的方法就可以

2.通过NSObject+IHFModelOperation.h对模型和字典进行互转操作。

3.IHFDBObjectDataSource.h可以设置
3.1.自定义主键 customPrimarykey（用来防止重复插入和根据主键查找）
3.2.映射关系 propertyNameDictForMapper（字典转模型和数据库操作都生效）
3.3.屏蔽字段 propertyNamesForIgnore（字典转模型和数据库操作都生效）
3.4.设置子项的类 relationshipDictForClassInArray（字典转模型和数据库操作都生效）
****
数据库中的CURL
****

使用方法：以模型Patient为例：

用户主要是调用NSObject+IHFDB.h中的方法，例如

****
创建表
****

```
//为Patient创建一张表名为Patient的表
[Patient createTable] ;

```
当然也可以使用Block回调，下面的增删改查的回调跟这个类似
```
[Patient createTableDidCompleteBlock:^(BOOL success) { // 创建成功后的回调; }]
```

如果想为Patient的关系类如例子中的Drugs建表，需要在Patient.m中声明。（不需要再调用[Drug createTable]来为子类建表） 
```
+ (NSDictionary *)relationshipDictForClassInArray {
return @{ @"drugs" : [Drug class],};
}
```

如果你不要创建跟类名一样的比如Patient,你可以通过传入Table name
```
+(BOOL)createTableWithName:(NSString *)tableName inDataBase:(FMDatabase *)db CompleteBlock:(IHFDBCompleteBlock)completion;
```

table name 为你想要的名称， 建议不要修改，修改后增删改查都要调用类似这样的方法（增删改查都提供）

db 默认是空的 ， 但是你可以在如下
```
[_queue inDatabase:^(FMDatabase *db) { // 在已经开始的操作下调用 }];
```
##### 增删改查与此同理#####


****
插入 
****

```
[Patient save]; //执行插入
```

> 建议在病人多的情况下，调用如下

```
[Patient saveModelArray:PatientArray completeBlock:^(BOOL success) {
NSLog(@"因为这是使用事务,增加插入速度"); 
}];
```
如果要插入子项，也就是
```
+ (NSDictionary *)relationshipDictForClassInArray { return @{ 
@"drugs" : [Drug class],}; 
}
```

****
查询
****


> 同上，有block的回调，db和tableName

跟Core Data 一样使用 predicate ，但是predicate 是自定义的IHFPredicate. 使用如下：
```
IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"name = %@",@"张飞"]; 
[patient updateWithPredicate:predicate completeBlock:^(BOOL success) { }];
```

1.可以找这个Patient表中的所有数据，你可以
```
[Patient selectAll]; 
```
2.可以查找数量
```
+ (NSInteger)selectCountWithPredicate:(IHFPredicate *)predicate;
```
3.可以根据主键来找
```
+ (NSArray *)selectWithCostomPrimaryKeyValue:(id)value ;
```
但是你要设置主键
```
+ (NSString *)customPrimarykey{
return @"patientID";
}
```

> 我们会将你要找的类和关联的类全部转成对象。

****
删除
****

// 删除与上述的都类似
> 唯一注意的 cascade ：级联
```
+(void)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion
{
// cascade 来设置级联
}
```

默认cascade yes . 也就是级联， 就是说当你删除了这个类后，会将他所关联的类都进行删除。当然你也可以设置成只删除这个类，不影响他的关联的类。

****
更新 
****


跟上述的类似，也有级联关系 
```
-(void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;
```
级联默认是yes ，也就是会让Patient病人下的所以关系表更加Patient的值重新更新一次，如果是Not，就算Patient下有Bed模型，也只会更新Patient的属性，关系表不做更新。


> 可以直接 deleteDirtyDataWithPredicate ，用Predicate对你网络请求的区间对脏数据进行删除和更新！就不要需要自己去删除和更新

****
模型与字典的转换
****

把模型转成字典
```
- (NSDictionary *)dictionaryFromModel;
```


把模型数组转成字典数组 （类方法和实例方法）
```
- (NSArray <NSDictionary *> *)dictionaryArrayFromModelArray;
```
```
+ (NSArray <NSDictionary *> *)dictionaryArrayFromModelArray:(NSArray *)modelArray;
```

把字典转成模型
```
+ (instancetype)modelFromDictionary:(NSDictionary *)dict;
```

把模型转成字典
```
+ (NSArray <id> *)modelArrayFromDictionaryArray:(NSArray <NSDictionary *> *)dict;
```
> 可以设置字典映射,和设置子项的类等信息

--------------------------- 也可以通过简书 http://www.jianshu.com/p/1f6e56ed76de 也看看说明。
有问题的话assues我163邮箱：cjsykx@163.com. 谢谢！



