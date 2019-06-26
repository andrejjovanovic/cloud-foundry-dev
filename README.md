# Cloud Foundry Dev

This deployment works on GCP only!

### Prerequisites 

For deploying to Google Cloud you need to set these three env variables inside the run.sh file:

```
TF_VAR_credentials_path
TF_VAR_project_id
TF_VAR_region_id
```

They are used trough deployment, both with Terraform and bosh later.

#### TF_VAR_credentials_path

This is a path to json file that you can obtain in gcp by creating the service account.

#### TF_VAR_project_id

You can see this by clicking on project name in your top bar of cloud console. When new windows open for choosing projects next to project name will be project id.

### TF_VAR_region_id

This is totally by your will but be aware that here you have to put general region id.

For example **us-east1** and not **us-east1-c**. Second one will not work properly when instantiating the machine for cloud foundry.