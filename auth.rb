#!/usr/bin/ruby1.9.1
# encoding: utf-8

require 'cgi'
require 'cgi/session'
require 'yaml'
require 'oauth'
require 'pp'

cgi = CGI.new('html4')

conf = YAML.load_file('config.yml')
consumer_key = conf['consumer_key']
consumer_secret = conf['consumer_secret']

session = CGI::Session.new(cgi)
oauth_token = cgi["oauth_token"]
oauth_vrfy = cgi["oauth_verifier"]

consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "https://twitter.com"})

request_token = OAuth::RequestToken.new(
	consumer,
	session["request_token"], session["request_token_secret"])

begin
access_token = request_token.get_access_token({:oauth_verifier => oauth_vrfy})
rescue => err
print cgi.header
print err
#print <<EOF;
#e: #{err}<BR>
#ot: #{oauth_token}<BR>
#ov: #{oauth_vrfy}<BR>
#rt: #{session["request_token"]}<BR>
#rts: #{session["request_token_secret"]}
#EOF
exit
end

session["access_token"] = access_token.token
session["access_secret"] = access_token.secret

print cgi.header("Location" => "twiplain.rb")
