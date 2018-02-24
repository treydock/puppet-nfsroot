require 'spec_helper'

describe 'nfsroot::partition_schema' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "RedHat",
        "operatingsystemrelease" => ["6", "7"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
        })
      end

      let :title do
        'default'
      end

      let :params do
        {
          :physical_volumes => ['/dev/sda'],
          :volume_groups    => {'vg0' => {'pv' => '/dev/sda'}},
          :logical_volumes  => {
            'lv_state' => {
              'vg' => 'vg0',
              'size' => '8g',
              'fs_type' => 'ext4',
              'label' => 'state',
              'order' => 1,
            },
            'lv_rw' => {
              'vg' => 'vg0',
              'size' => '8g',
              'fs_type' => 'ext4',
              'label' => 'rw',
              'order' => 2,
            },
            'lv_swap' => {
              'vg' => 'vg0',
              'size' => '48g',
              'fs_type' => 'swap',
              'label' => 'swap',
              'order' => 3,
            },
            'lv_tmp' => {
              'vg' => 'vg0',
              'size' => '100%FREE',
              'fs_type' => 'xfs',
              'label' => 'tmp',
              'order' => 4,
            },
          }
        }
      end

      it 'should have valid config content' do
        content = catalogue.resource('file', '/usr/local/partition-schemas/default').send(:parameters)[:content]
        puts content
        verify_contents(catalogue, '/usr/local/partition-schemas/default', [
          'pvcreate --yes /dev/sda',
          #'echo "Creating VG vg0"'
          'vgcreate --yes --autobackup n vg0 /dev/sda',
          #'echo "Creating LV lv_state"'
          'lvcreate --yes -Wy --autobackup n --zero y --size 8g --name lv_state vg0',
          'mkfs -t ext4 /dev/vg0/lv_state',
          'e2label /dev/vg0/lv_state state',
          'lvcreate --yes -Wy --autobackup n --zero y --size 8g --name lv_rw vg0',
          'mkfs -t ext4 /dev/vg0/lv_rw',
          'e2label /dev/vg0/lv_rw rw',
          'lvcreate --yes -Wy --autobackup n --zero y --size 48g --name lv_swap vg0',
          'mkswap -L swap /dev/vg0/lv_swap',
          'lvcreate --yes -Wy --autobackup n --zero y --size 100%FREE --name lv_tmp vg0',
          'mkfs -t xfs /dev/vg0/lv_tmp',
          'xfs_admin -L tmp /dev/vg0/lv_tmp'
        ])
      end

      it 'should schema' do
        is_expected.to contain_file('/usr/local/partition-schemas/default').with({
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0755',
        })
      end

    end
  end
end
