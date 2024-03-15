#!/usr/bin/env python

'''script that generates and submits applications to the underwriter microservice.'''
import sys
import os
import logging
from datetime import datetime
from json.decoder import JSONDecodeError
from random import randint, choice, sample
from os import makedirs
from pathlib import Path
import aline_datagen


def init_logger():
    '''initializes a logger and returns it'''
    if not Path('logs').exists():
        makedirs('logs')
    timestring = datetime.now().strftime("%Y_%m_%d_%H%M%S_%f")
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler=logging.FileHandler(f'logs/{sys.argv[0]}-_-{timestring}.log')
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.addHandler(logging.StreamHandler())
    return logger

def applications(num, logger, token):
    '''function for generating and submitting applications'''
    responses = []
    while len(responses) < num:
        error = False
        applicants = []
        for _ in range(randint(1,3)):
            applicants.append(aline_datagen.generate_approved_applicant())
        app_type = randint(0,1)
        if app_type:
            application = aline_datagen.generate_account_application(*applicants)
        else:
            application = aline_datagen.generate_credit_card_application(*applicants)
        resp = aline_datagen.submit_application(application, token)
        status = resp.status_code
        try:
            resp = resp.json()
        except JSONDecodeError:
            resp = resp.text
            error = True
        responses.append(resp)
        logger.info(f'{status}: {responses[-1]}')
        if app_type and randint(0,1) == 1 and len(token) > 0 and not error:
            applicants = resp['applicants']
            account_num = resp['createdAccounts'][0]['accountNumber']
            application = aline_datagen.generate_loan_application(account_num, applicants)
            resp = aline_datagen.submit_application(application, token)
            status = resp.status_code
            try:
                resp = resp.json()
            except JSONDecodeError:
                logger.error(f'error object: {application}')
                resp = resp.text
            responses.append(resp)
            logger.info(f'{status}: {responses[-1]}')

def banks(num, logger, token):
    '''function for generating and submitting applications'''
    responses = []
    while len(responses) < num:
        bank = aline_datagen.generate_bank()
        resp = aline_datagen.create_bank(bank, token)
        status = resp.status_code
        try:
            resp = resp.json()
        except JSONDecodeError:
            logger.error(f'error object: {bank}')
            resp = resp.text
        responses.append(resp)
        logger.info(f'{status}: {responses[-1]}')

def branches(num, logger, token):
    '''function for generating and submitting applications'''
    banks_list = aline_datagen.send_get('/banks?size=5000',
        80, {"Authorization": token})
    try:
        banks_list = banks_list.json()['content']
    except JSONDecodeError:
        logger.error(f'{banks_list.status_code} {banks_list.text}')
        return
    banks_list = [bank['id'] for bank in banks_list]
    responses = []
    while len(responses) < num:
        bank_id = choice(banks_list)
        branch = aline_datagen.generate_branch(bank_id)
        resp = aline_datagen.create_branch(branch, token)
        status = resp.status_code
        try:
            resp = resp.json()
        except JSONDecodeError:
            logger.error(f'error object: {branch}')
            resp = resp.text
        responses.append(resp)
        logger.info(f'{status}: {responses[-1]}')

def transactions(num, logger, token):
    '''function for generating and submitting transactions'''
    accounts = aline_datagen.send_get('/accounts?size=5000',
        80, {"Authorization": token})
    try:
        accounts = accounts.json()['content']
    except JSONDecodeError:
        logger.error(f'{accounts.status_code} {accounts.text}')
        accounts = []
        return
    if not accounts:
        logger.error("No accounts found")
        return
    responses = []
    while len(responses) < num:
        account = choice(accounts)
        transaction = aline_datagen.generate_transaction(account)
        resp = aline_datagen.create_transaction(transaction)
        status = resp.status_code
        try:
            resp = resp.json()
        except JSONDecodeError:
            logger.error(f'error object: {transaction}')
            logger.error(f'error object: {account}')
            resp = resp.text
        responses.append(resp)
        logger.info(f'{status}: {responses[-1]}')

def get_members(logger, token):
    '''helper function for users, gets a list of members that aren't already registered as users'''
    members = aline_datagen.send_get('/members?size=5000',
            80, {"Authorization": token})
    try:
        members = members.json()['content']
    except JSONDecodeError:
        logger.error(f'{members.status_code} {members.text}')
        members = []
    existing_users = aline_datagen.send_get('/users?size=5000',
        80, {"Authorization": token})
    try:
        existing_users = existing_users.json()['content']
    except JSONDecodeError:
        logger.error(f'{existing_users.status_code} {existing_users.text}')
        existing_users = []
    skip_members = []
    for user in existing_users:
        if user['role'] == 'MEMBER':
            skip_members.append(user['membershipId'])
    tmp = []
    for member in members:
        if member['membershipId'] not in skip_members:
            tmp.append(member)
    return tmp

