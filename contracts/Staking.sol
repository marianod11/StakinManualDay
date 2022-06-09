// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract Staking is Ownable {
    using SafeMath for uint256;

    IERC20 public USDT;

    uint public porcentajeSemanal = 200;
    uint public cantidadMinima = 100;

    uint256 totalSolicitado;
    uint256 totalStakeado;
    address [] public usuarios;
    address [] public usuariosPetisiones;

    struct Plan{
        uint256 cantidadInvertida;
        uint256 fechaDeEntrada;
        uint256 inversion;
    }

    struct UserInfo {
        address inversor;
        Plan[] plans;
        uint cantidadTotal;
    }



    mapping (address => UserInfo ) public userInfo;
    mapping (address => bool) public addressInfo;
    mapping (address => uint256) public petisionDeRetiro;
    

    event envioUSD(address inversor, uint256 cantidadInvertida);
    event totalCobrarSemanal(uint cantidad, address inversor);
    event retirarPlataInicial(uint);
    event retiroParcial (address, uint);
    event retiro(uint256);
    event noCobras (string);
    event solcictudRetiro(uint, address);


    constructor(address _usdt){
        USDT = IERC20 (_usdt);
    }
  

//------------------- envios y retiros ---------------------//


//ENVIO USDT AL CONTRATO (ESTA ES LA QUE VA) FUNCION NOTOCARRRRRRRRRRR!!!!!!!!!!!!!!!!!!!!!

    function envioUSDT(uint256 _cantidad) public   {
        uint256 balance = IERC20(USDT).balanceOf(msg.sender);
        require(balance >= _cantidad, "no tienes suficientes usdt");
        require(_cantidad >= cantidadMinima, "poner mas usdt");
        uint256 allowance = IERC20(USDT).allowance(msg.sender, address(this));
        require(_cantidad > 0, "You need to sell at least some tokens");
        require(allowance >= _cantidad, "Check the token allowance");
        UserInfo storage user = userInfo[msg.sender];
        if (_cantidad > 0){
            require(IERC20(USDT).transferFrom(msg.sender, address(this), _cantidad));
        }         
                    user.inversor = msg.sender;
                    user.plans.push(Plan(_cantidad, block.timestamp, _cantidad));
                 
                    usuarios.push(msg.sender);
                    addressInfo[msg.sender] = true;
         
                emit envioUSD( msg.sender, _cantidad);
            
        totalStakeado = totalStakeado.add(_cantidad);

    }






//SACAR USDT DEL CONTRATO (ESTA ES LA QUE VA) NO TOCARRRRRRRRRRRRRRRRRRRRRRRRRRR!!!!!!!
    function withdrawAll(uint256 _cantidad) external  onlyOwner {
            if(_cantidad > 0){
               IERC20(USDT).approve(address(this),_cantidad);
               require(IERC20(USDT).transferFrom(address(this), msg.sender, _cantidad),"DASDAS");
            }
        emit retiro(_cantidad);
    } 
/*
//SUMAR GANANCIAS (ESTA ES LA QUE VA) FUNCIONAA // CARGAA EL % DIARIO A CADA PAGO!!!
    function sumarGanancias() public onlyOwner{
        UserInfo storage user = userInfo[msg.sender]; 
    
        for(uint i = 0; i < user.plans.length; i++) {
          uint256 timeTamp = user.plans[i].fechaDeEntrada;
          uint256 timeInicial = block.timestamp.sub(timeTamp);
          if(timeInicial < 10 seconds) {
                string memory nocobras= "no cobrassss";
                emit noCobras ( nocobras);
           }else{      
                uint256 cantidadCobrar = user.plans[i].cantidadInvertida.mul(porcentajeSemanal).div(10000); 
                uint totalFinal = user.plans[i].cantidadInvertida.add(cantidadCobrar);
                user.plans[i].cantidadInvertida = totalFinal;

                user.cantidadTotal = returnTotal() ;
               
                emit totalCobrarSemanal(totalFinal, user.inversor);  
          }     
        }
    }
*/

