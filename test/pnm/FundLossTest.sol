// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {FundLossRecipe} from "@pwnednomore/contracts/recipes/FundLossRecipe.sol";

import "contracts/StaxLP.sol";
import "contracts/StaxLPStaking.sol";

import "./FakeStaking.sol";

contract FundLossTest is FundLossRecipe {
    StaxLP lp;
    StaxLPStaking lpStaking;

    uint256 userLpAmount = 1 ether;

    // MyContract myContract;

    // Define how to deploy the contract(s) to be tested
    // Returns the one for balance checking
    function deploy() public override returns (address) {
        // Deploy LP token and LP staking contract
        vm.startPrank(owner);
        lp = new StaxLP("Stax Frax/Temple LP Token", "xFraxTempleLP");
        lpStaking = new StaxLPStaking(address(lp), owner);
        vm.stopPrank();

        // Create a user who is going to stake 1 ether LP tokens
        vm.startPrank(user);
        deal(address(lp), user, userLpAmount);
        lp.approve(address(lpStaking), type(uint256).max);
        lpStaking.stakeAll();
        vm.stopPrank();

        return user;
    }

    // Define how to calculate the vaule you want to check
    function getTargetBalance(address target)
        public
        override
        returns (uint256)
    {
        return lp.balanceOf(target);
    }

    // TODO: To customize report trigerring condition, you could override following functions:
    // function checkProtocolFundIsSafe(address protocol, uint256 initValue) public override {}
    // function checkUserFundIsSafe(address user, uint256 initValue) public override {}
    // function checkAgentFundNoGain(address agent, uint256 initValue) public override {}
}
