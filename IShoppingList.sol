
pragma ton-solidity >= 0.35.0;

import "PurchaseSummary.sol";
import "PurchaseStruct.sol";

interface IShoppingList {
    function addPurchase(string name, uint quantity) external;
    function payForPurchase(uint id, uint price) external;
    function removePurchase(uint id) external;
    function getStat() view external returns (PurchaseSummary);
    function getPurchases() view external returns (Purchase[]);
}