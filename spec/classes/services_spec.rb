require 'spec_helper'

describe 'nfsroot::services' do
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
          :hostgroup      => 'base/owens/login',
          :fqdn           => 'owens-login01.hpc.osc.edu',
          :cluster        => 'owens',
          :nfsroot        => true,
          :nfsroot_ro     => true,
        })
      end
      let(:params) {{ }}

      it { should compile.with_all_deps }
      it { should create_class('nfsroot::services') }

    end
  end
end
