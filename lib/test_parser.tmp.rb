# -*- ruby -*-
#

require 'ap'
require_relative 'scanner'
require_relative 'parser.tab'

include Revo

scanner = Scanner.new
scanner.scan_string(DATA.read)
# ap scanner.to_a
parser = Parser.new(scanner)
ap parser.do_parse

__END__
(+ 1 2 (+ 2 3))


