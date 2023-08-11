// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {SignedWadMath} from "contracts/SignedWadMath.sol";
import {TestHelper} from "./helper/TestHelper.sol";
import {SignedWadMathWrapper} from "./wrapper/SignedWadMathWrapper.sol";

contract SignedWadMathTest is TestHelper {
    // SignedWadMath wrapper contract
    SignedWadMathWrapper signedWadMathWrapper;

    constructor() {
        signedWadMathWrapper = new SignedWadMathWrapper();
    }

    // ASSERTIONS

    function toWadUnsafe(uint256 x) public {
        // Precondition: x * 1e18 <= int256 max
        x = clampBetween(x, 1, uint256(type(int256).max) / 1e18);

        // Action: Call toWadUnsafe()
        int256 result = SignedWadMath.toWadUnsafe(x);

        /*
        Check: 
        - result > 0
        - result > x
        - result == x * 1e18
        */
        assertGt(result, 0, "testToWadUnsafe() result overflowed");
        assertGt(uint256(result), x, "testToWadUnsafe() result overflowed");
        assertEq(
            x * 1e18,
            uint256(result),
            "Wrong result for testToWadUnsafe()"
        );
    }

    function toWadUnsafeZero() public {
        // Action: Call toWadUnsafe(0)
        int256 result = SignedWadMath.toWadUnsafe(0);

        // Check: result == 0
        assertEq(result, 0, "Wrong result for testToWadUnsafeZero()");
    }

    function toWadUnsafeOverflow(uint256 x) public {
        // Precondition: x * 1e18 > int256 max
        x = clampGt(x, uint256(type(int256).max) / 1e18);

        // Action: Call toWadUnsafe()
        int256 result = SignedWadMath.toWadUnsafe(x);

        /*
        Check: 
        - result / 1e18 != x
        - result == x * 1e18, but unchecked
        */

        // If result is negative, it can't be equal to x * 1e18 as x is positive
        if (result >= 0) {
            assertNeq(
                uint256(result) / 1e18,
                x,
                "testToWadUnsafeOverflow() didn't overflow"
            );
        }
        unchecked {
            assertEq(
                int256(x * 1e18),
                result,
                "Wrong result for testToWadUnsafeOverflow()"
            );
        }
    }

    function toDaysWadUnsafe(uint256 x) public {
        // Precondition: x * 1e18 <= uint256 max
        x = clampBetween(x, 1, type(uint256).max / 1e18);

        // Action: Call toDaysWadUnsafe()
        int256 result = SignedWadMath.toDaysWadUnsafe(x);

        /*
        Check: 
        - result > 0
        - result > x
        - result == x * 1e18 / 86400
        */
        assertGt(result, 0, "testToWadUnsafe() result overflowed");
        assertGt(uint256(result), x, "testToWadUnsafe() result overflowed");
        assertEq(
            (x * 1e18) / 86400,
            uint256(result),
            "Wrong result for testToWadUnsafe()"
        );
    }

    function toDaysWadUnsafeZero() public {
        // Action: Call toDaysWadUnsafe(0)
        int256 result = SignedWadMath.toDaysWadUnsafe(0);

        // Check: result == 0
        assertEq(result, 0, "Wrong result for toDaysWadUnsafeZero()");
    }

    function toDaysWadUnsafeOverflow(uint256 x) public {
        // Precondition: x * 1e18 > uint256 max
        x = clampGt(x, type(uint256).max / 1e18);

        // Action: Call toDaysWadUnsafe()
        int256 result = SignedWadMath.toDaysWadUnsafe(x);

        /*
        Check: 
        - result * 86400 / 1e18 != x
        - result == x * 1e18 / 86400, but unchecked
        */

        // If result is negative, it can't be equal to x * 1e18 as x is positive
        if (result >= 0) {
            assertNeq(
                (uint256(result) * 86400) / 1e18,
                x,
                "toDaysWadUnsafeOverflow() didn't overflow"
            );
        }
        unchecked {
            assertEq(
                int256((x * 1e18) / 86400),
                result,
                "Wrong result for toDaysWadUnsafeOverflow()"
            );
        }
    }

    function fromDaysWadUnsafe(int256 x) public {
        // Precondition: x * 86400 <= uint256 max
        x = clampBetween(x, 1, int256(type(uint256).max / 86400));

        // Action: Call fromDaysWadUnsafe()
        uint256 result = SignedWadMath.fromDaysWadUnsafe(x);

        /*
        Check: 
        - result < x
        - result == x * 86400 / 1e18
        */
        assertLt(result, uint256(x), "fromDaysWadUnsafe() result overflowed");
        assertEq(
            (uint256(x) * 86400) / 1e18,
            result,
            "Wrong result for fromDaysWadUnsafe()"
        );
    }

    function fromDaysWadUnsafeZero() public {
        // Action: Call fromDaysWadUnsafe(0)
        uint256 result = SignedWadMath.fromDaysWadUnsafe(0);

        // Check: result == 0
        assertEq(result, 0, "Wrong result for fromDaysWadUnsafeZero()");
    }

    function fromDaysWadUnsafeOverflow(int256 x) public {
        // Precondition: x * 86400 > uint256 max
        x = clampGt(x, int256(type(uint256).max / 86400));

        // Action: Call fromDaysWadUnsafe()
        uint256 result = SignedWadMath.fromDaysWadUnsafe(x);

        /*
        Check: 
        - result * 1e18 / 86400 != x 
        - result == x * 86400 / 1e18, but unchecked
        */
        assertNeq(
            result * 1e18 / 86400,
            uint256(x),
            "fromDaysWadUnsafeOverflow() didn't overflow"
        );
        unchecked {
            assertEq(
                uint256(x) * 86400 / 1e18,
                result,
                "Wrong result for fromDaysWadUnsafeOverflow()"
            );
        }
    }

    function fromDaysWadUnsafeNegative(int256 x) public {
        // Precondition: x * 86400 > uint256 max
        x = clampLt(x, 0);

        // Action: Call fromDaysWadUnsafe()
        uint256 result = SignedWadMath.fromDaysWadUnsafe(x);

        /*
        Check: 
        - result == x * 86400 / 1e18, but unchecked
        */
        unchecked {
            assertEq(
                (uint256(x) * 86400) / 1e18,
                result,
                "Wrong result for fromDaysWadUnsafeNegative()"
            );
        }
    }

    function unsafeWadMulBothPositive(int256 x, int256 y) public {
        /*
        Precondition:
        - x > 0 and y > 0
        - x * y <= int256 max
        */
        x = clampGt(x, 0);
        y = clampBetween(y, 1, type(int256).max / x);

        // Action: Call unsafeWadMul()
        int256 result = SignedWadMath.unsafeWadMul(x, y);

        /*
        Check:
        - result >= 0
        - result == x * y / 1e18
        */
        assertGte(
            result,
            0,
            "Result not positive for unsafeWadMulBothPositive()"
        );
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for unsafeWadMulBothPositive()"
        );
    }

    function unsafeWadMulBothNegative(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y < 0
        - x * y <= int256 max
        */
        x = clampLt(x, 0);
        y = clampBetween(y, type(int256).max / x, -1);

        // Action: Call unsafeWadMul()
        int256 result = SignedWadMath.unsafeWadMul(x, y);

        /*
        Check:
        - result >= 0
        - result == x * y / 1e18
        */
        assertGte(
            result,
            0,
            "Result not positive for unsafeWadMulBothNegative()"
        );
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for unsafeWadMulBothNegative()"
        );
    }

    function unsafeWadMulSingleNegative(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y > 0
        - x * y >= int256 min
        */
        x = clampLt(x, 0);
        y = clampBetween(y, 1, type(int256).min / x);

        // Action: Call unsafeWadMul(x, y) and unsafeWadMul(y, x)
        int256 result = SignedWadMath.unsafeWadMul(x, y);
        int256 result2 = SignedWadMath.unsafeWadMul(y, x);

        /*
        Check:
        - For result and result2:
            - r <= 0
            - r == x * y / 1e18
        */
        assertLte(
            result,
            0,
            "Result not <= 0 for unsafeWadMulSingleNegative()"
        );
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for unsafeWadMulBothNegative()"
        );

        assertLte(
            result2,
            0,
            "Result not <= 0 for unsafeWadMulSingleNegative()"
        );
        assertEq(
            result2,
            (x * y) / 1e18,
            "Wrong result for unsafeWadMulBothNegative()"
        );
    }

    function unsafeWadMulZero(int256 x) public {
        // Action: Call unsafeWadMul(x, 0) and unsafeWadMul(0, x)
        int256 result = SignedWadMath.unsafeWadMul(x, 0);
        int256 result2 = SignedWadMath.unsafeWadMul(0, x);

        // Check: result == 0 and result2 == 0
        assertEq(result, 0, "Wrong result for unsafeWadMul(x, 0)");
        assertEq(result2, 0, "Wrong result for unsafeWadMul(0, x)");
    }

    function unsafeWadMulBothPositiveOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x > 0 and y > 0
        - x * y > int256 max
        */
        x = clampGt(x, 0);
        y = clampGt(y, type(int256).max / x);

        // Action: Call unsafeWadMul()
        int256 result = SignedWadMath.unsafeWadMul(x, y);

        // Check: result == x * y / 1e18, when unchecked
        unchecked {
            assertEq(
                result,
                (x * y) / 1e18,
                "Wrong result for unsafeWadMulBothPositiveOverflow()"
            );
        }
    }

    function unsafeWadMulBothNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y < 0
        - x * y > int256 max
        */
        x = clampLt(x, 0);
        y = clampLt(y, type(int256).max / x);

        // Action: Call unsafeWadMul()
        int256 result = SignedWadMath.unsafeWadMul(x, y);

        // Check: result == x * y / 1e18, when unchecked
        unchecked {
            assertEq(
                result,
                (x * y) / 1e18,
                "Wrong result for unsafeWadMulBothNegativeOverflow()"
            );
        }
    }

    function unsafeWadMulSingleNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y > 0
        - x * y < int256 min
        */
        x = clampLt(x, 0);
        y = clampGt(y, type(int256).min / x);

        // Action: Call unsafeWadMul(x, y) and unsafeWadMul(y, x)
        int256 result = SignedWadMath.unsafeWadMul(x, y);
        int256 result2 = SignedWadMath.unsafeWadMul(y, x);

        /*
        Check:
        - For result and result2:
            - result == x * y / 1e18, when unchecked
        */
        unchecked {
            assertEq(
                result,
                (x * y) / 1e18,
                "Wrong result for unsafeWadMulSingleNegative()"
            );
            assertEq(
                result2,
                (x * y) / 1e18,
                "Wrong result for unsafeWadMulSingleNegative()"
            );
        }
    }

    function unsafeWadDivBothPositive(int256 x, int256 y) public {
        /*
        Precondition: 
        - x > 0 and y > 0
        - x * 1e18 <= int256 max
        */
        x = clampBetween(x, 1, type(int256).max / 1e18);
        y = clampGt(y, 0);

        // Action: Call unsafeWadDiv()
        int256 result = SignedWadMath.unsafeWadDiv(x, y);

        /*
        Check:
        - result >= 0
        - result == x * 1e18 / y
        */
        assertGte(
            result,
            0,
            "Result not positive for unsafeWadDivBothPositive()"
        );
        assertEq(
            result,
            (x * 1e18) / y,
            "Wrong result for unsafeWadDivBothPositive()"
        );
    }

    function unsafeWadDivBothNegative(int256 x, int256 y) public {
        /*
        Precondition: 
        - x < 0 and y < 0
        - x * 1e18 >= int256 min
        */
        x = clampBetween(x, type(int256).min / 1e18, -1);
        y = clampLt(y, 0);

        // Action: Call unsafeWadDiv()
        int256 result = SignedWadMath.unsafeWadDiv(x, y);

        /*
        Check:
        - result >= 0
        - result == x * 1e18 / y
        */
        assertGte(
            result,
            0,
            "Result not positive for unsafeWadDivBothNegative()"
        );
        assertEq(
            result,
            (x * 1e18) / y,
            "Wrong result for unsafeWadDivBothNegative()"
        );
    }

    function unsafeWadDivSingleNegative(int256 x, int256 y) public {
        /*
        Precondition: 
        - x < 0 and y > 0 OR x > 0 and y < 0
        - int256 min <= x * 1e18 <= int256 max 
        */
        if (x < 0) {
            x = clampBetween(x, type(int256).min / 1e18, -1);
            y = clampGt(y, 0);
        } else {
            x = clampBetween(x, 1, type(int256).max / 1e18);
            y = clampLt(y, 0);
        }

        // Action: Call unsafeWadDiv()
        int256 result = SignedWadMath.unsafeWadDiv(x, y);

        /*
        Check:
        - result <= 0
        - result == x * 1e18 / y
        */
        assertLte(
            result,
            0,
            "Result not <= 0 for unsafeWadDivSingleNegative()"
        );
        assertEq(
            result,
            (x * 1e18) / y,
            "Wrong result for unsafeWadDivSingleNegative()"
        );
    }

    function unsafeWadDivNumeratorZero(int256 y) public {
        // Precondition: y != 0
        if (y == 0) return;

        // Action: Call unsafeWadDiv(0, y)
        int256 result = SignedWadMath.unsafeWadDiv(0, y);

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeWadDivNumeratorZero()");
    }

    function unsafeWadDivDenominatorZero(int256 x) public {
        // Action: Call unsafeWadDiv(x, 0)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.unsafeWadDiv,
            x,
            0,
            "unsafeWadDivDenominatorZero() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeWadDivDenominatorZero()");
    }

    function unsafeWadDivPositiveOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x * 1e18 > int256 max
        - y != 0
        */
        x = clampGt(x, type(int256).max / 1e18);
        if (y == 0) return;

        // Action: Call unsafeWadDiv()
        int256 result = SignedWadMath.unsafeWadDiv(x, y);

        // Check: result == x * 1e18 / y, when unchecked
        unchecked {
            assertEq(
                result,
                (x * 1e18) / y,
                "Wrong result for unsafeWadDivBothPositiveOverflow()"
            );
        }
    }

    function unsafeWadDivNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x * 1e18 < int256 min
        - y != 0
        */
        x = clampLt(x, type(int256).min / 1e18);
        if (y == 0) return;

        // Action: Call unsafeWadDiv()
        int256 result = SignedWadMath.unsafeWadDiv(x, y);

        // Check: result == x * 1e18 / y, when unchecked
        unchecked {
            assertEq(
                result,
                (x * 1e18) / y,
                "Wrong result for unsafeWadDivBothPositiveOverflow()"
            );
        }
    }

    function wadMulBothPositive(int256 x, int256 y) public {
        /* 
        Precondition:
        - x > 0 and y > 0
        - x * y <= int256 max
        */
        x = clampGt(x, 0);
        y = clampBetween(y, 1, type(int256).max / x);

        // Action: Call wadMul()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulBothPositive() reverted"
        );

        /*
        Check:
        - result >= 0
        - result == x * y / 1e18
        */
        assertGte(result, 0, "Result not positive for wadMulBothPositive()");
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for wadMulBothPositive()"
        );
    }

    function wadMulBothNegative(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y < 0
        - x * y <= int256 max
        */
        x = clampLt(x, 0);
        y = clampBetween(y, type(int256).max / x, -1);

        // Action: Call wadMul()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulBothNegative() reverted"
        );

        /*
        Check:
        - result >= 0
        - result == x * y / 1e18
        */
        assertGte(result, 0, "Result not positive for wadMulBothNegative()");
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for wadMulBothNegative()"
        );
    }

    function wadMulSingleNegative(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y > 0
        - x * y >= int256 min
        */
        x = clampLt(x, 0);
        y = clampBetween(y, 1, type(int256).min / x);

        // Action: Call wadMul(x, y)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulSingleNegative() reverted"
        );

        /*
        Check:
        - r <= 0
        - r == x * y / 1e18
        */
        assertLte(result, 0, "Result not <= 0 for wadMulSingleNegative()");
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for wadMulSingleNegative()"
        );

        // Action: Call wadMul(y, x)
        result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            y,
            x,
            "wadMulSingleNegative() reverted"
        );

        /*
        Check:
        - r <= 0
        - r == x * y / 1e18
        */
        assertLte(result, 0, "Result not <= 0 for wadMulSingleNegative()");
        assertEq(
            result,
            (x * y) / 1e18,
            "Wrong result for wadMulSingleNegative()"
        );
    }

    function wadMulZero(int256 x) public {
        // Action: Call wadMul(x, 0)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            x,
            0,
            "wadMulZero() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for wadMulZero(x, 0)");

        // Action: Call wadMul(0, x)
        result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            0,
            x,
            "wadMulZero() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for wadMulZero(0, x)");
    }

    function wadMulBothPositiveOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x > 0 and y > 0
        - x * y > int256 max
        */
        x = clampGt(x, 0);
        y = clampGt(y, type(int256).max / x);

        // Action: Call wadMul()
        bytes memory reason = expectRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulBothPositiveOverflow() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadMulBothPositiveOverflow() reverted with message"
        );
    }

    function wadMulBothNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y < 0
        - x * y > int256 max
        */
        x = clampLt(x, 0);
        y = clampLt(y, type(int256).max / x);
        if (x == -1 && y == type(int256).min) return; // Exclude edgecase that passes

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

    function wadMulSingleNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x < 0 and y > 0
        - x * y < int256 min
        */
        x = clampLt(x, 0);
        y = clampGt(y, type(int256).min / x);

        // Action: Call wadMul(x, y)
        bytes memory reason = expectRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulSingleNegativeOverflow() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadMulSingleNegativeOverflow() reverted with message"
        );

        // Action: Call wadMul(y, x)
        reason = expectRevert(
            signedWadMathWrapper.wadMul,
            y,
            x,
            "wadMulSingleNegativeOverflow() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadMulSingleNegativeOverflow() reverted with message"
        );
    }

    function wadMulEdgeCase() public {
        // Precondition: x == -1, y == int256 min
        int256 x = -1;
        int256 y = type(int256).min;

        // This doesn't revert although x * y > int256 max
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadMul,
            x,
            y,
            "wadMulEdgeCase() reverted"
        );

        // Check: result == x * y / 1e18, when unchecked
        // Evalutes to -57896044618658097711785492504343953926634992332820282019728
        unchecked {
            assertEq(
                result,
                (x * y) / 1e18,
                "Wrong result for wadMulEdgeCase()"
            );
        }
    }

    function wadDivBothPositive(int256 x, int256 y) public {
        /* 
        Precondition:
        - x > 0 and y > 0
        - x * 1e18 <= int256 max
        */
        x = clampBetween(x, 1, type(int256).max / 1e18);
        y = clampGt(y, 0);

        // Action: Call wadDiv()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadDiv,
            x,
            y,
            "wadDivBothPositive() reverted"
        );

        /*
        Check:
        - result >= 0
        - result == x * 1e18 / y 
        */
        assertGte(result, 0, "Result not positive for wadDivBothPositive()");
        assertEq(
            result,
            (x * 1e18) / y,
            "Wrong result for wadDivBothPositive()"
        );
    }

    function wadDivBothNegative(int256 x, int256 y) public {
        /*
        Precondition: 
        - x < 0 and y < 0
        - x * 1e18 >= int256 min
        */
        x = clampBetween(x, type(int256).min / 1e18, -1);
        y = clampLt(y, 0);

        // Action: Call wadDiv()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadDiv,
            x,
            y,
            "wadDivBothNegative() reverted"
        );

        /*
        Check:
        - result >= 0
        - result == x * 1e18 / y
        */
        assertGte(result, 0, "Result not positive for wadDivBothNegative()");
        assertEq(
            result,
            (x * 1e18) / y,
            "Wrong result for wadDivBothNegative()"
        );
    }

    function wadDivSingleNegative(int256 x, int256 y) public {
        /*
        Precondition: 
        - x < 0 and y > 0 OR x > 0 and y < 0
        - int256 min <= x * 1e18 <= int256 max 
        */
        if (x < 0) {
            x = clampBetween(x, type(int256).min / 1e18, -1);
            y = clampGt(y, 0);
        } else {
            x = clampBetween(x, 1, type(int256).max / 1e18);
            y = clampLt(y, 0);
        }

        // Action: Call wadDiv()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadDiv,
            x,
            y,
            "wadDivSingleNegative() reverted"
        );

        /*
        Check:
        - result <= 0
        - result == x * 1e18 / y
        */
        assertLte(result, 0, "Result not <= 0 for wadDivSingleNegative()");
        assertEq(
            result,
            (x * 1e18) / y,
            "Wrong result for wadDivSingleNegative()"
        );
    }

    function wadDivNumeratorZero(int256 y) public {
        // Precondition: y != 0
        if (y == 0) return;

        // Action: Call wadDiv(0, y)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadDiv,
            0,
            y,
            "wadDivNumeratorZero() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for wadDivNumeratorZero(0, y)");
    }

    function wadDivDenominatorZero(int256 x) public {
        // Action: Call wadDiv(x, 0)
        bytes memory reason = expectRevert(
            signedWadMathWrapper.wadDiv,
            x,
            0,
            "wadDivDenominatorZero() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadDivDenominatorZero() reverted with message"
        );
    }

    function wadDivPositiveOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x * 1e18 > int256 max
        - y != 0
        */
        x = clampGt(x, type(int256).max / 1e18);
        if (y == 0) return;

        // Action: Call wadDiv()
        bytes memory reason = expectRevert(
            signedWadMathWrapper.wadDiv,
            x,
            y,
            "wadDivPositiveOverflow() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadDivPositiveOverflow() reverted with message"
        );
    }

    function wadDivNegativeOverflow(int256 x, int256 y) public {
        /*
        Precondition:
        - x * 1e18 < int256 min
        - y != 0
        */
        x = clampLt(x, type(int256).min / 1e18);
        if (y == 0) return;

        // Action: Call wadDiv()
        bytes memory reason = expectRevert(
            signedWadMathWrapper.wadDiv,
            x,
            y,
            "wadDivNegativeOverflow() did not revert"
        );

        // Check: Reverted with empty reason
        assertEq(
            reason.length,
            0,
            "wadDivNegativeOverflow() reverted with message"
        );
    }

    function wadExpLowerBound(int256 x) public {
        // Precondition: x <= -42139678854452767551
        x = clampLte(x, -42139678854452767551);

        // Action: Call wadExp()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadExp,
            x,
            "wadExpLowerBound() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for wadExpLowerBound()");
    }

    function wadExpUpperBound(int256 x) public {
        // Precondition: x >= 135305999368893231589
        x = clampGte(x, 135305999368893231589);

        // Action: Call wadExp()
        expectRevert(
            signedWadMathWrapper.wadExp,
            x,
            "wadExpUpperBound() did not revert"
        );
    }

    function wadExpZero() public {
        // Action: Call wadExp(0)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadExp,
            0,
            "wadExpZero() reverted"
        );

        // Check: result == 1e18
        assertEq(result, 1e18, "Wrong result for wadExpZero()");
    }

    function wadExpResultPositive(int256 x) public {
        /*
        Precondition: 
        - -42139678854452767551 < x < 135305999368893231589
        - x != 0
        */
        x = clampBetween(
            x,
            -42139678854452767551 + 1,
            135305999368893231589 - 1
        );
        if (x == 0) return;

        // Action: Call wadExp()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadExp,
            x,
            "wadExpResultPositive() reverted"
        );

        // Check: result >= 0
        assertGte(result, 0, "Result not positive for wadExpResultPositive()");
    }

    function wadLnLowerBound(int256 x) public {
        // Precondition: x <= 0
        x = clampLte(x, 0);

        // Action: Call wadLn()
        expectRevert(
            signedWadMathWrapper.wadLn,
            x,
            "wadLnLowerBound() did not revert"
        );
    }

    function wadLnOne() public {
        // Action: Call wadLn(1e18)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadLn,
            1e18,
            "wadLnOne() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for wadLnOne()");
    }

    function wadLnResultPositive(int256 x) public {
        // Precondition: x > 1e18
        x = clampGt(x, 1e18);

        // Action: Call wadLn()
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadLn,
            x,
            "wadLnResultPositive() reverted"
        );

        // Check: result > 0
        assertGt(result, 0, "Result not positive for wadLnResultPositive()");
    }

    function wadLnExp(int256 x) public {
        // Precondition: 1e18 <= x < 135305999368893231589
        x = clampBetween(x, 1e18, 135305999368893231589 - 1);

        // Action: Call wadLn(wadExp(x))
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadExp,
            x,
            "wadLnExp() reverted"
        );
        if (result <= 0) return;

        result = callWithoutRevert(
            signedWadMathWrapper.wadLn,
            result,
            "wadLnExp() reverted"
        );

        // Check: result is within x - 1 to x + 1
        assertLte(result, x + 1, "Wrong result for wadLnExp()");
        assertGte(result, x - 1, "Wrong result for wadLnExp()");
    }

    function wadExpLn(int256 x) public {
        // Precondition: x >= 1e18
        x = clampGte(x, 1e18);

        // Action: Call wadExp(wadLn(x))
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadLn,
            x,
            "wadExpLn() reverted"
        );
        if (result <= -42139678854452767551 || result >= 135305999368893231589)
            return;

        result = callWithoutRevert(
            signedWadMathWrapper.wadExp,
            result,
            "wadExpLn() reverted"
        );

        // Check: result is within 1/1e17 of x
        assertErrorWithin(x, result, 10, "Wrong result for wadExpLn()");
    }

    function wadPow(int256 x, int256 y) public {
        /*
        Precondition: 
        - x >= 1e18
        - If y is positive, wadLn(x) * y / 1e18 < 135305999368893231589
        - If y is negative,  wadLn(x) * y / 1e18 > -42139678854452767551
        */
        x = clampGte(x, 1e18);
        if (y > 0) {
            y = clampLt(
                y,
                (135305999368893231589 * 1e18) / SignedWadMath.wadLn(x)
            );
            assert(y > 0);
        } else if (y < 0) {
            y = clampGt(
                y,
                (-42139678854452767551 * 1e18) / SignedWadMath.wadLn(x)
            );
            assert(y < 0);
        }

        // Action: Call wadPow
        int256 result = callWithoutRevert(
            signedWadMathWrapper.wadPow,
            x,
            y,
            "wadPow() reverted"
        );

        // Check: result == wadExp(wadLn(x) * y / 1e18)
        assertEq(
            result,
            SignedWadMath.wadExp((SignedWadMath.wadLn(x) * y) / 1e18),
            "Wrong result for wadPow()"
        );
    }

    function unsafeDivBothPositive(int256 x, int256 y) public {
        // Precondition: x > 0 and y > 0
        x = clampGt(x, 0);
        y = clampGt(y, 0);

        // Action: Call unsafeDiv()
        int256 result = SignedWadMath.unsafeDiv(x, y);

        /*
        Check:
        - result >= 0
        - result == x / y
        */
        assertGte(result, 0, "Result not positive for unsafeDivBothPositive()");
        assertEq(result, x / y, "Wrong result for unsafeDivBothPositive()");
    }

    function unsafeDivBothNegative(int256 x, int256 y) public {
        // Precondition: x < 0 and y < 0
        x = clampLt(x, 0);
        y = clampLt(y, 0);

        // Action: Call unsafeDiv()
        int256 result = SignedWadMath.unsafeDiv(x, y);

        /*
        Check:
        - result >= 0
        - result == x / y
        */
        assertGte(result, 0, "Result not positive for unsafeDivBothNegative()");
        assertEq(result, x / y, "Wrong result for unsafeDivBothNegative()");
    }

    function unsafeDivSingleNegative(int256 x, int256 y) public {
        /*
        Precondition: 
        - x < 0 and y > 0 OR x > 0 and y < 0
        */
        if (x < 0) {
            y = clampGt(y, 0);
        } else {
            y = clampLt(y, 0);
        }

        // Action: Call unsafeDiv()
        int256 result = SignedWadMath.unsafeDiv(x, y);

        /*
        Check:
        - result <= 0
        - result == x / y
        */
        assertLte(result, 0, "Result not <= 0 for unsafeDivSingleNegative()");
        assertEq(result, x / y, "Wrong result for unsafeDivSingleNegative()");
    }

    function unsafeDivNumeratorZero(int256 y) public {
        // Precondition: y != 0
        if (y == 0) return;

        // Action: Call unsafeDiv(0, y)
        int256 result = SignedWadMath.unsafeDiv(0, y);

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeDivNumeratorZero()");
    }

    function unsafeDivDenominatorZero(int256 x) public {
        // Action: Call unsafeDiv(x, 0)
        int256 result = callWithoutRevert(
            signedWadMathWrapper.unsafeDiv,
            x,
            0,
            "unsafeDivDenominatorZero() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeDivNumeratorZero()");
    }

    function unsafeFunctionsNeverRevert(
        int256 x,
        int256 y,
        uint256 funcSeed
    ) public {
        // Cache all unsafe functions
        bytes4[] memory singleParamSelectors = new bytes4[](3);
        singleParamSelectors[0] = signedWadMathWrapper.toWadUnsafe.selector;
        singleParamSelectors[1] = signedWadMathWrapper.toDaysWadUnsafe.selector;
        singleParamSelectors[2] = signedWadMathWrapper
            .fromDaysWadUnsafe
            .selector;

        bytes4[] memory twoParamSelectors = new bytes4[](3);
        twoParamSelectors[0] = signedWadMathWrapper.unsafeWadMul.selector;
        twoParamSelectors[1] = signedWadMathWrapper.unsafeWadDiv.selector;
        twoParamSelectors[2] = signedWadMathWrapper.unsafeDiv.selector;

        // Choose a function to call
        funcSeed = funcSeed % 6;
        bytes memory data;
        if (funcSeed < 3) {
            data = abi.encodeWithSelector(singleParamSelectors[funcSeed], x);
        } else {
            data = abi.encodeWithSelector(
                twoParamSelectors[funcSeed - 3],
                x,
                y
            );
        }

        // Action: Call unsafe function
        (bool success, ) = address(signedWadMathWrapper).call(data);

        // Check: Function call didn't revert
        assertEq(success, true, "unsafe function reverted");
    }
}
