// SPDX-License-Identifier: UNLICENSED
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Foundation, 2023.
pragma solidity ^0.8.17;

import {PriceFeedUnitTest} from "../../suites/PriceFeedUnitTest.sol";

import {WstETHMock} from "../../mocks/lido/WstETHMock.sol";

import {IwstETH} from "../../../interfaces/lido/IwstETH.sol";
import {WstETHPriceFeed} from "../../../oracles/lido/WstETHPriceFeed.sol";

contract WstETHPriceFeedUnitTest is PriceFeedUnitTest {
    WstETHPriceFeed priceFeed;
    WstETHMock wstETH;

    function setUp() public {
        _setUp();

        wstETH = new WstETHMock(makeAddr("stETH"));
        wstETH.hackStEthPerToken(1.02 ether);

        priceFeed = new WstETHPriceFeed(
            address(addressProvider),
            address(wstETH),
            address(underlyingPriceFeed),
            1 days
        );

        wstETH.hackStEthPerToken(1.03 ether);
    }

    /// @notice U:[LDO-1]: Price feed works as expected
    function test_U_LDO_01_price_feed_works_as_expected() public {
        // constructor
        assertEq(priceFeed.lpToken(), address(wstETH), "Incorrect lpToken");
        assertEq(priceFeed.lpContract(), address(wstETH), "Incorrect lpToken");
        assertEq(priceFeed.lowerBound(), 1.01796 ether, "Incorrect lower bound"); // 1.02 * 0.998

        // overriden functions
        vm.expectCall(address(wstETH), abi.encodeCall(IwstETH.stEthPerToken, ()));
        assertEq(priceFeed.getLPExchangeRate(), 1.03 ether, "Incorrect getLPExchangeRate");
        assertEq(priceFeed.getScale(), 1 ether, "Incorrect getScale");
    }
}
