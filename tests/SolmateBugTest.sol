// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {TestHelper} from "./helper/TestHelper.sol";
import {SignedWadMathWrapper} from "./wrapper/SignedWadMathWrapper.sol";

contract SolmateBugTest is TestHelper {
    SignedWadMathWrapper signedWadMathWrapper;

    constructor() {
        signedWadMathWrapper = new SignedWadMathWrapper();
    }

    // Check that wadMul() reverts if x * y > type(int256).max
    function wadMulBothNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y < 0
        - x * y > int256 max
        */
        x = clampLt(x, 0);
        y = clampLt(y, type(int256).max / x);

        // Action: Call wadMul()
        bytes memory reason = expectRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulBothNegativeOverflow() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadMulBothNegativeOverflow() reverted with message"
        );
    }  
}
