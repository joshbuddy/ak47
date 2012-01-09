require 'guard'
require 'shell_tools'
require "smart_colored/extend"
require 'optparse'

require "ak47/version"
require "ak47/runner"
require 'ak47/cli'

module Ak47
  Reload = Class.new(RuntimeError)
end

def Ak47(opts = nil, &blk)
  Ak47::Runner.new(opts, &blk).start
end