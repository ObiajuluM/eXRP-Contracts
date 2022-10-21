# @version ^0.3.7

sender: address

receiver: address

amount: uint256

expiry_date: uint256

authorized: HashMap[address, bool]

ledger_entry_type: String[5]

event check_create:
    sender: address
    amount: uint256
    receiver: address
    expiry_date: uint256

event deposit:
    sender: address
    amount: uint256

event check_cash:
    sender: address
    amount: uint256

event check_cancel:
    sender: address
    amount: uint256

@payable
@external
def __init__(_receiver: address, _expiry_date: uint256):
    # assert _expiry_date > block.timestamp, "expiry date is in the past"
    self.sender = msg.sender
    self.amount = msg.value
    self.receiver = _receiver
    self.expiry_date = block.timestamp + _expiry_date
    self.ledger_entry_type = "check"
    self.authorized[msg.sender] = True
    self.authorized[_receiver] = True
    log check_create(msg.sender, msg.value, _receiver, _expiry_date)

@nonreentrant("lock")
@external
def claim_check():
    assert self.authorized[msg.sender], "not authorized claim check"
    assert block.timestamp > self.expiry_date, "too early to claim check"
    log check_cash(msg.sender, self.balance)
    selfdestruct(self.receiver)

@nonreentrant("lock-2")
@external
def cancel_check():
    assert self.authorized[msg.sender], "not authorized to cancel check"
    assert block.timestamp > self.expiry_date, "unable to cancel check, expiry date not reached"
    log check_cancel(msg.sender, self.balance)
    selfdestruct(self.sender)

@external
def amount_in_check() -> uint256:
    return self.balance

@payable
@external
def __default__():

    self.amount += msg.value
    log deposit(msg.sender, msg.value)