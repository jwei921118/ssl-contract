pragma solidity ^0.4.20;


// 用户操作权限合约
contract UserOperaAuth {
    identity public owner;
    // 管理员map
    mapping(identity => bool) public adminSet;
    modifier onlyOwner {  require(msg.sender == owner); _; }

    // 管理员
    modifier allowAdmin {
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


contract UserCnt is UserOperaAuth {

    // 用户信息
    struct UserInfo {
        string keyhash; // 用户验证xinxi
        bool available; // 用户状态
    }
    // 用户长度
    uint public userLens = 0;
    // 用户的addr 的映射
    mapping(string => uint) addrs;
    mapping(uint => UserInfo) userList;

    // 设置为激活用户
    string sender;

    // 添加用户
    event ADD_USER(
        uint indexed _inx,
        string addr
    );

    // 用户状态
    event HANDLER_STATUS(bool);


    // 注册用户
    function registerUser(string addr, string keyhash) public allowAdmin returns(bool) {
        require(addrs[addr] == 0, "User already exists");
        UserInfo memory user;
        user.keyhash = keyhash;
        user.available = true;
        userLens++;
        userList[userLens] = user;
        addrs[addr] = userLens;
        emit ADD_USER(userLens, addr);
        return true;
    }

    // 设置调用者
    function setSender(string addr, string keyhash) public allowAdmin returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        require(keccak256(userList[addrs[addr]].keyhash) == keccak256(keyhash), "verification failed");
        sender = addr;
    }

    // 冻结用户
    function freeze(string addr) public allowAdmin returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        userList[addrs[addr]].available = false;
        emit HANDLER_STATUS(false);
        return true;
    }

    // 解冻状态
    function unfreeze(string addr) public allowAdmin returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        userList[addrs[addr]].available = true;
        emit HANDLER_STATUS(true);
        return true;
    }


    // 更新keyhash
    function updateKeyhash(string addr, string keyhash) public allowAdmin returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        userList[addrs[addr]].keyhash = keyhash;
        return true;
    }

    // 验证keyhash
    function verifyKeyhash(string addr, string keyhash) public view returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        return keccak256(userList[addrs[addr]].keyhash) == keccak256(keyhash);
    }

    // 验证sender

    function verifySender(string addr) public view returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        return keccak256(addr) == keccak256(sender);
    }

    // 验证可用状态
    function verifyAvailable(string addr) public view returns(bool) {
        require(addrs[addr] > 0, "unregister user");
        return userList[addrs[addr]].available;
    }

    // 获取sender
    function senderGet() public returns(string memory) {
        string memory ret = sender;
        return ret;
    }
}