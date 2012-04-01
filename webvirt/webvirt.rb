#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'libvirt'

get '/' do
  conn = Libvirt::open("qemu+ssh://root@kvmhost/system")
  @act_vm_list = conn.list_domains
  @sby_vm_list = conn.list_defined_domains
  erb :index
end
