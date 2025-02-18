module dual_faucet::fungible_asset_coin_dual_faucet_drop_logic {
    use std::signer;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::fungible_asset::{Self, FungibleAsset};
    use aptos_framework::object;
    use aptos_std::math64;
    use aptos_std::type_info;

    use dual_faucet::drop_record;
    use dual_faucet::fa_coin_dual_faucet_created::x_amount;
    use dual_faucet::fa_coin_dual_faucet_dropped;
    use dual_faucet::fungible_asset_coin_dual_faucet;
    use dual_faucet::genesis_account;

    friend dual_faucet::fungible_asset_coin_dual_faucet_aggregate;

    // Error codes
    const E_INSUFFICIENT_RESERVE: u64 = 1;
    const E_TOO_FREQUENT: u64 = 2;

    // Set appropriate amount for X token (in standard units)
    const DROP_AMOUNT_X: u64 = 100;

    // Set appropriate amount for Y token (in standard units)
    const DROP_AMOUNT_Y: u64 = 100;

    // Set the minimum time interval between drops in seconds
    const MIN_DROP_INTERVAL: u64 = 60 * 60 * 24; // 24 hours

    public(friend) fun verify<Y>(
        account: &signer,
        id: address,
        fungible_asset_coin_dual_faucet: &fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>,
    ): fungible_asset_coin_dual_faucet::FACoinDualFaucetDropped {
        let account_address = signer::address_of(account);
        if (fungible_asset_coin_dual_faucet::drop_records_contains(fungible_asset_coin_dual_faucet, account_address)) {
            let drop_record = fungible_asset_coin_dual_faucet::borrow_drop_record<Y>(
                fungible_asset_coin_dual_faucet,
                account_address
            );
            let last_drop_time = drop_record::last_drop_time(drop_record);
            let current_time = aptos_framework::timestamp::now_seconds();
            assert!(current_time - last_drop_time > MIN_DROP_INTERVAL, E_TOO_FREQUENT);
        };

        // Get current reserves
        let x_reserve = fungible_asset_coin_dual_faucet::x_reserve(fungible_asset_coin_dual_faucet);
        let y_reserve = fungible_asset_coin_dual_faucet::borrow_y_reserve(fungible_asset_coin_dual_faucet);

        // Get token types for event
        let x_token_metadata = fungible_asset::store_metadata(x_reserve);
        let x_amount = DROP_AMOUNT_X * math64::pow(10, (fungible_asset::decimals(x_token_metadata) as u64));
        let y_amount = DROP_AMOUNT_Y * math64::pow(10, (coin::decimals<Y>() as u64));

        // Verify sufficient reserves
        assert!(
            fungible_asset::balance(x_reserve) >= x_amount && coin::value(y_reserve) >= y_amount,
            E_INSUFFICIENT_RESERVE
        );

        fungible_asset_coin_dual_faucet::new_fa_coin_dual_faucet_dropped(
            id,
            fungible_asset_coin_dual_faucet,
            signer::address_of(account),
            x_amount,
            y_amount,
            object::object_address(&x_token_metadata),
            type_info::type_name<Y>(),
        )
    }

    public(friend) fun mutate<Y>(
        account: &signer,
        fa_coin_dual_faucet_dropped: &fungible_asset_coin_dual_faucet::FACoinDualFaucetDropped,
        id: address,
        fungible_asset_coin_dual_faucet: fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>,
    ): (fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>, FungibleAsset, Coin<Y>) {
        let account_address = signer::address_of(account);
        let x_amount = fa_coin_dual_faucet_dropped::x_amount(fa_coin_dual_faucet_dropped);
        let y_amount = fa_coin_dual_faucet_dropped::y_amount(fa_coin_dual_faucet_dropped);

        // Extract tokens from reserves
        let x_reserve = fungible_asset_coin_dual_faucet::x_reserve(&mut fungible_asset_coin_dual_faucet);
        let x_out = fungible_asset::withdraw(
            &genesis_account::resource_account_signer(),
            x_reserve,
            x_amount
        );

        let y_reserve = fungible_asset_coin_dual_faucet::borrow_mut_y_reserve(&mut fungible_asset_coin_dual_faucet);
        let y_out = coin::extract(y_reserve, y_amount);

        if (fungible_asset_coin_dual_faucet::drop_records_contains(&fungible_asset_coin_dual_faucet, account_address)) {
            let drop_record = fungible_asset_coin_dual_faucet::borrow_mut_drop_record<Y>(
                &mut fungible_asset_coin_dual_faucet,
                account_address
            );
            let current_time = aptos_framework::timestamp::now_seconds();
            drop_record::set_last_drop_time(drop_record, current_time);
        } else {
            let current_time = aptos_framework::timestamp::now_seconds();
            let drop_record = drop_record::new_drop_record(account_address, current_time);
            fungible_asset_coin_dual_faucet::add_drop_record(id, &mut fungible_asset_coin_dual_faucet, drop_record);
        };

        (fungible_asset_coin_dual_faucet, x_out, y_out)
    }
}
