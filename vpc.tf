# Master VPC
resource "aws_vpc" "master_vpc" {
    cidr_block = "${var.master_vpc_cidr}"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = "${
      map(
        "Name", "Master VPC",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
      )
    }"
}
resource "aws_internet_gateway" "master_igw" {
    vpc_id = "${aws_vpc.master_vpc.id}"
}
resource "aws_subnet" "master_public_subnet_a" {
  vpc_id                  = "${aws_vpc.master_vpc.id}"
  cidr_block              = "${var.master_pub_cidr_a}"
  availability_zone       = "${var.az_a}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "master_public_subnet_a",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{'purpose':'elb-subnets'}",
      )
    }"
}
resource "aws_subnet" "master_public_subnet_b" {
  vpc_id                  = "${aws_vpc.master_vpc.id}"
  cidr_block              = "${var.master_pub_cidr_b}"
  availability_zone       = "${var.az_b}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "master_public_subnet_b",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{'purpose':'elb-subnets'}",
      )
    }"
}
resource "aws_subnet" "master_private_subnet_a" {
  vpc_id                  = "${aws_vpc.master_vpc.id}"
  cidr_block              = "${var.master_prv_cidr_a}"
  availability_zone       = "${var.az_a}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "master_private_subnet_a",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{'purpose':'ec2-subnets'}",
      )
    }"
}
resource "aws_subnet" "master_private_subnet_b" {
  vpc_id                  = "${aws_vpc.master_vpc.id}"
  cidr_block              = "${var.master_prv_cidr_b}"
  availability_zone       = "${var.az_b}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "master_private_subnet_b",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{'purpose':'ec2-subnets'}",
      )
    }"
}
resource "aws_route_table" "master_public_rt" {
  vpc_id = "${aws_vpc.master_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.master_igw.id}"
  }

  route {
    cidr_block        = "${var.utility_vpc_cidr}"
    vpc_peering_connection_id  = "${aws_vpc_peering_connection.master_utility_pcx.id}"
  }

  tags {
    Name = "Master Public Route Table"
  }
}
resource "aws_route_table_association" "master_public_subnet_asso_a" {
  subnet_id      = "${aws_subnet.master_public_subnet_a.id}"
  route_table_id = "${aws_route_table.master_public_rt.id}"
}
resource "aws_route_table_association" "master_public_subnet_asso_b" {
  subnet_id      = "${aws_subnet.master_public_subnet_b.id}"
  route_table_id = "${aws_route_table.master_public_rt.id}"
}
resource "aws_route_table" "master_private_rt" {
  vpc_id = "${aws_vpc.master_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.master_nat.id}"
  }
  route {
    cidr_block        = "${var.utility_vpc_cidr}"
    vpc_peering_connection_id  = "${aws_vpc_peering_connection.master_utility_pcx.id}"
  }

  tags {
    Name = "Master Private Route Table"
  }
}

resource "aws_route_table_association" "master_private_subnet_assoc_a" {
  subnet_id      = "${aws_subnet.master_private_subnet_a.id}"
  route_table_id = "${aws_route_table.master_private_rt.id}"
}
resource "aws_route_table_association" "master_private_subnet_assoc_b" {
  subnet_id      = "${aws_subnet.master_private_subnet_b.id}"
  route_table_id = "${aws_route_table.master_private_rt.id}"
}
resource "aws_eip" "master_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "master_nat" {
  allocation_id = "${aws_eip.master_nat_eip.id}"
  subnet_id     = "${aws_subnet.master_public_subnet_a.id}"
}
### End Master VPC

### Utility VPC
resource "aws_vpc" "utility_vpc" {
    cidr_block = "${var.utility_vpc_cidr}"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
        Name = "Utility VPC"
    }
}
resource "aws_internet_gateway" "utility_igw" {
    vpc_id = "${aws_vpc.utility_vpc.id}"
}
resource "aws_subnet" "utility_public_subnet_a" {
  vpc_id                  = "${aws_vpc.utility_vpc.id}"
  cidr_block              = "${var.utility_pub_cidr_a}"
  availability_zone       = "${var.az_a}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "utility_public_subnet_a",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{\"purpose\":\"elb-subnets\"}",
      )
    }"
}
resource "aws_subnet" "utility_public_subnet_b" {
  vpc_id                  = "${aws_vpc.utility_vpc.id}"
  cidr_block              = "${var.utility_pub_cidr_b}"
  availability_zone       = "${var.az_b}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "utility_public_subnet_b",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{\"purpose\":\"elb-subnets\"}",
      )
    }"
}
resource "aws_subnet" "utility_private_subnet_a" {
  vpc_id                  = "${aws_vpc.utility_vpc.id}"
  cidr_block              = "${var.utility_prv_cidr_a}"
  availability_zone       = "${var.az_a}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "utility_private_subnet_b",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{'purpose':'ec2-subnets'}",
      )
    }"
}
resource "aws_subnet" "utility_private_subnet_b" {
  vpc_id                  = "${aws_vpc.utility_vpc.id}"
  cidr_block              = "${var.utility_prv_cidr_b}"
  availability_zone       = "${var.az_b}"
  map_public_ip_on_launch = false

  tags = "${
      map(
        "Name", "utility_privatesubnet_b",
        "kubernetes.io/cluster/${var.cluster_name}", "shared",
        "immutable_metadata","{'purpose':'ec2-subnets'}",
      )
    }"
}
resource "aws_route_table" "utility_public_rt" {
  vpc_id = "${aws_vpc.utility_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.utility_igw.id}"
  }

  route {
    cidr_block        = "${var.master_vpc_cidr}"
    vpc_peering_connection_id  = "${aws_vpc_peering_connection.master_utility_pcx.id}"
  }

  tags {
    Name = "Utility Public Route Table"
  }
}
resource "aws_route_table_association" "utility_public_subnet_asso_a" {
  subnet_id      = "${aws_subnet.utility_public_subnet_a.id}"
  route_table_id = "${aws_route_table.utility_public_rt.id}"
}
resource "aws_route_table_association" "utility_public_subnet_asso_b" {
  subnet_id      = "${aws_subnet.utility_public_subnet_b.id}"
  route_table_id = "${aws_route_table.utility_public_rt.id}"
}
resource "aws_route_table" "utility_private_rt" {
  vpc_id = "${aws_vpc.utility_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.utility_nat.id}"
  }

  route {
    cidr_block        = "${var.master_vpc_cidr}"
    vpc_peering_connection_id  = "${aws_vpc_peering_connection.master_utility_pcx.id}"
  }

  tags {
    Name = "Utility Private Route Table"
  }
}

resource "aws_route_table_association" "utility_private_subnet_assoc_a" {
  subnet_id      = "${aws_subnet.utility_private_subnet_a.id}"
  route_table_id = "${aws_route_table.utility_private_rt.id}"
}
resource "aws_route_table_association" "utility_private_subnet_assoc_b" {
  subnet_id      = "${aws_subnet.utility_private_subnet_b.id}"
  route_table_id = "${aws_route_table.utility_private_rt.id}"
}
resource "aws_eip" "utility_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "utility_nat" {
  allocation_id = "${aws_eip.utility_nat_eip.id}"
  subnet_id     = "${aws_subnet.utility_public_subnet_a.id}"
}
### End Utility VPC

### Peering Setup
resource "aws_vpc_peering_connection" "master_utility_pcx" {
  peer_owner_id = "${var.aws["account"]}"
  peer_vpc_id   = "${aws_vpc.master_vpc.id}"
  vpc_id        = "${aws_vpc.utility_vpc.id}"
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}