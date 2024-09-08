## Create a simple Root and Intermediate Certificate Authority
## with Terraform for a basic home lab

## Create Root CA
resource "tls_private_key" "root_ca_private_key" {
    algorithm = "RSA"
}

resource "local_file" "root_ca_key" {
    content  = tls_private_key.root_ca_private_key.private_key_pem
    filename = "${path.module}/rootCA/${replace(var.domain,".","-")}-root.key"
    file_permission = "600"
}

resource "tls_self_signed_cert" "root_ca_cert" {
    private_key_pem = tls_private_key.root_ca_private_key.private_key_pem

    is_ca_certificate = true

    subject {
        country             = var.country
        province            = var.province
        locality            = var.locality
        common_name         = "${var.domain} - Root CA"
        organization        = var.organization
        organizational_unit = "${var.organization} Root Certificate Auhtority"
    }

    validity_period_hours = 43800 //  1825 days or 5 years

    allowed_uses = [
        "cert_signing", "client_auth", "code_signing", 
        "content_commitment", "crl_signing", "data_encipherment", 
        "decipher_only", "digital_signature", "email_protection", 
        "encipher_only", "ipsec_end_system", "ipsec_tunnel", 
        "ipsec_user", "key_agreement", "key_encipherment", 
        "microsoft_commercial_code_signing", 
        "microsoft_kernel_code_signing", "microsoft_server_gated_crypto", 
        "netscape_server_gated_crypto", "ocsp_signing", "server_auth", 
        "timestamping"
        // "any_extended"
    ]
}

resource "local_file" "root_ca_cert" {
    content  = tls_self_signed_cert.root_ca_cert.cert_pem
    filename = "${path.module}/rootCA/${replace(var.domain,".","-")}-root.crt"
    file_permission = "600"
}


# Create Intermediate CA
resource "tls_private_key" "intermediate_ca_key" {
  algorithm   = "RSA"
}

resource "local_file" "intermediate_ca_key" {
    content  = tls_private_key.intermediate_ca_key.private_key_pem
    filename = "${path.module}/intCA//${replace(var.domain,".","-")}-int.key"
    file_permission = "600"
}

resource "tls_cert_request" "intermediate_csr" {
    private_key_pem = tls_private_key.root_ca_private_key.private_key_pem
  
    subject {
        country             = var.country
        province            = var.province
        locality            = var.locality
        common_name         = "${var.domain} - Intermediate CA"
        organization        = var.organization
        organizational_unit = "${var.organization} Intermediate Certificate Auhtority"
    }

    depends_on = [ local_file.root_ca_key ]
}

resource "local_file" "intermediate_csr" {
    content  = tls_cert_request.intermediate_csr.cert_request_pem
    filename = "${path.module}/intCA/${replace(var.domain,".","-")}-int.csr"
    file_permission = "600"
}

resource "tls_locally_signed_cert" "int_ca_cert" {
    cert_request_pem   = tls_cert_request.intermediate_csr.cert_request_pem
    ca_private_key_pem = tls_private_key.root_ca_private_key.private_key_pem
    ca_cert_pem        = tls_self_signed_cert.root_ca_cert.cert_pem

    is_ca_certificate = true

    validity_period_hours = 8760 //  1825 days or 5 years

    allowed_uses = [
        "cert_signing", "client_auth", "code_signing", 
        "content_commitment", "crl_signing", "data_encipherment", 
        "decipher_only", "digital_signature", "email_protection", 
        "encipher_only", "ipsec_end_system", "ipsec_tunnel", 
        "ipsec_user", "key_agreement", "key_encipherment", 
        "microsoft_commercial_code_signing", 
        "microsoft_kernel_code_signing", "microsoft_server_gated_crypto", 
        "netscape_server_gated_crypto", "ocsp_signing", "server_auth", 
        "timestamping"
        // "any_extended"
    ]
}

resource "local_file" "intermediate_cert" {
    content  = tls_locally_signed_cert.int_ca_cert.cert_pem
    filename = "${path.module}/intCA/${replace(var.domain,".","-")}-int.crt"
    file_permission = "600"
}
