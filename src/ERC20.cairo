#[starknet::contract];

mod ERC20{
    use contract::module::{IERC20Dispatcher, IERC20, IERC20LibraryDispatcher};
    use super::{IERC20Dispatcher, IERC20, IERC20LibraryDispatcher};
    use starknet::ContractAddress;
    use core::starknet::event::EventEmitter;

    
    #[storage]
    struct Storage{
        name:felt252,
        symbol:felt252,
        decimals:u8,
        totalSupply:u256,
        balances: LegacyMap::<ContractAddress,u256>,
        allowances: LegacyMap::<(ContractAddress,ContractAddress),u256>,
    }

    #[constructor]
    fn constructor(ref self:ContractState, name:felt252, symbol:felt252,decimals:u8){
        self.name.write(name),
        self.symbol.write(symbol),
        self.decimals.write(decimals),
    }

    #[event]
    #[derive(Drop,starknet::Event)]
    enum Event{
        Transfer:Transfer,
        Approval:Approval,
        Burn:Burn,
        Mint:Mint,
    }

    #[derive(Drop,starknet::Event)]
    struct Mint{
        #[key]
        to: ContractAddress,
        amount: u256,
    }

    struct Transfer{
        #[key]
        from:ContractAddress,
        to:ContractAddress,
        amount:u26,
    }

    struct Approval{
        #[key]
        owner:ContractAddress,
        spender:ContractAddress,
        amount:u256,
    }

    struct Burn{
        #[key]
        from:ContractAddress,
        amount:u256,
    }
}