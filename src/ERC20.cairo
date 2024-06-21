#[starknet::contract];
pub mod ERC20{
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
    impl ERC20impl of super::IERC20::IERC20<ContractState>{
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

        fn approve(ref self:@ContractState, spender:ContractAddress,amount:u256){
            let msg_sender =get_caller_address();
            self.allowance.write((msg_sender,spender),amount);
            self.emit(Approval{owner:msg_sender,spender:spender,amount:amount});
        }

        fn transferFrom(ref self:ContractState, owner:ContractAddress,to:ContractAddress,amount:u256){
            let msg_sender = get_caller_address();
            assert(self.allowance.read((owner,msg_sender)) >= amount, 'You do not have enough allowance');
            self._transfer(owner,to,amount);
            self.allowances.write((owner,msg_sender),allowance - amount);
        }

        fn mint(ref self:ContractState, to:ContractAddress,amount:u256){
            let total_supply = self.totalSupply.read();
            self.totalSupply.write(total_supply + amount);
            let balance = self.balances.read(to);
            self.balances.write(to,balance + amount)
            self.emit(Mint{to:to,amount:amount});
        }

        fn burn(ref self:ContractState, from:ContractAddress, to:ContractAddress, amount:u256){
            let balance = self.balances.read();
            assert(balance >= amount, 'Insufficient balance');
            self.balances.write(from,balance - amount);
            let total_supply = self.totalSupply.read();
            self.totalSupply.write(total_supply - amount);
            self.emit(Burn{from:from,amount:amount})
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _transfer(ref self:ContractState,sender:ContractAddress, recipient:ContractAddress,amount:u256){
            let address_zero:ContractAddress = contract_address_const::<0>();
            assert(recipient !=address_zero,"Address zero not allowed");
            assert(amount > 0 && self.balances.read(sender) >= amount,"Insufficient balance");
            
            self.balances.write(sender,self.balances.read(sender) - amount);
            self.balances.write(recipient,self.balances.read(recipient) + amount);
            self.emit(Transfer{from:sender,to:recipient,amount:amount});
        }
    }
}