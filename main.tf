# Defining Terraform configuration and required providers
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"  # The docker source used 
      version = "3.6.2"  # Specified version for stability
    }
  }
}

# Configuring the Docker provider
provider "docker" {
  host = "npipe:////./pipe/docker_engine"  # Windows Docker socket path (login to docker befor terraform planning)
}

# Creating a network for the WordPress stack
resource "docker_network" "wp_network" {
  name   = "wordpress_network"
  driver = "bridge"  # Bridge driver for isolated network
}

# Creating a volume for MySQL data persistence
resource "docker_volume" "mysql_data" {
  name = "mysql_data"
  driver = "local"  # Local driver for host machine storage
}

# MySQL Database container
resource "docker_container" "mysql" {
  name     = "wordpress_db"
  image    = "mysql:${var.mysql_version}"
  restart  = "unless-stopped" # Auto-restart policy
  hostname = "wordpress_db"   # Hostname for Windows DNS resolution

  env = [
    "MYSQL_ROOT_PASSWORD=wordpress",  # Root password
    "MYSQL_DATABASE=wordpress",       # Default database
    "MYSQL_USER=${var.username}",     # WordPress database user
    "MYSQL_PASSWORD=${var.password}"        # WordPress user password
  ]

  # Mount volume for persistent data storage
  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }
  
  # Attach to our network
  networks_advanced {
    name = docker_network.wp_network.name
  }

  # Health check configuration
  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-h", "localhost"]  # Test command
    interval = "5s"    # Check every 5 seconds
    timeout  = "5s"    # Timeout after 5 seconds
    retries  = 5       # Retry 5 times before marking as unhealthy
  }
}

# WordPress container
resource "docker_container" "wordpress" {
  name     = "wordpress_app"
  image    = "wordpress:php8.2-apache"  
  restart  = "unless-stopped" # Auto-restart policy
  hostname = "wordpress_app"  # Hostname for Windows DNS resolution

  # Port mapping(container(80) to host(8080))
  ports {
    internal = 80    # Container port
    external = var.hostPort  # Host port
  }

  env = [
    "WORDPRESS_DB_HOST=wordpress_db",    # Using MySQL container name
    "WORDPRESS_DB_USER=${var.username}",       # Database username
    "WORDPRESS_DB_PASSWORD=${var.password}",   # Database password
    "WORDPRESS_DB_NAME=wordpress",       # Database name
    "WORDPRESS_CONFIG_EXTRA=define('WP_HOME','http://localhost:8080'); define('WP_SITEURL','http://localhost:8080');"
  ]

   # Attach to our network
  networks_advanced {
    name = docker_network.wp_network.name
  }

  # To ensure MySQL starts first
  depends_on = [
    docker_container.mysql
  ]

  # Health check configuration
  healthcheck {
    test     = ["CMD", "powershell", "-command", "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/wp-admin/install.php' -UseBasicParsing -DisableKeepAlive; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"]
    interval = "10s"   # Check every 10 seconds
    timeout  = "5s"    # Timeout after 5 seconds
    retries  = 3       # Retry 3 times before marking as unhealthy
  }
}

