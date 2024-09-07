#---------------------#
## Create Private Keys
#---------------------#
resource "tls_private_key" "cert_priv_key" {
    for_each = var.certificates
    algorithm   = "RSA"
}

resource "local_file" "cert_priv_key" {
    for_each = var.certificates
    content  = tls_private_key.cert_priv_key[each.key].private_key_pem
    filename = "${path.module}/certs/${each.key}.key"
}
#----------------------------#
## Create the Signing Request
#----------------------------#
resource "tls_cert_request" "cert_csr" {
    for_each = var.certificates
    private_key_pem = tls_private_key.cert_priv_key[each.key].private_key_pem
    dns_names = each.value["dnsNames"]

    subject {
        country             = var.country
        province            = var.province
        locality            = var.locality
        common_name         = each.key
        organization        = var.organization
        organizational_unit = each.key
    }

}

resource "local_file" "cert_csr" {
    for_each = var.certificates
    content  = tls_cert_request.cert_csr[each.key].cert_request_pem
    filename = "${path.module}/certs/${each.key}.csr"
}

#-------------------------#
## Create the certificates
#-------------------------#
resource "tls_locally_signed_cert" "cert" {
    for_each = var.certificates
    cert_request_pem   = tls_cert_request.cert_csr[each.key].cert_request_pem
    ca_private_key_pem = file(var.intCAKeyLocation)
    ca_cert_pem        = file(var.intCACrtLocation)

    validity_period_hours = 8760 //  1 Year
    
    allowed_uses = each.value["allowedUses"]
}

resource "local_file" "cert" {
    for_each = var.certificates
    content  = tls_locally_signed_cert.cert[each.key].cert_pem
    filename = "${path.module}/certs/${each.key}.crt"
}