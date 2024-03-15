'''contains utility generator functions used in the primary data generation functions'''
import string
import random
import datetime
import os
import requests


def random_date():
    '''generates a random birthday for applicants that will always be at least 18 years ago'''
    today = datetime.date.today()
    earliest_date = datetime.date(1900, 1, 1)
    latest_date = datetime.date(today.year - 18, today.month, today.day)
    days_between = (latest_date - earliest_date).days
    rand_days = random.randrange(days_between)
    rand_date = earliest_date + datetime.timedelta(days=rand_days)
    return str(rand_date)

def random_phone():
    '''generates a random phone number for applicants'''
    first = str(random.randint(1,999)).zfill(3)
    second = str(random.randint(1,999)).zfill(3)
    last = (str(random.randint(1,9999)).zfill(4))
    return f'{first}-{second}-{last}'

def random_ssn():
    '''generates a random SSN for applicants'''
    first = str(random.randint(1,999)).zfill(3)
    second = str(random.randint(1,99)).zfill(2)
    last = (str(random.randint(1,9999)).zfill(4))
    return f'{first}-{second}-{last}'

def random_id():
    '''generates a random Driver's License/ID card number'''
    return random.choice(string.ascii_uppercase) + str(random.randint(1000000, 9999999))

def send_post(endpoint, port, obj, headers=None):
    '''sends a post request to specified endpoint (endpoint must start with /)'''
    if headers is None:
        headers = {}
    try:
        host = os.environ['APP_HOST']
    except KeyError:
        host = 'localhost'
    return requests.post(f'http://{host}:{port}{endpoint}',
        json=obj, timeout=5.0, headers=headers)

def send_get(endpoint, port, headers=None):
    '''sends a post request to specified endpoint (endpoint must start with /)'''
    if headers is None:
        headers = {}
    try:
        host = os.environ['APP_HOST']
    except KeyError:
        host = 'localhost'
    return requests.get(f'http://{host}:{port}{endpoint}',
        timeout=5, headers=headers)

def get_token(username, password, port):
    """logs a user in with provided username and password at the login endpoint
    on the specified port and returns the auth token"""
    response = send_post('/login', port, {"username": username, "password": password})
    return response.headers['Authorization']
