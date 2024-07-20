resource "aws_secretsmanager_secret" "pep-restaurant-ms-manager-db-secret5" {
 description             = "Secret to store pep restaurant ms manager db password"
 name                    = "/secret/pep/restaurant/ms/manager/database5"
 recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "pep-restaurant-ms-manager-db-secret-version5" {
 secret_id = aws_secretsmanager_secret.pep-restaurant-ms-manager-db-secret5.id
 secret_string = <<EOF
 {
   "engine": "postgres",
   "port": "${local.pep-restaurant-ms-manager-db-port}",
   "username": "${local.pep-restaurant-ms-manager-db-username}",
   "password": "${random_password.pep-ms-restaurant-db-password.result}",
   "dbname": "${local.pep-restaurant-ms-manager-db-name}"
 }
EOF
}