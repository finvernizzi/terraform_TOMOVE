
output "storageaccount_key" {
    value = azurerm_storage_account.storageaccount.primary_access_key
    sensitive = true
}
output "storageaccount_name" {
    value = azurerm_storage_account.storageaccount.name
    sensitive = true
}

output "geojson_share_ID" {
    value = azurerm_storage_share.geoJsonFileShare.id
}
output "geojson_share_URL" {
    value = azurerm_storage_share.geoJsonFileShare.url
}