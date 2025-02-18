module dual_faucet::fungible_asset_coin_dual_faucet_service {
    use std::signer;
    use aptos_framework::aptos_account;
    use aptos_framework::coin;
    use aptos_framework::object::Object;
    use aptos_framework::primary_fungible_store;

    use dual_faucet::fungible_asset_coin_dual_faucet::FungibleAssetCoinDualFaucet;
    use dual_faucet::fungible_asset_coin_dual_faucet_aggregate;

    public entry fun create<X: key, Y>(
        account: &signer,
        x_metadata: Object<X>,
        x_amount: u64,
        y_amount: u64,
    ) {
        let x_coin = primary_fungible_store::withdraw<X>(account, x_metadata, x_amount);
        let y_coin = coin::withdraw<Y>(account, y_amount);
        fungible_asset_coin_dual_faucet_aggregate::create<Y>(
            account,
            x_coin,
            y_coin,
        );
    }

    public entry fun drop<Y>(
        account: &signer,
        fungible_asset_coin_dual_faucet_obj: Object<FungibleAssetCoinDualFaucet<Y>>,
    ) {
        let (x_coin, y_coin) = fungible_asset_coin_dual_faucet_aggregate::drop<Y>(
            account,
            fungible_asset_coin_dual_faucet_obj,
        );
        primary_fungible_store::deposit(signer::address_of(account), x_coin);
        aptos_account::deposit_coins<Y>(signer::address_of(account), y_coin);
    }

    public entry fun replenish<X: key, Y>(
        account: &signer,
        fungible_asset_coin_dual_faucet_obj: Object<FungibleAssetCoinDualFaucet<Y>>,
        x_metadata: Object<X>,
        x_amount: u64,
        y_amount: u64,
    ) {
        let x_coin = primary_fungible_store::withdraw<X>(account, x_metadata, x_amount);
        let y_coin = coin::withdraw<Y>(account, y_amount);
        fungible_asset_coin_dual_faucet_aggregate::replenish<Y>(
            account,
            fungible_asset_coin_dual_faucet_obj,
            x_coin,
            y_coin,
        );
    }
}