/// SUMA TODO EN EL PRIMER PAGO Y ELIMINA LOS OTROS---- SI LE CARGAS OTRO PAGO SE LE SUMA DIRECTAMENTE. NO ESEPRA LAS HORAS
    function _sumarGanancias2() private returns(uint256 total){
    uint256 cantidadCobrarTotal ;
    for(uint j = 0 ; j < usuarios.length; j++){
        UserInfo storage user = userInfo[usuarios[j]]; 

        for(uint i = 0; i < user.plans.length; i++) {
          
          uint256 timeTamp = user.plans[i].fechaDeEntrada;
          uint256 timeInicial = block.timestamp.sub(timeTamp);
          if(timeInicial < 10 seconds) {
                string memory nocobras= "no cobrassss";
                emit noCobras ( nocobras);
           }else{    
               uint256 cantidadCobrar = user.plans[i].cantidadInvertida; 
            //   uint totalFinal = user.plans[i].cantidadInvertida.add(cantidadCobrar);
                cantidadCobrarTotal += user.plans[i].cantidadInvertida ;

                user.cantidadTotal = cantidadCobrarTotal ;

                emit totalCobrarSemanal(cantidadCobrar, user.inversor);           

                if( timeInicial > 10 seconds)  {
                    user.plans[i].cantidadInvertida = 0;
                }
            }    
        }
    }
        return cantidadCobrarTotal;
    }

    function sumaTotal() public onlyOwner {
        
        for(uint j = 0 ; j < usuarios.length; j++){
         UserInfo storage user = userInfo[usuarios[j]]; 
       
        uint256 total = user.cantidadTotal;
        uint256 totalfianl = _sumarGanancias2();

        uint sumaYTotal = total.add(totalfianl);
        uint totalCobrar = sumaYTotal.mul(porcentajeSemanal).div(10000);
        uint totalFinal = sumaYTotal.add(totalCobrar);
            
        user.cantidadTotal = totalFinal;
        }

    }


//SOLICITUD DE RETIRO (ESTA ES LA QUE VA) FUNCIONA 
    function solicitarRetiro(uint256 _cantidad) public {
        UserInfo storage user = userInfo[msg.sender]; 

        uint256 balance = IERC20(USDT).balanceOf(address(this));
        require(_cantidad <= balance, "no hay suficiente usdt");
        require(_cantidad <= user.cantidadTotal, "no tenes tanto usdt" );
        petisionDeRetiro[msg.sender] += _cantidad;
       // require(petisionDeRetiro[msg.sender] <= cantidadCobrar,"no tens tanto");
        require(petisionDeRetiro[msg.sender] <= user.cantidadTotal, "no hay tantoo");
   

        usuariosPetisiones.push(msg.sender);
        totalSolicitado = totalSolicitado.add(_cantidad);

        emit solcictudRetiro (_cantidad, msg.sender);  
    }


//REPARTO DE GANANCIAS (ESTA ES LA QUE VA) FUNCIONA NO TOCARR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    function repartoGananciasNosotros() public onlyOwner{
      for(uint i = 0; i <usuariosPetisiones.length; i++ ){
           uint256 cantidadCobrar = petisionDeRetiro[usuariosPetisiones[i]];
           uint256 balance = IERC20(USDT).balanceOf(address(this));
           require(balance >= totalSolicitado, "faltan usdtss");
            totalSolicitado=totalSolicitado.sub(cantidadCobrar);
            if(cantidadCobrar > 0){   
                IERC20(USDT).approve(address(this),cantidadCobrar);
                require(IERC20(USDT).transferFrom(address(this), usuariosPetisiones[i], cantidadCobrar),"DASDAS");   
            }       
         //   petisionDeRetiro[usuariosPetisiones[i]] -= cantidadCobrar;  

            delete petisionDeRetiro[usuariosPetisiones[i]];
             //  UserInfo storage user = userInfo[usuariosPetisiones[i]]; 
              //  user.cantidadTotal -= cantidadCobrar; 
                delete usuariosPetisiones[i];

            emit retiroParcial(usuariosPetisiones[i],cantidadCobrar );
        }
    }

