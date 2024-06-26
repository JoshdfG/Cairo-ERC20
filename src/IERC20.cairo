use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimal(self: @TContractState) -> u8;
    fn balanceOf(self: @TContractState, owner: ContractAddress) -> u256;
    fn totalSupply(self: @TContractState) -> u256;

    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256);
    fn transferFrom(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn allowance(
        ref self: TContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
    );

    fn mint(ref self: TContractState, to: ContractAddress, value: u256);
    fn burn(ref self: TContractState, to: ContractAddress, value: u256);
}
