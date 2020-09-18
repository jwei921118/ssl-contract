# 记账合约

稳定币合约是一个记录这和人名币换算保持一致的合约，依赖于用户合约，只有用户合约存在的用户才会使用稳定币合约，主要作用是当作钱包，供清分合约调用
 
## 部署 

稳定币合约部署需要需要一个参数，用户合约的地址，用于稳定币合约调用用户合约



## UserCntInterface 

用户合约接口，用于根据用户合约identity 生成合约实例

### 接口暴露方法

#### verifyAvailable

验证用户可用状态

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| addr | string | 用户唯一id |


## 合约事件

### Transfer 转帐事件

调用转账方法时触发，可在SDK订阅监听事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _from | string | 转出id |
| _to | string | 转入id |
| _value | uint | 金额 |



### Approval 预授权

调用预授权方法时触发，可在SDK订阅监听事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _provider | string | 授权方id |
| _spender | string | 接收方id |
| _value | uint | 金额 |



## 对外状态

### decimal

精度 ，默认未2 , 表示10^2 , 表示稳定币精确到分

### totalSupply 

合约发行总数（可用总数，不包括冻结，销毁）

## 对外方法

### init 

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _userCntIdentity | identity | 用户合约地址 |

返回值: bool

### mintAvailable 增发

给可用用户增发稳定币

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _to | string | 新增用户id |
| _value | uint | 金额 |

返回值 bool 执行成功返回true


### burntAvailable 销毁

销毁用户的稳定币

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _to | string | 用户id |
| _value | uint | 金额 |

返回值 bool 执行成功返回true


### balanceOfAvailable 查询用户可用稳定币

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _addr | string | 用户id |

返回值 uint ， 返回可用账户金额


### mintFreeze 冻结账户金额

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _to | string | 用户id |
| _value | uint | 金额 |

返回值 bool

### burntFreeze 销毁冻结金额

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _to | string | 用户id |
| _value | uint | 金额 |

返回值 bool

### unfreeze 解冻账户金额

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _to | string | 用户id |
| _value | uint | 金额 |

返回值 bool


### balanceOfFreeze 查询冻结金额

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _to | string | 用户id |

返回值 uint 冻结金额的值 


### transfer 转账

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _from | string | 用户id |
| _to | string | 用户id |
| _value | uint | 金额 |

返回值 bool






