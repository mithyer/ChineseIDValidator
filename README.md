# ChineseIDValidator
中国身份证号验证，信息获取，创造新ID


## 身份证验证

```
let id = "123456789012345678"
let validator = id.CNIDValidator() // 构造validator
let isValid = validator.isValid // 身份证是否有效
if isValid { // 若合法则获取相应信息
  let info = validator.info!
  let type = info.type // 是15位还是18位, 类型：enum
  let district1Name = info.districtInfo[.district1]?.name // 一级行政区名字, 类型：String
  let district2Name = info.districtInfo[.district2]?.name // 二级行政区名字, 类型：String
  let district3Name = info.districtInfo[.district3]?.name // 三级行政区名字, 类型：String
  let birthdayDateString = info.birthDayInfo.dateString // 生日，类型：String，格式：yyyyMMdd
  let birthdayDate = info.birthDayInfo.date // 生日，类型：Date
  let gender = info.gender // 性别，类型: enum
}

```

## 验证时的可选参数

```
let validator = id.CNIDValidator(withTypeOption: .both, // typeOption: 验证的类型，可以是老15位，或者新18位，默认都选
                                 toDistrict: .district1, // district: 默认验证只验证到一级行政区，最高到三级行政区
                                 withForm: CNID.districtForm) // form: 行政区表单，我只填写了一级和部分二三级，
                                                              // 若要验证到二级以上需自行根据此网址填写: http://www.stats.gov.cn/tjsj/tjbz/xzqhdm/，
                                                              // 一级填前2位，二级填前4位，三级填满6位，也可从服务端获取，数据结构见CNID.districtForm
```


## 伪造身份证
```
let fakedId = CNID.Faker(withTypeOption: .both, withForm: CNID.districtForm).id // 和验证有类似的可选参数，不填则用默认值
```

## 原理

[18位身份证原理](http://www.cnblogs.com/xudong-bupt/p/3293838.html) 

15位和18位比年份少了头2位“19”，且没有验证码