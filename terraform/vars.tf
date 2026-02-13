variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwKPjcdnk1I4g0ehjIGjl7aKvp826Z8RN1pPiLd+BqFN443P1ldP6tN3SpKk3K2rwU506Mi6bwC4d0rhyg9kAFkd1RV9oriy+L9ASrvTZETtxBtT3ZybZnIM9oFuVlp234z7FvM0OCWI5M7pX2CvB9GJdIlNFSZRfuU14m7m/R5DcKMzNS3jnmOF7C5+BH5YZDUY8X8wKlAbakpNz4DjvU1L1j9Zpft74Z0JdgkhHH0wPaRjgtF12iQB6Ht4WT4HQnQl2x+oRLm0AV9ri9R7OTC/QGbt8E3YlFQo0K6WYfnKIOMCKd1i3qLlob9D5poyWRoEz3fIm25NCydgmPCj8OJ5SuuHXxP8JkP9SME63MfswKqdTwK1XV2w8qK7MVMKMV/v4iLOxtN/8Kmi21ubTzIiY0nSHuHLPUvSF3kwhRPX1Vrenuo++Xt34EK3suhtGXg5nW13SanGb4MK1u+cENs/vnPN56o3bBoBOpaOkGz6qb5pK2hSalKF5B+2/IvVs= laurelio@localhost.localdomain"
}

variable "proxmox_host" {
  default = "pve-01"
}

variable "template_name" {
  default = "VM 9000"
}

variable "tailscale_auth_key" {
  default = "tskey-auth-kwQKYbRNB421CNTRL-VB44Xi7joyWkZzGVn5NizWXtVdmH5Chp8"
}

variable "nomad_version" {
  default = "1.9.4"
}

variable "consul_version" {
  default = "1.15.0"
}
