use use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self:@ContractState) -> felt252;
    fn symbol(self:@ContractState)-> felt252;
    fn decimal(self:@ContractState)->u8;
    fn balanceOf(self:@ContractState, owner:ContractAddress)->u256;
    fn totalSupply(self:@ContractState)->u256;

    fn transfer(ref self:TContractState, to:ContractAddress, amount:u256);
    fn transferFrom(ref self:TContractState,from:ContractAddress, to:ContractAddress,amount:u256);
    fn approve(ref self:TContractState, spender:ContractAddress, amount:u256);
    fn allowance(ref self:TContractState, owner:ContractAddress, spender:ContractAddress, amount:u256);

    fn mint(ref self:TContractState, to:ContractAddress,value:u256);
    fn burn(ref self:TContractState, to:ContractAddress, value:u256);
}