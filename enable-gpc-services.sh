
#Enable the following services:
gcloud services enable compute.googleapis.com

#Create GCS backend bucket for terraform: 
gcloud storage buckets create gs://terraform_state_bckup_bnk-project \
  --project="bankproject-486308" \
  --location="us-south1" \                       
  --uniform-bucket-level-access

