require 'spec_helper'

describe 'nfsroot::rw' do
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
          :hostgroup      => 'base/owens/rw',
          :hostgroup_parent => 'base/owens',
          :fqdn           => 'owens-rw01.ten.osc.edu',
          :cluster        => 'owens',
          :nfsroot        => true,
          :nfsroot_ro     => true,
        })
      end
      let(:params) {{ }}

      it { should compile.with_all_deps }
      it { should create_class('nfsroot::rw') }

    end
  end
end
