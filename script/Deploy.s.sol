// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "foundry-huff/HuffDeployer.sol";

/// @notice Deploy the HyVM using CREATE2
contract Deploy is Script {
    // The address is the same on all EVM chains.
    Deployer public constant DEPLOYER = Deployer(0x35Da41c476fA5c6De066f20556069096A1F39364);

    function run() public returns (address deployedAddress) {
        string memory bashCommand = 'cast abi-encode "f(bytes)" $(huffc ./src/HyVM.huff --bytecode -e paris | head)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        bytes memory bytecode = abi.decode(vm.ffi(inputs), (bytes));
        bytes32 salt = keccak256("ALPHA");

        deployedAddress = DEPLOYER.computeAddress(salt, keccak256(bytecode));

        vm.startBroadcast();

        // Call CREATE2 Deployer
        DEPLOYER.deploy(0, salt, bytecode);

        // Check if contract deployed at expected address
        require(deployedAddress.code.length > 0, "HyVM not deployed");

        vm.stopBroadcast();

        return deployedAddress;
    }
}

// Create2 Deployer Interface
// https://github.com/pcaversaccio/create2deployer
interface Deployer {
    function deploy(uint256 value, bytes32 salt, bytes memory code) external;

    function computeAddress(bytes32 salt, bytes32 codeHash) external returns (address);
}