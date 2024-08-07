module kaleidescope;
import std::io;
import std::collections::list;
import std::ascii;

def NodeList = List(<AstNode*>);
def StringList = List(<String>);

enum NodeType {
    SEQUENCE,
    VARIABLE,
    NUMBER,
    BINARY_EXPRESSION,
    UNARY_EXPRESSION,
    CALL,
    PROTOYPE,
    FUNCTION,
    IF_THEN_ELSE,
    FOR_IN,
    VAR_IN,
}


struct BinaryExpression {
    char operator;
    AstNode* lhs;
    AstNode* rhs;
}

struct UnaryExpression {
    char operator;
    AstNode* value;
}

struct CallExpression {
    String callee;
    NodeList arguments;
}

struct PrototypeExpression {
    String name;
    StringList arguments;
    bool is_operator; // If this is the case, then the operator is the first character and the function gets a separate name
}

struct FunctionExpression {
    PrototypeExpression prototype;
    AstNode* body;
}

struct IfThenElse {
    AstNode* condition;
    AstNode* on_true;
    AstNode* on_false;
}

struct ForIn {
    String name;
    AstNode* initializer;
    AstNode* condition;
    AstNode* step;
    AstNode* in;
}

struct VarIn {
    StringList names;
    NodeList initializers; // if any of these are null, it is then treated as a zero
    AstNode* in;   
}

struct AstNode {
    NodeType type;

    union {
        NodeList sequence;
        String variable;
        double number;
        BinaryExpression binary;
        CallExpression call;
        PrototypeExpression prototype;
        FunctionExpression function;
        IfThenElse if_then_else;
        ForIn for_in;
        UnaryExpression unary;
        VarIn var_in;
    }
}

// TODO: better error handling

fn void AstNode.free(&self) {
    if (!self) return;
    switch (self.type) {
        case SEQUENCE:
            foreach (AstNode* node : self.sequence) {
                node.free();
            }
            self.sequence.free();
        case BINARY_EXPRESSION:
            free(self.binary.lhs);
            free(self.binary.rhs);
        case UNARY_EXPRESSION:
            free(self.unary.value);
        case CALL:
            foreach (AstNode* node : self.call.arguments) {
                node.free();
            }
            self.call.arguments.free();
        case FUNCTION:
            self.function.prototype.arguments.free();
            self.function.body.free();
        case PROTOYPE:
            self.prototype.arguments.free();
        case IF_THEN_ELSE:
            self.if_then_else.condition.free();
            self.if_then_else.on_true.free();
            self.if_then_else.on_false.free();
        case FOR_IN:
            self.for_in.initializer.free();
            self.for_in.condition.free();
            self.for_in.step.free();
            self.for_in.in.free();
        case VAR_IN:
            self.var_in.names.free();
            foreach (AstNode* node : self.var_in.initializers) {
                node.free();
            }
            self.var_in.in.free();
        default:
            break;
    }
    free(self);
}

fn void print_indent(int indentation) {
    for (int i = 0; i < indentation; i++) {
        io::print("    ");
    }
}

