variable "oauth2_client_id" {
  type        = string
  description = "OAuth2 client ID key for chosen OAuth2 provider"
}

variable "oauth2_client_secret" {
  type        = string
  description = "OAuth2 client secret key for chosen OAuth2 provider"
}

variable "region" {
  type        = string
  description = "AWS regional endpoint"
  default     = "us-east-1"
}

variable "ingress_rules" {
  type    = list(string)
  default = ["http-80-tcp", "https-443-tcp", "ssh-tcp", "all-icmp"]
}

variable "egress_rules" {
  type    = list(string)
  default = ["all-all"]
}

variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))
  default = {
    http-80-tcp   = [80, 80, "tcp", "HTTP"]
    https-443-tcp = [443, 443, "tcp", "HTTPS"]
    ssh-tcp       = [22, 22, "tcp", "SSH"]
    all-icmp      = [-1, -1, "icmp", "All IPV4 ICMP"]
    all-all       = [-1, -1, "-1", "All protocols"]
  }
}

variable "zone_name" {
  description = "The name of the route53 zone."
  type = string
}
