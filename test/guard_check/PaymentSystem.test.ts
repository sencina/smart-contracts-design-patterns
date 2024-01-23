import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Signer } from 'ethers';


describe('PaymentSystem', function () {
  let paymentSystem: any;
  let owner: Signer;
  let user: Signer;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // Deploy the PaymentSystem contract
    const PaymentSystemFactory = await ethers.getContractFactory('PaymentSystem');
    paymentSystem = (await PaymentSystemFactory.deploy());
    await paymentSystem.deployed();
  });

  it('should transfer funds for the first payment', async function () {
    const recipient = await user.getAddress();
    const amount = ethers.parseEther('1.0');

    await expect(() =>
      owner.sendTransaction({
        to: paymentSystem.address,
        value: amount,
      })
    ).to.changeEtherBalance(owner, amount * BigInt(-1));

    await expect(() =>
      paymentSystem.pay(recipient, {
        value: amount,
      })
    ).to.changeEtherBalance(recipient, amount);

    expect(await paymentSystem.paid(await owner.getAddress())).to.be.true;
  });

  it('should transfer funds with fee for subsequent payments', async function () {
    const recipient = await user.getAddress();
    const amount = ethers.parseEther('1.0');

    await paymentSystem.pay(recipient, {
      value: amount,
    });

    const balanceBefore = await ethers.provider.getBalance(recipient);

    await expect(() =>
      paymentSystem.pay(recipient, {
        value: amount,
      })
    ).to.changeEtherBalance(recipient, amount * BigInt(90) / BigInt(100)); // 90% of amount after 10% fee

    const balanceAfter = await ethers.provider.getBalance(recipient);
    expect(balanceAfter - BigInt(balanceBefore)).to.equal(amount * BigInt(90) / BigInt(100));

    expect(await paymentSystem.paid(await owner.getAddress())).to.be.true;
  });

  it('should revert if recipient address is zero', async function () {
    const amount = ethers.parseEther('1.0');
    const zeroAddress = ethers.getAddress('0x0000000000000000000000000000000000000000');
    await expect(
      paymentSystem.pay(zeroAddress, {
        value: amount,
      })
    ).to.be.revertedWith('Recipient address cannot be zero');
  });

  it('should revert if amount is zero', async function () {
    const recipient = await user.getAddress();

    await expect(
      paymentSystem.pay(recipient, {
        value: 0,
      })
    ).to.be.revertedWith('Amount must not be 0');
  });

  it('should revert if transfer amount after fee is zero', async function () {
    const recipient = await user.getAddress();
    const amount = ethers.parseEther('0.001');

    await expect(
      paymentSystem.pay(recipient, {
        value: amount,
      })
    ).to.be.revertedWith('Transfer amount after fee must be greater than 0');
  });
});
