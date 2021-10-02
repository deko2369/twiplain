#!/usr/bin/ruby1.9.1
# encoding: utf-8 

require 'twitter'
require 'pp'
require 'cgi'
require 'cgi/session'
require 'yaml'

require './string_to_link.rb'

cgi = CGI.new
session = CGI::Session.new(cgi)

if (session['access_token'] == nil or
	session['access_secret'] == nil) then
	print cgi.header('Location' => './')
	exit
end

print "Content-type: text/html\n\n"

conf = YAML.load_file("config.yml")

Twitter.configure do |config|
	config.consumer_key = conf["consumer_key"]
	config.consumer_secret = conf["consumer_secret"]
	config.oauth_token = session["access_token"]
	config.oauth_token_secret = session["access_secret"]
end

#pp session["access_token"]
#pp session["access_secret"]

client_user = Twitter.current_user

if cgi.has_key?('u') and (cgi['u'] != "") then
	current_user = Twitter.user(cgi['u'])
else
	current_user = client_user
end

SCREENNAME = current_user.screen_name

print <<EOF;
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Twiplain - #{SCREENNAME}</title>
</head>
<body bgcolor="#efefef" text="black" link="blue" alink="red" vlink="#660099">
<div style="margin-top:1em;"><span style='float:left;'>
Twiplain(仮)
<a href="twiplain.rb">最新100</a>
<a href="twiplain.rb?at">@#{client_user.screen_name}</a>
<a href="logout.rb">ログアウト</a>
</span>
<span style='float:right;'>
</span>&nbsp;
<form method="get" action="twiplain.rb">
@<input type="text" name="u">
<input type="submit" value="Go">
</form>
</div>
<hr style="background-color:#888;color:#888;border-width:0;height:1px;position:relative;top:-.4em;">
<h1 style="color:red;font-size:larger;font-weight:normal;margin:-.5em 0 0;">
EOF

if cgi.has_key?('at') then
	timeline = Twitter.mentions
	print "@", client_user.screen_name, "宛てのツイート"
elsif cgi.has_key?('next') then
	timeline = Twitter.home_timeline(
		{:count => 100, :max_id => cgi['next']})
	print "@", client_user.screen_name, "のタイムライン"
elsif !(client_user == current_user) then
	timeline = Twitter.user_timeline(current_user.id, {:count => 100})
	print "@", current_user.screen_name, "のツイート"
else
	timeline = Twitter.home_timeline({:count => 100})
	print "@", client_user.screen_name, "のタイムライン"
end

i = 1
print '</h1><dl class="tweets">'

timeline.each do |data|
	#dc = data.source.match(/<a .+>(.*)<\/a>/)
	print '<dt>', i, '  : '
	print '<a href="https://twitter.com/', data.user.screen_name, '" target="_blank">'
	print '<img src="', data.user.profile_image_url, '" alt="profimg" width="24px" height="24px">'
	print '</a>'
	print '<font color="green"><b>', data.user.name, '</b></font> '
	print '[<a href="https://twitter.com/', data.user.screen_name
	print '/status/', data.id, '" target="_blank">status</a>] : '
    print data.created_at, ' By ', data.source, '<dd>'
	print string_to_link(data.text), "<BR><BR>\n"
	#print data.text, "<BR>&nbsp;&lt;at ", data.created_at, ' by ', dc[1], "&gt;<BR><BR>"
	i = i + 1
end	
print "</dl>\n"
nextstat = timeline.pop.id

=begin

auth = Twitter::HTTPAuth.new(USERNAME)
client = Twitter::Base.new(auth)

client.friends_timeline.each do |s|
	puts s.text, s.user.name
end
=end

print <<EOF;
<a href="javascript:history.back();">Back</a>
<a href="twiplain.rb?next=#{nextstat}">Next</a>
<hr style="background-color:#888;color:#888;border-width:0;height:1px;position:relative;top:-.4em;">
<div align="right"><a href="https://twitter.com/deko2369/" target="_blank">Developed by @deko2369</a></div>
</body>
</html>
EOF
#{Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"}
