require 'mongrel'
require 'json'
require 'relation'

def run
  server = Mongrel::HttpServer.new '0.0.0.0', '3000'

  server.register '/', RootHandler.new
  server.register '/bcnf', BCNFDecomposer.new
  server.register '/closure', ClosureGenerator.new

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

      relation = Relation.new attributes, fds
      decomposition = relation.bcnf_decomposition

      response.start 200 do |head, out|
        output = File.read 'html/bcnf.html'
        output.sub! '%%%Relation%%%', relation.to_s
        output.sub! '%%%BCNF%%%', decomposition.map(&:to_s).join("\n")
        output.sub! '%%%attributes%%%', params['attributes']
        output.sub! '%%%functional_dependencies%%%', params['functional_dependencies']
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
        output.sub! '%%%Set%%%', set.to_s
        output.sub! '%%%Closure%%%', closure.to_s
        output.sub! '%%%functional_dependencies%%%', params['functional_dependencies']
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
  str.gsub! /'([^'"]*)'/, '"\1"'
  str = "[#{str}" unless str.chars.first == '['
  str += ']' unless str.chars.entries.last == ']'
  raise unless str.match /^\s*\[\s*"[^"]*"(\s*,\s*"[^"]*")*\s*\]\s*$/
  JSON.parse str
end

def parse_functional_dependencies str
  str.gsub! /(\[[^\]]*\])\s*=>\s*(\[[^\]]*\])/, '[\1, \2]'
  str.gsub! /\['([^'"]*)'\]/, '["\1"]'
  str.sub! /^\{/, '['
  str.sub! /\}$/, ']'
  raise unless str.match /^\s*\[\s*\[\s*"[^"]*"\s*\](\s*,\s*\[\s*"[^"]*"\s*\])*\s*\](\s*,\s*\[\s*\[\s*"[^"]*"\s*\](\s*,\s*\[\s*"[^"]*"\s*\])*\s*\])*\s*$/
  JSON.parse str
end

run
