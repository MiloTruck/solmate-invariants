// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {FixedPointMathLib} from "contracts/FixedPointMathLib.sol";
import {TestHelper} from "./helper/TestHelper.sol";
import {FixedPointMathLibWrapper} from "./wrapper/FixedPointMathLibWrapper.sol";

contract FixedPointMathLibTest is TestHelper {
    // FixedPointMathLib wrapper contract
    FixedPointMathLibWrapper fixedPointMathLibWrapper;

    // Constants
    uint256 constant SQRT_UINT256_MAX = 340282366920938463463374607431768211455;

    constructor() {
        fixedPointMathLibWrapper = new FixedPointMathLibWrapper();
    }

    // FixedPointMathLib constants

    function maxUint256() public {
        assertEq(
            FixedPointMathLib.MAX_UINT256,
            type(uint256).max,
            "MAX_UINT256 is wrong"
        );
    }

    function wad() public {
        assertEq(FixedPointMathLib.WAD, 1e18, "WAD is wrong");
    }

    // ASSERTIONS

    function mulWadDown(uint256 x, uint256 y) public {
        // Precondition: x * y <= uint256 max
        if (x != 0) y = clampLte(y, type(uint256).max / x);

        // Action: Call mulWadDown()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.mulWadDown,
            x,
            y,
            "mulWadDown() reverted"
        );

        // Check: result == x * y / WAD
        assertEq(
            result,
            (x * y) / FixedPointMathLib.WAD,
            "Wrong result for mulWadDown()"
        );
    }

    function mulWadDownOverflow(uint256 x, uint256 y) public {
        // Precondition: x * y > uint256 max
        x = clampGt(x, 1);
        y = clampGt(y, type(uint256).max / x);

        // Action: Call mulDivDown()
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.mulWadDown,
            x,
            y,
            "mulWadDownOverflow() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "mulWadDownOverflow() reverted with error message"
        );
    }

    function mulWadUp(uint256 x, uint256 y) public {
        // Precondition: x * y <= uint256 max
        if (x != 0) y = clampLte(y, type(uint256).max / x);

        // Action: Call mulWadUp()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.mulWadUp,
            x,
            y,
            "mulWadUp() reverted"
        );

        /*
        Check:
        - If x * y % WAD > 0, result == x * y / WAD + 1
        - Otherwise, result == x * y  / WAD
        */
        if ((x * y) % FixedPointMathLib.WAD > 0) {
            assertEq(
                result,
                (x * y) / FixedPointMathLib.WAD + 1,
                "Wrong result for mulDivUp()"
            );
        } else {
            assertEq(
                result,
                (x * y) / FixedPointMathLib.WAD,
                "Wrong result for mulDivUp()"
            );
        }
    }

    function mulWadUpOverflow(uint256 x, uint256 y) public {
        // Precondition: x * y > uint256 max
        x = clampGt(x, 1);
        y = clampGt(y, type(uint256).max / x);

        // Action: Call mulWadUp()
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.mulWadUp,
            x,
            y,
            "mulWadUpOverflow() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "mulWadUpOverflow() reverted with error message"
        );
    }

    function divWadDown(uint256 x, uint256 y) public {
        /*
        Precondition: 
        - x * WAD <= uint256 max
        - y != 0
        */
        x = clampLte(x, type(uint256).max / FixedPointMathLib.WAD);
        if (y == 0) return;

        // Action: Call divWadDown()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.divWadDown,
            x,
            y,
            "divWadDown() reverted"
        );

        // Check: result == x * WAD / y
        assertEq(
            result,
            (x * FixedPointMathLib.WAD) / y,
            "Wrong result for divWadDown()"
        );
    }

    function divWadDownZero(uint256 x) public {
        // Precondition: x * WAD <= uint256 max
        x = clampLte(x, type(uint256).max / FixedPointMathLib.WAD);

        // Action: Call divWadDown(x, 0)
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.divWadDown,
            x,
            0,
            "divWadDownZero() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "divWadDownZero() reverted with error message"
        );
    }

    function divWadDownOverflow(uint256 x, uint256 y) public {
        /*
        Precondition: 
        - x * WAD > uint256 max
        - y != 0
        */
        x = clampGt(x, type(uint256).max / FixedPointMathLib.WAD);
        if (y == 0) return;

        // Action: Call divWadDown()
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.divWadDown,
            x,
            y,
            "divWadDownOverflow() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "divWadDownOverflow() reverted with error message"
        );
    }

    function divWadUp(uint256 x, uint256 y) public {
        /*
        Precondition: 
        - x * WAD <= uint256 max
        - y != 0
        */
        x = clampLte(x, type(uint256).max / FixedPointMathLib.WAD);
        if (y == 0) return;

        // Action: Call divWadUp()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.divWadUp,
            x,
            y,
            "divWadUp() reverted"
        );

        /*
        Check: 
        - If x * WAD % y > 0, result == x * WAD / y + 1
        - Otherwise, result == x * WAD / y
        */
        if ((x * FixedPointMathLib.WAD) % y > 0) {
            assertEq(
                result,
                (x * FixedPointMathLib.WAD) / y + 1,
                "Wrong result for divWadUp()"
            );
        } else {
            assertEq(
                result,
                (x * FixedPointMathLib.WAD) / y,
                "Wrong result for divWadUp()"
            );
        }
    }

    function divWadUpZero(uint256 x) public {
        // Precondition: x * WAD <= uint256 max
        x = clampLte(x, type(uint256).max / FixedPointMathLib.WAD);

        // Action: Call divWadUp(x, 0)
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.divWadUp,
            x,
            0,
            "divWadUpZero() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "divWadUpZero() reverted with error message"
        );
    }

    function divWadUpOverflow(uint256 x, uint256 y) public {
        /*
        Precondition: 
        - x * WAD > uint256 max
        - y != 0
        */
        x = clampGt(x, type(uint256).max / FixedPointMathLib.WAD);
        if (y == 0) return;

        // Action: Call divWadUp()
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.divWadUp,
            x,
            y,
            "divWadDownOverflow() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "divWadDownOverflow() reverted with error message"
        );
    }

    function mulDivDown(uint256 x, uint256 y, uint256 denominator) public {
        /*
        Precondition:
        - x * y <= uint256 max
        - denominator != 0
        */
        if (x != 0) y = clampLte(y, type(uint256).max / x);
        if (denominator == 0) return;

        // Action: Call mulDivDown()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.mulDivDown,
            x,
            y,
            denominator,
            "mulDivDown() reverted"
        );

        // Check: result == x * y / denominator
        assertEq(
            result,
            (x * y) / denominator,
            "Wrong result for mulDivDown()"
        );
    }

    function mulDivDownDenominatorZero(uint256 x, uint256 y) public {
        // Precondition: x * y <= uint256 max
        if (x != 0) y = clampLte(y, type(uint256).max / x);

        // Action: Call mulDivDown() with denominator == 0
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.mulDivDown,
            x,
            y,
            0,
            "mulDivDownDenominatorZero() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "mulDivDownDenominatorZero() reverted with error message"
        );
    }

    function mulDivDownOverflow(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public {
        /*
        Precondition: 
        - x * y > uint256 max
        - denominator != 0
        */
        x = clampGt(x, 1);
        y = clampGt(y, type(uint256).max / x);
        if (denominator == 0) return;

        // Action: Call mulDivDown()
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.mulDivDown,
            x,
            y,
            denominator,
            "mulDivDownOverflow() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "mulDivDownOverflow() reverted with error message"
        );
    }

    function mulDivUp(uint256 x, uint256 y, uint256 denominator) public {
        /*
        Precondition:
        - x * y <= uint256 max
        - denominator != 0
        */
        if (x != 0) y = clampLte(y, type(uint256).max / x);
        if (denominator == 0) return;

        // Action: Call mulDivUp()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.mulDivUp,
            x,
            y,
            denominator,
            "mulDivUp() reverted"
        );

        /*
        Check:
        - If x * y % denominator > 0, result == x * y / denominator + 1
        - Otherwise, result == x * y  / denominator
        */
        if ((x * y) % denominator > 0) {
            assertEq(
                result,
                (x * y) / denominator + 1,
                "Wrong result for mulDivUp()"
            );
        } else {
            assertEq(
                result,
                (x * y) / denominator,
                "Wrong result for mulDivUp()"
            );
        }
    }

    function mulDivUpDenominatorZero(uint256 x, uint256 y) public {
        // Precondition: x * y <= uint256 max
        if (x != 0) y = clampLte(y, type(uint256).max / x);

        // Action: Call mulDivDown() with denominator == 0
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.mulDivUp,
            x,
            y,
            0,
            "mulDivUpDenominatorZero() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "mulDivUpDenominatorZero() reverted with error message"
        );
    }

    function mulDivUpOverflow(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public {
        /*
        Precondition: 
        - x * y > uint256 max
        - denominator != 0
        */
        x = clampGt(x, 1);
        y = clampGt(y, type(uint256).max / x);
        if (denominator == 0) return;

        // Action: Call mulDivDown()
        bytes memory reason = expectRevert(
            fixedPointMathLibWrapper.mulDivUp,
            x,
            y,
            denominator,
            "mulDivUpOverflow() did not revert"
        );

        // Check: reverted without error message
        assertEq(
            reason.length,
            0,
            "mulDivUpOverflow() reverted with error message"
        );
    }

    // Helper function for checking correctness of rpow()
    function simulateRpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) public pure returns (uint256 z) {
        z = n % 2 == 0 ? scalar : x;
        
        uint256 half = scalar / 2;

        for (n /= 2; n > 0; n /= 2) {
            uint256 xxRound = x * x + half;
            x = scalar == 0 ? 0 : xxRound / scalar;

            if (n % 2 != 0) {
                uint256 zxRound = z * x + half;
                z = scalar == 0 ? 0 : zxRound / scalar;
            }
        }
    }

    function rpow(uint256 x, uint256 n, uint256 scalar) public {
        // Precondition: x > 0
        x = clampGt(n, 0);

        // Call helper function and check if it reverted
        (bool success, bytes memory data) = address(this).call(
            abi.encodeWithSelector(this.simulateRpow.selector, x, n, scalar)
        );

        if (success) {
            // If simulateRpow() didn't overflow, get the result
            uint256 expectedResult = abi.decode(data, (uint256));

            // Action: Call rpow()
            uint256 result = callWithoutRevert(
                fixedPointMathLibWrapper.rpow,
                x,
                n,
                scalar,
                "rpow() reverted unexpectedly"
            );

            // Check: result == expectedResult
            assertEq(result, expectedResult, "Wrong result for rpow()");
        } else {
            // If simulateRpow() overflows, call rpow() and check that it reverts
            bytes memory reason = expectRevert(
                fixedPointMathLibWrapper.rpow,
                x,
                n,
                scalar,
                "rpow() didn't revert"
            );

            // Check: Call reverted with no error message
            assertEq(reason.length, 0, "rpow() reverted with error message");
        }
    }

    function rpowXZero(uint256 n, uint256 scalar) public {
        // Action: Call rpow(0, n, scalar)
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.rpow,
            0,
            n,
            scalar,
            "rpowXZero() reverted unexpectedly"
        );

        /*
        Check: 
        - If n == 0, result == scalar
        - Otherwise, result == 0
        */
        if (n == 0) {
            assertEq(result, scalar, "Wrong result for rpow(0, 0, scalar)");
        } else {
            assertEq(result, 0, "Wrong result for rpow(0, n, scalar)");
        }
    }

    function sqrt(uint256 x) public {
        // Action: Call sqrt()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.sqrt,
            x,
            "sqrt() reverted"
        );

        /*
        Check:
        - If x == 0 or 1, result == x
        - Otherwise:
            - result < x
            - result <= sqrt(uint256 max)
            - result ** 2 <= x
            - x > (result - 1) ** 2  
            - If result < sqrt(uint256 max), x < (result + 1) ** 2
        */
        if (x == 0 || x == 1) {
            assertEq(result, x, "Wrong result for sqrt()");
            return;
        }

        assertLt(result, x, "sqrt(): result is larger than x");
        assertLte(
            result,
            SQRT_UINT256_MAX,
            "sqrt(): result greater than sqrt(uint256 max)"
        );
        assertLte(result ** 2, x, "sqrt(): result ** 2 is larger than x");

        assertGt(
            x,
            (result - 1) ** 2,
            "sqrt(): (result - 1) ** 2 is smaller than x"
        );
        if (result < SQRT_UINT256_MAX) {
            assertLt(
                x,
                (result + 1) ** 2,
                "sqrt(): (result + 1) ** 2 is smaller than x"
            );
        }
    }

    function sqrtPerfectSquare(uint256 x) public {
        // Precondition: x < sqrt(uint256 max)
        x = clampLte(x, SQRT_UINT256_MAX);

        // Action: Call sqrt(x ** 2)
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.sqrt,
            x ** 2,
            "sqrtPerfectSquare() reverted"
        );

        // Check: result == x
        assertEq(result, x, "Wrong result for sqrtPerfectSquare()");
    }

    function sqrtRpow(uint256 x) public {
        // Precondition: x < sqrt(uint256 max)
        x = clampLte(x, SQRT_UINT256_MAX);

        // Action: Call sqrt(rpow(x, 2, 1))
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.rpow,
            x,
            2,
            1,
            "sqrtRpow(): rpow() reverted"
        );

        result = callWithoutRevert(
            fixedPointMathLibWrapper.sqrt,
            result,
            "sqrtRpow(): sqrt() reverted"
        );

        // Check: result == x
        assertEq(result, x, "Wrong result for sqrtRpow()");
    }

    function unsafeMod(uint256 x, uint256 y) public {
        // Precondition: y != 0
        if (y == 0) return;

        // Action: Call unsafeMod()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.unsafeMod,
            x,
            y,
            "unsafeMod() reverted"
        );

        // Check: result == x % y
        assertEq(result, x % y, "Wrong result for unsafeMod()");
    }

    function unsafeModDenominatorZero(uint256 x) public {
        // Action: Call unsafeMod(x, 0)
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.unsafeMod,
            x,
            0,
            "unsafeMod() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeMod()");
    }

    function unsafeDiv(uint256 x, uint256 y) public {
        // Precondition: y != 0
        if (y == 0) return;

        // Action: Call unsafeDiv()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.unsafeDiv,
            x,
            y,
            "unsafeDiv() reverted"
        );

        // Check: result == x / y
        assertEq(result, x / y, "Wrong result for unsafeDiv()");
    }

    function unsafeDivDenominatorZero(uint256 x) public {
        // Action: Call unsafeDiv(x, 0)
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.unsafeDiv,
            x,
            0,
            "unsafeDiv() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeDiv()");
    }

    function unsafeDivUp(uint256 x, uint256 y) public {
        // Precondition: y != 0
        if (y == 0) return;

        // Action: Call unsafeDivUp()
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.unsafeDivUp,
            x,
            y,
            "unsafeDivUp() reverted"
        );

        /*
        Check: 
        - If x % y > 0, result == x / y + 1
        - Otherwise, result == x / y
        */
        if (x % y > 0) {
            assertEq(result, x / y + 1, "Wrong result for unsafeDivUp()");
        } else {
            assertEq(result, x / y, "Wrong result for unsafeDivUp()");
        }
    }

    function unsafeDivUpDenominatorZero(uint256 x) public {
        // Action: Call unsafeDivUp(x, 0)
        uint256 result = callWithoutRevert(
            fixedPointMathLibWrapper.unsafeDivUp,
            x,
            0,
            "unsafeDivUp() reverted"
        );

        // Check: result == 0
        assertEq(result, 0, "Wrong result for unsafeDivUp()");
    }

    function functionsNeverRevert(
        uint256 x,
        uint256 y,
        uint256 funcSeed
    ) public {
        // Cache all unsafe functions
        bytes4[] memory unsafeFunctionSelectors = new bytes4[](3);
        unsafeFunctionSelectors[0] = fixedPointMathLibWrapper
            .unsafeMod
            .selector;
        unsafeFunctionSelectors[1] = fixedPointMathLibWrapper
            .unsafeDiv
            .selector;
        unsafeFunctionSelectors[2] = fixedPointMathLibWrapper
            .unsafeDivUp
            .selector;

        // Choose a function to call
        funcSeed = funcSeed % 4;
        bytes memory data;
        if (funcSeed < 3) {
            data = abi.encodeWithSelector(
                unsafeFunctionSelectors[funcSeed],
                x,
                y
            );
        } else {
            data = abi.encodeWithSelector(
                fixedPointMathLibWrapper.sqrt.selector,
                x
            );
        }

        // Action: Call unsafe function
        (bool success, ) = address(fixedPointMathLibWrapper).call(data);

        // Check: Function call didn't revert
        assertEq(success, true, "Function reverted when it shouldn't");
    }
}
