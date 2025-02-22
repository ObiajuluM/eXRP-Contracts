# @version ^0.3.7

sender: address

ledger_entry_type: String[255]

did_document: String[255]

did_data: String[255]

did_uri: String[255]


event did_set:
    sender: address
    did_document: String[255]
    did_data: String[255]
    did_uri: String[255]

event did_delete:
    sender: address


@external
def __init__(_did_document: String[255], _did_data: String[255], _did_uri: String[255]):
    self.sender = msg.sender
    self.did_document = _did_document
    self.did_data = _did_data
    self.did_uri = _did_uri
    log did_set(self.sender, _did_document, _did_data, _did_uri)

@external
def set_did(_did_document: String[255], _did_data: String[255], _did_uri: String[255]):
    assert msg.sender == self.sender, "Only the owner can call this method"
    self.did_document = _did_document
    self.did_data = _did_data
    self.did_uri = _did_uri
    log did_set(self.sender, _did_document, _did_data, _did_uri)

@external
def delete_did():
    assert msg.sender == self.sender, "Only the owner can call this method"
    log did_delete(self.sender)
    selfdestruct(self.sender)
