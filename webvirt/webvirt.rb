#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'libvirt'
require 'rexml/document'

get '/' do
  conn = Libvirt::open("qemu+ssh://root@kvmhost/system")
  @act_vm_list = conn.list_domains
  @act_vm_list_name = []
  unless @act_vm_list.nil?
    act_vms = @act_vm_list
    act_vms.each do |act_vm|
      act_vm = act_vm.to_i
      vm = conn.lookup_domain_by_id(act_vm)
      @act_vm_list_name << vm.name
    end
  end
  @sby_vm_list = conn.list_defined_domains
  erb :index
end

get '/vnc' do
  conn = Libvirt::open("qemu+ssh://root@kvmhost/system")
  vm = conn.lookup_domain_by_name(params[:name])

  vm_source = vm.xml_desc
  vm.free

  vm_doc = REXML::Document.new vm_source

  # show guest xml
  # vm_doc.write(STDOUT)

  vm_doc.elements.each("/domain/devices/graphics[@type='vnc']/"){|address|
    @vm_port   =  address.attributes["port"]
    @vm_passwd =  address.attributes["passwd"]
    @vm_keymap =  address.attributes["keymap"]
    @vm_listen =  address.attributes["listen"]
  }

  erb :vnc
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
