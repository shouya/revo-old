

module Revo
  class Scanner
    rule(/[ \t]+/) { :PASS }
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
    rule(/\#[tT]/)   { [:BOOLEAN, true] }
    rule(/\#[fF]/)   { [:BOOLEAN, false] }

    symbol_rule('"')         { @state = :DSTR; @buffer[:str] = ''; :PASS }
    symbol_rule('\"', :DSTR) { @buffer[:str] << '"'; :PASS }
    symbol_rule('"', :DSTR)  { @state = nil; [:STRING, @buffer.delete(:str)] }
#    symbol_rule('\0[xX]\d+') {  }
    rule(/./, :DSTR)         { @buffer[:str] << @match; :PASS }

    rule(/[\w_\-\@\?\$\%\^\*\+\/\~\=\<\>\!]+/) { [:SYMBOL, @match] }

  end
end
