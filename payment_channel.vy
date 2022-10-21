# @version ^0.3.7

sender: public(address)

receiver: public(address)

ledger_entry_type: String[15]

expiry_date: public(uint256)

# 7 days
# DURATION: constant(uint256) = 7 * 24 * 60 * 60

event payment_channel_create:
    sender: address
    amount: uint256
    receiver: address
    expiry_date: uint256

event payment_channel_fund:
    sender: address
    amount: uint256

event payment_channel_claim:
    sender: address
    amount: uint256

event payment_channel_cancel:
    sender: address
    amount: uint256

@external
@payable
def __init__(_receiver: address, _duration: uint256):
    assert _receiver != empty(address), "receiver = zero address"
    self.sender = msg.sender
    self.receiver = _receiver
    self.ledger_entry_type = "payment channel"
    self.expiry_date = block.timestamp + _duration
    log payment_channel_create(msg.sender, msg.value, _receiver, self.expiry_date)

@internal
def _getHash(_amount: uint256) -> bytes32:
    return keccak256(concat(
        convert(self, bytes32),
        convert(_amount, bytes32)
    ))

@external
def getHash(_amount: uint256) -> bytes32:
    return self._getHash(_amount)

@internal
def _getEthSignedHash(_amount: uint256) -> bytes32:
    hash: bytes32 = self._getHash(_amount)
    return keccak256(
        concat(
            b'\x19Ethereum Signed Message:\n32',
            hash
        )
    )

@external
def getEthSignedHash(_amount: uint256) -> bytes32:
    return self._getEthSignedHash(_amount)

@internal
def _verify(_amount: uint256, _sig: Bytes[65]) -> bool:
    ethSignedHash: bytes32 = self._getEthSignedHash(_amount)

    r: uint256 = convert(slice(_sig, 0, 32), uint256)
    s: uint256 = convert(slice(_sig, 32, 32), uint256)
    v: uint256 = convert(slice(_sig, 64, 1), uint256)

    return ecrecover(ethSignedHash, v, r, s) == self.sender

@external
def verify(_amount: uint256, _sig: Bytes[65]) -> bool:
    return self._verify(_amount, _sig)

@nonreentrant("lock")
@external
def claim(_amount: uint256, _sig: Bytes[65]):
    assert msg.sender == self.receiver, "!receiver"
    assert self.balance >= _amount, "balance < payment"
    assert self._verify(_amount, _sig), "invalid sig"
    raw_call(self.receiver, b'\x00', value=_amount)
    log payment_channel_claim(msg.sender, self.balance)
    selfdestruct(self.sender)

@external
def cancel():
    assert msg.sender == self.sender, "!sender"
    assert block.timestamp >= self.expiry_date, "!expired"
    log payment_channel_cancel(msg.sender, self.balance)
    selfdestruct(self.sender)

@external
def amountInChannel() -> uint256:
    return self.balance


@payable
@external
def __default__():

    log payment_channel_fund(msg.sender, msg.value)