output "password" {
    # value = random_password.pass_admin.result
    value = local.admin_pass
    sensitive = true
}
output "admin_user" {
    value = local.admin_user
    sensitive = true
}