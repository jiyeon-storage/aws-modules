locals {
  env        = "dev"
  team       = "devops"
  purpose    = "test"
  prefix     = "jiyeon"
  
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789"
  origin_bucket_name = "mytests3bucket"
  log_bucket_name= "mylogtests3bucket"
  domain_name = "test.com"
  subdomain   = "mycdntest"

}