fn void AstNode.dump(&self, int indentation=1) {
    bool loop_started = false;
    switch (self.type) {
        case SEQUENCE:
            foreach (AstNode* node : self.sequence) {
                node.dump(indentation);
                io::printn("");
            }
        case VARIABLE:
            io::printn(self.variable);
        case NUMBER:
            io::printf("%f\n", self.number);
        case BINARY_EXPRESSION:
            io::printf("%c\n", self.binary.operator);
            print_indent(indentation);
            io::print("-> ");
            self.binary.lhs.dump(indentation+1);
            print_indent(indentation);
            io::print("-> ");
            self.binary.rhs.dump(indentation+1);
        case UNARY_EXPRESSION:
            io::printf("%c\n", self.unary.operator);
            print_indent(indentation);
            io::print("-> ");
            self.unary.value.dump(indentation+1);
        case CALL:
            io::printf("%s()\n", self.call.callee);
            foreach (AstNode* arg : self.call.arguments) {
                print_indent(indentation);
                io::print("-> ");
                arg.dump(indentation+1);
            }
        case PROTOYPE:
            io::printf("extern %s(", self.prototype.name);
            foreach (String arg : self.prototype.arguments) {
                if (loop_started) {
                    io::print(", ");
                }
                io::print(arg);
            }
            io::printn(")\n");
        case FUNCTION:
            io::printf("function %s(", self.function.prototype.name);
            foreach (String arg : self.function.prototype.arguments) {
                if (loop_started) {
                    io::print(", ");
                }
                io::print(arg);
            }
            io::printn(")");
            print_indent(indentation);
            io::print("-> ");
            self.function.body.dump(indentation+1);
        case IF_THEN_ELSE:
            io::printn("if-then-else");
            print_indent(indentation);
            io::print("-> ");
            self.if_then_else.condition.dump(indentation+1);
            print_indent(indentation);
            io::print("-> ");
            self.if_then_else.on_true.dump(indentation+1);
            print_indent(indentation);
            io::print("-> ");
            self.if_then_else.on_false.dump(indentation+1);
        case FOR_IN:
            io::printf("for %s in\n",self.for_in.name);
            print_indent(indentation);
            io::print("-> ");
            self.for_in.initializer.dump(indentation+1);
            print_indent(indentation);
            io::print("-> ");
            self.for_in.condition.dump(indentation+1);
            print_indent(indentation);
            io::print("-> ");
            if (self.for_in.step) {
                self.for_in.step.dump(indentation+1);
            } else {
                io::printn("1.0");
            }
            print_indent(indentation);
            io::print("-> ");
            self.for_in.in.dump(indentation+1);
        case VAR_IN:
            io::printf("var-in\n");
            for (usz i = 0; i < self.var_in.names.len(); i++) {
                print_indent(indentation);
                io::print(self.var_in.names[i]);
                io::print(" -> ");
                if (self.var_in.initializers[i]) {
                    self.var_in.initializers[i].dump(indentation+1);
                } else {
                    io::printn("0.0");
                }
            }
            print_indent(indentation);
            io::print("-> ");
            self.var_in.in.dump(indentation+1);
    }
}


struct Parser {
    Tokenizer tokenizer;
    Token last_token;
    char[256] operators;
    bool[256] unary;
}

fn void Parser.init(&self, Tokenizer t) {
    self.tokenizer = t;
    self.last_token = self.tokenizer.get_tok();
    self.operators[':'] = 1;
    self.operators['='] = 2;
    self.operators['<'] = 10;
    self.operators['>'] = 10;
    self.operators['+'] = 20;
    self.operators['-'] = 30;
    self.operators['*'] = 40;
    self.operators['/'] = 50;
    self.operators['%'] = 60;

}

fn Token Parser.peek(&self) {
    return self.last_token;
}

fn void Parser.advance(&self) {
    self.last_token = self.tokenizer.get_tok();
}


fault ParserFault {
    UNEXPECTED_TOKEN,
    MISSING_SEMICOLON
}

fn AstNode*! Parser.parse(&self) {
    AstNode* node = mem::new(AstNode, {
        .type = SEQUENCE,
        .sequence = {}
    });
    while (self.peek().type != EOF) {
        node.sequence.push(self.parse_statement()!);
    }
    return node;
}

fn AstNode*! Parser.parse_statement(&self) {
    Token peek = self.peek();
    AstNode* statement;
    switch (peek.type) {
        case DEFINE:
            statement = self.parse_definition()!;
        case EXTERN:
            statement = self.parse_extern()!;
        default:
            statement =  self.parse_expr()!;
    }
    if (self.peek().operator() != ';') {
        io::printf("expected semicolon after statement, not %s", self.peek().view);
        return ParserFault.MISSING_SEMICOLON?;
    }
    self.advance();
    return statement;
}

