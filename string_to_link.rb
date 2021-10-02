require 'cgi'

def string_to_link(html_string)
	html_string = html_string.gsub(/\r\n|\r|\n/, "<BR>")
	if html_string.match(/http/) then
		html_string = html_string.gsub(
			/(http[s]?\:\/\/[\w\+\$\;\?\.\%\,\!\#\~\*\/\:\@\&\\\=\_\-]+)/,
			'<a href="\1" target="_blank">\1</a>')
	end
	html_string.gsub(/@(\w+)/, '<a href="twiplain.rb?u=\1">@\1</a>')
end
