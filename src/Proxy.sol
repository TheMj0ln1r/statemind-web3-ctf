// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin-contracts-4.8.0/contracts/utils/Address.sol"; 
import "@openzeppelin-contracts-4.8.0/contracts/proxy/utils/Initializable.sol";

contract Proxy {
    // bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    struct AddressSlot {
        address value;
    }
    
    constructor(address _logic, address _player) {
        require(Address.isContract(_logic), "implementation_not_contract");
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = _logic;

        (bool success,) = _logic.delegatecall(
            abi.encodeWithSignature("initialize(address)", _player)
        );

        require(success, "call_failed");
    }

    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // proxy fallback
    fallback() external payable virtual {
        _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }

    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract Executor is Initializable {
    address public owner;
    address public player;

    function initialize(address _player) external initializer {
        owner = msg.sender;
        player = _player;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not_owner");
        _;
    }
    
    function execute(address logic) external payable {
        (bool success,) = logic.delegatecall(abi.encodeWithSignature("exec()"));
        require(success, "call_fail");
    }

    function isSolved() external pure returns (bool) {
        return false;
    }
}