def users(num, logger, token):
    '''function for generating and submitting users'''
    if not token:
        responses = []
        while len(responses) < num:
            user = aline_datagen.generate_admin_user()
            resp = aline_datagen.create_user(user)
            status = resp.status_code
            try:
                resp = resp.json()
            except JSONDecodeError:
                logger.error(f'error object: {user}')
                resp = f'{resp.text}'
            resp['password'] = user['password']
            responses.append(resp)
            logger.info(f'{status}: {responses[-1]}')
        return
    members = get_members(logger, token)
    responses = []
    if num > len(members):
        logger.warning("There are less valid members than the requested amount of users\
 to generate, generating as many as possible instead")
        num = len(members)
    members = sample(members, num)
    for member in members:
        if randint(1,10) != 10 and token:
            applicant = member['applicant']
            member_id = member['membershipId']
            user = aline_datagen.generate_member_user(applicant, member_id)
        else:
            user = aline_datagen.generate_admin_user()
        resp = aline_datagen.create_user(user)
        status = resp.status_code
        try:
            resp = resp.json()
        except JSONDecodeError:
            logger.error(f'error object: {user}')
            logger.error(f'error object: {member}')
            resp = f'{resp.text}' 
        responses.append(resp)
        logger.info(f'{status}: {responses[-1]}')

def transfers(num, logger, token):
    '''function for generating and submitting transfers'''
    accounts = aline_datagen.send_get('/accounts?size=5000',
        80, {"Authorization": token})
    accounts = accounts.json()['content']
    responses = []
    while len(responses) < num:
        count = 0
        account1 = accounts[randint(0, len(accounts)-1)]
        while account1['type'] == 'CREDIT_CARD' and count < 10000:
            account1 = accounts[randint(0, len(accounts)-1)]
            count += 1
        account2 = accounts[randint(0, len(accounts)-1)]
        while account2['type'] == 'CREDIT_CARD' and count < 10000:
            account2 = accounts[randint(0, len(accounts)-1)]
            count += 1
        while account1 == account2 or (account1['balance'] < 1 and account2['balance'] < 1):
            account1 = accounts[randint(0, len(accounts)-1)]
            account2 = accounts[randint(0, len(accounts)-1)]
            count += 1
            if count > 10000:
                break
        if count > 10000:
            logger.error('Could not find any accounts with a balance available for transfer')
            break
        transfer = aline_datagen.generate_transfer(account1, account2)
        resp = aline_datagen.create_transfer(transfer, token)
        status = resp.status_code
        try:
            resp = resp.json()
        except JSONDecodeError:
            logger.error(f'error object: {transfer}')
            logger.error(f'error object: {account1}')
            logger.error(f'error object: {account2}')
            resp = resp.text
        responses.append(resp)
        logger.info(f'{status}: {responses[-1]}')

def main():
    '''takes command line arguments to decide how many applications to generate and submit'''
    logger = init_logger()
    argv = sys.argv
    if len(argv) < 2:
        num = 0
    else:
        try:
            num = int(sys.argv[1])
        except ValueError:
            num = 0
    if num < 1:
        logger.warning("invalid or no amount specified, defaulting to 10")
        num = 10
    if len(argv) < 3:
        func = None
    else:
        match argv[2].lower():
            case "applications":
                func = applications
            case "users":
                func = users
            case "transactions":
                func = transactions
            case "transfers":
                func = transfers
            case "banks":
                func = banks
            case "branches":
                func = branches
            case _:
                func = None
    if not func:
        logger.error('Invalid or no object type to generate given')
        logger.error('usage: generate.py <num> <type> <admin username> <admin password>')
        return

    if len(argv) < 5:
        uname = ''
        pword = ''
    else:
        uname = argv[3]
        pword = argv[4]
    try:
        port = os.environ['SVC_PORT']
    except KeyError:
        port = 80
    try:
        token = aline_datagen.get_token(uname, pword, port)
    except KeyError:
        token = ''
        logger.warning('Invalid or no admin user credentials given, auth actions will be skipped')
        logger.warning('usage: generate_applications.py <num> <type> <admin username> <admin password>')
    func(num, logger, token)
if __name__ == "__main__":
    main()
