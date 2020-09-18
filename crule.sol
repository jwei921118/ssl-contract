pragma solidity ^0.4.20;

library CRstrings {
     struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }


     /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string self) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

     /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice self, slice other) internal pure returns (string) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
}

// 工具库
library CRutils {
    function uintToString(uint i) internal pure returns(string) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(uint8(48) + uint8(i % 10));
            i /= 10;
        }
        return string(bstr);
    }
}

// 安全计算库
library CSafeMath {

    //乘法
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
    //除法
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
    //减法
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
    //加法
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// 权限合约
contract COperaAuth {
    identity public owner;
    // 管理员map
    mapping(identity => bool) public adminSet;
    modifier onlyOwner () {  require(msg.sender == owner); _; }

    
    // 管理员
    modifier allowAdmin () {
        require(msg.sender == owner || adminSet[msg.sender]); _;
    }
    constructor() public { owner = msg.sender; }

    // 添加管理员
    function addAdmin(identity _id) public onlyOwner returns(bool) {
        adminSet[_id] = true;
        return true;
    }

    // 删除管理员
    function delAdmin(identity _id) public onlyOwner returns(bool) {
        adminSet[_id] = false;
        return true;
    }
}

// 用户系统合约接口
contract UserCntInterface {
    function senderGet() public returns(string memory);
    function verifyAvailable(string addr) public view returns(bool);
}


// 稳定币合约接口
contract StablecoinInterface {
    identity public owner;
    // 管理员map
    mapping(identity => bool) public adminSet;
    modifier onlyOwner { require(msg.sender == owner); _; }
    // 管理员
    modifier allowAdmin {
        require(msg.sender == owner || adminSet[msg.sender]); _;
    }
    function balanceOfAvailable(string _addr) public returns (uint);
    function transfer(string _from, string _to, uint _value) public allowAdmin returns(bool);
}

// 清分规则合约
contract CRules is COperaAuth {
    using CRstrings for *;
    using CSafeMath for uint;
    using CRutils for *;

    // 合约用户id
    string public contractUserAddr;

    // 精度
    // 总数 固定10000
    uint public totalSupply;
    // 合伙人大小
    uint public partnerSize;

    // 合约是否激活
    bool public activated;
    // sign数量
    // uint signedNum;

    // 合伙人列表

    struct account {
        string addr;
        uint value;
    }
    mapping(uint => account) accountList;
    mapping(string => uint) partnerNumber;

    event LOG_ADDR(int,string,uint);

    event LOG_VALUE(int,uint,uint);

    event LOG_PATH(string);

    event LOG_I(uint);

    // 定义用户合约接口
    UserCntInterface userCntInterface;
    // 定义稳定币合约接口
    StablecoinInterface stablecoinInterface;


    //***********************************************//
    // _userCntIdentity 用户合约地址
    // _scoinIdentity 稳定币合约地址
    // _addr 合约在用户系统的唯一id
    // _partnersJson 合伙人json "{\"partners\": [{\"addr\": \"realsu\", \"value\": 100} ,{\"addr\": \"huiy\", \"value\": 200}]}";
    // 部署本合约之前必须确保在用户合约注册一个合约用户， _addr 是用户id, account 为合约名称
    //***********************************************//
    function init(identity _userCntIdentity,identity _scoinIdentity, string _contractUserAddr, string memory _partnersJson) public returns(bool) {
        require(!activated, "contract is activated");
        totalSupply = 10000;
        contractUserAddr = _contractUserAddr;
        userCntInterface = UserCntInterface(_userCntIdentity);
        stablecoinInterface = StablecoinInterface(_scoinIdentity);
        return parseJson(_partnersJson);
    }

    // // 激活合约 只需执行一次 ，必须在权益分配完成之后方可执行
    // function activeContract() public allowAdmin returns(bool) {
    //     require(quotaCompleted, "quota uncompleted");
    //     activated = true;
    //     return activated;
    // }

    //添加合伙人
    // function addPartner(string _partner,uint _value) public allowAdmin returns(bool){
    //     require(!activated, "contract is activated");
    //     // 验证用户
    //     require(userCntInterface.verifyAvailable(_partner), "unavailable account");
    //     uint _nowTotalSupply = nowTotalSupply.add(_value);
    //     if(_nowTotalSupply <= totalSupply){
    //         if (partnerNumber[_partner] > 0) {
    //             uint inx = partnerNumber[_partner];
    //             accountList[inx].value = accountList[inx].value.add(_value);
    //         } else {
    //             partnerSize = partnerSize.add(1);
    //             partnerNumber[_partner] = partnerSize;
    //             accountList[partnerSize].addr = _partner;
    //             accountList[partnerSize].value = _value;
    //         }
    //          nowTotalSupply = _nowTotalSupply;
    //          if (nowTotalSupply == totalSupply) {
    //              quotaCompleted = true;
    //          }
    //         return true;
    //     }else{
    //         return false;
    //     }
    // }

    // 解析 数据
    // 格式 "{\"partners\": [{\"addr\": \"realsu\", \"value\": 100} ,{\"addr\": \"huiy\", \"value\": 200}]}";
    function parseJson(string memory data) private returns(bool) {
        emit LOG_PATH(data);
        string memory strKey = "partners[";
        int property_type = 0;
        uint handler = property_parse(data , property_type);
        partnerSize = property_get_list_count(handler, "partners");
        uint i = 0;
        uint total;
        for (; i < partnerSize; i++) {
            string memory addrPath = strKey.toSlice().concat(i.uintToString().toSlice());
            addrPath = addrPath.toSlice().concat("].addr".toSlice());
            string memory valuePath = strKey.toSlice().concat(i.uintToString().toSlice());
            valuePath = valuePath.toSlice().concat("].value".toSlice());
            emit LOG_PATH(addrPath);
            emit LOG_PATH(valuePath);
            int s;
            int v;
            string memory addr;
            uint value;
            (s, addr) = property_get_string(handler, addrPath);
            emit LOG_ADDR(s,addr,i);
            (v, value) = property_get_uint(handler, valuePath);
            emit LOG_VALUE(v,value,i);
            if (s == 0 && v == 0) {
                // partners[addr] = value;
                total.add(i);
                partnerNumber[addr] = i;
                accountList[i].addr = addr;
                accountList[i].value = value;
            } else {
                break;
            }
        }
        emit LOG_I(i);
        property_destroy(handler);
        if ( i == partnerSize && i != 0 && totalSupply == total) {
            activated = true;
            return true;
        } else {
            return false;
        }
    }

    // 签名 ，确认合约
    // function signed() public allowAdmin returns(bool) {
    //     require(quotaCompleted, "quota uncompleted");
    //     require(partnerNumber[userCntInterface.senderGet()] > 0, "No permission");
    //     require(!accountList[partnerNumber[userCntInterface.senderGet()]].signed, "user has signed");
    //     uint inx = partnerNumber[userCntInterface.senderGet()];
    //     accountList[inx].signed = true;
    //     signedNum.add(1);
    //     if (signedNum == partnerSize) {
    //         activated = true;
    //     } else {
    //         activated = false;
    //     }
    //     return true;
    // }

    // //交易
    // function transfer(string _from, string _to, uint _value) public allowAdmin returns(bool){
    //     require(!activated, "contract is activated");
    //     // 判断转账发起人是否为调用者
    //     require(keccak256(_from) != keccak256(_to), "illegal transfer");
    //     // 验证用户
    //     require(userCntInterface.verifyAvailable(_from),"_from unavailable account");
    //     require(userCntInterface.verifyAvailable(_to),"_to unavailable account");
    //     require(accountList[partnerNumber[_from]].value >= _value,"");
    //     if(partnerNumber[_to] < 1){
    //         accountList[partnerNumber[_from]].value = accountList[partnerNumber[_from]].value.sub(_value);
    //         nowTotalSupply = nowTotalSupply.sub(_value);
    //         bool isParterAdded = addPartner(_to,_value);
    //         if (!isParterAdded) {
    //             accountList[partnerNumber[_from]].value = accountList[partnerNumber[_from]].value.add(_value);
    //             nowTotalSupply = nowTotalSupply.add(_value);
    //         }
    //         return isParterAdded;
    //     }else{
    //         accountList[partnerNumber[_from]].value = accountList[partnerNumber[_from]].value.sub(_value);
    //         accountList[partnerNumber[_to]].value = accountList[partnerNumber[_to]].value.add(_value);
    //     }
    //     return true;
    // }

    // 清分操作
    function handlerSettlement(uint money) public returns(string memory) {
        uint total = 0;
        string memory property_value;
        // 第一步调用 property_parse
        uint handler = property_parse(property_value, 0);

        for (uint i = 0; i < partnerSize; i++) {
            uint transferAmount = money.mul(accountList[i].value).div(totalSupply);
            total = total.add(transferAmount);
            if (transferAmount > 0) {
                stablecoinInterface.transfer(contractUserAddr, accountList[i].addr, transferAmount);
            }
            property_set_uint(handler, accountList[i].addr, transferAmount);
        }
        string memory ret = property_write(handler, 0);
        property_destroy(handler);
        return ret;
    }


    // 获取 合伙人分成值
    function balanceOf(string _id) public view returns(uint){
        return accountList[partnerNumber[_id]].value;
    }

    // 获取 合伙人索引
    function indexOfAccount(string _id) public view returns(uint) {
        return partnerNumber[_id];
    }
}