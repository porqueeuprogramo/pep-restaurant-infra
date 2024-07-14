resource "aws_secretsmanager_secret" "pep-restaurant-ms-manager-db-secret" {
  description             = "Secret to store pep restaurant ms manager db password"
  name                    = "/pep/ms/manager/database"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "pep-restaurant-ms-manager-db-secret-version" {
  secret_id = aws_secretsmanager_secret.pep-restaurant-ms-manager-db-secret.id
  secret_string = <<EOF
  {
    "engine": "postgres",
    "host": "${local.pep-restaurant-ms-manager-db-endpoint}",
    "port": "${module.pep-restaurant-ms-manager-db.this_db_instance_port}",
    "username": "${local.pep-restaurant-ms-manager-db-username}",
    "password": "${random_password.pep-ms-restaurant-db-password.result}",
    "dbname": "${local.pep-restaurant-ms-manager-db-name}"
  }
EOF
}