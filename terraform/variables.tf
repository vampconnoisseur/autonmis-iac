variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "clusterName" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "autonmis-eks"
}

variable "db_password" {
  description = "Password for the external PostgreSQL database"
  type        = string
  sensitive   = true
  default     = "mysecretpassword"
}
