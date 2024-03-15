import os
from aline_datagen import generate_bank, generate_branch, generate_admin_user
from aline_datagen import create_bank, create_branch, create_user, get_token

def test_bank_generation():
    bank = generate_bank()
    assert bank
    assert len(bank['routingNumber']) == 9
    assert len(bank['zipcode']) == 5

def test_bank_creation():
    user = generate_admin_user()
    create_user(user)
    global TOKEN
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    TOKEN = get_token(user['username'], user['password'], port)
    bank = generate_bank()
    response = create_bank(bank, TOKEN)
    assert response.status_code == 201
    response = response.json()
    assert response['routingNumber'] == bank['routingNumber']
    assert not response['branches']

def test_branch_generation():
    branch = generate_branch()
    assert branch
    assert branch['bankID'] == 1
    assert len(branch['zipcode']) == 5

def test_branch_creation():
    user = generate_admin_user()
    create_user(user)
    branch = generate_branch()
    response = create_branch(branch, TOKEN)
    assert response.status_code == 201