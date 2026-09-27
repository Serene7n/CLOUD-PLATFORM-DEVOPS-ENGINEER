# CLOUD-PLATFORM-DEVOPS-ENGINEER

SS0-Login ~/.aws/config 

```
[profile Dev]
region = eu-west-2
sso_session = network-sandbox-sso
sso_account_id = 139488227705
sso_role_name = AWSPowerUserAccess


[sso-session network-sandbox-sso]
sso_start_url = https://identitycenter.amazonaws.com/ssoins-7535b7a9db2409b3
sso_region = eu-west-2
sso_registration_scopes = sso:account:access
```

loging before running the terraform code from Local CLI
```
 aws sso login --profile Dev
 export AWS_PROFILE="Dev"
```