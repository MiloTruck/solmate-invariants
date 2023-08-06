// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IVM} from "contracts/IVM.sol";
import {ERC20BurnWrapper} from "./ERC20BurnWrapper.sol";
import {TestHelper} from "./TestHelper.sol";

contract ERC20Test is TestHelper {
    // Cheatcodes
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // ERC20Burn related
    uint256 constant INITIAL_TOTAL_SUPPLY = 1e18;
    string startingName;
    string startingSymbol;
    uint8 startingDecimals;
    ERC20BurnWrapper token;

    // State tracking
    uint256 previousTotalSupply = INITIAL_TOTAL_SUPPLY;

    constructor() {
        // Deploy the token
        token = new ERC20BurnWrapper();

        // Ensure deployment works as intended
        assert(token.balanceOf(address(this)) == INITIAL_TOTAL_SUPPLY);
        assert(keccak256(bytes(token.name())) == keccak256(bytes("MyToken")));
        assert(keccak256(bytes(token.symbol())) == keccak256(bytes("MT")));
        assert(token.decimals() == 18);

        // Store name, symbol and decimals
        startingName = token.name();
        startingSymbol = token.symbol();
        startingDecimals = token.decimals();
    }

    // ASSERTIONS

    function testApprove(
        uint256 callerSeed,
        uint256 spenderSeed,
        uint256 amount
    ) public {
        address caller = token.getActor(callerSeed);
        address spender = token.getActor(spenderSeed);

        // Action: Caller approves amount for spender
        vm.prank(caller);
        bool r = token.approve(spender, amount);

        /* 
        Check:
        - approve() returned true
        - spender's allowance == amount
        */
        assertEq(r, true, "approve() returned false");

        assertEq(
            token.allowance(caller, spender),
            amount,
            "Allowance not set correctly"
        );
    }

    function testTransfer(
        uint256 fromSeed,
        uint256 toSeed,
        uint256 amount
    ) public {
        address sender = token.getActor(fromSeed);
        address recipient = token.getActor(toSeed);

        // Precondition: amount <= sender's balance
        amount = clampLte(amount, token.balanceOf(sender));

        // Action: Transfer amount from sender to recipient
        uint256 senderBalanceBefore = token.balanceOf(sender);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);

        vm.prank(sender);
        bool r = token.transfer(recipient, amount);

        /*
        Check:
        - transfer() returned true
        - If from == to, balance remained the same
        - If from != to:
            - sender's balance decreased by amount
            - recipient's balance increased by amount
        */
        assertEq(r, true, "transfer() returned false");

        if (sender == recipient) {
            assertEq(
                recipientBalanceBefore,
                token.balanceOf(recipient),
                "Incorrect balance after transfer() to self"
            );
        } else {
            assertEq(
                senderBalanceBefore - amount,
                token.balanceOf(sender),
                "Incorrect sender balance after transfer()"
            );

            assertEq(
                recipientBalanceBefore + amount,
                token.balanceOf(recipient),
                "Incorrect recipient balance after transfer()"
            );
        }
    }

    function testTransferFrom(
        uint256 callerSeed,
        uint256 fromSeed,
        uint256 toSeed,
        bool giveApproval,
        uint256 amount
    ) public {
        address caller = token.getActor(callerSeed);
        address sender = token.getActor(fromSeed);
        address recipient = token.getActor(toSeed);

        /* 
        Precondition: 
        - amount <= sender's balance 
        - amount <= caller's allowance
        */
        amount = clampLte(amount, token.balanceOf(sender));

        if (giveApproval) {
            vm.prank(sender);
            token.approve(caller, amount);
        } else {
            amount = clampLte(amount, token.allowance(sender, caller));
        }

        // Action: Transfer amount from sender to recipient
        uint256 senderBalanceBefore = token.balanceOf(sender);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 allowanceBefore = token.allowance(sender, caller);

        vm.prank(caller);
        bool r = token.transferFrom(sender, recipient, amount);

        /*
        Check:
        - transferFrom() returned true
        - If sender == recipient, balance remained the same
        - If sender != recipient:
            - sender's balance decreased by amount
            - recipient's balance increased by amount
        - If caller's allowance == uint256 max, allowance remained the same
        - If caller's allowance < uint256 max, allowance decreased by amount
        */
        assertEq(r, true, "transfer() returned false");

        if (sender == recipient) {
            assertEq(
                recipientBalanceBefore,
                token.balanceOf(recipient),
                "Incorrect balance after transferFrom() to self"
            );
        } else {
            assertEq(
                senderBalanceBefore - amount,
                token.balanceOf(sender),
                "Incorrect sender balance after transferFrom()"
            );

            assertEq(
                recipientBalanceBefore + amount,
                token.balanceOf(recipient),
                "Incorrect recipient balance after transferFrom()"
            );
        }

        if (allowanceBefore == type(uint256).max) {
            assertEq(
                allowanceBefore,
                token.allowance(sender, caller),
                "Incorrect allowance after transferFrom() with infinite allowance"
            );
        } else {
            assertEq(
                allowanceBefore - amount,
                token.allowance(sender, caller),
                "Incorrect allowance after transferFrom()"
            );
        }
    }

    function testBurn(uint256 callerSeed, uint256 amount) public {
        address caller = token.getActor(callerSeed);

        // Precondition: amount <= caller's balance
        amount = clampLte(amount, token.balanceOf(caller));

        // Action: Burn amount from caller's balance
        uint256 balanceBefore = token.balanceOf(caller);
        uint256 totalSupplyBefore = token.totalSupply();

        vm.prank(caller);
        token.burn(amount);

        /*
        Check: 
        - Caller's balance decreased by amount
        - totalSupply decreased by amount
        */
        assertEq(
            balanceBefore - amount,
            token.balanceOf(caller),
            "Incorrect balance after burn()"
        );

        assertEq(
            totalSupplyBefore - amount,
            token.totalSupply(),
            "Incorrect totalSupply after burn()"
        );
    }

    function testApproveTwice(
        uint256 callerSeed,
        uint256 spenderSeed,
        uint256 amount
    ) public {
        address caller = token.getActor(callerSeed);
        address spender = token.getActor(spenderSeed);

        /*
        Action: 
        1. Caller approves amount for spender
        2. Caller approves amount / 2 for spender
        */
        vm.prank(caller);
        bool r = token.approve(spender, amount);

        uint256 allowanceAfterFirstApprove = token.allowance(caller, spender);

        vm.prank(caller);
        bool r2 = token.approve(spender, amount / 2);

        /* 
        Check:
        - First approve() returned true
        - Second approve() returned true
        - First approve() set spender's allowance to amount
        - Second approve() set spender's allowance to amount / 2
        */
        assertEq(r, true, "First approve() returned false");
        assertEq(r2, true, "Second approve() returned false");

        assertEq(
            allowanceAfterFirstApprove,
            amount,
            "Allowance not correct after first approve"
        );

        assertEq(
            token.allowance(caller, spender),
            amount / 2,
            "Allowance not correct after second approve"
        );
    }

    function testTransferMoreThanSenderBalance(
        uint256 fromSeed,
        uint256 toSeed,
        uint256 amount
    ) public {
        address sender = token.getActor(fromSeed);
        address recipient = token.getActor(toSeed);

        // Precondition: amount > sender's balance
        amount = clampGt(amount, token.balanceOf(sender));

        // Action: Transfer amount from sender to recipient
        vm.prank(sender);
        try token.transfer(recipient, amount) {
            failWithMsg(
                "transfer() with more than sender's balance did not revert"
            );
        } catch (bytes memory reason) {
            // Check: Reverted due to arithmetic underflow
            assertPanic(
                reason,
                0x11,
                "transfer() with more than sender's balance reverted with wrong reason"
            );
        }
    }

    function testTransferFromMoreThanSenderBalance(
        uint256 callerSeed,
        uint256 fromSeed,
        uint256 toSeed,
        uint256 amount
    ) public {
        address caller = token.getActor(callerSeed);
        address sender = token.getActor(fromSeed);
        address recipient = token.getActor(toSeed);

        // Precondition: amount > sender's balance
        amount = clampGt(amount, token.balanceOf(sender));

        // Give caller the required allowance
        vm.prank(sender);
        token.approve(caller, amount);

        // Action: Transfer amount from sender to recipient
        vm.prank(caller);
        try token.transferFrom(sender, recipient, amount) {
            failWithMsg(
                "transferFrom() with more than sender's balance did not revert"
            );
        } catch (bytes memory reason) {
            // Check: Reverted due to arithmetic underflow
            assertPanic(
                reason,
                0x11,
                "transferFrom() more than sender's balance reverted with wrong reason"
            );
        }
    }

    function testTransferFromMoreThanCallerAllowance(
        uint256 callerSeed,
        uint256 fromSeed,
        uint256 toSeed,
        uint256 amount
    ) public {
        address caller = token.getActor(callerSeed);
        address sender = token.getActor(fromSeed);
        address recipient = token.getActor(toSeed);

        // Avoid this test if caller's allowance is uint256 max
        if (token.allowance(sender, caller) == type(uint256).max) return;

        // Precondition: amount > caller's allowance
        amount = clampGt(amount, token.allowance(sender, caller));

        // Action: Transfer amount from sender to recipient
        vm.prank(caller);
        try token.transferFrom(sender, recipient, amount) {
            failWithMsg(
                "transferFrom() with more than caller's allowance did not revert"
            );
        } catch (bytes memory reason) {
            // Check: Reverted due to arithmetic underflow
            assertPanic(
                reason,
                0x11,
                "transferFrom() more than caller's allowance reverted with wrong reason"
            );
        }
    }

    function testBurnMoreThanCallerBalance(
        uint256 callerSeed,
        uint256 amount
    ) public {
        address caller = token.getActor(callerSeed);

        // Precondition: amount > caller's balance
        amount = clampGt(amount, token.balanceOf(caller));

        // Action: Burn amount from caller's balance
        vm.prank(caller);
        try token.burn(amount) {
            failWithMsg(
                "burn() with more than caller's balance did not revert"
            );
        } catch (bytes memory reason) {
            // Check: Reverted due to arithmetic underflow
            assertPanic(
                reason,
                0x11,
                "burn() more than caller's allowance reverted with wrong reason"
            );
        }
    }

    function testTotalSupplyRemainsUnchanged(
        uint256 callerSeed,
        uint256 fromSeed,
        uint256 toSeed,
        uint256 amount,
        bool giveApproval,
        uint256 funcSeed
    ) public {
        // Store totalSupply before
        uint256 totalSupplyBefore = token.totalSupply();

        // Call one out of 3 functions
        funcSeed = funcSeed % 3;
        if (funcSeed == 0) testApprove(callerSeed, fromSeed, amount);
        else if (funcSeed == 1) testTransfer(fromSeed, toSeed, amount);
        else
            testTransferFrom(
                callerSeed,
                fromSeed,
                toSeed,
                giveApproval,
                amount
            );

        // Check that totalSupply didn't change
        assertEq(
            token.totalSupply(),
            totalSupplyBefore,
            "totalSupply() changed"
        );
    }

    function testOtherUsersBalancesRemainUnchanged(
        uint256 callerSeed,
        uint256 fromSeed,
        uint256 toSeed,
        uint256 amount,
        bool giveApproval,
        uint256 funcSeed
    ) public {
        // Store all user balances for future comparison
        uint256[] memory userBalances = new uint256[](token.actorCount());
        for (uint256 i; i < token.actorCount(); i++) {
            userBalances[i] = token.balanceOf(token.getActor(i));
        }

        // Choose one out of 4 functions
        funcSeed = funcSeed % 4;
        if (funcSeed == 0) {
            // Action: Call approve()
            testApprove(callerSeed, fromSeed, amount);

            // Check: All user balances remain unchanged
            for (uint256 i; i < token.actorCount(); i++) {
                assertEq(
                    userBalances[i],
                    token.balanceOf(token.getActor(i)),
                    "Wrong user balance changed after approve()"
                );
            }
        } else if (funcSeed == 1 || funcSeed == 2) {
            // Action: Call transfer() or transferFrom()
            if (funcSeed == 1) {
                testTransfer(fromSeed, toSeed, amount);
            } else {
                testTransferFrom(
                    callerSeed,
                    fromSeed,
                    toSeed,
                    giveApproval,
                    amount
                );
            }

            // Check: All user balances except from and to remain unchanged
            for (uint256 i; i < token.actorCount(); i++) {
                if (
                    token.getActor(i) == token.getActor(fromSeed) ||
                    token.getActor(i) == token.getActor(toSeed)
                ) continue;

                assertEq(
                    userBalances[i],
                    token.balanceOf(token.getActor(i)),
                    "Wrong user balance changed after transfer()/transferFrom()"
                );
            }
        } else {
            // Action: Call burn()
            testBurn(callerSeed, amount);

            // Check: All user balances except caller remain unchanged
            for (uint256 i; i < token.actorCount(); i++) {
                if (token.getActor(i) == token.getActor(callerSeed)) continue;

                assertEq(
                    userBalances[i],
                    token.balanceOf(token.getActor(i)),
                    "Wrong user balance changed after burn()"
                );
            }
        }
    }

    // PROPERTIES

    // name never changes
    function fuzz_nameNeverChanges() public returns (bool) {
        return keccak256(bytes(token.name())) == keccak256(bytes(startingName));
    }

    // symbol never changes
    function fuzz_symbolNeverChanges() public returns (bool) {
        return
            keccak256(bytes(token.symbol())) ==
            keccak256(bytes(startingSymbol));
    }

    // decimal never changes
    function fuzz_decimalNeverChanges() public returns (bool) {
        return token.decimals() == startingDecimals;
    }

    // totalSupply never exceeds initial minted amount
    function fuzz_totalSupplyNeverExceedsInitialAmount() public returns (bool) {
        return token.totalSupply() <= INITIAL_TOTAL_SUPPLY;
    }

    // totalSupply never increases
    function fuzz_totalSupplyNeverIncreases() public returns (bool) {
        if (token.totalSupply() > previousTotalSupply) {
            return false;
        }

        // Store totalSupply for future use
        previousTotalSupply = token.totalSupply();

        return true;
    }

    /*
    1. No user balance exceeds totalSupply
    2. Sum of all balances == totalSupply
    
    Note: We group these invariants together to avoid looping over users twice
    */
    function fuzz_userProperties() public returns (bool) {
        uint256 sumOfBalances;
        for (uint256 i; i < token.actorCount(); i++) {
            uint256 userBalance = token.balanceOf(token.getActor(i));

            // Invariant 1
            if (userBalance > token.totalSupply()) {
                return false;
            }

            sumOfBalances += userBalance;
        }

        // Invariant 2
        return sumOfBalances == token.totalSupply();
    }
}
