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

    #[derive(Drop,starknet::Event)]
    struct Transfer{
        #[key]
        from:ContractAddress,
        to:ContractAddress,
        amount:u26,
    }

    #[derive(Drop,starknet::Event)]
    struct Approval{
        #[key]
        owner:ContractAddress,
        spender:ContractAddress,
        amount:u256,
    }

    #[derive(Drop,starknet::Event)]
    struct Burn{
        #[key]
        from:ContractAddress,
        amount:u256,
    }

    #[external(v0)]
    [abi(embed_v0)]
    impl ERC20impl of IERC20<ContractState>{
        fn name(self:@ContractState)->felt252{
            self.name.read()
        }

        fn symbol(self:@ContractState)->felt252{
            self.symbol.read()
        }

        fn decimal(self:@ContractState)->u8{
            self.decimal.read()
        }

        fn totalSupply(self:@ContractState)->u256{
            self.totalSupply.read()
        }

        fn balanceOf(self:@ContractState, owner:ContractAddress)->u256{
            self.balanceOf.read(owner)
        }

        fn allowance(self:@ContractState, owner:ContractAddress, spender:ContractAddress)->u256{
            self.allowances.read(owner,spender)
        }
    }
}