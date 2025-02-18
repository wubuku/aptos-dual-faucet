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
- Test coin YOLO (Fungible Asset) metadata: `0x9faa96e24f9c278669f1806aeb4856fb04d3186ed3bc494d2041d3cecaea05b`
- Test coin MoonCoin type: `0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::moon_coin::MoonCoin`

Run the following command to create the dual faucet:

```shell
aptos move run --function-id 'default::fungible_asset_coin_dual_faucet_service::create' \
  --type-args \
    '0x1::fungible_asset::Metadata' \
    '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::moon_coin::MoonCoin' \
  --args \
    'address:0x9faa96e24f9c278669f1806aeb4856fb04d3186ed3bc494d2041d3cecaea05b' \
    'u64:100000000000' \
    'u64:100000000000' \
  --assume-yes
```

Assuming that the created dual faucet object address is `0x96521f6a04f6cf6187101d537970e8304dc1abc8781062a9e45e94cf3740de09`,

Run the following command to request coins from the dual faucet:

```shell
aptos move run --function-id 'default::fungible_asset_coin_dual_faucet_service::drop' \
  --type-args \
    '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::moon_coin::MoonCoin' \
  --args \
    'address:0x96521f6a04f6cf6187101d537970e8304dc1abc8781062a9e45e94cf3740de09' \
  --assume-yes
```

Run the following command to replenish the dual faucet:

```shell
aptos move run --function-id 'default::fungible_asset_coin_dual_faucet_service::replenish' \
  --type-args \
    '0x1::fungible_asset::Metadata' \
    '0x76ffc077ebde06ee2d20d819429f52a211934d97fc9fb0a98b07d241453ad139::moon_coin::MoonCoin' \
  --args \
    'address:0x96521f6a04f6cf6187101d537970e8304dc1abc8781062a9e45e94cf3740de09' \
    'address:0x9faa96e24f9c278669f1806aeb4856fb04d3186ed3bc494d2041d3cecaea05b' \
    'u64:100000000000' \
    'u64:100000000000' \
  --assume-yes
```


