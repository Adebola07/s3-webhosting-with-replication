terraform { 
  cloud { 
    
    organization = "zamani" 

    workspaces { 
      name = "cloud-computing" 
    } 
  } 
}

provider "aws" {
  region = "us-east-1"
}