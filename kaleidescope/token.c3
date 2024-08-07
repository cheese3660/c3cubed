module kaleidescope;
import std::io;
import std::collections::list;
import std::ascii;

enum TokenType {
    UNKNOWN,
    DEFINE,
    EXTERN,
    IF,
    THEN,
    ELSE,
    FOR,
    IN,
    UNARY,
    BINARY,
    VAR,
    IDENTIFIER,
    NUMBER,

    EOF
}

struct Token {
    TokenType type;
    String view;
}

const char EOF = 255;

fn char Token.operator(&self) {
    if (self.view.len == 1) return self.view[0];
    return EOF;
}

fn void Token.dump(&self) {
    switch (self.type) {
        case UNKNOWN:
            io::printf("unknown('%s')",self.view);
        case DEFINE:
            io::print("def");
        case EXTERN:
            io::print("extern");
        case IF:
            io::print("if");
        case THEN:
            io::print("then");
        case ELSE:
            io::print("else");
        case FOR:
            io::print("for");
        case IN:
            io::print("in");
        case UNARY:
            io::print("unary");
        case BINARY:
            io::print("binary");
        case VAR:
            io::print("var");
        case IDENTIFIER:
            io::printf("ident(%s)",self.view);
        case NUMBER:
            io::printf("number(%s)",self.view);
        case EOF:
            io::printf("EOF",self.view);
    }
}

struct Tokenizer {
    String stream;
    usz index;
    char lastchar;
}


fn void Tokenizer.init(&self, String stream) {
    self.stream = stream;
    self.index = 0;
}


fn void Tokenizer.next(&self) {
    if (self.index < self.stream.len) {
        self.index++;
    }
}

fn char Tokenizer.peek(&self, usz offset=0) {
    if (self.index+offset >= self.stream.len) {
        return EOF;
    } else {
        return self.stream[self.index+offset];
    }
}

fn void Tokenizer.skip_whitespace_or_comment(&self) {
    while (self.peek().is_space()) {
        self.next();
    }
    while (self.peek() == '#') {
        do {
            self.next();
        } while (self.peek() != EOF && self.peek() != '\r' && self.peek() != '\n');
        while (self.peek().is_space()) {
            self.next();
        }
    }
}

fn Token Tokenizer.get_tok(&self) {
    self.skip_whitespace_or_comment();
    usz start = self.index;
    char peek = self.peek();
    if (peek == EOF) {
        return {
            .type = EOF,
            .view = ""
        };
    } else if (peek.is_alpha()) {
        do {
            self.next();
            peek = self.peek();
        } while (peek.is_alnum());
        String view = self.stream[start..self.index-1];
        TokenType type;
        switch (view) {
            case "def":
                type = DEFINE;
            case "extern":
                type = EXTERN;
            case "if":
                type = IF;
            case "then":
                type = THEN;
            case "else":
                type = ELSE;
            case "in":
                type = IN;
            case "for":
                type = FOR;
            case "unary":
                type = UNARY;
            case "binary":
                type = BINARY;
            case "var":
                type = VAR;
            default:
                type = IDENTIFIER;
        }
        return {
            .type = type,
            .view = view
        };
    } else if (peek.is_digit()) {
        do {
            self.next();
            peek = self.peek();
        } while (peek.is_digit() || peek == '.');
        String view = self.stream[start..self.index-1];
        return {
            .type = NUMBER,
            .view = view
        };
    } else {
        self.next();
        String view = self.stream[start..self.index-1];
        return {
            .type = UNKNOWN,
            .view = view
        };
    }
}