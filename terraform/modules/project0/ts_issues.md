#There errors when running Gihub actions plus terraform plan 
#main issues seems to be that when running terraform pla or apply via github actions the remote terraform state store in the GCP storage bucket seems like its not read by github actions and #terraform. 

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


Alrady tried: 

Check the syntax and indentation in the Ci and ci yaml files. 

Removed: "-backend-config="project=$CLEAN_PROJECT"" since its causing Errors: 
"│ Error: Invalid backend configuration argument

│ 
│ The backend configuration argument "project" given on the command line is
│ not expected for the selected backend type.
"


Github actions-terraform example Errors: 

  │ Error: Module not installed

