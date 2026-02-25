// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {

    function balanceOf(address _account) external view returns(uint256);

    function transfer(address _recipient, uint256 _amount) external returns(bool);

    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

      function approve(address _spender, uint256 _amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 _amount, uint256 _fee);
}