# 清分合约

清分合约对于一个具体的分账业务而生成的合约，针对不同的分账（人员和比例的不同）需要需要多次部署

## 依赖合约

### 用户合约接口

#### 暴露方法

verifyAvailable: 验证用户状态
senderGet: 获取当前调用者

### 稳定币合约

#### 暴露方法
balanceOfAvailable: 查看用户稳定币数量
transfer: 转账

## 部署

清分合约的部署依赖于用户合约，和稳定币合约，部署之前需要在用户合约中注册一个清分合约用户

部署参数说明

<!-- | 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _userCntIdentity | identity | 用户合约地址 |
| _scoinIdentity | identity | 稳定币合约地址 |
| _addrId | string | 用户id |
| _accountName | string | 合约用户账号 |

由于清分合约需要调用稳定币的transfer，该方法是有管理员权限的，因此清分合约在调用清分方法之前需要调用稳定币合约的setAdmin 方法赋予该清分合约用户权限，参数为本清分合约的地址（identity），同时transfer 会判断_from 当前是否是合约用户，即在调用清分方法的时候需要在用户合约设置成为调用者 -->


## 对外属性

###  

合约id，对应用户合约系统的id

<!-- ### accountName -->

合约名称，用户系统合约的描述

### partnerSize

合伙人数量


### activated

表示合约状态

## 对外方法

<!-- ### addPartner

添加合伙人, 给分账的用户添加一定比例的值，范围在0-10000之间，10000表示只有一个用户分账

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _partner | string | 用户id |
| _value | uint | 金额 |

### signed

分账用户对合约分账比例的确认，只有当所有的用户都通过了，合约才可以激活

参数： 无
权限： 管理员权限调用 -->

<!-- 
### transfer

用户比例转移，合约激活之前调用

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _from | string | 转出账号 |
| _to | string | 转入账号 |
| _value | uint | 转入值 |

权限：管理员调用 -->

### init 

初始化合约方法

参数说明


| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _userCntIdentity | identity | 用户合约地址 |
| _scoinIdentity | identity | 稳定币合约地址 |
| _contractUserAddr | string | 合约在用户系统的唯一id |
| _partnersJson | string | 合伙人json 数据 格式 "{\"partners\": [{\"addr\": \"realsu\", \"value\": 100} ,{\"addr\": \"huiy\", \"value\": 200}]}" |

返回值: bool

由于清分合约需要调用稳定币的transfer，该方法是有管理员权限的，因此清分合约在调用清分方法之前需要调用稳定币合约的setAdmin 方法赋予该清分合约用户权限，参数为本清分合约的地址（identity），同时transfer 会判断_from 当前是否是合约用户，即在调用清分方法的时候需要在用户合约设置成为调用者




### handlerSettlement

清分操作，合约激活之后

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| money | uint | 清分金额 |


### balanceOf

查询用户比例

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _id | string | 用户id |

返回值: uint

### indexOfAccount

获取合伙人索引

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _id | string | 用户id |

返回值: uint








