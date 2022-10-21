# @version ^0.3.7


# previous_txn_id: String[256]
# destination_tag: uint256
# flags: uint256
# condition: String[256]
# fulfillment: String[256]

sender: address

receiver: address

claim_date: uint256

expiry_date: uint256

authorized: HashMap[address, bool]

ledger_entry_type: String[6]

event escrow_create:
    sender: address
    amount: uint256
    receiver: address
    claim_date: uint256
    expiry_date: uint256

event deposit:
    sender: address
    amount: uint256

event escrow_claim:
    sender: address
    amount: uint256

event escrow_cancel:
    sender: address
    amount: uint256

@payable
@external
def __init__(_receiver: address, _claim_date: uint256, _expiry_date: uint256):
    # assert _claim_date > block.timestamp, "claim date is in the past"
    # assert _expiry_date > block.timestamp, "expiry date is in the past"
    assert _expiry_date > _claim_date, "error, expiry date cannot be earlier than claim date"
    self.sender = msg.sender
    self.receiver = _receiver
    self.claim_date = block.timestamp + _claim_date
    self.expiry_date = block.timestamp + _expiry_date
    self.ledger_entry_type = "escrow"
    self.authorized[msg.sender] = True
    self.authorized[_receiver] = True
    log escrow_create(msg.sender, msg.value, _receiver, _claim_date, _expiry_date)

@nonreentrant("lock")
@external
def claim_escrow():
    assert self.authorized[msg.sender], "not authorized to claim escrow"
    assert block.timestamp > self.claim_date, "too early to claim"
    assert block.timestamp < self.expiry_date, "too late to claim, can only cancel escrow"
    log escrow_claim(msg.sender, self.balance)
    selfdestruct(msg.sender)
    
@nonreentrant("lock-2")
@external
def cancel_escrow():
    assert self.authorized[msg.sender], "not authorized to cancel escrow"
    assert block.timestamp > self.expiry_date, "unable to cancel escrow, expiry date not reached"
    log escrow_cancel(msg.sender, self.balance)
    selfdestruct(self.sender)

@external
def amount_in_escrow() -> uint256:
    return self.balance

@payable
@external
def __default__():

    log deposit(msg.sender, msg.value)