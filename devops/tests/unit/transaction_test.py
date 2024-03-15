import os
from random import randint
from aline_datagen import generate_transfer, generate_transaction, generate_admin_user, generate_account_application, generate_approved_applicant
from aline_datagen import create_transfer, create_transaction, get_token, send_get, create_user, submit_application
admin = generate_admin_user()
uname = admin['username']
pword = admin['password']
create_user(admin)
token = get_token(uname, pword, os.environ['SVC_PORT'])
application = generate_account_application(generate_approved_applicant())
submit_application(application).json()
application = generate_account_application(generate_approved_applicant())
submit_application(application).json()
accounts = send_get('/accounts?size=5000', os.environ['ACC_PORT'], {'Authorization':token}).json()['content']
account1 = accounts[-1]
account2 = accounts[-2]

def test_transaction_generation():
    transaction = generate_transaction(account1)
    assert transaction['type'] in ["DEPOSIT", "WITHDRAWAL", "PURCHASE", "PAYMENT", "REFUND"]
    assert transaction['amount'] <= 50000
    assert transaction['accountNumber'] == account1['accountNumber']

def test_transaction_creation():
    transaction = generate_transaction(account1)
    response = create_transaction(transaction)
    assert response.status_code == 200
    response = response.json()
    assert response['status'] == 'APPROVED'
    assert response['amount'] == transaction['amount']
    assert response['merchantResponse']
    transaction = generate_transaction(account2)
    response = create_transaction(transaction)
    assert response.status_code == 200
    response = response.json()
    assert response['status'] == 'APPROVED'
    assert response['amount'] == transaction['amount']
    assert response['merchantResponse']

def test_transfer_generation():
    transfer = generate_transfer(account1, account2)
    assert transfer
    assert transfer['memo'] == "DUMMY"
    assert transfer['fromAccountNumber'] == account1['accountNumber']

def test_transfer_creation():
    accounts = send_get('/accounts?size=5000', os.environ['ACC_PORT'], {'Authorization':token}).json()['content']
    account1 = accounts[-1]
    account2 = accounts[-2]
    transfer = generate_transfer(account1, account2)
    response = create_transfer(transfer, {'Authorization':token})
    assert response.status_code == 200
    response = response.json()
    assert len(response) == 2