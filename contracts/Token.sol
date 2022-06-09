// SPDX-License-Identifier: MIT


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


pragma solidity ^0.8.0;

/**
 *@dev Interfaz del estándar ERC20 según se define en el EIP.
 */
interface IERC20 {
    /**
     * @dev Devuelve la cantidad de tokens existentes.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Devuelve la cantidad de tokens que posee la `cuenta`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Mueve los tokens de "cantidad" de la cuenta de la persona que llama al "destinatario".
     *
     * Devuelve un valor booleano que indica si la operación se realizó correctamente.
     *
     * Emite un evento {Transfer}.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Devuelve el número restante de tokens que el `gastador` será
     * permitido gastar en nombre del `propietario` a través de {transferFrom}. Este es
     * cero por defecto.
     *
     * Este valor cambia cuando se llama a {aprobar} o {transferFrom}.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Establece `amount` como la asignación de` gastador` sobre los tokens de la persona que llama.
     *
     * Devuelve un valor booleano que indica si la operación se realizó correctamente.
     *
     * IMPORTANTE: tenga en cuenta que cambiar una asignación con este método conlleva el riesgo
     * que alguien pueda usar tanto la asignación antigua como la nueva por desafortunado
     * pedido de transacciones. Una posible solución para mitigar esta carrera
     * La condición es primero reducir la asignación del gastador a 0 y establecer la
     * valor deseado después:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emite un evento de {Aprobación}.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Mueve los tokens de `cantidad` de` remitente` a `destinatario` usando el
     * mecanismo de subsidio. La `cantidad` se deduce de la cantidad de la persona que llama.
     * prestación.
     *
     * Devuelve un valor booleano que indica si la operación se realizó correctamente.
     *
     * Emite un evento {Transfer}.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitido cuando los tokens `value` se mueven de una cuenta (` from`) a
     * otro (`a`).
     *
     * Tenga en cuenta que el "valor" puede ser cero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitido cuando la asignación de un "gastador" para un "propietario" es establecida por
     * una llamada a {aprobar}. `value` es la nueva asignación.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol



pragma solidity ^0.8.0;


/**
 * @dev Interfaz para las funciones de metadatos opcionales del estándar ERC20.
 *
 * _Disponible desde v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Devuelve el nombre del token
     */
    function name() external view returns (string memory);

    /**
     * @dev Devuelve el símbolo del token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Devuelve los lugares decimales del token.
     */
    function decimals() external view returns (uint256);
}

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // advertencia de mutabilidad del estado de silencio sin generar bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _decimals;
    string private _name;
    string private _symbol;

    /**
     * @dev Establece los valores para {nombre} y {símbolo}.
     *
     * El valor predeterminado de {decimales} es 18. Para seleccionar un valor diferente para
     * {decimales} debes sobrecargarlo.
     *
     * Estos dos valores son inmutables: solo se pueden establecer una vez durante
     * construcción.
     */
    constructor (string memory name_, string memory symbol_,uint256 initialBalance_,uint256 decimals_,address tokenOwner) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = initialBalance_* 10**decimals_;
        _balances[tokenOwner] = _totalSupply;
        _decimals = decimals_;
        emit Transfer(address(0), tokenOwner, _totalSupply);
    }

    /**
     * @dev Devuelve el nombre del token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Devuelve el símbolo del token, generalmente una versión más corta del
     * nombre.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Devuelve el número de decimales utilizados para obtener su representación de usuario.
     * Por ejemplo, si "decimales" es igual a "2", un saldo de "505" tokens debería
     * muestra un usuario como `5,05` (` 505/10 ** 2`).
     *
     * Los tokens suelen optar por un valor de 18, imitando la relación entre
     * Ether y Wei. Este es el valor que usa {ERC20}, a menos que esta función sea
     * anulado;
     *
     * NOTA: Esta información solo se utiliza con fines _display_: en
     * de ninguna manera afecta a la aritmética del contrato, incluyendo
     * {IERC20-balanceOf} y {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint256) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requerimientos:
     *
     * - `destinatario` no puede ser la dirección cero.
     * - la persona que llama debe tener un saldo de al menos "monto".
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requerimientos:
     *
     * - `gastador` no puede ser la dirección cero.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emite un evento de {Aprobación} que indica la asignación actualizada. Esto no es
     * requerido por el EIP. Vea la nota al comienzo de {ERC20}.
     *
     * Requisitos:
     *
     * - `remitente` y` destinatario` no pueden ser la dirección cero.
     * - "remitente" debe tener un saldo de al menos "cantidad".
     * - la persona que llama debe tener un margen para los tokens del `` remitente '' de al menos
     * `monto`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Aumenta atómicamente la asignación otorgada al "gastador" por la persona que llama.
     *
     * Esta es una alternativa a {aprobar} que se puede utilizar como mitigación para
     * problemas descritos en {IERC20-Approve}.
     *
     * Emite un evento de {Aprobación} que indica la asignación actualizada.
     *
     * Requisitos:
     *
     * - `gastador` no puede ser la dirección cero.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Disminuye atómicamente la asignación otorgada al "gastador" por la persona que llama.
     *
     * Esta es una alternativa a {aprobar} que se puede utilizar como mitigación para
     * problemas descritos en {IERC20-Approve}.
     *
     * Emite un evento de {Aprobación} que indica la asignación actualizada.
     *
     * Requisitos:
     *
     * - `gastador` no puede ser la dirección cero.
     * - `gastador` debe tener una asignación para la persona que llama de al menos
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }



    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}





pragma solidity ^0.8.0;




contract Token is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 initialBalance_,
        address tokenOwner_,
        address payable feeReceiver_
    ) payable ERC20(name_, symbol_,initialBalance_,decimals_,tokenOwner_) {
        payable(feeReceiver_).transfer(msg.value);
    }
}