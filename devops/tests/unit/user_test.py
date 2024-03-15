'''test for random admin user creation'''
import os
from random import randint
import mysql.connector
from aline_datagen import generate_admin_user, create_user, generate_approved_applicant, send_get
from aline_datagen import generate_member_user, generate_account_application, submit_application, get_token

def test_admin_generator():
    '''check if users are generated with all appropriate fields populated'''
    user = generate_admin_user()
    assert user["username"]
    assert len(user["password"]) >= 8
    assert user["role"] == "admin"
    assert user["firstName"]
    assert user["lastName"]
    assert user["email"]
    assert user["phone"]

def test_admin_creation():
    '''check if generated user successfully sends to the service and is created in the db'''
    user = generate_admin_user()
    response = create_user(user)
    assert response.json()["username"] == user["username"]
    assert response.json()["firstName"] == user["firstName"]
    assert response.json()["lastName"] == user["lastName"]
    assert response.json()["role"] == "ADMINISTRATOR"
    assert response.json()["enabled"] is True
    assert response.json()["email"] == user["email"]
    assert response.status_code == 201
    global TOKEN
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    TOKEN = get_token(user['username'], user['password'], port) 

def test_member_generator():
    '''check if a correctly formed member user is generated'''
    applicant = generate_approved_applicant()
    membership_id = str(randint(10000000, 99999999))
    user = generate_member_user(applicant, membership_id)
    assert user['username']
    assert user['membershipId'] == membership_id
    assert user['lastFourOfSSN'] == applicant['socialSecurity'][-4:]

def test_member_creation():
    '''check if a generated member user can be registered and persist in the DB'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    num_users = send_get('/users', port, {"Authorization": TOKEN}).json()['totalElements']
    applicant = generate_approved_applicant()
    application = generate_account_application(applicant)
    app_response = submit_application(application).json()
    member_id = app_response['createdMembers'][0]['membershipId']
    user = generate_member_user(applicant, member_id)
    create_user(user)
    assert num_users + 1 == send_get('/users', port, {"Authorization": TOKEN}).json()['totalElements']
    last_user = send_get(f'/users/{num_users+1}', port, {"Authorization": TOKEN}).json()
    assert last_user['role'] == 'MEMBER'
    assert last_user['username'] == user['username']
