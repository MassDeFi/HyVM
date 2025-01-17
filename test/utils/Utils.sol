// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import "forge-std/Test.sol";

library Utils {
    function iToHex(bytes memory buffer) internal pure returns (string memory) {
        return iToHex(buffer, 0);
    }

    function iToHex(bytes memory buffer, uint256 padTo) internal pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        uint256 len = buffer.length > padTo ? buffer.length : padTo;
        bytes memory converted = new bytes(len * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        for (uint256 i = buffer.length * 2; i < padTo * 2; i++) {
            converted[i] = "0";
        }

        return string(abi.encodePacked("0x", converted));
    }

    function replace(bytes memory data, address _find, address _replaceBy)
        internal
        pure
        returns (bytes memory replaced)
    {
        bytes memory find = abi.encodePacked(_find);

        uint256 idx = 0;
        while (true) {
            (bool success, uint256 at) = indexOf(data, find, idx);
            if (!success) {
                return data;
            }

            bytes memory replaceBy = abi.encodePacked(_replaceBy);
            for (uint256 i = 0; i < replaceBy.length; i++) {
                data[at + i] = replaceBy[i];
            }
            idx = at + 1;
        }
        return data;
    }

    function replaceFirstOccurenceBytes(bytes memory data, bytes memory find, bytes memory replaceBy)
        internal
        pure
        returns (bytes memory replaced)
    {
        (bool success, uint256 at) = indexOf(data, find, 0);
        if (!success) {
            return data;
        }

        for (uint256 i = 0; i < replaceBy.length; i++) {
            data[at + i] = replaceBy[i];
        }
        return data;
    }

    function replaceSelectorBypassCalldataSizeCheck(bytes memory bytecode, bytes memory selector)
        internal
        pure
        returns (bytes memory finalBytecode)
    {
        // we replace the function selector by 0 to
        // run the function by default
        bytes memory zeroSelector = hex"00000000";
        bytes memory removedSelector = replaceFirstOccurenceBytes(bytecode, selector, zeroSelector);
        // bypass the calldata size check
        bytes memory calldataSizeCheck = hex"6004";
        bytes memory bypassCalldataSizeCheck = hex"6000";
        finalBytecode = replaceFirstOccurenceBytes(removedSelector, calldataSizeCheck, bypassCalldataSizeCheck);
    }

    function indexOf(bytes memory data, bytes memory find, uint256 startAt)
        internal
        pure
        returns (bool success, uint256 index)
    {
        uint256 fl = find.length;
        if (data.length < fl) {
            return (false, 0);
        }
        uint256 len = data.length - fl + 1;
        for (uint256 i = startAt; i < len; i++) {
            bool ok = true;
            for (uint256 j = 0; j < fl; j++) {
                if (data[i + j] != find[j]) {
                    ok = false;
                    break;
                }
            }
            if (ok) {
                return (true, i);
            }
        }
        return (false, 0);
    }
}
