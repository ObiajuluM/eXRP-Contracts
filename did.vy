# @version ^0.3.7

sender: public(address)

ledger_entry_type: public(String[256])

did_document: public(String[256])

data: public(String[256])

uri: public(String[256])

event did_set:
    sender: address
    did_document: String[256]
    data: String[256]
    uri: String[256]

event did_delete:
    sender: address


@external
def __init__(_did_document: String[256], _data: String[256], _uri: String[256]):
    self.sender = msg.sender
    self.did_document = _did_document
    self.data = _data
    self.uri = _uri
    log did_set(self.sender, _did_document, _data, _uri)

@external
def did_set(_did_document: String[256], _data: String[256], _uri: String[256]):
    assert msg.sender == self.sender, "Only the owner can call this method"
    self.did_document = _did_document
    self.data = _data
    self.uri = _uri
    log did_set(self.sender, _did_document, _data, _uri)

@external
def did_delete():
    assert msg.sender == self.sender, "Only the owner can call this method"
    log did_delete(self.sender)
    selfdestruct(self.sender)
