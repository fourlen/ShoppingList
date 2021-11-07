pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "InitialListDebot.sol";

contract BaseDebot is InitialListDebot  {
    function _menu() virtual internal override {}

    function printPurchases() public {
        optional(uint256) none;
        IShoppingList(contractAddress).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printPurchases_),
            onErrorId: 0
        }();
    }

    function printPurchases_(Purchase[] purchases) public {
        for (uint i = 0; i < purchases.length; i++) {
            Purchase currentPurchase = purchases[i];
            if (currentPurchase.isPaid) {
                Terminal.print(0, format("ID: {}\nName: {}\nQuantity: {}\nTime: {}\nPrice: {}\n PURCHASED", 
                currentPurchase.id,
                currentPurchase.name,
                currentPurchase.quantity,
                currentPurchase.purchasedAt,
                currentPurchase.price
                ));
            }
            else {
                Terminal.print(0, format("ID: {}\nName: {}\nQuantity: {}\nTime: {}\n NOT PURCHASED YET", 
                currentPurchase.id,
                currentPurchase.name,
                currentPurchase.quantity,
                currentPurchase.purchasedAt
                ));
            }
        }
    }

    function removePurchase() public {
        if (stat.paidPurchases + stat.unpaidPurchases > 0) {
            Terminal.input(tvm.functionId(removePurchase_), "Input ID of purchase: ", false);
        }
        else {
            Terminal.print(0, "Shopping list is empty.");
            _menu();
        }
    }

    function removePurchase_(string value) public {
        (uint id, bool status) = stoi(value);
        if (status) {
            optional(uint256) pubkey = 0;
            IShoppingList(contractAddress).removePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(id);
        }
        else {
            Terminal.print(0, "ID must be a numer");
        }
    } 
}