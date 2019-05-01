## EKS Cluster
resource "aws_eks_cluster" "master_eks" {
  name            = "${var.cluster_name}"
  role_arn        = "${aws_iam_role.eks_cluster_role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks_cluster_sg.id}"]
    subnet_ids         = ["${aws_subnet.master_private_subnet_a.id}","${aws_subnet.master_private_subnet_b.id}"]
  }

  depends_on = [
    "aws_subnet.master_private_subnet_a",
    "aws_subnet.master_private_subnet_b",
    "aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy",
  ]
}

## Cluster Security Groups
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.stack_name}-${var.environment}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.master_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_name}-${var.environment}-sg"
  }
}

## Cluster Roles
resource "aws_iam_role" "eks_cluster_role" {
    name                     = "${var.stack_name}-${var.environment}-role"
    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_cluster_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_cluster_role.name}"
}

# Worker Node Setup
## Worker Node Role
resource "aws_iam_role" "eks_cluster_node_role" {
    name                     = "${var.stack_name}-${var.environment}-node-role"
    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_cluster_node_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks_cluster_node_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks_cluster_node_role.name}"
}

resource "aws_iam_instance_profile" "eks_cluster_node_instance_profile" {
  name = "terraform-eks-cluster-irole"
  path = "/"
  role = "${aws_iam_role.eks_cluster_node_role.name}"
}
## Ingress Worker Security Group
resource "aws_security_group" "eks_cluster_ingress_node_sg" {
  name        = "${var.stack_name}-${var.environment}-ingress-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.master_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-node-ingress-sg",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}
## Worker Node Security Group
resource "aws_security_group" "eks_cluster_node_sg" {
  name        = "${var.stack_name}-${var.environment}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.utility_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-node-sg",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}
resource "aws_security_group_rule" "eks_cluster_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks_cluster_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_node_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_cluster_ingress_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks_cluster_ingress_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_ingress_node_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_cluster_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_cluster_ingress_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_cluster_ingress_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_cluster_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_cluster_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_node_sg.id}"
  to_port                  = 443
  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks_cluster_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_ingress_node_sg.id}"
  to_port                  = 443
  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_cluster_node_talk" {
  description              = "Allow pods to communicate with the other nodes"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks_cluster_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_ingress_node_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_cluster_ingress_node_talk" {
  description              = "Allow pods to communicate with the other nodes"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks_cluster_ingress_node_sg.id}"
  source_security_group_id = "${aws_security_group.eks_cluster_node_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.master_eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}
## Worker Node ASG
resource "aws_launch_configuration" "eks_worker_launch_config" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.eks_cluster_node_instance_profile.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  #image_id                    = "ami-0a2abab4107669c1b"
  instance_type               = "${var.instance_size}"
  name_prefix                 = "terraform-eks-"
  security_groups             = ["${aws_security_group.eks_cluster_node_sg.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  ### Remove before prod
  key_name                    = "${var.key_pair}"
  lifecycle {
    create_before_destroy = true
  }
}
## Ingress Worker Node ASG
resource "aws_launch_configuration" "eks_ingress_worker_launch_config" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.eks_cluster_node_instance_profile.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  #image_id                    = "ami-0a2abab4107669c1b"
  instance_type               = "${var.instance_size}"
  name_prefix                 = "terraform-eks-"
  security_groups             = ["${aws_security_group.eks_cluster_ingress_node_sg.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  ### Remove before prod
  key_name                    = "${var.key_pair}"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "eks_ingress_worker_asg" {
  desired_capacity     = 7
  launch_configuration = "${aws_launch_configuration.eks_ingress_worker_launch_config.id}"
  max_size             = 7
  min_size             = 2
  name                 = "${var.stack_name}-${var.environment}-ingress-asg"
  vpc_zone_identifier  = ["${aws_subnet.master_private_subnet_a.id}, ${aws_subnet.master_private_subnet_b.id}"]

  tag {
    key                 = "Name"
    value               = "${var.stack_name}-${var.environment}-ingress-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "eks_worker_asg" {
  desired_capacity     = 0
  launch_configuration = "${aws_launch_configuration.eks_worker_launch_config.id}"
  max_size             = 1
  min_size             = 0
  name                 = "${var.stack_name}-${var.environment}-asg"
  vpc_zone_identifier  = ["${aws_subnet.utility_private_subnet_a.id}", "${aws_subnet.utility_private_subnet_b.id}"]

  tag {
    key                 = "Name"
    value               = "${var.stack_name}-${var.environment}-worker-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
# resource "null_resource" "copy_config" {
#   provisioner "local-exec" {
#       command = "echo ${local.eks-node-userdata} > ~/.kube/config"
#   }
#   depends_on = [
#       "aws_eks_cluster.master_eks"
#   ]
# }
# resource "null_resource" "add_node_auth" {
#   provisioner "local-exec" {
#       command = "echo ${local.config_map_aws_auth} > ./node_auth.yaml"
#   }
#   depends_on = [
#     "null_resource.copy_config",
#     "aws_eks_cluster.master_eks"
#   ]
# }
# resource "null_resource" "add_node_auth_apply" {
#   provisioner "local-exec" {
#       command = "kubectl apply -f ./node_auth.yaml"
#   }
#   depends_on = [
#     "null_resource.add_node_auth",
#     "null_resource.copy_config"
#   ]
# }


## EKS Post Build - Access 
locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.master_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.master_eks.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.master_eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.master_eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG

config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_cluster_node_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}