# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/warning/all/warning.rbi
#
# warning-1.2.1

module Warning
  extend Warning::Processor
end
module Warning::Processor
  def clear; end
  def convert_regexp(regexp); end
  def dedup; end
  def freeze; end
  def ignore(regexp, path = nil); end
  def process(path = nil, actions = nil, &block); end
  def synchronize(&block); end
  def warn(str); end
end
