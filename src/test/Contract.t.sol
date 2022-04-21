// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import { ClonesWithImmutableArgs } from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";
import { Clone } from "clones-with-immutable-args/Clone.sol";

contract Vault is Clone {
    address internal owner_;

    function _OWNER() internal pure returns (address) {
        return _getArgAddress(0);
    }

    function owner() public view returns (address owner) {
        owner_ == address(0) ? owner = _OWNER() : owner = owner_;
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner(), "not owner");
        require(_newOwner != address(0), "renounce to another address");
        owner_ = _newOwner;
    }
}

contract Vault2 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner, "not owner");
        owner = _newOwner;
    }
}

contract CloneFactory {
    using ClonesWithImmutableArgs for address;
    Vault public implementation;

    constructor() {
        implementation = new Vault();
    }

    function createClone(address owner) external returns (Vault clone) {
        bytes memory data = abi.encodePacked(owner);
        clone = Vault(address(implementation).clone(data));
    }
}

contract VaultFactory {
    function createVault(address owner) external returns (Vault2 vault) {
        vault = new Vault2(owner);
    }
}

contract ContractTest is Test {
    CloneFactory cloneFactory;
    VaultFactory vaultFactory;

    function setUp() public {
        cloneFactory = new CloneFactory();
        vaultFactory = new VaultFactory();
    }

    function testClone() public {
        Vault clone = cloneFactory.createClone(address(this));
        assertEq(address(this), clone.owner());
        clone.transferOwnership(address(1));
        assertEq(address(1), clone.owner());
    }

    function testCreate() public {
        Vault2 vault = vaultFactory.createVault(address(this));
        assertEq(address(this), vault.owner());
        vault.transferOwnership(address(1));
        assertEq(address(1), vault.owner());
    }
}
