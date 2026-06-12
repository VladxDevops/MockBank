#There errors when running Gihub actions plus terraform plan 
#main issues seems to be that when running terraform pla or apply via github actions the remote terraform state store in the GCP storage bucket seems like its not read by github actions and #terraform. 

Alrady tried: 

Check the syntax and indentation in the Ci and 

There are no errors nor issues rhen running via local terminal:
terraform validate && \
terraform init \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform plan \
  -var-file="dev.tfvars" \
  -target=module.project0 && \
terraform apply -auto-approve \
  -var-file="dev.tfvars" \
  -target=module.project0 



Github actions-terraform example Errors: 

  │ Error: Module not installed

