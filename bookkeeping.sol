pragma solidity ^0.4.20;

library SafeMath {

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

library Utils {
    function compare_string(string a, string b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(a) == keccak256(b);
        }
    }
}


// 用户系统合约接口
contract UserCntInterface {
    function verifyAvailable(string addr) public view returns(bool);
    function verifySender(string addr) public view returns(bool);
    function getAccount(string addr) public returns(string memory);
}


contract Stablecoin {
    using SafeMath for uint;
    using Utils for *;

    event LOG_STRING(string);

    identity public owner;
    // 管理员map
    mapping(identity => bool) public adminSet;
    modifier onlyOwner { require(msg.sender == owner); _; }

    // 管理员
    modifier allowAdmin {
        require(msg.sender == owner || adminSet[msg.sender]); _;
    }

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

    // 用户合约接口指针
    UserCntInterface userCntInterface;
    uint8 public decimal;
    uint public totalSupply;
    mapping (string => uint) availableAccount;
    mapping (string => uint) freezeAccount;
    mapping(string => mapping (string => uint)) allowed;

    constructor() public { owner = msg.sender; }

    function init(identity _userCntIdentity) public onlyOwner returns(bool) {
        decimal = 2;
        // owner = msg.sender;
        userCntInterface = UserCntInterface(_userCntIdentity);
        return true;
    }


    event Transfer(string indexed _from, string indexed _to, uint _value);
    event Approval(string indexed _provider, string indexed _spender, uint _value);

    //增发可用账户
    function mintAvailable(string _to, uint _value) public allowAdmin returns(bool) {
        require(userCntInterface.verifyAvailable(_to),"unavailable account");
        availableAccount[_to] = availableAccount[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        return true;
    }

    //销毁可用账户
    function burntAvailable(string _to, uint _value) public allowAdmin returns(bool){
        // userCntInterface.verifyAvailable(_to);
        require(userCntInterface.verifyAvailable(_to),"unavailable account");
        require(availableAccount[_to] >= _value,"account is not enough");
        availableAccount[_to] = availableAccount[_to].sub(_value);
        totalSupply = totalSupply.sub(_value);
        return true;
    }

    //查询可用账户
    function balanceOfAvailable(string _addr) public view returns(uint){
        return availableAccount[_addr];
    }

    //增加冻结金额
    function mintFreeze(string _to, uint _value) public allowAdmin returns(bool) {
        require(userCntInterface.verifyAvailable(_to),"unavailable account");
        require(availableAccount[_to] > _value, "account is not enough");
        availableAccount[_to] = availableAccount[_to].sub(_value);
        freezeAccount[_to] = freezeAccount[_to].add(_value);
        totalSupply = totalSupply.sub(_value);
        return true;
    }

    //销毁冻结金额
    function burntFreeze(string _to,uint _value) public allowAdmin returns(bool){
        require(userCntInterface.verifyAvailable(_to),"unavailable account");
        require(freezeAccount[_to] >= _value, "freezeAccount is not enough");
        freezeAccount[_to] = freezeAccount[_to].sub(_value);
        return true;
    }
    //解冻冻结金额
    function unfreeze(string _to, uint _value) public allowAdmin returns(bool){
        require(userCntInterface.verifyAvailable(_to),"unavailable account");
        require(freezeAccount[_to] >= _value, "freezeAccount is not enough");
        freezeAccount[_to] = freezeAccount[_to].sub(_value);
        availableAccount[_to] = availableAccount[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        return true;
    }

    //查询冻结账户余额
    function balanceOfFreeze(string _addr) public view returns(uint){
        return freezeAccount[_addr];
    }
    //交易
    function transfer(string _from, string _to, uint _value) public allowAdmin returns(bool){
        // 判断账户是否存在
        // userCntInterface.verifyAvailable(_from);
        // userCntInterface.verifyAvailable(_to);
        require(userCntInterface.verifyAvailable(_from),"_from unavailable account");
        require(userCntInterface.verifyAvailable(_to),"_to unavailable account");
        require(userCntInterface.verifySender(_from), "Illegal user");
        require(!_from.compare_string(_to),"illegal transfer");
        // require(keccak256(_from) != keccak256(_to), "illegal transfer");
        require(availableAccount[_from] >= _value,"availableAccount is not enough");
        require(_value > 0, "transfer value must more then 0");
        availableAccount[_from] = availableAccount[_from].sub(_value);
        availableAccount[_to] = availableAccount[_to].add(_value);
        emit Transfer(_from,_to,_value);
        return true;
    }

    //批准_spender账户从自己的账户转移_value个token。可以分多次转移。
    function approve(string _provider, string _spender,uint _amount) public allowAdmin returns(bool){
        // userCntInterface.verifyAvailable(_provider);
        // userCntInterface.verifyAvailable(_spender);
        require(userCntInterface.verifyAvailable(_provider),"_provider unavailable account");
        require(userCntInterface.verifyAvailable(_spender),"_spender unavailable account");
        require(userCntInterface.verifySender(_provider), "Illegal user");
        require(availableAccount[_provider] >= _amount,"availableAccount is not enough");
        allowed[_provider][_spender] = _amount;
        emit Approval(_provider,_spender,_amount);
        return true;
    }

    //与approve搭配使用，approve批准之后，调用transferFrom函数来转移token。
    // @param {发债账户} _provider
    // @param {用债金额} _amount
    // return bool
    function transferFrom(string _provider, string _spender, uint _amount) public allowAdmin returns(bool){
        // userCntInterface.verifyAvailable(_provider);
        // userCntInterface.verifyAvailable(_spender);
        require(userCntInterface.verifyAvailable(_provider),"_provider unavailable account");
        require(userCntInterface.verifyAvailable(_spender),"_spender unavailable account");
        require(userCntInterface.verifySender(_spender), "Illegal user");
        require(availableAccount[_provider] >= _amount,"");
        require(allowed[_provider][_spender] >= _amount,"");
        require(_amount > 0,"");
        availableAccount[_provider] = availableAccount[_provider].sub(_amount);
        availableAccount[_spender] = availableAccount[_spender].add(_amount);
        emit Transfer(_provider,_spender,_amount);
        return true;
    }

    //返回_spender还能提取token的个数。
    function allowance(string _provider,string _spender) public allowAdmin view returns(uint){
        // userCntInterface.verifyAvailable(_provider);
        // userCntInterface.verifyAvailable(_spender);
        require(userCntInterface.verifyAvailable(_provider),"_provider unavailable account");
        require(userCntInterface.verifyAvailable(_spender),"_spender unavailable account");
        return allowed[_provider][_spender];
    }

} 