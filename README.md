# WordPress with MySQL on Docker using Terraform

This Terraform configuration deploys a WordPress site with MySQL database using Docker containers, suitable for local development on Windows.

## Features

- Docker containers managed by Terraform
- MySQL 5.7 with persistent storage
- WordPress with PHP 8.2
- Dedicated Docker network for isolation
- Auto-restart policy for containers
- Health checks for both services
- Outputs for easy access to services

## Prerequisites

1. **Docker Desktop** installed and running
   - [Download Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
   - Enable WSL 2 backend (recommended)

2. **Terraform** installed
   - [Download Terraform](https://www.terraform.io/downloads)
   - Add to system PATH

## Cloning this repository
   
   ```bash
   git clone https://github.com/AhmedShawkySokkar/wordpress-docker-terraform.git
   cd wordpress-docker-terraform
