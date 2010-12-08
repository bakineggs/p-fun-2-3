require 'mongrel'
require 'json'
require 'cgi'
require 'relation'

def run
  server = Mongrel::HttpServer.new '0.0.0.0', '3000'

  server.register '/', RootHandler.new
  server.register '/bcnf', BCNFDecomposer.new
  server.register '/closure', ClosureGenerator.new
  server.register '/css', Mongrel::DirHandler.new('css')

  server.run.join
end

class RootHandler < Mongrel::HttpHandler
  def process request, response
    response.start 200 do |head, out|
      out.write File.read('html/root.html')
    end
  end
end

class BCNFDecomposer < Mongrel::HttpHandler
  def process request, response
    begin
      params = request.class.query_parse request.body.read

      attributes = parse_attributes params['attributes']
      fds = parse_functional_dependencies params['functional_dependencies']
      preserve_dependencies = params['preserve_dependencies'] == 'on'

      relation = Relation.new attributes, fds
      decomposition = relation.bcnf_decomposition preserve_dependencies

      response.start 200 do |head, out|
        output = File.read 'html/bcnf.html'
        output.sub! '%%%Relation%%%', CGI.escapeHTML(relation.to_s)
        output.sub! '%%%BCNF%%%', CGI.escapeHTML(decomposition.map(&:to_s).join("\n"))
        output.sub! '%%%attributes%%%', CGI.escapeHTML(params['attributes'])
        output.sub! '%%%functional_dependencies%%%', CGI.escapeHTML(params['functional_dependencies'])
        output.sub! '%%%preserve_dependencies%%%', preserve_dependencies ? 'checked="checked" ' : ''
        out.write output
      end
    rescue DependencyPreservationError
      response.start 200 do |head, out|
        output = File.read 'html/bcnf.html'
        output.sub! '%%%Relation%%%', CGI.escapeHTML(relation.to_s)
        output.sub! '%%%BCNF%%%', 'Could not decompose due to a dependency preservation error'
        output.sub! '%%%attributes%%%', CGI.escapeHTML(params['attributes'])
        output.sub! '%%%functional_dependencies%%%', CGI.escapeHTML(params['functional_dependencies'])
        output.sub! '%%%preserve_dependencies%%%', preserve_dependencies ? 'checked="checked" ' : ''
        out.write output
      end
    rescue
      response.start 400 do |head, out|
        out.write File.read('html/bad_request.html')
      end
    end
  end
end

class ClosureGenerator < Mongrel::HttpHandler
  def process request, response
    begin
      params = request.class.query_parse request.body.read

      fds = parse_functional_dependencies params['functional_dependencies']

      set = FunctionalDependencySet.new fds
      closure = set.closure

      response.start 200 do |head, out|
        output = File.read 'html/closure.html'
        output.sub! '%%%Set%%%', CGI.escapeHTML(set.to_s)
        output.sub! '%%%Closure%%%', CGI.escapeHTML(closure.to_s)
        output.sub! '%%%functional_dependencies%%%', CGI.escapeHTML(params['functional_dependencies'])
        out.write output
      end
    rescue
      response.start 400 do |head, out|
        out.write File.read('html/bad_request.html')
      end
    end
  end
end

def parse_attributes str
  str = str.clone
  str.gsub! /'([^'"]*)'/, '"\1"'
  str.gsub! /(^|,\s*)([^",]*)(\s*,|$)/, '\1"\2"\3'
  str.gsub! /(^|,\s*)([^",]*)(\s*,|$)/, '\1"\2"\3'
  str = "[#{str}" unless str.chars.first == '['
  str += ']' unless str.chars.entries.last == ']'
  raise unless str.match /^\s*\[\s*"[^"]*"(\s*,\s*"[^"]*")*\s*\]\s*$/
  JSON.parse str
end

def parse_functional_dependencies str
  str = str.clone
  str.gsub! /(\[[^\]]*\])\s*=>\s*(\[[^\]]*\])/, '[\1, \2]'
  str.gsub! /(\[|,)\s*'([^'"]*)'\s*(\]|,)/, '\1"\2"\3'
  str.gsub! /(\[|,)\s*'([^'"]*)'\s*(\]|,)/, '\1"\2"\3'
  str.sub! /^\s*\{/, '['
  str.sub! /\}\s*$/, ']'
  raise unless str.match /^\s*\[\s*\[\s*\[\s*"[^"]*"\s*(,\s*"[^"]*"\s*)*\]\s*,\s*\[\s*"[^"]*"\s*(,\s*"[^"]*"\s*)*\]\s*\]\s*(,\s*\[\s*\[\s*"[^"]*"\s*(,\s*"[^"]*"\s*)*\]\s*,\s*\[\s*"[^"]*"\s*(,\s*"[^"]*"\s*)*\]\s*\]\s*)*\]\s*$/
  JSON.parse str
end

run
