import os
import json
import re
import boto3

from botocore.exceptions import ClientError
from botocore.exceptions import ParamValidationError

import lambda_proxy

SUCCESS      = 200
CLIENT_ERROR = 400
SERVER_ERROR = 500

def sendEmail( event, context ):

    print(event)

    request = lambda_proxy.Request(event)

    print('request', request.__dict__)

    data = {
        'name': request.data.get('name'),
        'email': request.data.get('email'),
        'message': request.data.get('message'),
    }

    errors = validate(data)

    if errors:
        return response(CLIENT_ERROR, errors)

    try:

        client = boto3.client('ses' )

        client.send_email(
            Source="%s <%s>" % (data['name'], 'hello@sierradelta.co.uk'),
            Destination={
                'ToAddresses': ['simon@sierradelta.co.uk']
                },
            ReplyToAddresses=["%s <%s>" % (data['name'], data['email'])],
            Message={
                'Body': {
                    'Text': {
                        'Charset': 'UTF-8',
                        'Data': data['message'],
                    },
                },
                'Subject': {
                    'Charset': 'UTF-8',
                    'Data': 'Web Enquiry',
                },
            },
        )

    except (ClientError, ParamValidationError) as e:
        print(e)
        return response(SERVER_ERROR)

    return response(SUCCESS)


def validate( data ):

    errors = {}

    for k, v in data.items():
        v = '' if v is None else str(v)
        if not v.strip():
            errors[k] = 'This is a required field'

    # very basic regex validation for email address
    if not errors.get('email') and not re.match("^[^@]+@[^@]+\.[^@.]+$", data['email']):
        errors['email'] = 'Invalid email address'

    return errors

def response( statusCode, errors = None ):

    body = {
        'success': True if statusCode == SUCCESS else False,
    }

    if errors is not None:
        body['errors'] = errors

    return lambda_proxy.Response(
        statusCode=statusCode,
        body=body,
        headers={
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
        }
    ).makeProxyResponse()
