#
define nfsroot::partition_schema (
  $disks            = [],
  $physical_volumes = [],
  $volume_groups    = {},
  $logical_volumes  = {},
) {

  include nfsroot::rw

  $_path = "${nfsroot::rw::data_dir}/partition-schemas/${name}"
  $_wait_path = "${_path}-wait"

  file { $_path:
    ensure  => 'file',
    content => template('nfsroot/partition_schema.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { $_wait_path:
    ensure  => 'file',
    content => template('nfsroot/partition_schema-wait.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

}
