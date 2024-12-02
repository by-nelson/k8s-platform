# Platform infrastructure resources

## Deploy

How to run the stack deployment

```sh
# set aws credentials profile
export PROFILE="<your-profile-name>"

# create cf bucket
./hack/bucket.sh

# upload templates
./hack/upload.sh
```

Recommended Parameters to use for the first deployment

| Parameter Name     | Value                    |
| ------------------ | ------------------------ |
| AvailabilityZones  | us-east-1a, us-east-1b   |
| PrivateSubnetsCIDR | 10.0.0.0/24, 10.0.1.0/24 |
| PublicSubnetsCIDR  | 10.0.2.0/24, 10.0.3.0/24 |
| Role               | LabRole                  |
| VpcCIDR            | 10.0.0.0/16              |
