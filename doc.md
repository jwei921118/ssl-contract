# 用户合约

继承权限合约

## 部署
无参数

## 存储信息

### 用户结构体

字段说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户id | 
| account | string | 手机号或者邮箱 |
| keyhash | string | 关键字 | 
| available | bool | 可用状态 |

## 对外属性

### sender 

当前合约调用者，类型string，表示一个用户的id，其他合约的方法调用依赖于这个属性


## 事件

外部可订阅

### ADD_USER

添加用户事件，调用注册用户方法触发事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _inx | uint | 用户索引 |
| addr | string | 用户id | 
| account | string | 账号或者姓名 |


### HANDLER_STATUS 

改变用户状态事件，在调用冻结用户或者解冻用户方法时触发事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| 无 | bool | 用户可用状态值 |


## 对外方法

### registerUser 

注册用户 会触发添加用户事件，已经注册的用户id返回错误

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |
| account | string | 账户或者姓名 |
| keyhash | string | 关键字 |

返回值 bool, 调用成功会返回true 

### setSender 

设置合约调用者, 其他合约需要用户调用转账或者私密操作的时候需要调用这个方法

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |
| keyhash | string | 关键字 |

返回值 bool, 调用成功会返回true 

### freeze 

冻结用户 将用户的状态设置未false，并触发HANDLER_STATUS事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |

返回值 bool

### unfreeze 

解冻用户 将用户的状态设置未true，并触发HANDLER_STATUS事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |

返回值 bool， 输入不存在的用户报错


### updateKeyhash 

更新关键字

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id | 
| keyhash | string | 关键字 |

返回值 bool， 输入不存在的用户报错


### verifyKeyhash 

验证关键字

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |
| keyhash | string | 关键字 |

返回值 bool， 输入不存在的用户报错



### verifySender 

验证调用者，验证调用者是否为当前调用者　

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |

返回值 bool， 输入不存在的用户报错

### verifyAvailable

验证可用状态

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |

返回值 bool， 输入不存在的用户报错
