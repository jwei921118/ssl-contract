
# 艺术品存证合约

艺术品存在合约是用于对艺术品数据上链，更新，依赖用户合约


## UserCntInterface 

用户合约接口，用于根据用户合约identity 生成合约实例

### 接口暴露方法

#### senderGet

获取当前调用者

参数: 无

## 事件

### LOG_TABLE

将数据table化写入日志中，最主要用于小程序的查询，初次插入或者更新的时候都会触发

参数说明

| 类型 | 描述 |
| -----| ---- |
| string | json格式 | 

### LOG_CONST

在日志中记录静态数据，对艺术品不可变数据进行上链，调用insertArt 方法触发事件

参数说明

| 类型 | 描述 | 格式示例 |
| -----| ---- | ----|
| string | json格式 |  artName: 艺术品名称, author: 艺术品作者 , creationDate: 艺术品创作时间 , recordDate: 艺术品备案日期 , des: 描述 , ... 


### LOG_VAR 

在日志中记录动态数据，对艺术品可变数据上链， 调用insetArt updateArt 都会触发事件

参数说明

| 类型 | 描述 | 格式示例 |
| -----| ---- | ---- |
| string | json格式 | { escrowStatus: 托管状态, organizationName: 托管机构名称... } |

### COM_TRANSFER 

自定义物权转移事件，在调用updateArt 方法时触发

参数说明

| 类型 | 描述 | 
| -----| ---- | 
| string | 转出用户id |
| string | 转入用户id |
| string | 艺术品唯一hash |


## 对外方法

### init 

初始化合约

参数说明
| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| _userCntIdentity | identity | 用户合约地址 |

返回值: bool


### getArtInfoByHash

通过hash获取艺术品信息

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| hash | string | 艺术品唯一hash |

返回值:json 字符串
权限: 管理员权限

### authorize

授权方法, 艺术品所有人必须授权之后方可上线拍卖,在授权之前updateArt 方法不能调用

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| hash | string | 艺术品唯一hash |

返回值: (status: bool , msg: string)
权限: 无


### insertArt 

插入艺术品，及对艺术品进行初次上链， 调用成功会触发 LOG_TABLE 、 LOG_CONST 、LOG_VAR 事件

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| hash | string | 艺术品唯一hash |
| artId | string | 艺术品编号，鉴定中心提供 |
| constInfo | string | 艺术品静态数据 |
| varInfo | string | 艺术品动态数据 |

### updateArt 

更新艺术品信息，包括物权信息、价格等其他可变信息，调用会触发 LOG_VAR 、 COM_TRANSFER 事件 ，调用之前确保状态是可用

参数说明

| 字段名 | 类型 | 描述 |
| -----| ---- | ---- |
| hash | string | 艺术品唯一hash |
| owner | string | 用户id |
| latestPrice | uint | 最新价格 |
| varInfo | string | 艺术品动态数据 |









