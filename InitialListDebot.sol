
pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "base/Debot.sol";
import "base/Sdk.sol";
import "base/Terminal.sol";
import "base/Upgradable.sol";
import "base/Menu.sol";
import "base/AddressInput.sol";
import "IShoppingList.sol";
import "HasConstructorWithPubKey.sol";
import "TransactableInterface.sol";


abstract contract InitialListDebot is Debot, Upgradable {
    TvmCell stateInit;
    // TvmCell listCode;
    uint pubKey;
    address contractAddress;
    address userWalletAddress;
    PurchaseSummary stat;

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {}

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID ];
    }


    function setListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        // listCode = code;
        stateInit = tvm.buildStateInit(code, data);
    }

    function savePublicKey(string value) public {
        (uint resault, bool status) = stoi("0x" + value);
        if (status) {
            pubKey = resault;
            TvmCell deployState = tvm.insertPubkey(stateInit, pubKey);
            contractAddress = address.makeAddrStd(0, tvm.hash(deployState));
            Sdk.getAccountType(tvm.functionId(checkAccountType), contractAddress);
        }
        else {
            Terminal.input(tvm.functionId(savePublicKey), "Wrong pubkey. Try again.", false);
        }
    }

    function checkAccountType(int8 accType) public {
        if (accType == -1) {
            Terminal.print(0, "You don't shopping list yet. Contract with initial balance of 0.2 tokens will be deployed.");
            AddressInput.get(tvm.functionId(creditAccount), "Select a wallet for payment.");
        }
        else if (accType == 0) {
            Terminal.print(0, "Deploying...");
            deploy();
        }
        else if (accType == 1) {
            _getStat(tvm.functionId(setStat));
            Terminal.print(0,
            format("You have {}/{}/{} (paid, unpaid, total) purchases.",
            stat.paidPurchases,
            stat.unpaidPurchases,
            stat.paidPurchases + stat.unpaidPurchases));
        }
        else if (accType == 2) {
            Terminal.print(0, format("Error: account {} is frozen", contractAddress));
        }
    }

    function _getStat(uint32 answerId) public {
        optional(uint256) none;
        IShoppingList(contractAddress).getStat{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function setStat(PurchaseSummary _stat) public {
        stat = _stat;
        _menu();
    }

    function deploy() public view {
        TvmCell deployState = tvm.insertPubkey(stateInit, pubKey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: contractAddress,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: deployState,
                call: {HasConstructorWithPubKey, pubKey}
            });
        tvm.sendrawmsg(deployMsg, 1);
    }

    function onSuccess() public {
        _getStat(tvm.functionId(setStat));
    }

    function onErrorRepeatDeploy() public {
        deploy();
    }

    function creditAccount(address value) public {
        userWalletAddress = value;
        optional(uint256) none;
        TvmCell empty;
        TransactableInterface(userWalletAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(contractAddress, 200000000, false, 3, empty);
    }

    function waitBeforeDeploy() public {
        Sdk.getAccountType(tvm.functionId(checkIfAccountIsDeployed), contractAddress);
    }

    function checkIfAccountIsDeployed(int8 accType) public {
        if (accType == 0) {
            deploy();
        }
        else {
            waitBeforeDeploy();
        }
    }

    function onErrorRepeatCredit() public {
        creditAccount(userWalletAddress);
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function _menu() virtual internal;
}