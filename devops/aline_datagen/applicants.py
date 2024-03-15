'''Creates random applicants for smoke testing'''
import string
import random
from faker import Faker
from .util import random_phone, random_ssn, random_id, random_date

def generate_applicant():
    '''generates and return an object representing a valid applicant'''
    fake = Faker()
    genders = ["MALE", "FEMALE", "OTHER" ,"UNSPECIFIED"]
    applicant = {
        'firstName' : fake.first_name(),
        'middleName' : fake.first_name(),
        'lastName' : fake.last_name(),
        'dateOfBirth' : random_date(),
        'gender' : genders[random.randint(0,3)],
        'email' : fake.email(),
        'phone' : random_phone(),
        'socialSecurity' : random_ssn(),
        'driversLicense' : random_id(),
        'income' : random.randint(0, 3000000),
        'address' : fake.street_address(),
        'city' : fake.city(),
        'state' : random.choice(string.ascii_uppercase)\
            + random.choice(string.ascii_uppercase),
        'zipcode' : fake.zipcode(),
        'mailingAddress' : fake.street_address(),
        'mailingCity' : fake.city(),
        'mailingState' : random.choice(string.ascii_uppercase)\
            + random.choice(string.ascii_uppercase),
        'mailingZipcode' : fake.zipcode(),
    }
    return applicant

def generate_approved_applicant():
    '''generates and return an object representing a valid applicant'''
    fake = Faker()
    genders = ["MALE", "FEMALE", "OTHER" ,"UNSPECIFIED"]
    applicant = {
        'firstName' : fake.first_name(),
        'middleName' : fake.first_name(),
        'lastName' : fake.last_name(),
        'dateOfBirth' : random_date(),
        'gender' : genders[random.randint(0,3)],
        'email' : fake.email(),
        'phone' : random_phone(),
        'socialSecurity' : random_ssn(),
        'driversLicense' : random_id(),
        'income' : random.randint(1500000, 3000000),
        'address' : fake.street_address(),
        'city' : fake.city(),
        'state' : random.choice(string.ascii_uppercase)\
            + random.choice(string.ascii_uppercase),
        'zipcode' : fake.zipcode(),
        'mailingAddress' : fake.street_address(),
        'mailingCity' : fake.city(),
        'mailingState' : random.choice(string.ascii_uppercase)\
            + random.choice(string.ascii_uppercase),
        'mailingZipcode' : fake.zipcode(),
    }
    return applicant
