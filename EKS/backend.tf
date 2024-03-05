terraform {
   backend  "s3" {
     bucket = "ci-cd terraform"
     key = "Jenkins/terraform.tfstate"
     region = "us-east1" 
   }
}


