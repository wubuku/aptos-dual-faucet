module dual_faucet::fungible_asset_coin_dual_faucet_accessor {
    use aptos_framework::coin;
    use aptos_framework::object::Object;
    use aptos_framework::primary_fungible_store;

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
}