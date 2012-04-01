#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'libvirt'

get '/' do
  conn = Libvirt::open("qemu+ssh://root@kvmhost/system")
  @act_vm_list = conn.list_domains
  @act_vm_list_name = []
  act_vms = @act_vm_list
  act_vms.each do |act_vm|
    act_vm = act_vm.to_i
    vm = conn.lookup_domain_by_id(act_vm)
    @act_vm_list_name << vm.name
  end
  @sby_vm_list = conn.list_defined_domains
  erb :index
end

post '/vm_start' do
  conn = Libvirt::open("qemu+ssh://root@kvmhost/system")
  vm = conn.lookup_domain_by_name(params[:vm_name])
  vm.create
  redirect '/'
end

post '/vm_shutdown' do
  conn = Libvirt::open("qemu+ssh://root@kvmhost/system")
  vm = conn.lookup_domain_by_name(params[:vm_name])
  if params[:Submit] == "shutdown"
    vm.shutdown
  elsif params[:Submit] == "destroy"
    vm.destroy
  end
  redirect '/'
end
