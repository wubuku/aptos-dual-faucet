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




