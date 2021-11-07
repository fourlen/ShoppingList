
pragma ton-solidity >= 0.35.0;

interface TransactableInterface {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell code) external;
}