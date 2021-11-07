pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "BaseDebot.sol";

contract FillShoppingListDebot is BaseDebot {

    string name;

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
                MenuItem("Add purchases","",tvm.functionId(addPurchase)),
                MenuItem("Print purchases","",tvm.functionId(printPurchases)),
                MenuItem("Remove purchase","",tvm.functionId(removePurchase))
            ]
        );
    }

    function addPurchase() public {
        Terminal.input(tvm.functionId(addPurchase_), "Input name of purchase: ", false);
    }

    function addPurchase_(string value) public {
        name = value;
        Terminal.input(tvm.functionId(addPurchase__), "Input quantity: ", false);
    }

    function addPurchase__(string value) public {
        (uint quantity, bool status) = stoi(value);
        optional(uint256) pubkey = 0;
        IShoppingList(contractAddress).addPurchase{
            abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
        }(name, quantity);
    }
}