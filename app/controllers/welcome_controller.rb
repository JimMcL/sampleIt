require 'socket'

class WelcomeController < ApplicationController
  def index
    @ip_addr =  Socket.ip_address_list.reject { |addr| addr.ipv4_loopback? || addr.ipv6_loopback? }.map { |addr| addr.ip_address }
  end
end
