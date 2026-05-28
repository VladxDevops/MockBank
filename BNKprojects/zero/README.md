## Verifirstime seting up project zero:
Use script to give IAM roles to terraform service account: 

Before that: Can use this commd to retrive roles from the other GCP project: 
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:[SERVICE_ACCOUNT_EMAIL]" \
    --format="value(bindings.role)"

*Replace placeholder: SERVICE_ACCOUNT_EMAIL with actual service account email. 

After that: 
give execute permission to script: 
chmod +x project0firstrun.sh

Run script: 
cd BNKprojects/0
./project0firstrun.sh





##