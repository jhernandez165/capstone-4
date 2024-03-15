'''test for random applicant generation'''
from aline_datagen import generate_applicant

def test_applicant_generator():
    '''check if applicants are generated with all appropriate fields populated'''
    applicant = generate_applicant()
    assert applicant["firstName"]
    assert applicant["middleName"]
    assert applicant["lastName"]
    assert applicant["dateOfBirth"]
    assert applicant["gender"]
    assert applicant["email"]
    assert applicant["phone"]
    assert applicant["socialSecurity"]
    assert applicant["driversLicense"]
    assert applicant["income"]
    assert applicant["address"]
    assert applicant["city"]
    assert applicant["state"]
    assert applicant["zipcode"]
    assert applicant["mailingAddress"]
    assert applicant["mailingCity"]
    assert applicant["mailingState"]
    assert applicant["mailingZipcode"]

