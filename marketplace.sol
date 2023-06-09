pragma solidity ^0.8.0;

contract Marketplace {
    struct Product {
        uint256 id;
        address seller;
        string name;
        uint256 price;
        uint256 quantity;
    }

    uint256 public productCount;
    mapping(uint256 => Product) public products;

    event ProductAdded(uint256 id, address indexed seller, string name, uint256 price, uint256 quantity);
    event ProductPurchased(uint256 id, address indexed buyer, address indexed seller, string name, uint256 price, uint256 quantity);

    function addProduct(string memory _name, uint256 _price, uint256 _quantity) public {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(_price > 0, "Price must be greater than zero");
        require(_quantity > 0, "Quantity must be greater than zero");

        productCount++;

        products[productCount] = Product(
            productCount,
            msg.sender,
            _name,
            _price,
            _quantity
        );

        emit ProductAdded(productCount, msg.sender, _name, _price, _quantity);
    }

    function purchaseProduct(uint256 _id, uint256 _quantity) public payable {
        require(_id > 0 && _id <= productCount, "Invalid product ID");
        Product storage product = products[_id];
        require(product.quantity >= _quantity, "Insufficient product quantity");
        require(msg.value >= product.price * _quantity, "Insufficient payment");

        product.quantity -= _quantity;

        emit ProductPurchased(_id, msg.sender, product.seller, product.name, product.price, _quantity);

        if (msg.value > product.price * _quantity) {
            uint256 refundAmount = msg.value - (product.price * _quantity);
            payable(msg.sender).transfer(refundAmount);
        }
    }
}
