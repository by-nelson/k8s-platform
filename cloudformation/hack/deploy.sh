#!/bin/bash

set -e

# Function to display usage
function usage() {
  echo "Usage: $0 [-s <STACK_NAME>] [-p <PARAMETER_OVERRIDES>] [-r <REGION>] [-c]"
  echo "  -s: (Optional) Name of the CloudFormation stack to deploy"
  echo "  -p: (Optional) Parameter overrides in the format Key1=Value1 Key2=Value2"
  echo "  -r: (Optional) AWS Region (default: us-east-1)"
  echo "  -c: (Optional) Create or update the stack (default is update if stack exists)"
  exit 1
}

export OWNER=$(whoami)

# Defaults
AWS_REGION="us-east-1"

STACK_NAME="platform"
STACK_CREATE=false

S3_BUCKET="platform-infrastructure-on-aws-cf-$OWNER"
S3_TEMPLATE="infrastructure-root-cf.yaml"

# Parse command-line arguments
while getopts "s:p:r:c" opt; do
  case $opt in
    s) STACK_NAME="$OPTARG" ;;
    p) PARAMETER_OVERRIDES+=" $OPTARG" ;;
    r) AWS_REGION="$OPTARG" ;;
    c) STACK_CREATE=true ;;
    *) usage ;;
  esac
done

# S3 URL for the CloudFormation template
TEMPLATE_URL="https://$S3_BUCKET.s3.$AWS_REGION.amazonaws.com/$S3_TEMPLATE"

# Check if the stack exists
STACK_EXISTS=$(aws cloudformation describe-stacks --profile "$PROFILE" --region "$AWS_REGION" --stack-name "$STACK_NAME" 2>/dev/null || echo "false")


# Parameters
for param in $PARAMETER_OVERRIDES
do 
    PARAMS+=" $(echo -e "$param" | sed -E 's/([^=]*)=([^=]*)/ParameterKey=\1,ParameterValue=\2/')"
done
    
# Deploy the stack
if [[ "$STACK_EXISTS" == "false" ]]; then
  if [[ "$STACK_CREATE" == "true" ]]; then
    echo "Creating stack: $STACK_NAME"
    aws cloudformation create-stack \
      --region "$AWS_REGION" \
      --stack-name "$STACK_NAME" \
      --profile ${PROFILE} \
      --template-url "$TEMPLATE_URL" \
      ${PARAMETER_OVERRIDES:+--parameters $(echo -e "$PARAMS")}
  else
    echo "Stack $STACK_NAME does not exist. Use the -c flag to create it."
    exit 1
  fi
else
  echo "Updating stack: $STACK_NAME"
  aws cloudformation update-stack \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME" \
    --profile ${PROFILE} \
    --template-url "$TEMPLATE_URL" \
    ${PARAMETER_OVERRIDES:+--parameters $(echo "$PARAMETER_OVERRIDES" | sed 's/ / ParameterKey=/g' | sed 's/^/ParameterKey=/')}
fi

# Wait for the stack operation to complete
echo "Waiting for stack operation to complete..."
aws cloudformation wait stack-$([[ "$STACK_EXISTS" == "false" ]] && echo "create-complete" || echo "update-complete") \
  --profile ${PROFILE} \
  --region "$AWS_REGION" \
  --stack-name "$STACK_NAME"

echo "Stack deployment complete."
