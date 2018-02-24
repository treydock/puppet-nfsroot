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
          :nfsroot        => true,
          :nfsroot_ro     => false,
        })
      end
      let(:params) {{ }}

      it { should compile.with_all_deps }
      it { should create_class('nfsroot::rw') }

    end
  end
end
