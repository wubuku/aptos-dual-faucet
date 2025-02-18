# README


# Flex Swap - Aptos Move


## Programming

### Write DDDML model files

The DDDML model files can be found in the `dddml` directory at the repository root: [dddml](./dddml).

> **Tip**
>
> About DDDML, here is an introductory article: ["Introducing DDDML: The Key to Low-Code Development for Decentralized Applications"](https://github.com/wubuku/Dapp-LCDP-Demo/blob/main/IntroducingDDDML.md).


### Run dddappp project creation tool

#### Update dddappp Docker image

In repository root directory, run:

```shell
docker run \
-v .:/myapp \
wubuku/dddappp-aptos:master \
--dddmlDirectoryPath /myapp/dddml \
--boundedContextName Dddml.DualFaucet \
--aptosMoveProjectDirectoryPath /myapp/aptos-contracts \
--boundedContextAptosPackageName DualFaucet \
--boundedContextAptosNamedAddress dual_faucet \
--boundedContextJavaPackageName org.dddml.dualfaucet \
--javaProjectsDirectoryPath /myapp/aptos-java-service \
--javaProjectNamePrefix aptosdualfaucet \
--pomGroupId dddml.aptosdualfaucet
#--enableMultipleMoveProjects
```

> **Hint**
>
> Since the dddappp image is updated frequently, if you have already run it before, 
> you may need to clean up exited Docker containers first to make sure you are using the latest image.
>
> ```shell
> docker rm $(docker ps -aq --filter "ancestor=wubuku/dddappp-aptos:master")
> # remove the image
> docker image rm wubuku/dddappp-aptos:master
> # pull the image
> docker pull wubuku/dddappp-aptos:master
> ```



Compile Move contracts:

```shell
# cd aptos-contracts
aptos move compile --skip-fetch-latest-git-deps --named-addresses dual_faucet=default
```


## Publish Aptos Move contracts


```shell
aptos move publish --skip-fetch-latest-git-deps --named-addresses dual_faucet=default --assume-yes

# Initialize Fee Config Contract
aptos move run --function-id 'default::dual_faucet_init::initialize' --assume-yes
```

## Test Aptos Move contracts

Assuming that:
- Test FLEX (Fungible Asset) metadata: `0x82ca696c48f3985f8d6b1a2213333c6487d6261ffe0df1f3a1c72062b7503450`
- Test coin MoonCoin type: `0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::fake_usd::FakeUSD`

Run the following command to create the dual faucet:

```shell
aptos move run --function-id 'default::fungible_asset_coin_dual_faucet_service::create' \
  --type-args \
    '0x1::fungible_asset::Metadata' \
    '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::fake_usd::FakeUSD' \
  --args \
    'address:0x82ca696c48f3985f8d6b1a2213333c6487d6261ffe0df1f3a1c72062b7503450' \
    'u64:900000000000000000' \
    'u64:10000000000000' \
  --assume-yes
```

Assuming that the created dual faucet object address is `0xf941eee75b40dbb850411009cab34cec0704fd7110f3f1974b7bf8d8fcbb7c84`,

Run the following command to request coins from the dual faucet:

```shell
aptos move run --function-id 'default::fungible_asset_coin_dual_faucet_service::drop' \
  --type-args \
    '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::fake_usd::FakeUSD' \
  --args \
    'address:0xf941eee75b40dbb850411009cab34cec0704fd7110f3f1974b7bf8d8fcbb7c84' \
  --assume-yes
```

Run the following command to replenish the dual faucet:

```shell
aptos move run --function-id 'default::fungible_asset_coin_dual_faucet_service::replenish' \
  --type-args \
    '0x1::fungible_asset::Metadata' \
    '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::fake_usd::FakeUSD' \
  --args \
    'address:0xf941eee75b40dbb850411009cab34cec0704fd7110f3f1974b7bf8d8fcbb7c84' \
    'address:0x82ca696c48f3985f8d6b1a2213333c6487d6261ffe0df1f3a1c72062b7503450' \
    'u64:1000000000000000' \
    'u64:100000000000' \
  --assume-yes
```


## Tips

### Mint meme coin

```shell
aptos move run --function-id '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::launchpad_service::mint_and_drop_burn_ref' \
  --type-args \
    '0x1::fungible_asset::Metadata' \
  --args \
    'string:FLEXT' \
    'string:Test FLEX Coin' \
    'string:' \
    'string:' \
  --assume-yes
```
