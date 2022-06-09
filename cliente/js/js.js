const NETWORK_ID = 5777
var contract
var contract1
var accounts
var web3
var balance
var price
var price1
let arrayUsuarios = [];
var balanceETH

function metamaskReloadCallback()
{
  window.ethereum.on('accountsChanged', (accounts) => {
    document.getElementById("web3_message").textContent="Accounts changed, realoading...";
    window.location.reload()
  })
  window.ethereum.on('networkChanged', (accounts) => {
    document.getElementById("web3_message").textContent="Network changed, realoading...";
    window.location.reload()
  })
}

const getWeb3 = async () => {
  return new Promise((resolve, reject) => {
    if(document.readyState=="complete")
    {
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum)
        metamaskReloadCallback()
        try {
          // ask user permission to access his accounts
          (async function(){
            await window.ethereum.request({ method: "eth_requestAccounts" })
          })()
          resolve(web3)
        } catch (error) {
          reject(error)
        }
      } else {
        reject("must install MetaMask")
        document.getElementById("web3_message").textContent="Error: Please install Metamask";
      }
    }else
    {
      window.addEventListener("load", async () => {
        if (window.ethereum) {
          const web3 = new Web3(window.ethereum)
          metamaskReloadCallback()
          try {
            // ask user permission to access his accounts
            await window.ethereum.request({ method: "eth_requestAccounts" })
            resolve(web3);
          } catch (error) {
            reject(error);
          }
        } else {
          reject("must install MetaMask")
          document.getElementById("web3_message").textContent="Error: Please install Metamask";
        }
      });
    }
  });
};





function handleRevertError(message) {
  alert(message)
}

async function getRevertReason(txHash) {
  const tx = await web3.eth.getTransaction(txHash)
  await web3.eth
    .call(tx, tx.blockNumber)
    .then((result) => {
      throw Error("unlikely to happen")
    })
    .catch((revertReason) => {
      var str = "" + revertReason
      json_reason = JSON.parse(str.substring(str.indexOf("{")))
      handleRevertError(json_reason.message)
    });
}

const getContract = async (web3) => {
  const data = await getJSON("./contract/Staking.json")
  const netId = await web3.eth.net.getId()
  const deployedNetwork = data.networks[netId]
  const contract = new web3.eth.Contract(
    data.abi,
    deployedNetwork && deployedNetwork.address
  )
  return contract
}


const getContract1 = async (web3) => {
  const data = await getJSON("./contract/Token.json")

  const netId = await web3.eth.net.getId()
  const deployedNetwork = data.networks[netId]
  const contract1 = new web3.eth.Contract(
    data.abi,
    deployedNetwork && deployedNetwork.address
  )
  return contract1
}




function getJSON(url) {
  return new Promise(resolve => {
    var xhr = new XMLHttpRequest()
    xhr.open("GET", url, true)
    xhr.responseType = "json"
    xhr.onload = function () {
      resolve(xhr.response)
    };
    xhr.send()
  });
}


async function loadApp() {
  var awaitWeb3 = async function () {
    web3 = await getWeb3()
    web3.eth.net.getId((err, netId) => {
      if (netId == NETWORK_ID) {
        var awaitContract = async function () {
      
          //NFT CONTRACT
          contract = await getContract(web3);

          //STAKE CONTRACT
          contract1 = await getContract1(web3);

          var awaitAccounts = async function () {

          //ADDRESS
            accounts = await web3.eth.getAccounts()
            document.getElementById("web3_message").textContent="Connected";
            balanceETH = await web3.eth.getBalance(accounts[0])
            document.getElementById("balanceETH").textContent=balanceETH/1000000000000000000;

          //BALANCE DE NFT 
         
            document.getElementById("accounts").textContent=accounts;
                  
          //BALANCE DE TOKEN
            const balancetoken = await contract1.methods.balanceOf(accounts[0]).call()
        
            document.getElementById("tokens").textContent=balancetoken 

            const USDT = await contract.methods.balanceUSDT().call()
            document.getElementById("USDT").textContent=USDT

            const totalUSDT = await contract.methods.returnTot(accounts[0]).call()

            document.getElementById("usdtotal").textContent=totalUSDT  

            const totalStakeado = await contract.methods.returnCantidadUst().call()

            document.getElementById("totalStakeado").textContent=totalStakeado  
          
           

            
          };
          awaitAccounts();
        };
        awaitContract();
      } else {
        document.getElementById("web3_message").textContent="Please connect to Rinkeby Testnet";
      }
    });
  };
  awaitWeb3();
}

