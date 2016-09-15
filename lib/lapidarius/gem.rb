require "lapidarius/env"

module Lapidarius
  class Gem
    class KindError < ArgumentError; end

    def self.factory(name)
      name.match(/Gem ([a-z0-9\-_]+)-(\d{1,2}\.\d{1,3}\.\d{1,2})/) do |m|
        return new(name: m[1], version: m[2])
      end
      name.match(/([a-z0-9\-_]+) \(([0-9~<>,= \.]+)(?:, (#{Env::DEVELOPMENT}))?\)/) do |m|
        return new(name: m[1], version: m[2], env: m[3] || Env::RUNTIME)
      end
    end

    attr_reader :name, :version, :env

    def initialize(name:, version:, env: Env::RUNTIME, deps: [])
      @name = name
      @version = version
      @env = env.to_sym
      @deps = deps
    end

    def deps(env = :all)
      return @deps.clone if env == :all
      @deps.select { |dep| dep.env == env }
    end

    def <<(dep)
      fail KindError, "#{dep.inspect} is not a valid gem" unless gem?(dep)
      @deps << dep
    end

    def ==(gem)
      return false unless gem?(gem)
      gem.name == name && gem.version == version && gem.env == env
    end

    def to_s
      "#{name} (#{version})"
    end

    def runtime?
      @env == Env::RUNTIME
    end

    def development?
      @env == Env::DEVELOPMENT
    end

    private def gem?(gem)
      %i{name version env deps}.all? { |msg| gem.respond_to?(msg) }
    end
  end
end
