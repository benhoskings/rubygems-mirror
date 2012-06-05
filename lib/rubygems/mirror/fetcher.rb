require 'net/http/persistent'
require 'time'

class Gem::Mirror::Fetcher
  # TODO  beef
  class Error < StandardError; end

  def initialize
    @http = Net::HTTP::Persistent.new(self.class.name, :ENV)
    $stderr.sync = true
  end

  # Fetch a source path under the base uri, and put it in the same or given
  # destination path under the base path.
  def fetch(uri, path)
    modified_time = File.exists?(path) && File.stat(path).mtime.rfc822

    req = Net::HTTP::Get.new URI.parse(uri).path
    req.add_field 'If-Modified-Since', modified_time if modified_time

    @http.request URI(uri), req do |resp|
      return handle_response(resp, path)
    end
  end

  # Handle an http response, follow redirects, etc. returns true if a file was
  # downloaded, false if a 304. Raise Error on unknown responses.
  def handle_response(resp, path)
    case resp.code.to_i
    when 304
      print '~'
    when 302
      print '>'
      fetch resp['location'], path
    when 200
      print '.'
      write_file(resp, path)
    when 403, 404
      warn "#{resp.code} on #{File.basename(path)}"
    else
      raise Error, "unexpected response #{resp.inspect}"
    end
    # TODO rescue http errors and reraise cleanly
  end

  # Efficiently and atomically writes an http response object to a particular path.
  def write_file(resp, path)
    FileUtils.mkdir_p File.dirname(path)
    # Download to a temporary file...
    File.open(tmp_path_for(path), 'wb') do |output|
      resp.read_body { |chunk| output << chunk }
    end
    # ... and atomically move it into place when it succeeds.
    FileUtils.mv tmp_path_for(path), path
    true
  rescue StandardError
    # Delete (likely incomplete) temporary files on error.
    File.delete(tmp_path_for(path))
  end

  def tmp_path_for path
    File.join File.dirname(path), ".#{File.basename(path)}.tmp"
  end

end
