# solmate-invariants

This repository contains over 100 invariants implemented in [`medusa`](https://github.com/crytic/medusa) during a workshop held by [TrailOfBits](https://www.trailofbits.com/). More information about the workshop can be found [here](/secureum-workshop.md).

The goal was to find injected bugs in following three contracts, which are adapted directly from [solmate](https://github.com/transmissions11/solmate):

- [`ERC20Burn`](/contracts/ERC20Burn.sol) - A standard ERC-20 token with burn functionality.
- [`FixedPointMathLib`](/contracts/FixedPointMathLib.sol) - Arithmetic library with operations for fixed-point numbers.
- [`SignedWadMath`](/contracts/SignedWadMath.sol) - Signed integer 18 decimal fixed point arithmetic library.

The invariants for each contract are defined in separate test files:

- [`ERC20Test.sol`](/tests/ERC20Test.sol)
- [`FixedPointMathLibTest.sol`](/tests/FixedPointMathLibTest.sol)
- [`SignedWadMathTest.sol`](/tests/SignedWadMathTest.sol)

## Running `medusa`

First, follow the instructions stated [here](/secureum-workshop.md#before-starting) to setup `medusa` and `solc`.

To start fuzzing, run the following command:

```bash
medusa fuzz --target tests/submission.sol --deployment-order ERC20Test,FixedPointMathLibTest,SignedWadMathTest
```

## Finding a bug in solmate

During the workshop, an edge case was discovered in the [`wadMul()`](https://github.com/transmissions11/solmate/blob/bfc9c25865a274a7827fea5abf6e4fb64fc64e6c/src/utils/SignedWadMath.sol#L58-L72) function of solmate's `SignedWadMath` library. Specific details of the bug can be found [here](https://github.com/transmissions11/solmate/pull/380).

The invariant that found the bug can be found in [`SolmateBugTest.sol`](/tests/SolmateBugTest.sol). To run the test, use the following command:

```bash
medusa fuzz --target tests/SolmateBugTest.sol  --deployment-order SolmateBugTest
```

`medusa` will instantly flag out an example where the invariant is violated.

## References

Some useful references while writing invariants:
- [Pre-built properties](https://github.com/crytic/properties) by [TrailOfBits](https://www.trailofbits.com/)
- [WETH invariant testing](https://github.com/horsefacts/weth-invariant-testing/tree/main) by [@horsefacts](https://twitter.com/eth_call)