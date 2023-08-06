// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {FixedPointMathLibTest} from "./FixedPointMathLibTest.sol";
import {SignedWadMathTest} from "./SignedWadMathTest.sol";
import {ERC20Test} from "./ERC20Test.sol";

/*
Fuzz with the following command:

./medusa fuzz --target submission.sol --deployment-order FixedPointMathLibTest,SignedWadMathTest,ERC20Test 
*/