#
class nfsroot::params {

  $rwtabs = {
    'dirs' => [
      '/var/cache/man',
      '/var/gdm',
      '/var/lib/xkb',
      '/var/log',
      '/var/lib/puppet',
      '/var/lib/dbus',
      '/var/lib/nfs',
    ],
    'empty' => [
      '/tmp',
      '/var/cache/foomatic',
      '/var/cache/logwatch',
      '/var/cache/httpd/ssl',
      '/var/cache/httpd/proxy',
      '/var/cache/php-pear',
      '/var/cache/systemtap',
      '/var/db/nscd',
      '/var/lib/dav',
      '/var/lib/dhcpd',
      '/var/lib/dhclient',
      '/var/lib/php',
      '/var/lib/pulse',
      '/var/lib/ups',
      '/var/tmp',
    ],
    'files' => [
      '/etc/adjtime',
      '/etc/ntp.conf',
      '/etc/resolv.conf',
      '/etc/lvm/cache',
      '/etc/lvm/archive',
      '/etc/lvm/backup',
      '/var/account',
      '/var/lib/arpwatch',
      '/var/lib/NetworkManager',
      '/var/cache/alchemist',
      '/var/lib/gdm',
      '/var/lib/iscsi',
      '/var/lib/logrotate.status',
      '/var/lib/ntp',
      '/var/lib/xen',
      '/var/empty/sshd/etc/localtime',
      '/var/lib/random-seed',
      '/var/spool',
      '/var/lib/samba',
      '/var/log/audit/audit.log',
    ]
  }

}
