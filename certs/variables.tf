

variable "intCAKeyLocation" {
	type	= string
	sensitive = true
}

variable "intCACrtLocation" {
	type	= string
	sensitive = true
}

variable "domain" {
	type	= string
}

variable "country" {
	type	= string
}

variable "province" {
	type	= string
}

variable "locality" {
	type	= string
}

variable "organization" {
	type	= string
}

variable "certificates" {
  type = map(object({
	commonName	= string
    dnsNames   	= list(string)
    allowedUses	= list(string)
  }))
}