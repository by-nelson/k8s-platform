import boto3
import os

from botocore.config import Config

# Replace with your Cognito details
USER_POOL_ID = "us-east-1_iYEI3Xt6s" #os.environ["SHARED_USER_POOL_ID"]
CLIENT_ID = "38our2quuv14g6jofvcam7k3qb" #os.environ["SHARED_CLIENT_ID"]
USERNAME = "user-shared-cluster" #os.environ["SHARED_USERNAME"]
NEW_PASSWORD = "NewSecurePassword123!" #os.environ["TEST_PASSWORD"]

PROFILE = os.environ["PROFILE"]

boto3.setup_default_session(profile_name=PROFILE)
my_config = Config(
    region_name = 'us-east-1',
    signature_version = 'v4',
    retries = {
        'max_attempts': 10,
        'mode': 'standard'
    }
)

# Create a Cognito client
client = boto3.client('cognito-idp', config=my_config)

# Step 1: Set a new permanent password for the user
client.admin_set_user_password(
    UserPoolId=USER_POOL_ID,
    Username=USERNAME,
    Password=NEW_PASSWORD,
    Permanent=True
)

# Step 2: Authenticate the user
response = client.initiate_auth(
    ClientId=CLIENT_ID,
    AuthFlow='USER_PASSWORD_AUTH',
    AuthParameters={
        'USERNAME': USERNAME,
        'PASSWORD': NEW_PASSWORD
    }
)

# Print the authentication tokens
print("Authentication Successful!")
print("ID Token:", response['AuthenticationResult']['IdToken'])
print("Access Token:", response['AuthenticationResult']['AccessToken'])
print("Refresh Token:", response['AuthenticationResult']['RefreshToken'])
