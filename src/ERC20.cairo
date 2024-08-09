use starknet::ContractAddress;
use starknet::{contract_address_const, get_caller_address};

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn mint(ref self: TContractState, to: ContractAddress, value: u256);
    fn burn(ref self: TContractState, from: ContractAddress, value: u256);
}

#[starknet::contract]
mod ERC20 {
    use core::starknet::event::EventEmitter;
    use super::IERC20;
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        total_supply: u256,
        allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>,
        balances: LegacyMap::<ContractAddress, u256>,
        decimals: u8,
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        _name: felt252,
        _symbol: felt252,
        _decimals: u8,
        _owner: ContractAddress
    ) {
        self.name.write(_name);
        self.symbol.write(_symbol);
        self.decimals.write(_decimals);
        self.owner.write(_owner);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        Mint: Mint,
        Burn: Burn,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Mint {
        #[key]
        to: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Burn {
        #[key]
        from: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        spender: ContractAddress,
        amount: u256,
    }

    #[abi(embed_v0)]
    impl ERC20Impl of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let msg_sender = get_caller_address();
            self.transfer_(msg_sender, recipient, amount);
            true
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let msg_sender = get_caller_address();
            let allowance = self.allowance(sender, msg_sender);
            assert(allowance >= amount, 'insufficient allowance');
            self.transfer_(sender, recipient, amount);
            self.allowances.write((sender, msg_sender), allowance - amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let msg_sender = get_caller_address();
            self.allowances.write((msg_sender, spender), amount);
            self.emit(Approval { owner: msg_sender, spender, amount });
            true
        }

        fn mint(ref self: ContractState, to: ContractAddress, value: u256) {
            let total_supply = self.total_supply.read();
            self.total_supply.write(total_supply + value);
            let balance = self.balances.read(to);
            self.balances.write(to, balance + value);
            self.emit(Mint { to, value });
        }

        fn burn(ref self: ContractState, from: ContractAddress, value: u256) {
            let balance = self.balances.read(from);
            assert(balance >= value, 'Insufficient balance');
            self.balances.write(from, balance - value);
            let total_supply = self.total_supply.read();
            self.total_supply.write(total_supply - value);
            self.emit(Burn { from, value });
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn transfer_(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            assert(caller == sender, 'Not owner');
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.emit(Transfer { sender, recipient, amount });
            true
        }
    }
}
