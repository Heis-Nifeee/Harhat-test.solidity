import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("ERC20", function () {
  async function deployERC20() {
   
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const ERC20 = await hre.ethers.getContractFactory("Token");
    const erc20 = await ERC20.deploy("NifToken", "NTK", 18, 1000000);

    return {erc20, owner, otherAccount};
    
  }
  describe("Deployment", function () {
    it("it Should get name", async function () {
      const { erc20 } = await loadFixture(deployERC20);

      const name = erc20.getterName();

      expect(await name).to.equal("NifToken");
    });

    it("it Should get symbol", async function () {
      const { erc20 } = await loadFixture(deployERC20);

      const symbol = erc20.getterSymbol();

      expect(await symbol).to.equal("NTK");
    });

    it("it Should get total supply", async function () {
      const { erc20 } = await loadFixture(deployERC20);

      const totalSupply = erc20.totalSupply();

      expect(await totalSupply).not.equal(0);
    });

    it("it Should get decimal", async function () {
      const { erc20 } = await loadFixture(deployERC20);

      const totalSupply = erc20.getterDecimal();

      expect(await totalSupply).to.equal(18);
    });

       it("it Should get the balance of an address", async function () {
      const { erc20, owner } = await loadFixture(deployERC20);

      const balanceOf = erc20.balanceOf(owner);

      // expect(await balanceOf).to.equal();

      console.log(await balanceOf);
    });
  });
});

describe("SaveAsset", function () {
  async function deploySaveAsset() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    // Deploy ERC20 first
    const ERC20 = await hre.ethers.getContractFactory("Token");
    const token = await ERC20.deploy("NifeToken", "NTK", 18, 1000000);

    // Deploy save contract with token addr
    const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
    const save_asset = await SaveAsset.deploy(token.target);

    return { save_asset, token, owner, otherAccount };
  }

  describe("ERC20 Deposits & Withdrawals", function () {
    it("Should deposit ERC20", async function () {
      const { save_asset, token, owner } = await loadFixture(deploySaveAsset);

      await token.approve(save_asset.target, 1000);
      await save_asset.depositERC20(1000);

      expect(await save_asset.getErc20SavingsBalance(owner.address)).to.equal(1000);
    });

    it("Should withdraw ERC20", async function () {
      const { save_asset, token, owner } = await loadFixture(deploySaveAsset);

      await token.approve(save_asset.target, 1000);
      await save_asset.depositERC20(1000);

      await save_asset.withdrawERC20(500);

      expect(await save_asset.getErc20SavingsBalance(owner.address)).to.equal(500);
    });

    it("Should revert withdraw if insufficient funds", async function () {
      const { save_asset } = await loadFixture(deploySaveAsset);

      await expect(save_asset.withdrawERC20(1000)).to.be.revertedWith(
        "Not enough savings"
      );
    });
  });

  describe("Ether Deposits", function () {
    it("Should deposit Ether", async function () {
      const { save_asset } = await loadFixture(deploySaveAsset);

      await save_asset.deposit({ value: hre.ethers.parseEther("1") });

      expect(await save_asset.getUserSavings()).to.equal(
        hre.ethers.parseEther("1")
      );
    });

    it("Contract should show Ether balance", async function () {
      const { save_asset } = await loadFixture(deploySaveAsset);

      const etherBalance = await save_asset.deposit({
        value: hre.ethers.parseEther("0.5"),
      });

      expect(await save_asset.getContractBalance()).to.equal(
        hre.ethers.parseEther("0.5")
      );

    });
  });
});