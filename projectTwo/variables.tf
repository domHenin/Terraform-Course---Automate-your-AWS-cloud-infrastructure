# AWS Region Variable
variable "aws_region" {
    description = "AWS Region Variable"
    default = "us-east-2"
}

# TLS Port Variable
variable "tls_port" {
    description = "port for TLS 443"
    default = "443"
}

# SSH Port Variable
variable "ssh_port" {
    description = "port for SSH 22"
    default = "22"
}

# HTTP Port Variable
variable "http_port" {
    description = "port for HTTP 80"
    default = "80"
}