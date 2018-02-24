#
class nfsroot::services inherits nfsroot::params {

  $disable = lookup('nfsroot::services::disable', Array, 'unique', [])
  $stop    = lookup('nfsroot::services::stop', Array, 'unique', [])
  $enable  = lookup('nfsroot::services::enable', Array, 'unique', [])
  $start   = lookup('nfsroot::services::start', Array, 'unique', [])

  $_stop_disable_services  = intersection($stop, $disable)
  $_stop_services          = difference($stop, $_stop_disable_services)
  $_disable_services       = difference($disable, $_stop_disable_services)
  $_start_enable_services  = intersection($start, $enable)
  $_start_services         = difference($start, $_start_enable_services)
  $_enable_services        = difference($enable, $_start_enable_services)

  # TODO: Better to brute force or let Puppet handle enable/disable on a per-service / module basis?
  #if $::nfsroot == 'true' and $::nfsroot_ro == 'false' {
  #  Service <| |> {
  #    enable => false,
  #  }
  #}

  each($_stop_disable_services) |$_stop_disable| {
    if defined(Service[$_stop_disable]) {
      Service <| title == $_stop_disable |> {
        ensure => 'stopped',
        enable => false,
      }
    } else {
      service { $_stop_disable:
        ensure => 'stopped',
        enable => false,
      }
    }
  }

  each($_disable_services) |$_disable| {
    if defined(Service[$_disable]) {
      Service <| title == $_disable |> {
        enable => false,
      }
    } else {
      service { $_disable:
        ensure => undef,
        enable => false,
      }
    }
  }

  each($_stop_services) |$_stop| {
    if defined(Service[$_stop]) {
      Service <| title == $_stop |> {
        ensure => 'stopped',
      }
    } else {
      service { $_stop:
        ensure => 'stopped',
        enable => undef,
      }
    }
  }

  each($_start_enable_services) |$_start_enable| {
    if defined(Service[$_start_enable]) {
      Service <| title == $_start_enable |> {
        ensure => 'running',
        enable => true,
      }
    } else {
      service { $_start_enable:
        ensure => 'running',
        enable => true,
      }
    }
  }

  each($_enable_services) |$_enable| {
    if defined(Service[$_enable]) {
      Service <| title == $_enable |> {
        enable => true,
      }
    } else {
      service { $_enable:
        ensure => undef,
        enable => true,
      }
    }
  }

  each($_start_services) |$_start| {
    if is_hash($_start) {
      $_s = keys($_start)[0]
      if has_key($_start, 'before') {
        $_before = $_start[$_s]['before']
      } else {
        $_before = undef
      }
      $_require = $_start[$_s]['require']
    } else {
      $_s = $_start
      $_before = undef
      $_require = undef
    }
    if defined(Service[$_s]) {
      Service <| title == $_s |> {
        ensure  => 'running',
        before  => $_before,
        require => $_require,
      }
    } else {
      service { $_s:
        ensure  => 'running',
        enable  => undef,
        before  => $_before,
        require => $_require,
      }
    }
  }

}
