
pragma ton-solidity >= 0.35.0;

struct Purchase {
        uint id;
        string name;
        uint quantity;
        uint purchasedAt;
        bool isPaid;
        uint price;
    }