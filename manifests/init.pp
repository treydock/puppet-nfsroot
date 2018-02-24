#
class nfsroot (
  Boolean $fstabs_hiera_merge = true,
  Hash $fstabs = {}
) inherits nfsroot::params {

  if $fstabs_hiera_merge {
    $mounts = lookup('nfsroot::fstabs', Hash, 'deep', {})
  } else {
    $mounts = $fstabs
  }

  $_fstab_defaults = {
    'ensure' => 'present',
    'tag'    => 'fstab',
  }
  create_resources('mount', $mounts, $_fstab_defaults)

}
