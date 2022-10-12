// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "contracts/StaxLP.sol";
import "contracts/StaxLPStaking.sol";
import "@pwnednomore/contracts/PTest.sol";

contract StaxLPStakingTest is PTest {
    StaxLP lp;
    StaxLPStaking lp_staking;

    address owner = address(0x1011);
    address user = address(0x1012);
    uint256 user_lp_amount = 1 ether;

    function setUp() public {
        // Deploy LP token and LP staking contract
        lp = new StaxLP("Stax Frax/Temple LP Token", "xFraxTempleLP");
        lp_staking = new StaxLPStaking(address(lp), owner);

        // Create a user who is going to stake 1 ether LP tokens
        vm.startPrank(user);
        deal(address(lp), user, user_lp_amount);
        lp.approve(address(lp_staking), type(uint256).max);
        lp_staking.stakeAll();
        vm.stopPrank();

        useDefaultAgent();
    }

    // User should always be able to withdraw the tokens once staked
    function invariantGetWhatPut() public {
        vm.prank(user);
        lp_staking.withdrawAll(false);
        assert(lp.balanceOf(user) >= user_lp_amount);
    }
}
