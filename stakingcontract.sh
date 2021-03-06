#!/bin/bash
export MAIN_ACCOUNT=hocnear.testnet
export NEAR_ENV=testnet
export CONTRACT_STAKING_ID=staking.$MAIN_ACCOUNT
export CONTRACT_FT_ID=ft.$MAIN_ACCOUNT
export ONE_YOCTO=0.000000000000000000000001
export ACCOUNT_TEST=test.hocnear.testnet
#export ACCOUNT_TUN=tun.hocnear.testnet
export GAS=300000000000000
export AMOUNT=100000000000000000000000000

# 1. Build smart contract and deploy
./build.sh

echo "################### DELETE ACCOUNT ###################"
near delete $CONTRACT_STAKING_ID $MAIN_ACCOUNT
near delete $ACCOUNT_TEST $MAIN_ACCOUNT

echo "################### CREATE ACCOUNT ###################"
near create-account $CONTRACT_STAKING_ID --masterAccount $MAIN_ACCOUNT --initialBalance 10
near create-account $ACCOUNT_TEST --masterAccount $MAIN_ACCOUNT --initialBalance 10

# 2. Deploy:
echo "****************near deploy --wasmFile res/staking-contract.wasm****************"
near deploy --wasmFile out/stakingcontract.wasm --accountId $CONTRACT_STAKING_ID

# 3. Init contract
echo "**********near call $CONTRACT_STAKING_ID new_default_config"
near call $CONTRACT_STAKING_ID new_default_config '{"owner_id": "'$MAIN_ACCOUNT'", "ft_contract_id": "'$CONTRACT_FT_ID'"}' --accountId $MAIN_ACCOUNT

# 4. Add account to storage staking
echo "*****near call STAKING.TESTNET.HOCNEAR.TESTNET storage_deposit***********"
near call $CONTRACT_STAKING_ID storage_deposit '{"account_id": "'$ACCOUNT_TEST'"}' --accountId $ACCOUNT_TEST --deposit 0.01
#near call $CONTRACT_STAKING_ID storage_deposit '{"account_id": "'$ACCOUNT_TUN'"}' --accountId $ACCOUNT_TUN --deposit 0.01
echo "********SATKING.HOCNEAR.TESTNET"
near call $CONTRACT_STAKING_ID storage_deposit '{"account_id": "'$MAIN_ACCOUNT'"}' --accountId $MAIN_ACCOUNT --deposit 0.01

# 5. Staking ft token to pool
echo "******** ft.hocnear.testnet**********"
near call $CONTRACT_FT_ID ft_transfer_call '{"receiver_id": "'$CONTRACT_STAKING_ID'", "amount": "'$AMOUNT'", "msg": ""}' --accountId $MAIN_ACCOUNT --deposit $ONE_YOCTO --gas $GAS
echo "******** ft.test.hocnear.testnet**********"
near call $CONTRACT_FT_ID ft_transfer_call '{"receiver_id": "'$CONTRACT_STAKING_ID'", "amount": "10000000000000000000000000", "msg": ""}' --accountId $ACCOUNT_TEST --deposit $ONE_YOCTO --gas $GAS

#near call $CONTRACT_FT_ID ft_transfer_call '{"receiver_id": "'$CONTRACT_STAKING_ID'", "amount": "10000000000000000000000000", "msg": ""}' --accountId $ACCOUNT_TUN --deposit $ONE_YOCTO --gas $GAS
echo "******** ft.test.hocnear.testnet**********"
near call $CONTRACT_FT_ID ft_transfer_call '{"receiver_id": "'$CONTRACT_STAKING_ID'", "amount": "50000000000000000000000000", "msg": ""}' --accountId $ACCOUNT_TEST --deposit $ONE_YOCTO --gas $GAS

#near call $CONTRACT_FT_ID ft_transfer_call '{"receiver_id": "'$CONTRACT_STAKING_ID'", "amount": "50000000000000000000000000", "msg": ""}' --accountId $ACCOUNT_TUN --deposit $ONE_YOCTO --gas $GAS

# 6. Harvest all reward
echo "********harvest test.hocnear.testnet"
near call $CONTRACT_STAKING_ID harvest --accountId $ACCOUNT_TEST --deposit $ONE_YOCTO --gas $GAS

#near call $CONTRACT_STAKING_ID harvest --accountId $ACCOUNT_TUN --deposit $ONE_YOCTO --gas $GAS

# 7. Unstacked
echo "*******unstake test.hocnear.testnet*************"
near call $CONTRACT_STAKING_ID unstake '{"amount": "10000000000000000000000000"}' --accountId $ACCOUNT_TEST --deposit $ONE_YOCTO

#near call $CONTRACT_STAKING_ID unstake '{"amount": "10000000000000000000000000"}' --accountId $ACCOUNT_TUN --deposit $ONE_YOCTO

# 8. Withdraw
echo "******** withdraw *************"
near call $CONTRACT_STAKING_ID withdraw '' --accountId $ACCOUNT_TEST --deposit $ONE_YOCTO --gas $GAS
#near call $CONTRACT_STAKING_ID withdraw '' --accountId $ACCOUNT_TUN --deposit $ONE_YOCTO --gas $GAS

# 9. Get pool info
echo "********xem thong tin pool"
near view $CONTRACT_STAKING_ID get_pool_info

# 10. Get account info
echo "***********xem thong tin account info *************"
near view $CONTRACT_STAKING_ID get_account_info '{"account_id": "'$ACCOUNT_TEST'"}'
near view $CONTRACT_STAKING_ID get_account_info '{"account_id": "'$MAIN_ACCOUNT'"}'
near view $CONTRACT_STAKING_ID get_account_info '{"account_id": "'$ACCOUNT_TUN'"}'