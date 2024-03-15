'''contains functions for generating and submitting transactions'''
import os
from random import randint
from .util import send_post

def generate_transaction(account):
    '''generates and returns a transaction object using a passed account object'''
    upper_limit = account['balance']
    account_num = account['accountNumber']
    
    methods = ["ACH", "ATM", "CREDIT_CARD", "DEBIT_CARD", "APP"]
    if account['type'] == 'CREDIT_CARD':
        types = ['PAYMENT', 'PURCHASE', 'REFUND']
        if upper_limit:
            if upper_limit <= 250000:
                upper_limit = 250000 - upper_limit
            elif upper_limit <= 500000:
                upper_limit = 500000 - upper_limit
            else:
                upper_limit = 800000 - upper_limit
        else:
            upper_limit = 250000
            types = ['PURCHASE']
    elif account['type'] == 'LOAN':
        types = ['PAYMENT']
    else:
        types = ["DEPOSIT", "WITHDRAWAL", "PURCHASE", "REFUND"]
        if upper_limit < 1:
            types = ['DEPOSIT', 'REFUND']
    t_type = types[randint(0,len(types) - 1)]
    if (t_type in ['DEPOSIT', 'REFUND']):
        upper_limit = 50000
    if upper_limit < 0:
        print("WHAT")
        print(account)
        print("WHAT")
    transaction = {
        "type": t_type,
        "method": methods[randint(0,len(methods) - 1)],
        "amount": randint(0, upper_limit),
        "merchantCode": "DUMMY",
        "merchantName": "Dummy Merchant",
        "description": "Test",
        "accountNumber": account_num,
        "hold": [True, False][randint(0,1)]
    }
    return transaction

def generate_transfer(src_act, dst_act):
    '''generates and returns a transfer object using two passed account objects'''
    src_num = src_act['accountNumber']
    dst_num = dst_act['accountNumber']
    upper_limit = src_act['balance']
    transaction = {
        "fromAccountNumber": src_num,
        "toAccountNumber": dst_num,
        "amount": randint(1, upper_limit) if upper_limit > 1 else 1,
        "memo": "DUMMY",
}
    return transaction

def create_transaction(transaction):
    '''submits a transaction object to the appropriate endpoint'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    return send_post('/transactions', port, transaction)

def create_transfer(transfer, token=''):
    '''submits a transaction object to the appropriate endpoint'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    return send_post('/transactions/transfer', port, transfer, {"Authorization": token})
