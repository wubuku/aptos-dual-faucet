// <autogenerated>
//   This file was generated by dddappp code generator.
//   Any changes made to this file manually will be lost next time the file is regenerated.
// </autogenerated>

module dual_faucet::dual_faucet_init {
    use dual_faucet::fungible_asset_coin_dual_faucet;
    use dual_faucet::genesis_account;

    public entry fun initialize(account: &signer) {
        genesis_account::initialize(account);
        fungible_asset_coin_dual_faucet::initialize(account);
    }

}
