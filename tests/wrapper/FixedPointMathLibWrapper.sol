// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {FixedPointMathLib} from "contracts/FixedPointMathLib.sol";

contract FixedPointMathLibWrapper {
    function mulWadDown(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.mulWadDown(x, y);
    }

    function mulWadUp(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.mulWadUp(x, y);
    }

    function divWadDown(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.divWadDown(x, y);
    }

    function divWadUp(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.divWadUp(x, y);
    }

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) external pure returns (uint256) {
        return FixedPointMathLib.mulDivDown(x, y, denominator);
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) external pure returns (uint256) {
        return FixedPointMathLib.mulDivUp(x, y, denominator);
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) external pure returns (uint256) {
        return FixedPointMathLib.rpow(x, n, scalar);
    }

    function sqrt(uint256 x) external pure returns (uint256) {
        return FixedPointMathLib.sqrt(x);
    }

    function unsafeMod(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.unsafeMod(x, y);
    }

    function unsafeDiv(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.unsafeDiv(x, y);
    }

    function unsafeDivUp(uint256 x, uint256 y) external pure returns (uint256) {
        return FixedPointMathLib.unsafeDivUp(x, y);
    }
}
