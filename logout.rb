#!/usr/bin/ruby1.9.1
# encoding: utf-8

require 'cgi'
require 'cgi/session'

cgi = CGI.new('html4')
session = CGI::Session.new(cgi)
session.delete

print cgi.header("Location" => "./")
