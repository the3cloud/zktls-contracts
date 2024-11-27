# The3CloudCoin
[Git Source](https://github.com/the3cloud/zktls-contracts/blob/e6bdae6114eff2aa42754cf1e1bcce6d5dd03dd2/src/PaymentToken.sol)

**Inherits:**
ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit


## Functions
### constructor


```solidity
constructor(address initialOwner) ERC20("The3CloudCoin", "TCC") Ownable(initialOwner) ERC20Permit("The3CloudCoin");
```

### pause


```solidity
function pause() public onlyOwner;
```

### unpause


```solidity
function unpause() public onlyOwner;
```

### mint


```solidity
function mint(address to, uint256 amount) public onlyOwner;
```

### _update


```solidity
function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable);
```

