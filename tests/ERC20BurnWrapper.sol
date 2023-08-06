// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ERC20Burn} from "contracts/ERC20Burn.sol";
import {AddressSet, LibAddressSet} from "./AddressSet.sol";

contract ERC20BurnWrapper is ERC20Burn {
    using LibAddressSet for AddressSet;

    // User tracking
    AddressSet internal _actors;

    function getActor(uint256 actorSeed) public view returns (address) {
        return _actors.rand(actorSeed);
    }

    function actorCount() public view returns (uint256) {
        return _actors.count();
    }

    // ERC20Burn functions
    constructor() ERC20Burn() {
        _actors.add(msg.sender);
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _actors.add(msg.sender);
        _actors.add(spender);

        return super.approve(spender, amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _actors.add(msg.sender);
        _actors.add(to);

        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _actors.add(msg.sender);
        _actors.add(from);
        _actors.add(to);

        return super.transferFrom(from, to, amount);
    }
}
