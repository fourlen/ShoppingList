pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "BaseDebot.sol";

contract WalkingInShopDebot is BaseDebot {

    uint id;

    function _menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{} purchases. Summary paid: {}",
                    stat.paidPurchases,
                    stat.unpaidPurchases,
                    stat.summary
            ),
            sep,
            [
                MenuItem("Print purchases","",tvm.functionId(printPurchases)),
                MenuItem("Remove purchase","",tvm.functionId(removePurchase)),
                MenuItem("Pay for purchase","",tvm.functionId(payForPurchase))
            ]
        );
    }

    function payForPurchase() public {
        Terminal.input(tvm.functionId(payForPurchase_), "Input ID: ", false);
    }

    function payForPurchase_(string value) public {
        (uint _id, bool status) = stoi(value);
        id = _id;
        Terminal.input(tvm.functionId(payForPurchase__), "Input quantity: ", false);
    }

    function payForPurchase__(string value) public {
        (uint price, bool status) = stoi(value);
        optional(uint256) pubkey = 0;
        IShoppingList(contractAddress).payForPurchase{
            abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
        }(id, price);
    }
}