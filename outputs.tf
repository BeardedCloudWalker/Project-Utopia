output "master_vpc_id" {
    value = "${aws_vpc.master_vpc.id}"
}
output "master_vpc_priv_subnet_a" {
    value = "${aws_subnet.master_private_subnet_a.id}"
}
output "master_vpc_priv_subnet_b" {
    value = "${aws_subnet.master_private_subnet_b.id}"
}
output "kubeconfig" {
    value = "${local.kubeconfig}"
}
output "config_map_aws_auth" {
    value = "${local.config_map_aws_auth}"
}