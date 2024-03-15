'''Creates dummy banks for smoke testing'''
import os
from random import randint
from faker import Faker
from .util import send_post, random_phone

def generate_branch(bank_id):
    """generates and returns an object representing a branch to be generated,
    takes a bank_id as an argument to assign to the branch"""
    fake = Faker()
    branch =  {
      "name": f'{fake.city()} Branch',
      "address": fake.street_address(),
      "city": fake.city(),
      "state": fake.state(),
      "zipcode": fake.zipcode(),
      "phone": random_phone(),
      "bankID": bank_id
    }
    return branch

def create_branch(branch, token=''):
    '''sends a post request to the service to submit a generated branch'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    return send_post('/branches', port, branch, {"Authorization": token})

def generate_bank():
    '''generates and returns an object representing a bank to be generated'''
    fake = Faker()
    bank =  {
        "routingNumber": str(randint(100000000, 999999999)),
        "address": fake.street_address(),
        "city": fake.city(),
        "state": fake.state(),
        "zipcode": fake.zipcode()
    }
    return bank

def create_bank(bank, token=''):
    '''sends a post request to the service to submit a generated bank'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    return send_post('/banks', port, bank, {"Authorization": token})
