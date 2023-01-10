//import logo from './logo.svg';
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import './App.css';
import HOG from './artifacts/contracts/Hog.sol/HOG.json';
import nft from './artifacts/contracts/Nft.sol/nft.json';
import hogMarket from './artifacts/contracts/SimpleHogMarket.sol/SimpleHogMarket.json';

const hogAddress = '0xa0F92Df550E1E12452C250465E54fDF77B9cf64d';//'0x5fbdb2315678afecb367f032d93f642f64180aa3';
const nftAddress = '0xC29Ca7c72Da0873693BF2d686544C17222EC2659';//'0x5FC8d32690cc91D4c39d9d3abcBD16989F875707';
const hogMarketAddress = '0xb2808904AD5E12163fB3cdf9d10350FDDE3B5B93';//'0x4b6aB5F819A515382B0dEB6935D793817bB4af28';

function App() {
  // Token
  const [totalSupply, setTotalSupplyValue] = useState();
  const [name, setNameValue] = useState();
  const [symbol, setSymbolValue] = useState();
  const [address, setAddressValue] = useState();
  const [balance, setBalanceOfValue] = useState();
  // Nft
  const [nftName, setNftNameValue] = useState();
  const [nftSymbol, setNftSymbolValue] = useState();
  //const [mintAddress, setMintAddressValue] = useState();
  //const [mint, setMintValue] = useState();
  const [nftPrice, setNftPriceValue] = useState();
  const [tokenId, setTokenIdValue] = useState();
  const [ownerOfNftAddress, setOwnerOfNftAddressValue] = useState();
  const [nftBalanceOfAddress, setNftBalanceOfAddressValue] = useState();
  // Market buy
  const [idToBuy, setIdToBuyValue] = useState();
  const [buy, setBuyValue] = useState();
  const [tokenApproval, setTokenApprovalValue] = useState();

  
  useEffect(() => {
    fetchInfo();
  }, [])

  async function fetchInfo() {
    if(typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(hogAddress, HOG.abi, provider);
      const contract2 = new ethers.Contract(nftAddress, nft.abi, provider);
      const contract3 = new ethers.Contract(hogMarketAddress, hogMarket.abi, provider);
      try {
        const data = await contract.totalSupply();
        const data2 = parseInt(data._hex, 16)*10**-18;
        setTotalSupplyValue(data2);
        const data3 = await contract.symbol();
        const data4 = await contract.name();
        setNameValue(data4);
        setSymbolValue(data3);
        // Nft
        const data5 = await contract2.symbol();
        const data6 = await contract2.name();
        const data7 = await contract2.balanceOf(hogMarketAddress);
        const data8 = parseInt(data7._hex, 16);
        setNftNameValue(data6);
        setNftSymbolValue(data5);
        setNftBalanceOfAddressValue(data8);
        const data9 = await contract3.buyPrice();
        const data10 = Math.round(parseInt(data9._hex, 16)*10**-18);
        setNftPriceValue(data10);
      }
      catch(err) {
        console.log(err);
      }
    }
  }
  //
  async function getOwnerOfToken() {
    if(!tokenId) return
    if(typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(nftAddress, nft.abi, provider);
      try {
        const data = await contract.ownerOf(tokenId);
        //const data2 = parseInt(data._hex, 16)*10**-18;
        setOwnerOfNftAddressValue(data);
      }
      catch(err) {
        console.log(err);
      }
    }
  }


  //

  async function requestAccount() {
    await window.ethereum.request({method: 'eth_requestAccounts'});
  }

  // Buy Nft

  async function giveApprovalToBuyNft() {
    //if(!idToBuy) return
    if(typeof window.ethereum !== 'undefined') {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(hogMarketAddress, hogMarket.abi, signer);
      const contract2 = new ethers.Contract(hogAddress, HOG.abi, signer);
      const price = await contract.buyPrice();
      const approval = await contract2.approve(hogMarketAddress, price);
      await approval.wait();
      setTokenApprovalValue(approval);
    }
  }

  async function buyNft() {
    if(!idToBuy) return
    if(typeof window.ethereum !== 'undefined') {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(hogMarketAddress, hogMarket.abi, signer);
      const contract3 = new ethers.Contract(nftAddress, nft.abi, signer);
      const ownerOfNft = await contract3.ownerOf(idToBuy);
      if(ownerOfNft !== hogMarketAddress) return
      const transaction = await contract.simpleBuy(idToBuy);
      await transaction.wait();
      setBuyValue(transaction);
    }
  }
  

  return (
    <div className="App">
      <h1>Simple Hog Market</h1>
      <h3>by Harmonauts DAO and Tr4ck3r</h3>

      <div className="instructions">
        <h2>Instructions</h2>
        <h3>1. Check you're connected to Harmony network.</h3>
        <h3>2. Identify the Harmonaut you want to buy in the wallet of contract.</h3>
          <p>https://nftkey.app/address/?address=0xb2808904AD5E12163fB3cdf9d10350FDDE3B5B93</p>
          <p>https://www.harmonautsforce.one/view/0xb2808904AD5E12163fB3cdf9d10350FDDE3B5B93</p>
        <h3>3. Approve</h3>
          <p>To allow the contract to take $HOG in exchange of the Harmonaut.</p>
        <h3>4. Buy</h3>
          <p>Enter wanted Harmonaut #ID and click "Buy".</p>
      </div>

      <div className="right">
        <h2>NFT</h2>
          <p>HNAUTS balance in Hog Market: {nftBalanceOfAddress} available to buy.</p>
        <h3>Ownership</h3>
        <input onChange={e => setTokenIdValue(e.target.value)} placeholder="0" />
        <button onClick={getOwnerOfToken}>Owner of NFT</button>
        <p>Owner of {tokenId}: {ownerOfNftAddress}</p>
        <hr></hr>
        <h3>Approval {nftPrice} $HOG</h3>
        <button onClick={giveApprovalToBuyNft}>Approve</button>
        <hr></hr>
        <h3>Buy HNAUT #{idToBuy} for {nftPrice} $HOG</h3>
        <input onChange={e => setIdToBuyValue(e.target.value)} placeholder="0" />
        <button onClick={buyNft}>Buy</button>
      </div>

      <hr></hr>
      <h3>Community and Support</h3>
      <p>Discord: https://discord.gg/pkGjmyMUfN</p>
      <p>Twitter: https://twitter.com/harmonauts_dao</p>
      <h3>Send Tips</h3>
      <p>Harmonauts DAO: 0x3A46ed57A297f9D6BbF9DDd054B5419b707781aB</p>
      <p>Developer: 0xff005147ef4A0e8358Ee1363e25C63C1A29db62b</p>
    </div>
  );
}

export default App;