fn PrototypeExpression! Parser.parse_prototype(&self) {
    bool unary;
    bool binary;
    if (self.peek().type == UNARY) {
        unary = true;
        self.advance();
    }
    if (self.peek().type == BINARY) {
        binary = true;
        self.advance();
    }

    if (!(unary || binary) && self.peek().type != IDENTIFIER) {
        io::printf("unexpected token %s, expected identifier\n",self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    String name = self.peek().view;
    self.advance();
    if (unary) {
        self.unary[name[0]] = true;
    }
    if (binary) {
        if (self.peek().type != NUMBER) {
            io::printf("unexpected token %s, expected operator precedence", self.peek().view);
            return ParserFault.UNEXPECTED_TOKEN?;
        }
        self.operators[name[0]] = self.peek().view.to_uchar()!;
        self.advance();
    }
    if (self.peek().operator() != '(') {
        io::printf("unexpected token %s, expected '('\n",self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();
    StringList args;

    while (self.peek().type == IDENTIFIER) {
        args.push(self.peek().view);
        self.advance();
    }
    if (self.peek().operator() != ')') {
        io::printf("unexpected token %s, expected ')'\n",self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();

    return {
        .name = name,
        .arguments = args,
        .is_operator = binary || unary
    };
}

fn AstNode*! Parser.parse_definition(&self) {
    self.advance();
    PrototypeExpression prototype = self.parse_prototype()!;
    AstNode* body = self.parse_expr()!;
    return mem::new(
        AstNode,
        {
            .type = FUNCTION,
            .function = {
                .prototype = prototype,
                .body = body
            }
        }
    );
}

fn AstNode*! Parser.parse_extern(&self) {
    self.advance();
    PrototypeExpression prototype = self.parse_prototype()!;
    return mem::new(
        AstNode,
        {
            .type = PROTOYPE,
            .prototype = prototype
        }
    );
}

fn AstNode*! Parser.parse_primary(&self) {
    Token peek = self.peek();
    switch (peek.type) {
        case NUMBER:
            self.advance();
            return self.parse_number(peek.view);
        case IDENTIFIER:
            return self.parse_identifier_expr();
        case IF:
            return self.parse_if_then_else();
        case FOR:
            return self.parse_for_in();
        case VAR:
            return self.parse_var_in();
        case UNKNOWN:
            if (peek.operator() == '(') {
                return self.parse_paren_expression();
            } else if (self.unary[peek.operator()]) {
                self.advance();
                AstNode* value = self.parse_primary()!;
                return mem::new(AstNode, {
                    .type = UNARY_EXPRESSION,
                    .unary = {
                        .operator = peek.operator(),
                        .value = value
                    }
                });
            }
            nextcase;
        default:
            io::printf("unexpected token %s when expecting expression\n", self.peek().view);
            return ParserFault.UNEXPECTED_TOKEN?;
    }
}

fn AstNode*! Parser.parse_var_in(&self) {
    self.advance();
    StringList names;
    NodeList initializers;
    while (true) {
        AstNode* initializer = null;
        if (self.peek().type != IDENTIFIER) {
            io::printf("unexpected token %s when expecting identifier\n", self.peek().view);
            return ParserFault.UNEXPECTED_TOKEN?;
        }
        String name = self.peek().view;
        self.advance();
        if (self.peek().operator() == '=') {
            self.advance();
            initializer = self.parse_expr()!;
        }
        if (self.peek().type == IN) {
            self.advance();
            break;
        } else if (self.peek().operator() != ',') {
            io::printf("unexpected token %s when expecting 'in' or ','\n", self.peek().view);
            return ParserFault.UNEXPECTED_TOKEN?;
        }
        self.advance();
        names.push(name);
        initializers.push(initializer);
    }
    AstNode* in = self.parse_expr()!;
    return mem::new(AstNode, {
        .type = VAR_IN,
        .var_in = {
            .names = names,
            .initializers = initializers,
            .in = in,
        }
    });
}

fn AstNode*! Parser.parse_for_in(&self) {
    self.advance();
    if (self.peek().type != IDENTIFIER) {
        io::printf("unexpected token %s when expecting identifier\n", self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    String name = self.peek().view;
    self.advance();
    
    if (self.peek().operator() != '=') {
        io::printf("unexpected token '%s' when expecting '='\n", self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();
    AstNode* initializer = self.parse_expr()!;

    if (self.peek().operator() != ',') {
        io::printf("unexpected token '%s' when expecting ','", self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();
    AstNode* condition = self.parse_expr()!;

    AstNode* step = null;
    if (self.peek().operator() == ',') {
        self.advance();
        step = self.parse_expr()!;
    }

    if (self.peek().type != IN) {
        io::printf("unexpected token '%s' when expecting 'in'", self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();
    AstNode* in = self.parse_expr()!;
    return mem::new(AstNode, {
        .type = FOR_IN,
        .for_in = {
            .name = name,
            .initializer = initializer,
            .condition = condition,
            .step = step,
            .in = in
        }
    });
}

fn AstNode*! Parser.parse_if_then_else(&self) {
    self.advance();
    AstNode* condition = self.parse_expr()!;
    if (self.peek().type != THEN) {
        io::printf("unexpected token %s when expecting 'then'\n", self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();
    AstNode* on_true = self.parse_expr()!;
    if (self.peek().type != ELSE) {
        io::printf("unexpected token %s when expecting 'else'\n", self.peek().view);
    }
    self.advance();
    AstNode* on_false = self.parse_expr()!;
    return mem::new(AstNode, {
        .type = IF_THEN_ELSE,
        .if_then_else = {
            .condition = condition,
            .on_true = on_true,
            .on_false = on_false
        }
    });
}

fn AstNode*! Parser.parse_number(&self, String view) {
    AstNode* node = mem::new(AstNode, {
        .type = NUMBER,
        .number = view.to_double()!
    });
    return node;
}

fn AstNode*! Parser.parse_paren_expression(&self) {
    self.advance();
    AstNode*! result = self.parse_expr();
    if (self.peek().type != UNKNOWN || self.peek().operator() != ')') {
        io::printf("unexpected token %s when expecting ')'\n", self.peek().view);
        return ParserFault.UNEXPECTED_TOKEN?;
    }
    self.advance();
    return result;
}

fn AstNode*! Parser.parse_identifier_expr(&self) {
    String ident = self.peek().view;
    self.advance();
    if (self.peek().operator() != '(') {
        return mem::new(AstNode, {
            .type = VARIABLE,
            .variable = ident
        });
    }
    self.advance();
    NodeList args;
    if (self.peek().operator() != ')') {
        while (true) {
            AstNode* arg = self.parse_expr()!;
            args.push(arg);
            if (self.peek().operator() == ')') {
                break;
            } else if (self.peek().operator() != ',') {
                io::printf("unexpected token %s when expecting ')' or ','\n", self.peek().view);
                return ParserFault.UNEXPECTED_TOKEN?;
            }
            self.advance();
        }
    }
    self.advance();
    return mem::new(AstNode, {
        .type = CALL,
        .call = {
            .callee = ident,
            .arguments = args
        }
    });
}

fn AstNode*! Parser.parse_expr(&self) {
    AstNode* primary = self.parse_primary()!;
    return self.parse_binop_rhs(primary);
}

fn AstNode*! Parser.parse_binop_rhs(&self, AstNode* lhs, char expr_precedence=1) {
    while (true) {
        char operator = self.peek().operator();
        char precedence = self.operators[operator];
        if (precedence < expr_precedence) {
            return lhs;
        }
        self.advance();
        AstNode* rhs = self.parse_primary()!;
        char next_operator = self.peek().operator();
        char next_precedence = self.operators[next_operator];
        if (precedence < next_precedence) {
            rhs = self.parse_binop_rhs(rhs,precedence+1)!;
        }
        lhs = mem::new(AstNode, {
            .type = BINARY_EXPRESSION,
            .binary = {
                .operator = operator,
                .lhs = lhs,
                .rhs = rhs
            }
        });
    }
}