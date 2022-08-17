console.log("main.js 실행...");

let globalObj = {
    genPrice: 0.10498,
    address: "",
    eth: 0,
    gen: 0,
    stgen: 0,
    stakingBalance: 0,
    epochTotalReward: 0,
    totalStakedStGen: 0,
    myRewards: 0
}

const GEN_STAKING_CONTRACT = "0x40289128883b225700Ffca81Eb64DbA1B23EBf3a";
const GEN_STAKING_ABI = [{"inputs":[{"internalType":"contract IERC20","name":"_stGenToken","type":"address"},{"internalType":"contract IERC20","name":"_genToken","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"ConvertGenToStGen","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"oldManager","type":"address"},{"indexed":true,"internalType":"address","name":"newManager","type":"address"}],"name":"ManagerSet","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Stake","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Unstake","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"YieldWithdraw","type":"event"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"calculateYieldTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"calculateYieldTotal","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newManager","type":"address"}],"name":"changeManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"claimYield","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"convertGenToStGen","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"epochTotalReward","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"genToken","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getEpochTotalReward","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getManager","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getMyRewards","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getThisAddressGenTokenBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getThisAddressStGenTokenBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTotalStaked","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"isStaking","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"manager","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"rewardBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"setEpochTotalReward","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"stGenToken","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"stake","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"stakingBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"startTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"unstake","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"version","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"},{"stateMutability":"payable","type":"receive"}];

