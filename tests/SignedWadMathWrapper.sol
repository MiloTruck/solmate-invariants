// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {SignedWadMath} from "contracts/SignedWadMath.sol";

contract SignedWadMathWrapper {
    function toWadUnsafe(uint256 x) external pure returns (int256) {
        return SignedWadMath.toWadUnsafe(x);
    }

    function toDaysWadUnsafe(uint256 x) external pure returns (int256) {
        return SignedWadMath.toDaysWadUnsafe(x);
    }

    function fromDaysWadUnsafe(int256 x) external pure returns (uint256 r) {
        return SignedWadMath.fromDaysWadUnsafe(x);
    }

    function unsafeWadMul(int256 x, int256 y) external pure returns (int256 r) {
        return SignedWadMath.unsafeWadMul(x, y);
    }

    function unsafeWadDiv(int256 x, int256 y) external pure returns (int256) {
        return SignedWadMath.unsafeWadDiv(x, y);
    }

    function wadMul(int256 x, int256 y) external pure returns (int256) {
        return SignedWadMath.wadMul(x, y);
    }

    function wadDiv(int256 x, int256 y) external pure returns (int256) {
        return SignedWadMath.wadDiv(x, y);
    }

    function wadPow(int256 x, int256 y) external pure returns (int256) {
        return SignedWadMath.wadPow(x, y);
    }

    function wadExp(int256 x) external pure returns (int256) {
        return SignedWadMath.wadExp(x);
    }

    function wadLn(int256 x) external pure returns (int256) {
        return SignedWadMath.wadLn(x);
    }

    function unsafeDiv(int256 x, int256 y) external pure returns (int256) {
        return SignedWadMath.unsafeDiv(x, y);
    }
}
