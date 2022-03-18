const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber }=require('ethers');



describe("Don Rouch", function(){


    before(async () => {

    [owner, buyer,admin] = await ethers.getSigners();
    });

    it("Should deploy contract", async function(){
    const DonRouchFactory = await ethers.getContractFactory("DonRouch");
    donrouch = await DonRouchFactory.deploy("https://samotclub.mypinata.cloud/ipfs/QmeLn1Vx2FLMQypLPqQfohYqEt4kJnUx5DUpc3pmwGU85w/{id}.json","DonRouch","DR");
    await donrouch.deployed();
    const contractAddress = donrouch.address;


    });
})
