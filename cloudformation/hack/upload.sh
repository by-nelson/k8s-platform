#!/bin/sh

set -xe

# Render cf files resolving environemnt variables
mkdir ./render -p

export OWNER=$(whoami)

# Iterate over files
for file in $(find . -not -path "./render/*" -type f -regex ".*cf\.yaml"); do
    echo "Processing file: $file"
    mkdir -p "./render/$(dirname $file)"
    envsubst < $file >"./render/$file"
done

# Move all cf files
aws s3 cp ./render "s3://platform-infrastructure-on-aws-cf-$OWNER" \
    --recursive \
    --exclude "*" \
    --include "*cf.yaml" \
    --profile ${PROFILE}

# JWT Layer
mkdir python
(cd python && pip install PyJWT -t .)

zip -r pyjwt-layer.zip ./python

# Upload
aws s3 cp pyjwt-layer.zip "s3://platform-infrastructure-on-aws-cf-$OWNER" \
    --profile ${PROFILE}

# Cleanup
rm -rf ./render 
rm -rf ./python
rm -f pyjwt-layer.zip
