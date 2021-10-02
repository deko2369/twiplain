#!/usr/bin/ruby1.9.1
# encoding: utf-8

require 'cgi'
require 'cgi/session'
require 'yaml'
require 'oauth'
require 'pp'

cgi = CGI.new('html4')
session = CGI::Session.new(cgi, {"new_session" => true})

conf = YAML.load_file('config.yml')
consumer_key = conf['consumer_key']
consumer_secret = conf['consumer_secret']
#access_token = conf['access_token']
#access_token_secret = conf['access_token_secret']

# http://doruby.kbmj.com/daoka_tips/20100302/ruby_OAuth_
consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => "https://twitter.com", :scheme => :header)
request_token = consumer.get_request_token({:oauth_callback => "http://domain/twiplain/auth.rb"}, {})

source = <<EOF;
<html>
<head>
<title>Twiplain - twitter client like a 2ch</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<div align="center">
<h1>Twiplain(仮)</h1>
<a href="#{request_token.authorize_url}">Twitter を使ってログイン</a>
</div>
<h2>とくちょう</h2>
<ul>
<li>(2ch|したらば)っぽいTwitterクライアント</li>
<li>タイムラインがだいたい読める</li>
<li>公式より軽いHTML</li>
<li>公式より読み込みが重い</li>
<li>つぶやけない</li>
<li>なんというか未完成</li>
</ul>
以上の点を我慢できる人だけお使いください。
</body>
</html>
EOF

cgi.out { source }

session["request_token"] = request_token.token
session["request_token_secret"] = request_token.secret
