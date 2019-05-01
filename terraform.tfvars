aws =  {
        region   = "us-west-2",
        account  = ""
}
master_vpc_cidr            = "10.100.0.0/22"
az_a                       = "us-west-2a"
az_b                       = "us-west-2b"
master_pub_cidr_a          = "10.100.0.0/24"
master_pub_cidr_b          = "10.100.1.0/24"
master_prv_cidr_a          = "10.100.2.0/24"
master_prv_cidr_b          = "10.100.3.0/24"
utility_vpc_cidr           = "100.64.0.0/22"
utility_pub_cidr_a         = "100.64.0.0/24"
utility_pub_cidr_b         = "100.64.1.0/24"
utility_prv_cidr_a         = "100.64.2.0/24"
utility_prv_cidr_b         = "100.64.3.0/24"

cluster_name               = "master-eks"
environment                = "Dev"
stack_name                 = "multi-vpc"
key_pair                   = ""
instance_size              = "t3.large"
