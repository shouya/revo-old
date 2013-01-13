

module Revo
  class Scanner
    rule(/\s+/) { :PASS }
    rule(/\r\n|\r|\n/) { increase_line_number; :PASS }

    symbol_rule(';') { @state = :COMMENT; :PASS }
    rule(/\r\n|\r|\n/, :COMMENT) { increase_line_number; @state = nil; :PASS }
    rule(/./, :COMMENT) { :PASS }

    symbol_rule('(')  { [:LBRACKET, nil]  }
    symbol_rule(')')  { [:RBRACKET, nil]  }
    symbol_rule(',@') { [:COMMA_AT, nil]  }
    symbol_rule(',')  { [:COMMA, nil]     }
    symbol_rule("'")  { [:QUOTE, nil]     }
    symbol_rule('&')  { [:AMPERSAND, nil] }
    symbol_rule('`')  { [:BACKQUOTE, nil] }
    symbol_rule('.')  { [:PERIOD, nil]    }


    rule(/\d+\.\d*/) { [:FLOAT, parse_float(@match)] }
    rule(/\d+/)      { [:INTEGER, parse_int(@match)] }

    symbol_rule('"')         { @state = :DSTR; @buffer[:str] = ''; :PASS }
    symbol_rule('\"', :DSTR) { @buffer[:str] << '"'; :PASS }
    symbol_rule('"', :DSTR)  { @state = nil; [:STRING, @buffer.delete(:str)] }
#    symbol_rule('\0[xX]\d+') {  }
    rule(/./, :DSTR)         { @buffer[:str] << @match; :PASS }

    rule(/[\w_\-\@\?\$\%\^\*\+\/\~]+/)   { [:NAME, @match] }
    rule(/\:[\w_\-\@\?\$\%\^\*\+\/\~]+/) { [:SYMBOL, @match] }

  end
end
