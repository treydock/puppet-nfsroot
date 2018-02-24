#
class nfsroot::rw (
  $site_data_dir = undef,
  $partition_schemas = {},
  $rw_host_regex = '.*rw*.',
  $rw_mount = '/var/lib/stateless/writable',
  $rw_label = 'stateless-rw',
  $rw_options = '',
  $state_label = 'stateless-state',
  $state_mount = '/var/lib/stateless/state',
  $state_options = '',
  $statetabs = [],
  $rwtabs = $nfsroot::params::rwtabs,
  $script_intercepts = {},
  $foreman_build_param = 'nfsroot_build',
) inherits nfsroot::params {

  include nfsroot
  include nfsroot::foreman
  include ::osc

  $_statetabs   = lookup('nfsroot::rw::statetabs', Array, 'unique', $statetabs)
  $_rwtabs      = lookup('nfsroot::rw::rwtabs', Hash, 'deep', $rwtabs)

  $data_dir = pick($site_data_dir, $::osc::base_dir)
  $_etc  = $::osc::etc_dir
  $_sbin = $::osc::sbin_dir
  $_osc_partition_path = "${_sbin}/osc-partition"
  $_foreman_host_param_conf_path = $nfsroot::foreman::_foreman_host_param_conf_path
  $_foreman_host_param_script_path = $nfsroot::foreman::_foreman_host_param_script_path

  file { "${data_dir}/partition-schemas":
    ensure => 'directory',
  }

  create_resources('nfsroot::partition_schema', $partition_schemas)

  file { '/etc/sysconfig/readonly-root':
    ensure  => 'present',
    content => template('nfsroot/readonly-root.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Template uses:
  # - $_statetabs
  file { '/etc/statetab':
    ensure  => 'present',
    content => template('nfsroot/statetab.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Template uses:
  # - $_rwtabs
  file { '/etc/rwtab':
    ensure  => 'present',
    content => template('nfsroot/rwtab.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $::operatingsystemmajrelease == '7' {
    file_line { 'comment out rpm tmpfiles':
      path               => '/usr/lib/tmpfiles.d/rpm.conf',
      line               => '#r /var/lib/rpm/__db.*',
      match              => '^r /var/lib/rpm/__db.\*',
      append_on_no_match => false,
    }

    file_line { 'comment out /var/lock tmpfiles':
      path               => '/usr/lib/tmpfiles.d/legacy.conf',
      line               => '#L /var/lock - - - - ../run/lock',
      match              => '^L /var/lock',
      append_on_no_match => false,
    }
  }

  file { $_osc_partition_path:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nfsroot/osc-partition.erb'),
  }

  if $::service_provider == 'systemd' {
    systemd::unit_file { 'osc-partition.service':
      content => template('nfsroot/osc-partition.service.erb'),
      before  => Service['osc-partition'],
    }
  } else {
    #
  }

  service { 'osc-partition':
    ensure => undef,
    enable => true,
  }

  create_resources('nfsroot::script_intercept', $script_intercepts)

}
