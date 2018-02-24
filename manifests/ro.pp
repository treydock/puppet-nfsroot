#
class nfsroot::ro (
  Hash $file_capabilities = {},
) inherits nfsroot::params {

  include nfsroot

  create_resources('file_capability', $file_capabilities)

}