const CONVERT_GEN_CONTRACT = "0xDf93ee0Ef0E85d469E4312580224401a812ec519";
const CONVERT_GEN_ABI = [{"inputs":[{"internalType":"address","name":"newManager","type":"address"}],"name":"changeManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract IERC20","name":"_stGenToken","type":"address"},{"internalType":"contract IERC20","name":"_genToken","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Convert","type":"event"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"convertGen","outputs":[],"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"oldManager","type":"address"},{"indexed":true,"internalType":"address","name":"newManager","type":"address"}],"name":"ManagerSet","type":"event"},{"inputs":[],"name":"withdrawETH","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_token","type":"address"},{"internalType":"address","name":"receiver","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"withdrawToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"},{"inputs":[],"name":"genToken","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getManager","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"manager","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"stGenToken","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"version","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"}];

const GEN_TOKEN_CONTRACT = "0x4D5fB13d366d19b98bc3292cF8cC3dC4DB7B87A9";
const STGEN_TOKEN_CONTRACT = "0x7E8D501c0c76Bf8E3E74bcD3f7c3a9d3cA86547e";
const ERC20_ABI = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function","signature":"0x06fdde03"},{"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x095ea7b3"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function","signature":"0x18160ddd"},{"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x23b872dd"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function","signature":"0x313ce567"},{"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"addedValue","type":"uint256"}],"name":"increaseAllowance","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x39509351","gas":250000},{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x40c10f19"},{"constant":false,"inputs":[{"name":"value","type":"uint256"}],"name":"burn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x42966c68"},{"constant":true,"inputs":[{"name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function","signature":"0x70a08231"},{"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"value","type":"uint256"}],"name":"burnFrom","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x79cc6790"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function","signature":"0x95d89b41"},{"constant":false,"inputs":[{"name":"account","type":"address"}],"name":"addMinter","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x983b2d56"},{"constant":false,"inputs":[],"name":"renounceMinter","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0x98650275"},{"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"subtractedValue","type":"uint256"}],"name":"decreaseAllowance","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0xa457c2d7"},{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function","signature":"0xa9059cbb"},{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"isMinter","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function","signature":"0xaa271e1a"},{"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function","signature":"0xdd62ed3e"},{"inputs":[{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_decimals","type":"uint8"}],"payable":false,"stateMutability":"nonpayable","type":"constructor","signature":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"account","type":"address"}],"name":"MinterAdded","type":"event","signature":"0x6ae172837ea30b801fbfcdd4108aa1d5bf8ff775444fd70256b44e6bf3dfc3f6"},{"anonymous":false,"inputs":[{"indexed":true,"name":"account","type":"address"}],"name":"MinterRemoved","type":"event","signature":"0xe94479a9f7e1952cc78f2d6baab678adc1b772d936c6583def489e524cb66692"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event","signature":"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event","signature":"0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"}];

const provider = new ethers.providers.Web3Provider(window.ethereum);
let genStakingContract;
let convertGenContract;

let genTokenContract;
let stGenTokenContract;

// Util
function sleep(ms) {
    return new Promise((r) => setTimeout(r, ms));
}

async function init() {
    // https://api.probit.com/api/exchange/v1/ticker?market_ids=GEN-USDT
    const options = {method: 'GET'};

    await fetch('https://api.probit.com/api/exchange/v1/ticker?market_ids=GEN-USDT', options)
    .then(response => response.json())
    .then(response => {
        console.log(response);
        globalObj.genPrice = response.data[0].last * 1;
    })
    .catch(err => console.error(err));

    console.log("globalObj.genPrice: ", globalObj.genPrice);
    $(".genPrice").text(globalObj.genPrice);

    // const provider = new ethers.providers.Web3Provider(window.ethereum);
    // Prompt user for account connections
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    globalObj.address = await signer.getAddress();
    console.log("Account:", globalObj.address);

    // Staking 컨트랙트
    genStakingContract = new ethers.Contract(GEN_STAKING_CONTRACT, GEN_STAKING_ABI, signer);
    // Convert 컨트랙트
    convertGenContract = new ethers.Contract(CONVERT_GEN_CONTRACT, CONVERT_GEN_ABI, signer);
    // GEN 컨트랙트
    genTokenContract = new ethers.Contract(GEN_TOKEN_CONTRACT, ERC20_ABI, signer);
    // stGEN 컨트랙트
    stGenTokenContract = new ethers.Contract(STGEN_TOKEN_CONTRACT, ERC20_ABI, signer);

    $(".myAddress").text(globalObj.address);
    // 메타마스크 버튼 숨기기
    $(".metamaskBtn").hide();
    $(".connected").show();

    // console.log("signer: ", signer);
    
    




    refresh();
    // 5초마다 갱신
    setInterval(() => refresh(), 3000);

    

    // If a user enters a string in an input field, you may need
    // to convert it from ether (as a string) to wei (as a BigNumber)
    // ethers.utils.parseEther("1.0")
    // { BigNumber: "1000000000000000000" }


    // 
    // 0x6234651DaCcdcF2de68e9d2eD7896B27c8AAE4C5

}

async function refresh() {
    console.log("refresh!");

    balance = await provider.getBalance(globalObj.address);
    // { BigNumber: "182826475815887608" }
    // Often you need to format the output to something more user-friendly,
    // such as in ether (instead of wei)
    globalObj.eth = ethers.utils.formatEther(balance);
    console.log("balance: ", globalObj.eth);
    $(".ethBalance").text(globalObj.eth);

    let epochTotalReward = await genStakingContract.getEpochTotalReward();
    globalObj.epochTotalReward = ethers.utils.formatEther(epochTotalReward);
    console.log("epochTotalReward: ", globalObj.epochTotalReward);
    $(".currentEpochReward").text(globalObj.epochTotalReward);

    let totalStakedStGen = await genStakingContract.getTotalStaked();
    globalObj.totalStakedStGen = ethers.utils.formatEther(totalStakedStGen);
    console.log("totalStakedStGen: ", globalObj.totalStakedStGen);
    $(".totalStakedStGen").text(globalObj.totalStakedStGen);

    // 유저 GEN
    // myGenBalance
    const genBalance = await genTokenContract.balanceOf(globalObj.address);
    globalObj.gen = ethers.utils.formatEther(genBalance);
    $(".myGenBalance").text(globalObj.gen);

    // myStGenBalance
    const myStGenBalance = await stGenTokenContract.balanceOf(globalObj.address);
    globalObj.stgen = ethers.utils.formatEther(myStGenBalance);
    $(".myStGenBalance").text(globalObj.stgen);

    let stakingBalance = await genStakingContract.stakingBalance(globalObj.address);
    globalObj.stakingBalance = ethers.utils.formatEther(stakingBalance);
    console.log("stakingBalance: ", globalObj.stakingBalance);
    $(".myStakedStGen").text(globalObj.stakingBalance);

    let myRewards = await genStakingContract.getMyRewards(globalObj.address);
    globalObj.myRewards = ethers.utils.formatEther(myRewards);

    let usdValue = (globalObj.myRewards * globalObj.genPrice).toFixed(4);
    $(".myRewards").text(globalObj.myRewards + " GEN ($ " + usdValue + ")");
}

async function stake() {
    let stGenInputNum = $(".stGenInput").val();
    console.log("stGenInputNum: ", stGenInputNum);
    let convertedNum = ethers.utils.parseEther(stGenInputNum.toString());
    console.log("convertedNum: ", convertedNum);
    
    // increase allowance
    try {
        let result0 = await stGenTokenContract.increaseAllowance(
            GEN_STAKING_CONTRACT,
            convertedNum.toString()
        );
    } catch (error0) {
        $.toast({
            heading: 'Error',
            text: error0.message,
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'error'
        })

        return;
    }

    $.LoadingOverlay("show");
    await sleep(3000);
    $.LoadingOverlay("hide");

    // stake
    try {
        let result = await genStakingContract.stake(convertedNum.toString());
        console.log("result: ", result);
        
        $.toast({
            heading: 'Success',
            text: 'Completed to stake!',
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'success'
        })

        $(".stGenInput").val(0);
    } catch(error) {
        $.toast({
            heading: 'Error',
            text: error.message,
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'error'
        })
    }
}

async function unstake() {
    let stGenInputNum = $(".stGenInput").val();
    console.log("stGenInputNum: ", stGenInputNum);
    let convertedNum = ethers.utils.parseEther(stGenInputNum.toString());
    console.log("convertedNum: ", convertedNum);
    
    // unstake
    try {
        let result = await genStakingContract.unstake(convertedNum.toString());
        console.log("result: ", result);
        
        $.toast({
            heading: 'Success',
            text: 'Completed to unstake!',
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'success'
        })

        $(".stGenInput").val(0);
    } catch(error) {
        $.toast({
            heading: 'Error',
            text: error.message,
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'error'
        })
    }
}

async function claim() {
    let result;
    try {
        result = await genStakingContract.claimYield();
        console.log("result: ", result);

        $.toast({
            heading: 'Success',
            text: 'Completed to claim!',
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'success'
        })
    } catch(error) {
        $.toast({
            heading: 'Error',
            text: error.message,
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'error'
        })
    }
}

async function burn() {
    let burningGenAmountNum = $(".burningGenAmount").val();
    console.log("burningGenAmountNum: ", burningGenAmountNum);
    let convertedNum = ethers.utils.parseEther(burningGenAmountNum.toString());
    console.log("convertedNum: ", convertedNum);
    
    // increase allowance
    try {
        let result0 = await genTokenContract.increaseAllowance(
            CONVERT_GEN_CONTRACT,
            convertedNum.toString()
        );
    } catch (error0) {
        $.toast({
            heading: 'Error',
            text: error0.message,
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'error'
        })

        return;
    }

    $.LoadingOverlay("show");
    await sleep(3000);
    $.LoadingOverlay("hide");
    
    // convertGen
    try {
        let result = await convertGenContract.convertGen(convertedNum.toString());
        console.log("result: ", result);
        
        $.toast({
            heading: 'Success',
            text: 'Completed to burn!',
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'success'
        })

        $(".burningGenAmount").val(0);
    } catch(error) {
        $.toast({
            heading: 'Error',
            text: error.message,
            showHideTransition: 'fade',
            position: 'top-right',
            hideAfter: 5000,
            icon: 'error'
        })
    }
}