# To output the WordPress URL after deployment
output "wordpress_url" {
  description = "URL to access WordPress"  
  value = "http://localhost:8080"
}

# To output MySQL connection details (for reference)
output "mysql_connection" {
  description = "MySQL connection details"  
  sensitive = true
  value = {
    host     = docker_container.mysql.name
    port     = 3306
    database = "wordpress"
    username = "wordpress"
    password = "wordpress"
  }
}