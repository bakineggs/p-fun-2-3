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
      out.write File.read('html/index.html')
    end
  end
end

class BCNFDecomposer < Mongrel::HttpHandler
  def process request, response
    begin
      attributes = JSON.parse request.params['attributes']
      fds = parse_functional_dependencies request.params['functional_dependencies']

      relation = Relation.new attributes, fds
      decomposition = relation.bcnf_decomposition

      response.start 200 do |head, out|
        output = File.read 'html/bcnf.html'
        output.sub! '%%%Relation%%%', relation.to_s
        output.sub! '%%%BCNF%%%', decomposition.map(&:to_s).join("\n")
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
      fds = parse_functional_dependencies request.params['functional_dependencies']

      set = FunctionalDependencySet.new fds
      closure = set.closure

      response.start 200 do |head, out|
        output = File.read 'html/closure.html'
        output.sub! '%%%Set%%%', set.to_s
        output.sub! '%%%Closure%%%', closure.to_s
        out.write output
      end
    rescue
      response.start 400 do |head, out|
        out.write File.read('html/bad_request.html')
      end
    end
  end
end

def parse_functional_dependencies str
  str.gsub! /(\[[^\]]*\])=>(\[[^\]]*\])/, '[\1, \2]'
  str.sub! /^\{/, '['
  str.sub! /\}$/, ']'
end

run