//RETIRO DE GANANCIAS PAGANDO EL GAS ELLOS FUNCIONA NOTOCAAA!!!
    function retiroGananciasCadaUno() public{
     
           uint256 cantidadCobrar = petisionDeRetiro[msg.sender];
            totalSolicitado=totalSolicitado.sub(cantidadCobrar);
            if(cantidadCobrar > 0){   
                IERC20(USDT).approve(address(this),cantidadCobrar);
                require(IERC20(USDT).transferFrom(address(this), msg.sender, cantidadCobrar),"DASDAS");   
            } 
            petisionDeRetiro[msg.sender] = 0; 

            delete usuariosPetisiones;

            emit retiroParcial(msg.sender,cantidadCobrar );
        
    }

function returnTot(address _user) public view returns(uint total){
     UserInfo storage user = userInfo[_user]; 

    return user.cantidadTotal;

   
}

//FUNCION PENDIENTE DE PAGO NO FUNCIONA!!! NOTOCARRRRRRRR!!!!
  function pendientePago() public onlyOwner{
      for(uint i = 0; i <usuariosPetisiones.length; i++ ){
           UserInfo storage user = userInfo[usuariosPetisiones[i]]; 
           uint256 cantidadCobrar = petisionDeRetiro[usuariosPetisiones[i]];      
            user.cantidadTotal -= cantidadCobrar; 
            emit retiroParcial(usuariosPetisiones[i],cantidadCobrar );
        }
    }

//CUANTOS USDT SE SOLICITARON
    function totalPedidos() public view onlyOwner returns(uint256){
        return totalSolicitado;
    }


//BALANCE USDT
    function balanceUSDT() public view returns(uint256){
        uint256 balance = IERC20(USDT).balanceOf(address(this));
        return balance;
    }   

//AGREGAR CANTIDAD TOTAL
    function agregarCantidadTotal(address _user, uint256 _cantidad) public onlyOwner{
        UserInfo storage user = userInfo[_user];

        user.cantidadTotal += _cantidad; 
    }
//SACAR CANTIDAD TOTAL
    function sacarCantidadTotal(address _user, uint256 _cantidad) public onlyOwner{
        UserInfo storage user = userInfo[_user];
        user.cantidadTotal -= _cantidad; 
    }


    function cantidadTotalUSDT() public view returns(uint256){
        uint256 cantidadTotalusd;
        for(uint i = 0; i < usuarios.length; i++) {
             UserInfo storage user = userInfo[usuarios[i]]; 
            cantidadTotalusd += user.cantidadTotal;
        }
        return cantidadTotalusd;

    }


 //------------------ retornos y cambios de variables -------------------//   
    function returnTotal()public view returns(uint256 cantidad){
      UserInfo storage user = userInfo[msg.sender]; 
      uint256 cantidadCobrar;
      for(uint i = 0; i < user.plans.length; i++) {  
         cantidadCobrar += user.plans[i].cantidadInvertida;
      }
       return cantidadCobrar;
    }

    function returnPorcentajeSemanal()public view returns(uint){
        return porcentajeSemanal;
    }

    function cambiarPorcetajeSemanal(uint _porcertaje) public onlyOwner{
        porcentajeSemanal = _porcertaje;
    }

    function returnminimoUSDT()public view returns(uint){
        return cantidadMinima;
    }

    function cambiarMinimoUsdt(uint _cantidad) public onlyOwner{
        cantidadMinima = _cantidad;
    }

    function returnCantidadUst()public view returns(uint){
        return totalStakeado;
    }


}