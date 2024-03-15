from aline_datagen import generate_account_application, generate_approved_applicant, generate_credit_card_application, generate_loan_application
from aline_datagen import generate_admin_user, create_user, submit_application, get_token
import os

def test_account_application():
    '''creates and submits an application and verifies that it was sent and approved'''
    applicant = generate_approved_applicant()
    application = generate_account_application(applicant)
    response = submit_application(application).json()
    assert response['applicants'][0]['email'] == applicant['email']
    assert response['accountsCreated']
    assert response['createdMembers'][0]['name'] == f"{applicant['firstName']} {applicant['lastName']}"

def test_credit_card_application():
    user = generate_admin_user()
    create_user(user)
    global TOKEN
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    TOKEN = get_token(user['username'], user['password'], port)
    applicant = generate_approved_applicant()
    applicant_name = f"{applicant['firstName']} {applicant['lastName']}"
    application = generate_credit_card_application(applicant)
    response = submit_application(application, TOKEN).json()
    assert response['applicants'][0]['email'] == applicant['email']
    assert response['accountsCreated']
    assert response['createdMembers'][0]['name'] == applicant_name

def test_loan_application():
    applicant = generate_approved_applicant()
    applicant_name = f"{applicant['firstName']} {applicant['lastName']}"
    application = generate_loan_application(applicant)
    response = submit_application(application, TOKEN).json()
    assert response['applicants'][0]['email'] == applicant['email']
    assert response['accountsCreated']
    assert response['createdMembers'][0]['name'] == applicant_name
