module dual_faucet::fungible_asset_coin_dual_faucet_drop_logic {
    use std::signer;

    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::fungible_asset::{Self, FungibleAsset};
    use aptos_framework::object;
    use aptos_std::type_info;

    use dual_faucet::genesis_account;
    use dual_faucet::fa_coin_dual_faucet_dropped;
    use dual_faucet::fungible_asset_coin_dual_faucet;

    friend dual_faucet::fungible_asset_coin_dual_faucet_aggregate;

    // Error codes
    const E_INSUFFICIENT_RESERVE: u64 = 1;

    // Constants for drop amounts
    const DROP_AMOUNT_X: u64 = 1000;
    // Set appropriate amount for X token
    const DROP_AMOUNT_Y: u64 = 1000; // Set appropriate amount for Y token

    public(friend) fun verify<Y>(
        account: &signer,
        id: address,
        fungible_asset_coin_dual_faucet: &fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>,
    ): fungible_asset_coin_dual_faucet::FACoinDualFaucetDropped {
        // Get current reserves
        let x_reserve = fungible_asset_coin_dual_faucet::x_reserve(fungible_asset_coin_dual_faucet);
        let y_reserve = fungible_asset_coin_dual_faucet::borrow_y_reserve(fungible_asset_coin_dual_faucet);

        // Verify sufficient reserves
        assert!(
            fungible_asset::balance(x_reserve) >= DROP_AMOUNT_X &&
                coin::value(y_reserve) >= DROP_AMOUNT_Y,
            E_INSUFFICIENT_RESERVE
        );

        // Get token types for event
        let x_token_metadata = fungible_asset::store_metadata(x_reserve);

        fungible_asset_coin_dual_faucet::new_fa_coin_dual_faucet_dropped(
            id,
            fungible_asset_coin_dual_faucet,
            signer::address_of(account),
            DROP_AMOUNT_X,
            DROP_AMOUNT_Y,
            object::object_address(&x_token_metadata),
            type_info::type_name<Y>(),
        )
    }

    public(friend) fun mutate<Y>(
        _account: &signer,
        fa_coin_dual_faucet_dropped: &fungible_asset_coin_dual_faucet::FACoinDualFaucetDropped,
        id: address,
        fungible_asset_coin_dual_faucet: fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>,
    ): (fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>, FungibleAsset, Coin<Y>) {
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

        (fungible_asset_coin_dual_faucet, x_out, y_out)
    }
}
