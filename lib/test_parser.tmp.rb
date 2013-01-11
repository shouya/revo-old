# -*- ruby -*-
#

require 'ap'
require_relative 'scanner'
require_relative 'parser.tab'

include Revo

scanner = Scanner.new
scanner.scan_string(DATA.read)
#ap scanner.to_a
parser = Parser.new(scanner)
puts parser.do_parse.to_s

__END__
; (+ 1 2 (+ 2 3 '() ))
(3 . (1 . 2))


