## Create a simple Root and Intermediate Certificate Authority
## with Terraform for a basic home lab

## Create Root CA
resource "tls_private_key" "root_ca_private_key" {
    algorithm = "RSA"
}

resource "local_file" "root_ca_key" {
    content  = tls_private_key.root_ca_private_key.private_key_pem
    filename = "${path.module}/rootCA/home-local-root.key"
}

resource "tls_self_signed_cert" "root_ca_cert" {
    private_key_pem = tls_private_key.root_ca_private_key.private_key_pem

    is_ca_certificate = true

    subject {
        country             = "AU"
        province            = "ACT"
        locality            = "Braddon"
        common_name         = "home.local Root CA"
        organization        = "Home Systems"
        organizational_unit = "Home Systems Root Certificate Auhtority"
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
    filename = "${path.module}/rootCA/home-local-root.crt"
}


# Create Intermediate CA
resource "tls_private_key" "intermediate_ca_key" {
  algorithm   = "RSA"
}

resource "local_file" "intermediate_ca_key" {
    content  = tls_private_key.intermediate_ca_key.private_key_pem
    filename = "${path.module}/intCA/home-local-int.key"
}

resource "tls_cert_request" "intermediate_csr" {
    private_key_pem = file("${path.module}/intCA/home-local-int.key")
  
    subject {
        country             = "AU"
        province            = "ACT"
        locality            = "Braddon"
        common_name         = "home.local Intermediate CA"
        organization        = "Home Systems"
        organizational_unit = "Home Systems Intermediate Certificate Auhtority"
    }
}

resource "local_file" "intermediate_csr" {
    content  = tls_cert_request.intermediate_csr.cert_request_pem
    filename = "${path.module}/intCA/home-local-int.csr"
}

resource "tls_locally_signed_cert" "int_ca_cert" {

    cert_request_pem   = file("${path.module}/intCA/home-local-int.csr")
    ca_private_key_pem = file("${path.module}/rootCA/home-local-root.key")
    ca_cert_pem        = file("${path.module}/rootCA/home-local-root.crt")

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
    filename = "${path.module}/intCA/home-local-int.crt"
}
