'''generates and submits randomly generated applications to the application'''
import os
from random import randint
from .util import send_post
#from .users import generate_member_user, create_user

def generate_account_application(*applicants):
    """generates and returns an object representing a valid checking/saving account application,
    takes any number of applicants as an argument"""
    application_types = ["CHECKING", "SAVINGS", "CHECKING_AND_SAVINGS"]
    app_type = application_types[randint(0,2)]
    application = {
        "applicationType": app_type,
        "noNewApplicants": False,
        "applicants": applicants,
    }
    return application

def generate_credit_card_application(*applicants):
    '''generates and returns an application for a credit card, takes any number of applicants'''
    application = {
        "applicationType": "CREDIT_CARD",
        "noNewApplicants": False,
        "applicants": applicants,
        "cardOfferId": randint(1, 4)
    }
    return application

def generate_loan_application(account_num, applicants):
    """generates and returns an object representing a valid loan application,
   takes an account number and an array of applicant info
   as would be returned by the API (includes IDs)"""
    applicant_ids = [applicant['id'] for applicant in applicants]
    loan_types = ["PERSONAL", "AUTO", "HOME", "BUSINESS", "SECURE"]
    loan_type = loan_types[randint(0,4)]
    application = {
        "applicationType": "LOAN",
        "noNewApplicants": True,
        "loanType": loan_type,
        "applicantIds": applicant_ids,
        "applicants": applicants,
        "depositAccountNumber": account_num,
        "applicationAmount": randint(1000, 1000000)
    }
    return application


def submit_application(application, token=''):
    '''sends a post request to the service to submit a created application'''
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = '80'
    return send_post('/applications', port, application, {"Authorization": token})
