// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "contracts/StaxLP.sol";
import "contracts/StaxLPStaking.sol";
import "@pwnednomore/contracts/PTest.sol";

contract StaxLPStakingTest is PTest {
    function setUp() public {
        deploy();
        init();
    }

    StaxLP public lp;
    StaxLPStaking public lpStaking;
    address public owner;

    function deploy() public {
        owner = makeAddr("OWNER");
        vm.startPrank(owner);
        lp = new StaxLP("Stax Frax/Temple LP Token", "xFraxTempleLP");
        lpStaking = new StaxLPStaking(address(lp), owner);
        vm.stopPrank();
    }

    address public user;
    uint256 public constant AMOUNT = 10e18;

    function init() public {
        user = makeAddr("USER");
        deal(address(lp), user, AMOUNT);
        vm.startPrank(user);
        lp.approve(address(lpStaking), lp.balanceOf(user));
        lpStaking.stakeAll();
        vm.stopPrank();
    }

    function invariantSafeUserAsset() public {
        vm.prank(user);
        lpStaking.withdrawAll(false);
        assert(lp.balanceOf(user) >= AMOUNT);
    }
}
