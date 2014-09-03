require 'dnsruby'
require_relative 'hash_helper'

def getZone (zone, nameservers, tsig)
  zt = Dnsruby::ZoneTransfer.new
  zt.server = nameservers.first
  if tsig
    tsig = Dnsruby::RR::TSIG.create(
      tsig.to_sym.merge({:type=>'TSIG', :klass=>'ANY'})
    )
    zt.tsig = tsig
  end

  zoneref = zt.transfer(zone)
  if zoneref == nil
    raise RuntimeError,  "couldn't transfer zone\n"
  end
  zoneref
end

def rr_filter(rrs)
  grrs = {}
  rrs.each do |rr|
    key = {
      :kind => 'dns#resourceRecordSet',
      :name => rr.name.to_s,
      :type => rr.type.to_s,
      :ttl => rr.ttl
    }
    grrs[key] = [] unless grrs.key?(key)
    grrs[key] << rr.rdata.to_s
  end
  grrsa = []
  grrs.each do |k, v|
    k['rrdatas'] = v
    grrsa << k
  end
  grrsa
end
