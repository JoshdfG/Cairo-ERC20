CONTRACT_HASH=0x03a3819d94f1e1d3ec58dbcab556a567a8000312a677a6b84039e205e1ce56ab
RPC_URL=https://free-rpc.nethermind.io/sepolia-juno
ACCOUNT_FILE=account0_account.json
KEYSTORE_FILE=account0_keystore.json



deploy:
	@echo "Deploying the contract..."
	starkli deploy $(CONTRACT_HASH) \
		--rpc $(RPC_URL) \
		--account $(ACCOUNT_FILE) \
		--keystore $(KEYSTORE_FILE) \
	0x736567 0x7367 18 0x0785940c89f936c4b2aab5078f18050e1d172227e13441697f1e7dd5ef11266c \
	
