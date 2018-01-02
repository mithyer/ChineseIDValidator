# ChineseIDValidator
中国身份证号验证，信息获取，创造新ID


## 身份证验证

```
let validator = id.CNIDValidator(withTypeOption: .both) // typeOption: 验证的类型，可以是老15位，或者新18位，默认都选
let isValid = validator.isValid // 看是否合法
if isValid {
    let info = validator.info!
    let type = info.type
    let district1Name = info.districtInfo[.district1]?.name
    let district2Name = info.districtInfo[.district2]?.name
    let district3Name = info.districtInfo[.district3]?.name
    let birthdayDateString = info.birthDayInfo.dateString
    let birthdayDate = info.birthDayInfo.date
    let gender = info.gender
}

```


## 伪造身份证
```
let fakedId = CNID.Faker(withTypeOption: .both, withForm: CNID.districtForm).id // 和验证有类似的可选参数，不填则用默认值
```


## 行政区划表

表单数据来自http://www.stats.gov.cn/tjsj/tjbz/xzqhdm/

可从服务端获取数据后更新本地验证表单

```
do {
    try CNID.updateForm(formData: newData, version: "20180101")
} catch {
    print(error)
}
```

Or

```
do {
    try CNID.updateForm(formDataDic: newDataDic, version: "20180101")
} catch {
    print(error)
}
```


## 原理

[18位身份证原理](http://www.cnblogs.com/xudong-bupt/p/3293838.html) 

15位和18位比年份少了头2位“19”，且没有验证码