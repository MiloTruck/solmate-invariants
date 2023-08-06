// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {PropertiesAsserts} from "contracts/helper.sol";

contract TestHelper is PropertiesAsserts {
    function failWithMsg(string memory reason) internal {
        emit AssertFail(reason);
        assert(false);
    }

    // A hacky way to check for panics
    function assertPanic(
        bytes memory errorMsg,
        uint8 panicCode,
        string memory reason
    ) internal {
        if (
            bytes4(errorMsg) != bytes4("NH{q") ||
            errorMsg[errorMsg.length - 1] != bytes1(panicCode)
        ) {
            failWithMsg(reason);
        }
    }

    // Ensure the difference between expected and result is within errorMargin
    function assertErrorWithin(
        int256 expected,
        int256 result,
        int256 errorMargin,
        string memory reason
    ) internal {
        int256 err = expected > result ? expected - result : result - expected;
        if (expected < 0) {
            expected = -expected;
        }
        assertLte(err, (expected * errorMargin) / 1e18, reason);
    }

    // Call function and ensure it did not revert
    function callWithoutRevert(
        function(uint256) external returns (uint256) f,
        uint256 a,
        string memory reason
    ) internal returns (uint256 r) {
        try f(a) returns (uint256 result) {
            r = result;
        } catch {
            failWithMsg(reason);
        }
    }

    function callWithoutRevert(
        function(uint256, uint256) external returns (uint256) f,
        uint256 a,
        uint256 b,
        string memory reason
    ) internal returns (uint256 r) {
        try f(a, b) returns (uint256 result) {
            r = result;
        } catch {
            failWithMsg(reason);
        }
    }

    function callWithoutRevert(
        function(uint256, uint256, uint256) external returns (uint256) f,
        uint256 a,
        uint256 b,
        uint256 c,
        string memory reason
    ) internal returns (uint256 r) {
        try f(a, b, c) returns (uint256 result) {
            r = result;
        } catch {
            failWithMsg(reason);
        }
    }

    function callWithoutRevert(
        function(int256) external returns (int256) f,
        int256 a,
        string memory reason
    ) internal returns (int256 r) {
        try f(a) returns (int256 result) {
            r = result;
        } catch {
            failWithMsg(reason);
        }
    }

    function callWithoutRevert(
        function(int256, int256) external returns (int256) f,
        int256 a,
        int256 b,
        string memory reason
    ) internal returns (int256 r) {
        try f(a, b) returns (int256 result) {
            r = result;
        } catch {
            failWithMsg(reason);
        }
    }

    // Call function and ensure that it reverted
    function expectRevert(
        function(uint256) external returns (uint256) f,
        uint256 a,
        string memory reason
    ) internal returns (bytes memory r) {
        try f(a) {
            failWithMsg(reason);
        } catch (bytes memory errorMsg) {
            r = errorMsg;
        }
    }

    function expectRevert(
        function(uint256, uint256) external returns (uint256) f,
        uint256 a,
        uint256 b,
        string memory reason
    ) internal returns (bytes memory r) {
        try f(a, b) {
            failWithMsg(reason);
        } catch (bytes memory errorMsg) {
            r = errorMsg;
        }
    }

    function expectRevert(
        function(uint256, uint256, uint256) external returns (uint256) f,
        uint256 a,
        uint256 b,
        uint256 c,
        string memory reason
    ) internal returns (bytes memory r) {
        try f(a, b, c) {
            failWithMsg(reason);
        } catch (bytes memory errorMsg) {
            r = errorMsg;
        }
    }

    function expectRevert(
        function(int256) external returns (int256) f,
        int256 a,
        string memory reason
    ) internal returns (bytes memory r) {
        try f(a) {
            failWithMsg(reason);
        } catch (bytes memory errorMsg) {
            r = errorMsg;
        }
    }

    function expectRevert(
        function(int256, int256) external returns (int256) f,
        int256 a,
        int256 b,
        string memory reason
    ) internal returns (bytes memory r) {
        try f(a, b) {
            failWithMsg(reason);
        } catch (bytes memory errorMsg) {
            r = errorMsg;
        }
    }
}
