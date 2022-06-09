
const Stake = artifacts.require("./Staking.sol")
const Token = artifacts.require("./Token.sol")


contract ("NFTStake", async()=>{
    let stake 
    let token;



    before(async()=>{
        token = await Token.deployed("marina","asdas", 18, 1000000000000000, 0x4e12b9E4298DC8Ac476221dC7BE80d27470852f6,0x4e12b9E4298DC8Ac476221dC7BE80d27470852f6)
        stake = await Stake.deployed(token.address)
    })

    
    describe("deployed", async()=>{
        it("cuenta del dueño", async()=>{

           await token.approve(stake.address, 10000000000);


           const envio1 = await stake.envioUSDT(100)
  


           const envio2 = await stake.envioUSDT(100)


           const sumarGanancias = await stake.sumarGanancias()

           console.log("sumarrr gananciasis",sumarGanancias)


           const solicitarRetiro = await stake.solicitarRetiro(100)

           console.log("retiroooo",solicitarRetiro )


           const repartoGanancias = await stake.repartoGanancias()

           console.log("reparto de ganancias",repartoGanancias )
      
            
        })

    })  

    



    


    })