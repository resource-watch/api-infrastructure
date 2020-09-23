output "passwords" {
  value = "${zipmap(postgresql_database.default.*.name, random_password.default.*.result)}"
}