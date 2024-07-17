resource "aws_secretsmanager_secret" "pep-restaurant-ms-manager-db-secret4" {
 description             = "Secret to store pep restaurant ms manager db password"
 name                    = "/secret/pep/restaurant/ms/manager/database2"
 recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "pep-restaurant-ms-manager-db-secret-version4" {
 secret_id = aws_secretsmanager_secret.pep-restaurant-ms-manager-db-secret4.id
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