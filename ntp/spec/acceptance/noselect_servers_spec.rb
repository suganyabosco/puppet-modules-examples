require 'spec_helper_acceptance'

config = if fact('osfamily') == 'Solaris'
           '/etc/inet/ntp.conf'
         else
           '/etc/ntp.conf'
         end

describe 'noselect servers', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  pp = <<-MANIFEST
    class { '::ntp':
      servers          => ['a', 'b', 'c', 'd'],
      noselect_servers => ['c', 'd'],
    }
  MANIFEST

  it 'applies cleanly' do
    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to match(%r{error}i)
    end
  end

  describe file(config.to_s) do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match 'server a' }
    its(:content) { is_expected.to match 'server b' }
    its(:content) { is_expected.to match %r{server c (iburst\s|)noselect} }
    its(:content) { is_expected.to match %r{server d (iburst\s|)noselect} }
  end
end
