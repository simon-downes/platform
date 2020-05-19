
import json
import urllib.parse

class Request:
    """Takes a Lambda event object and extra data to represent a more traditional http request."""

    def __init__(self, event):
        self.method     = event['httpMethod']
        self.path       = event['path']
        self.headers    = {k.lower():v for k,v in event['headers'].items()}
        self.parameters = event['queryStringParameters']
        self.body       = event['body']
        (self.data, self.dataError) = self.__decodeBody()

    def __decodeBody(self):
        """Decodes a json or x-www-form-urlencoded body string into a dictionary."""

        data  = {}
        error = None

        content_type = self.headers.get('content-type', '')

        try:
            if content_type == 'application/json':
                data = json.loads(self.body)

            elif content_type == 'application/x-www-form-urlencoded':
                data = dict(urllib.parse.parse_qsl(self.body, strict_parsing=True))

        except ValueError as e:
            print(e)
            error = str(e)

        return (data, error)


class Response:
    """Represents a simple HTTP response and generates a suitable return value for Lambda Proxy."""

    def json():
        """Create an empty json response."""
        return lambda_proxy.Response(
            headers={
                'Content-Type': 'application/json'
            }
        )

    def xml():
        """Create an empty xml response."""
        return lambda_proxy.Response(
            headers={
                'Content-Type': 'application/json'
            }
        )

    def __dictToXML(tag, d):
        """Convert a dictionary to xml with keys as tags, works recursively with nested dictionaries."""

        parts = ['<{}>'.format(tag)]

        for k, v in d.items():
            if isinstance(v, dict):
                parts.append(Response.__dictToXML(k, v))
            else:
                parts.append('<{0}>{1}</{0}>'.format(k,v))

        parts.append('</{}>'.format(tag))

        return ''.join(parts)

    def __init__( self, statusCode=200, headers=None, body=None ):
        self.statusCode = statusCode
        self.body       = {} if body is None else body
        self.headers    = {} if headers is None else {k.lower():v for k,v in headers.items()}

    def setHeader( self, header, value ):
        """Set a header value."""
        self.headers[header.lower()] = value

    def isJSON( self ):
        """Determines if the response has a JSON content-type."""
        return self.headers.get('content-type') == 'application/json'

    def isXML( self ):
        """Determines if the response has an XML content-type."""
        return self.headers.get('content-type') == 'application/xml'

    def makeProxyResponse( self ):
        """Returns a dictionary that can be used as a return value to Lambda Proxy."""

        if isinstance(self.body, dict):
            if self.isJSON():
                body = json.dumps(self.body)

            elif self.isXML():
                body = Response.__dictToXML('response', self.body)

            else:
                body = str(self.body)

        return {
            'statusCode': self.statusCode,
            'body': body,
            'headers': self.headers.copy(),
        }
