#!/bin/bash
# Smart contract FT để tạo 1 Token dùng cho Staking contract
# Source code: https://github.com/near-examples/FT
# More: https://nomicon.io/Standards/Tokens/FungibleToken/Core
export MAIN_ACCOUNT=hocnear.testnet
export NEAR_ENV=testnet
export CONTRACT_STAKING_ID=staking.$MAIN_ACCOUNT
export CONTRACT_FT_ID=ft.$MAIN_ACCOUNT
export ONE_YOCTO=0.000000000000000000000001
export ACCOUNT_TEST=test.hocnear.testnet
#export ACCOUNT_TUN=tun.hocnear.testnet
#export ACCOUNT_THAO=thao.hocnear.testnet
export GAS=300000000000000
export AMOUNT=100000000000000000000000000

echo "################### DELETE ACCOUNT ###################"
near delete $CONTRACT_FT_ID $MAIN_ACCOUNT
near delete $ACCOUNT_TEST $MAIN_ACCOUNT

echo "################### CREATE ACCOUNT ###################"
near create-account $CONTRACT_FT_ID --masterAccount $MAIN_ACCOUNT --initialBalance 10
near create-account $ACCOUNT_TEST --masterAccount $MAIN_ACCOUNT --initialBalance 10
#near create-account $ACCOUNT_TUN --masterAccount $MAIN_ACCOUNT --initialBalance 10
#near create-account $ACCOUNT_THAO --masterAccount $MAIN_ACCOUNT --initialBalance 10

# 1. Deploy:
echo "*********deploy token vbi**********"
near deploy --wasmFile token-test/create-token.wasm --accountId $CONTRACT_FT_ID

# 2. Init contract: Tạo contract default
echo "**********Khoi tao token ************"
near call $CONTRACT_FT_ID new_default_meta '{"owner_id": "'$MAIN_ACCOUNT'", "total_supply": "1000000000000000000000000000000000"}' --accountId $CONTRACT_FT_ID
# Có thể tạo contract theo ý muốn:
# near call $CONTRACT_FT_ID new '{"owner_id": "'$ID'", "total_supply": "1000000000000000", "metadata": { "spec": "ft-1.0.0", "name": "Example Token Name", "symbol": "EXLT", "decimals": 8 }}' --accountId $CONTRACT_FT_ID

# 3. Register account to ft contract
echo "**************Dang ky tai khoan voi ft contract"
near call $CONTRACT_FT_ID storage_deposit '{"account_id": "'$CONTRACT_STAKING_ID'"}' --accountId $MAIN_ACCOUNT --deposit 0.01
near call $CONTRACT_FT_ID storage_deposit '{"account_id": "'$ACCOUNT_TEST'"}' --accountId $MAIN_ACCOUNT --deposit 0.01
#near call $CONTRACT_FT_ID storage_deposit '{"account_id": "'$ACCOUNT_TUN'"}' --accountId $MAIN_ACCOUNT --deposit 0.01
#near call $CONTRACT_FT_ID storage_deposit '{"account_id": "'$ACCOUNT_THAO'"}' --accountId $MAIN_ACCOUNT --deposit 0.01

echo "*******transfer ft token tu owner_id den tai khoan test = claim token"
# 4. Transfer ft token from owner_id to account test(Claim token)
near call $CONTRACT_FT_ID ft_transfer '{"receiver_id": "'$ACCOUNT_TEST'", "amount": "'$AMOUNT'"}' --accountId $MAIN_ACCOUNT --deposit $ONE_YOCTO
#near call $CONTRACT_FT_ID ft_transfer '{"receiver_id": "'$ACCOUNT_TUN'", "amount": "'$AMOUNT'"}' --accountId $MAIN_ACCOUNT --deposit $ONE_YOCTO
#near call $CONTRACT_FT_ID ft_transfer '{"receiver_id": "'$ACCOUNT_THAO'", "amount": "'$AMOUNT'"}' --accountId $MAIN_ACCOUNT --deposit $ONE_YOCTO


# 5. Check FT metadata
echo "********check FT metadata **********"
near view $CONTRACT_FT_ID ft_metadata

# 6. View balance of account
echo "************view ft_balance_of"
near view $CONTRACT_FT_ID ft_balance_of '{"account_id": "'$CONTRACT_STAKING_ID'"}'
near view $CONTRACT_FT_ID ft_balance_of '{"account_id": "'$ACCOUNT_TEST'"}'
near view $CONTRACT_FT_ID ft_balance_of '{"account_id": "'$MAIN_ACCOUNT'"}'
#near view $CONTRACT_FT_ID ft_balance_of '{"account_id": "'$ACCOUNT_TUN'"}'
#near view $CONTRACT_FT_ID ft_balance_of '{"account_id": "'$ACCOUNT_THAO'"}'