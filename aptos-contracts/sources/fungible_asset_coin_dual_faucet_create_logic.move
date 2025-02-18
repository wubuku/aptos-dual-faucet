module dual_faucet::fungible_asset_coin_dual_faucet_create_logic {
    use std::signer;

    use aptos_std::type_info;
    use aptos_framework::object;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::fungible_asset::{Self, FungibleAsset};

    use dual_faucet::fa_coin_dual_faucet_created;
    use dual_faucet::fungible_asset_coin_dual_faucet;
    use dual_faucet::genesis_account;

    friend dual_faucet::fungible_asset_coin_dual_faucet_aggregate;

    const E_INVALID_AMOUNT: u64 = 1;

    public(friend) fun verify<Y>(
        account: &signer,
        x_amount: &FungibleAsset,
        y_amount: &Coin<Y>,
        id: address,
    ): fungible_asset_coin_dual_faucet::FACoinDualFaucetCreated {
        let x_token_metadata = fungible_asset::metadata_from_asset(x_amount);
        let x_amount_value = fungible_asset::amount(x_amount);
        let y_amount_value = coin::value(y_amount);

        // Verify amounts are not zero
        assert!(x_amount_value > 0 && y_amount_value > 0, E_INVALID_AMOUNT);

        fungible_asset_coin_dual_faucet::new_fa_coin_dual_faucet_created<Y>(
            signer::address_of(account),
            object::object_address(&x_token_metadata),
            type_info::type_name<Y>(),
            x_amount_value,
            y_amount_value,
        )
    }

    public(friend) fun mutate<Y>(
        _account: &signer,
        fa_coin_dual_faucet_created: &fungible_asset_coin_dual_faucet::FACoinDualFaucetCreated,
        x_amount: FungibleAsset,
        y_amount: Coin<Y>,
        id: address,
        object_signer: &signer,
    ): (fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet<Y>, address) {
        let provider = fa_coin_dual_faucet_created::provider(fa_coin_dual_faucet_created);
        let x_token_type = fa_coin_dual_faucet_created::x_token_type(fa_coin_dual_faucet_created);
        let y_token_type = fa_coin_dual_faucet_created::y_token_type(fa_coin_dual_faucet_created);
        let x_amount_value = fa_coin_dual_faucet_created::x_amount(fa_coin_dual_faucet_created);
        let y_amount_value = fa_coin_dual_faucet_created::y_amount(fa_coin_dual_faucet_created);

        // Create store for X token

        let genesis_account_signer = genesis_account::resource_account_signer();
        let x_store_constructor_ref = object::create_object(
            signer::address_of(&genesis_account_signer)
        );
        let x_store_transfer_ref = object::generate_transfer_ref(&x_store_constructor_ref);
        object::disable_ungated_transfer(&x_store_transfer_ref);
        let x_token_metadata = fungible_asset::metadata_from_asset(&x_amount);
        let x_store = fungible_asset::create_store(&x_store_constructor_ref, x_token_metadata);


        // Create the dual faucet
        let dual_faucet = fungible_asset_coin_dual_faucet::new_fungible_asset_coin_dual_faucet<Y>(
            x_store
        );

        // Deposit initial amounts
        let x_reserve = fungible_asset_coin_dual_faucet::x_reserve(&mut dual_faucet);
        fungible_asset::deposit(x_reserve, x_amount);
        let y_reserve = fungible_asset_coin_dual_faucet::borrow_mut_y_reserve(&mut dual_faucet);
        coin::merge(y_reserve, y_amount);

        (dual_faucet, id)
    }
}
