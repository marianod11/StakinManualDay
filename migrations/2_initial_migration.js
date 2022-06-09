const Staking = artifacts.require("Staking");
const Token = artifacts.require("Token");

module.exports = function (deployer) {
    deployer.deploy(Token, "marina","asdas", 18, 1000000000000000, "0x0C9c9875f797C403781533FF6a1334cA8436756C","0x0C9c9875f797C403781533FF6a1334cA8436756C").then(function () {
        console.log('Stake Contract Deployed: ', Token.address)
        return deployer.deploy(Staking, Token.address ).then(() => {
            console.log("ERC20 Contract Deployed",Staking.address)
        })
    })
};