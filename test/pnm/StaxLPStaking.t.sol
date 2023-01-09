// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./FakeStaking.sol";

import "contracts/StaxLP.sol";
import "contracts/StaxLPStaking.sol";
import "@pwnednomore/contracts/invariants/DepositWithdrawalFailureTest.sol";

contract StaxLPStakingTest is DepositWithdrawalFailureTest {
    StaxLP public lp;
    StaxLPStaking public lpStaking;

    uint256 public constant AMOUNT = 10e18;
    address public owner;
    address public user;

    function deploy() public override {
        owner = makeAddr("OWNER");
        vm.startPrank(owner);
        lp = new StaxLP("Stax Frax/Temple LP Token", "xFraxTempleLP");
        lpStaking = new StaxLPStaking(address(lp), owner);
        vm.stopPrank();
    }

    function init() public override {
        user = makeAddr("USER");
        deal(address(lp), user, AMOUNT);
        deposit();
    }

    function deposit() public override {
        vm.startPrank(user);
        lp.approve(address(lpStaking), lp.balanceOf(user));
        lpStaking.stakeAll();
        vm.stopPrank();
    }

    function withdraw() public override {
        vm.prank(user);
        lpStaking.withdrawAll(false);
    }

    function invariantDepositWithdrawalFailure() public override {
        withdraw();
        assert(lp.balanceOf(user) >= AMOUNT);
    }
}
