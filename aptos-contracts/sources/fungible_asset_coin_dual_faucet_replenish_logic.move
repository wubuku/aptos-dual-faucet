module dual_faucet::fungible_asset_coin_dual_faucet_replenish_logic {
    use std::signer;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::fungible_asset::{Self, FungibleAsset};
    use aptos_framework::object;
    use aptos_std::type_info;

    use dual_faucet::fa_coin_dual_faucet_replenished;
    use dual_faucet::fungible_asset_coin_dual_faucet;

    friend dual_faucet::fungible_asset_coin_dual_faucet_aggregate;

    // Error codes
    const E_INVALID_AMOUNT: u64 = 1;

    public(friend) fun verify<Y>(
        account: &signer,
        x_amount: &FungibleAsset,
        y_amount: &Coin<Y>,
        id: address,
        fungible_asset_coin_dual_faucet: &fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>,
    ): fungible_asset_coin_dual_faucet::FACoinDualFaucetReplenished {
        let x_amount_value = fungible_asset::amount(x_amount);
        let y_amount_value = coin::value(y_amount);

        // Verify amounts are not zero
        assert!(x_amount_value > 0 && y_amount_value > 0, E_INVALID_AMOUNT);

        // Get token types for event
        let x_reserve = fungible_asset_coin_dual_faucet::x_reserve(fungible_asset_coin_dual_faucet);
        let x_token_metadata = fungible_asset::store_metadata(x_reserve);

        fungible_asset_coin_dual_faucet::new_fa_coin_dual_faucet_replenished(
            id,
            fungible_asset_coin_dual_faucet,
            signer::address_of(account),
            object::object_address(&x_token_metadata),
            type_info::type_name<Y>(),
            x_amount_value,
            y_amount_value,
        )
    }

    public(friend) fun mutate<Y>(
        account: &signer,
        fa_coin_dual_faucet_replenished: &fungible_asset_coin_dual_faucet::FACoinDualFaucetReplenished,
        x_amount: FungibleAsset,
        y_amount: Coin<Y>,
        id: address,
        fungible_asset_coin_dual_faucet: fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>,
    ): fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y> {
        // let x_amount_value = fa_coin_dual_faucet_replenished::x_amount(fa_coin_dual_faucet_replenished);
        // let y_amount_value = fa_coin_dual_faucet_replenished::y_amount(fa_coin_dual_faucet_replenished);

        // Deposit tokens to reserves
        let x_reserve = fungible_asset_coin_dual_faucet::x_reserve(&mut fungible_asset_coin_dual_faucet);
        fungible_asset::deposit(x_reserve, x_amount);

        let y_reserve = fungible_asset_coin_dual_faucet::borrow_mut_y_reserve(&mut fungible_asset_coin_dual_faucet);
        coin::merge(y_reserve, y_amount);

        fungible_asset_coin_dual_faucet
    }
}
