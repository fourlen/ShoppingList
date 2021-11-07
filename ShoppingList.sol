
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "PurchaseStruct.sol";
import "PurchaseSummary.sol";
import "IShoppingList.sol";

contract ShoppingList is IShoppingList {

    uint ownerPubkey;
    uint counter;
    mapping(uint => Purchase) purchases;

    constructor(uint pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        ownerPubkey = pubkey;
    }

    modifier onlyOwner() {
        require(msg.pubkey() == ownerPubkey, 101);
        _;
    }

    function addPurchase(string name, uint quantity) external override onlyOwner {
        tvm.accept();
        counter++;
        purchases[counter] = Purchase(counter, name, quantity, now, false, 0);
    }

    function payForPurchase(uint id, uint price) external override onlyOwner{
        require(purchases.exists(id), 101);
        tvm.accept();
        purchases[id].isPaid = true;
        purchases[id].price = price;
    }

    function removePurchase(uint id) external override onlyOwner {
        require(purchases.exists(id), 101);
        tvm.accept();
        delete purchases[id];
    }

    function getStat() external view override returns (PurchaseSummary stat) {
        uint paidCount;
        uint unpaidCount;
        uint summary;
        for ((, Purchase purchase) : purchases) {
            if (purchase.isPaid) {
                paidCount++;
                summary += purchase.price;
            }
            else {
                unpaidCount++;
            }
        }
        stat = PurchaseSummary(paidCount, unpaidCount, summary);
    }

    function getPurchases() external view override returns (Purchase[] purchasesArr) {
        for ((, Purchase purchase) : purchases) {
            purchasesArr.push(purchase);
        }
    }
}