# Pubsub Push Flow
## What is it?
This repo contains Terraform and Golang code for showcasing of Pub/Sub message flow using IaC and principle of least privilege on GCP.

## Deploying:
Export `PROJECT_ID` as environmental variable before running docker-compose build and push. The solution assumes you're utilizing GCR as your container registry and you should enable GCR API in the project on beforehand.

Terraform requires following variables to be passed:
```
TF_VAR_project_id=<your-project-id>
TF_VAR_mailgun_domain=<your-mailgun-domain>
```

I recommend creating secret and secret version before applying the rest of the configuration to ensure that notifier Cloud Run instance starts properly. This can be achieved by using terraform apply --target command.

## Testing it out
Curl the publisher API with following command:
```
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" -X POST "$(terraform output -raw publisher_url)/generate-messages"
```
