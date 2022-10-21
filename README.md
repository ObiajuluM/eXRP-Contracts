# eXRP-Contracts
Contracts to emulate XRPL objects on EVM chain


### Usage

    pip install vyper==0.3.7

**compile**

    vyper file-name.vy
  
***generate bytecode***

    vyper -f bytecode file-name.vy > file-name.bin

***generate abi***

    vyper -f abi file-name.vy > file-name.abi

   
  Code found in this repo was written and tested to compile for vyper version 0.3.7, compiling with earlier versions of vyper may result in errors or warning messages.


Written to emulate XRPL objects such as `Escrows`, `Payment Channels`, `Checks`, etc on XRP sidechains or any other EVM chain.  I didnt see any need to copy XRP's token format on an EVM chain.

Although there are slight differences in the parameters it still delivers the same results as their XRP counterparts. Currently the contracts only support the native coin of the network they can be modified if a need present itself.

There are alot params XRPL objects support that were purposefully left out to minimize the cost of gas and a host of other reasons.

Aside from that, they all perfectly implement XRPL object logic

The `PaymentChannel.vy`  is a fork of [smartcontractprogrammer's](https://github.com/t4sk/vyper-by-example/blob/master/src/PaymentChannel.vy) vyper 0.2^ code. 



Currenlty working to implement this in solidity and wrap them in a js or py sdk
