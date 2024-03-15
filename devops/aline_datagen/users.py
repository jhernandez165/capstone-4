'''Creates random applicants for smoke testing'''
import os
from random import randint
from faker import Faker
from .util import random_phone, send_post

def generate_admin_user():
    '''generates and return an object representing a valid admin user to be created'''
    fake = Faker()
    pass_base = fake.password(length=8, special_chars=False,
        digits=True, upper_case=True, lower_case=True)
    user = {
        'username': fake.user_name()+str(randint(1,200)),
        'password': f"Test{pass_base}!",
        'firstName': fake.first_name(),
        'lastName': fake.last_name(),
        'email': fake.email(),
        'phone': random_phone(),
        'role': 'admin'
    }
    return user

def generate_member_user(applicant, membership_id):
    """generates and returns object representing a valid member user to be created
    uses data from the response from a submitted application to build user"""
    fake = Faker()
    pass_base = fake.password(length=8, special_chars=False,
        digits=True, upper_case=True, lower_case=True)
    user = {
        'username': f'{fake.user_name()}123',
        'password': f"Test{pass_base}!",
        'firstName': applicant['firstName'],
        'lastName': applicant['lastName'],
        'email': applicant['email'],
        'phone': applicant['phone'],
        'role': 'member',
        "lastFourOfSSN": applicant['socialSecurity'][-4:],
        "membershipId": membership_id
    }
    return user

def create_user(user):
    '''generates a user request and sends it to the server, returning the response'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    return send_post('/users/registration', port, user)