loadApp()

const envioUSDT= async () =>{ 

  arrayUsuarios.push(accounts[0]);


 await contract.methods.envioUSDT(1000)
 
  .send({ from: accounts[0], gas: 1000000 })


  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="levantoandoooo...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Minting finished.";    })
  .catch((revertReason) => {
    getRevertReason(revertReason.receipt.transactionHash);
  });

}
const sumaTotal = async () =>{ 
   await contract.methods.sumaTotal()
  .send({ from: accounts[0], gas: 10000000 })


  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="levantoandoooo...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Minting finished.";    })
  .catch((revertReason) => {
    getRevertReason(revertReason.receipt.transactionHash);
  });
}

 const solicitarRetiro = async () =>{ 
    await  contract.methods.solicitarRetiro(500)
    .send({ from: accounts[0], gas: 1000000 })
  
  
    .on('transactionHash', function(hash){
      document.getElementById("web3_message").textContent="levantoandoooo...";
    })
    .on('receipt', function(receipt){
      document.getElementById("web3_message").textContent="Success! Minting finished.";    })
    .catch((revertReason) => {
      getRevertReason(revertReason.receipt.transactionHash);
    });
 }
 const retiroGananciasCadaUno = async () =>{ 
    await  contract.methods.retiroGananciasCadaUno()
    .send({ from: accounts[0], gas: 1000000 })
    
    
      .on('transactionHash', function(hash){
        document.getElementById("web3_message").textContent="levantoandoooo...";
      })
      .on('receipt', function(receipt){
        document.getElementById("web3_message").textContent="Success! Minting finished.";    })
      .catch((revertReason) => {
        getRevertReason(revertReason.receipt.transactionHash);
      });
    }

const pendientePago = async () =>{   
  await contract.methods.pendientePago()
      .send({ from: accounts[0], gas: 1000000 })
      
      
        .on('transactionHash', function(hash){
          document.getElementById("web3_message").textContent="levantoandoooo...";
        })
        .on('receipt', function(receipt){
          document.getElementById("web3_message").textContent="Success! Minting finished.";    })
        .catch((revertReason) => {
          getRevertReason(revertReason.receipt.transactionHash);
        });

    }

    const approve = async () =>{   
     await   contract1.methods.approve("0xC19ec3ec19D6DA9fF5BF76ef140F10C36a4FFfcd", 100000000000)
          .send({ from: accounts[0], gas: 1000000 })
          
          
            .on('transactionHash', function(hash){
              document.getElementById("web3_message").textContent="levantoandoooo...";
            })
            .on('receipt', function(receipt){
              document.getElementById("web3_message").textContent="Success! Minting finished.";    })
            .catch((revertReason) => {
              getRevertReason(revertReason.receipt.transactionHash);
            });
    
        }

        const transfer = async () =>{   
          await   contract1.methods.transfer("0x3A1C796Ec83788A448FD9e6E4451be69Da842B33", web3.utils.toWei("10000", "ether"))
               .send({ from: accounts[0], gas: 1000000 })
               
               
                 .on('transactionHash', function(hash){
                   document.getElementById("web3_message").textContent="levantoandoooo...";
                 })
                 .on('receipt', function(receipt){
                   document.getElementById("web3_message").textContent="Success! Minting finished.";    })
                 .catch((revertReason) => {
                   getRevertReason(revertReason.receipt.transactionHash);
                 });
         
             }

     

