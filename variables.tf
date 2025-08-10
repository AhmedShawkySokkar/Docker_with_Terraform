variable "mysql_version" {
    description = "select the mysql image version"
    type = string
    default = "5.7"
}

variable "hostPort" {
    description = "select the Host Port"
    type = number
    default = 8080
}

variable "username" {
    description = "select default username for any username"
    type = string
    sensitive = true
    default = "wordpress"
}

variable "password" {
    description = "select default password for any password"
    type = string
    sensitive = true
    default = "wordpress"
}