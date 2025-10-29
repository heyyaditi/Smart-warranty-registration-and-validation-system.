// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartWarranty {
    // Structure to hold warranty info
    struct Warranty {
        string productName;
        address owner;         // current owner of the product
        uint256 purchaseDate;  // timestamp when warranty starts
        uint256 warrantyPeriod; // duration in seconds
        bool valid;
    }

    // Map product serial number to its warranty info
    mapping(string => Warranty) public warranties;

    // Address of the manufacturer/seller (the deployer)
    address public manufacturer;

    // Events for transparency
    event WarrantyRegistered(string serialNumber, address indexed owner);
    event OwnershipTransferred(string serialNumber, address indexed newOwner);
    event WarrantyChecked(string serialNumber, bool isValid);

    constructor() {
        manufacturer = msg.sender; // the one who deploys is the manufacturer
    }

    // Register a new product warranty (only manufacturer)
    function registerWarranty(
        string memory _serialNumber,
        string memory _productName,
        address _buyer,
        uint256 _warrantyPeriodInDays
    ) public {
        require(msg.sender == manufacturer, "Only manufacturer can register");
        require(warranties[_serialNumber].purchaseDate == 0, "Already registered");

        warranties[_serialNumber] = Warranty({
            productName: _productName,
            owner: _buyer,
            purchaseDate: block.timestamp,
            warrantyPeriod: _warrantyPeriodInDays * 1 days,
            valid: true
        });

        emit WarrantyRegistered(_serialNumber, _buyer);
    }

    // Check if warranty is still valid
    function checkWarranty(string memory _serialNumber) public view returns (bool) {
        Warranty memory w = warranties[_serialNumber];
        if (!w.valid) return false;
        bool active = (block.timestamp <= w.purchaseDate + w.warrantyPeriod);
        return active;
    }

    // Transfer ownership (e.g., resale)
    function transferOwnership(string memory _serialNumber, address _newOwner) public {
        Warranty storage w = warranties[_serialNumber];
        require(msg.sender == w.owner, "Only current owner can transfer");
        require(w.valid, "Warranty not valid");
        w.owner = _newOwner;

        emit OwnershipTransferred(_serialNumber, _newOwner);
    }

    // Manufacturer can revoke or mark a warranty as invalid (optional)
    function revokeWarranty(string memory _serialNumber) public {
        require(msg.sender == manufacturer, "Only manufacturer can revoke");
        warranties[_serialNumber].valid = false;
    }
}

