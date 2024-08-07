module kaleidescope;
import c3cubed;
import std::collections::map;
import std::io;

// This just provides a map of function aritys
def ArityMap = HashMap(<String, usz>);
def IdentifierMap = HashMap(<String, Identifier>);
def OpMap = HashMap(<char, Identifier>);

struct Context {
    Module mod;
    ArityMap method_arity;
    OpMap binary_operators;
    OpMap unary_operators;
    IdentifierMap method_identifiers;
    Function* main;
}

fn void Context.init(&self) {
    self.setup_prologue();
    self.setup_methods();
    self.setup_main();
}

fn void create_putc(Module* mod) {
    Function* putc = mod.register_function("_putc");
    Identifier putchar = mod.import_ident("putchar");
    putc.set_return_type(c3cubed::TYPE_DOUBLE);
    Identifier ch = putc.add_parameter(c3cubed::TYPE_DOUBLE, "char");
    putc.begin_and_add_block();
    Identifier converted = putc.current_block.convert(c3cubed::TYPE_DOUBLE, ch, c3cubed::TYPE_UBYTE);
    putc.current_block.call_void(putchar, c3cubed::TYPE_UBYTE, converted);
    putc.current_block.ret((double)0.0);
}

fn void create_print_and_printn(Module* mod) {
    Function* print = mod.register_function("_print");
    print.set_return_type(c3cubed::TYPE_DOUBLE);
    Identifier input = print.add_parameter(c3cubed::TYPE_DOUBLE, "to_print");
    Function* printn = mod.register_function("_printn");
    printn.add_parameter(c3cubed::TYPE_DOUBLE, "to_print");
    printn.set_return_type(c3cubed::TYPE_DOUBLE);
    Data* print_format = mod.register_data("_print_format");
    print_format.add_string("%lf");
    Data* printn_format = mod.register_data("_printn_format");
    printn_format.add_string("%lf\n");
    Identifier printf = mod.import_ident("printf");
    Block* print_b = print.begin_and_add_block();
    Block* printn_b = printn.begin_and_add_block();
    CallList c1 = print_b.create_call_list();
    CallList c2 = printn_b.create_call_list();
    c1.arg(c3cubed::TYPE_LONG, print_format);
    c2.arg(c3cubed::TYPE_LONG, printn_format);
    c1.var_args();
    c2.var_args();
    c1.arg(c3cubed::TYPE_DOUBLE, input);
    c2.arg(c3cubed::TYPE_DOUBLE, input);
    print_b.call(printf,c1);
    printn_b.call(printf,c2);
    print_b.ret((double)0.0);
    printn_b.ret((double)0.0);
}

const ulong GET_BUFFER_SIZE = 256; 

fn void create_get(Module* mod) {
    Function* get = mod.register_function("_get");
    get.set_return_type(c3cubed::TYPE_DOUBLE);
    Identifier gets_s = mod.import_ident("gets");
    Identifier atof = mod.import_ident("atof");
    Block* get_b = get.begin_and_add_block();
    Identifier buffer = get_b.allocate(4, GET_BUFFER_SIZE);
    Identifier str = get_b.call_typed(gets_s, c3cubed::TYPE_LONG, c3cubed::TYPE_LONG, buffer);
    Identifier result = get_b.call_typed(atof, c3cubed::TYPE_DOUBLE, c3cubed::TYPE_LONG, str);
    get_b.ret(result);
}

fn void Context.setup_prologue(&self) {
    self.mod.set_header("Compiled using the Kaleidescope example compiler for c3-cubed\nAny bugs should be reported to the maintainer");
    create_putc(&self.mod);
    create_print_and_printn(&self.mod);
    create_get(&self.mod);
}

fn void Context.setup_methods(&self) {
    // These are the standard library methods that are outputted in the prologue
    self.method_arity.set("putc",1);
    self.method_identifiers.set("putc",self.mod.import_ident("_putc"));
    self.method_arity.set("print",1);
    self.method_identifiers.set("print",self.mod.import_ident("_print"));
    self.method_arity.set("printn",1);
    self.method_identifiers.set("printn",self.mod.import_ident("_printn"));
    self.method_arity.set("get", 0);
    self.method_identifiers.set("get",self.mod.import_ident("_get"));
}

fn void Context.setup_main(&self) {
    Function* main = self.mod.register_function("main");
    main.add_linkage({.type = EXPORT});
    main.set_return_type(c3cubed::TYPE_WORD);
    main.begin_and_add_block();
    self.main = main;
}

fn void Context.finalize(&self) {
    self.main.current_block.ret(0);
}

fault CodegenFault {
    UNKNOWN_OPERATOR,
    UNKNOWN_METHOD,
    INCORRECT_ARITY,
    ARITY_DOES_NOT_MATCH_PROTOTYPE,
    NOT_IMPLEMENTED,
    LHS_IS_NOT_NAME,
}

fn void! Context.add_tree(&self, AstNode* tree) {
    // This will add everything from a tree into the context
    foreach (AstNode* statement : tree.sequence) {
        self.add_statement(statement)!;
    }
}

fn void! Context.add_statement(&self, AstNode* statement) {
    switch (statement.type) {
        case PROTOYPE:
            self.compile_prototype(statement.prototype)!;
        case FUNCTION:
            self.compile_function(statement.function)!;
        default:
            self.compile_expression(statement, self.main)!;
    }
}

fn String get_operator_name(String kind, char c) {
    DString str;
    str.temp_init();
    str.appendf("_op_%s_%d", kind, c);
    return str.str_view();
}


fn void! Context.compile_prototype(&self, PrototypeExpression prototype) {
    if (prototype.is_operator) {
        @pool() {
            usz arity = prototype.arguments.len();
            if (arity == 1) {
                // unary
                self.unary_operators.set(prototype.name[0], self.mod.import_ident(get_operator_name("un",prototype.name[0])));
            } else {
                self.binary_operators.set(prototype.name[0],self.mod.import_ident(get_operator_name("bin",prototype.name[0])));
            }
        };
        return;
    }
    if (self.method_arity.has_key(prototype.name)) {
        if (self.method_arity.get(prototype.name)! != prototype.arguments.len()) {
            io::printf("Method arity for %s does not match prototype!\n", prototype.name);
            return CodegenFault.ARITY_DOES_NOT_MATCH_PROTOTYPE?;
        }
    }
    self.method_arity.set(prototype.name, prototype.arguments.len());
    self.method_identifiers.set(prototype.name, self.mod.import_ident(prototype.name));
}

fn void! Context.compile_function(&self, FunctionExpression expression) {
    Function* function;
    if (expression.prototype.is_operator) {
        PrototypeExpression prototype = expression.prototype;
        @pool() {
            usz arity = prototype.arguments.len();
            String name;
            if (arity == 1) {
                // unary
                name = get_operator_name("un",prototype.name[0]);
                self.unary_operators.set(prototype.name[0], self.mod.import_ident(name));
            } else {
                name = get_operator_name("bin",prototype.name[0]);
                self.binary_operators.set(prototype.name[0], self.mod.import_ident(name));
            }
            function = self.mod.register_function(name);
        };
    } else {
        if (self.method_arity.has_key(expression.prototype.name)) {
            if (self.method_arity.get(expression.prototype.name)! != expression.prototype.arguments.len()) {
                io::printf("Method arity for %s does not match prototype!\n", expression.prototype.name);
                return CodegenFault.ARITY_DOES_NOT_MATCH_PROTOTYPE?;
            }
        }
        self.method_arity.set(expression.prototype.name, expression.prototype.arguments.len());
        self.method_identifiers.set(expression.prototype.name, self.mod.import_ident(expression.prototype.name));
        function = self.mod.register_function(expression.prototype.name);
    }
    foreach (String parameter : expression.prototype.arguments) {
        function.add_parameter(c3cubed::TYPE_DOUBLE, parameter);
    }
    function.set_return_type(c3cubed::TYPE_DOUBLE);
    Block* start_block = function.begin_and_add_block();
    Value return_value = self.compile_expression(expression.body, function)!;
    function.current_block.ret(return_value);
}

fn Value! Context.compile_expression(&self, AstNode* tree, Function* function) {
    switch (tree.type) {
        case VARIABLE:
            return c3cubed::create_value(self.mod.import_ident(tree.variable,LOCAL));
        case NUMBER:
            return c3cubed::create_value(tree.number);
        case CALL:
            return self.compile_call(tree.call, function);
        case BINARY_EXPRESSION:
            return self.compile_binary_expression(tree.binary, function);
        case IF_THEN_ELSE:
            return self.compile_if_then_else(tree.if_then_else, function);
        case FOR_IN:
            return self.compile_for_in(tree.for_in, function);
        case UNARY_EXPRESSION:
            return self.compile_unary(tree.unary, function);
        case VAR_IN:
            return self.compile_var_in(tree.var_in, function);
        case SEQUENCE:
        case PROTOYPE:
        case FUNCTION:
            unreachable();
    }
}

fn Value! Context.compile_var_in(&self, VarIn var_in, Function* function) {
    for (int i = 0; i < var_in.names.len(); i++) {
        Identifier ident = self.mod.import_ident(var_in.names[i],LOCAL);
        Value to_store;
        if (var_in.initializers[i]) {
            to_store = self.compile_expression(var_in.initializers[i], function)!;
        } else {
            to_store = c3cubed::create_value((double)0.0);
        }
        function.current_block.copy(to_store,c3cubed::TYPE_DOUBLE,ident);
    }
    return self.compile_expression(var_in.in,function);
}

fn Value! Context.compile_unary(&self, UnaryExpression unary, Function* function) {
    if (!self.unary_operators.has_key(unary.operator)) {
        io::printf("Unknown operator %c\n", unary.operator);
        return CodegenFault.UNKNOWN_OPERATOR?;
    }
    Identifier method = self.unary_operators.get(unary.operator)!;
    Value value = self.compile_expression(unary.value, function)!;
    return c3cubed::create_value(function.current_block.call_typed(method,c3cubed::TYPE_DOUBLE,c3cubed::TYPE_DOUBLE, value));
}

fn Value! Context.compile_for_in(&self, ForIn for_in, Function* function) {
    Identifier symbol = self.mod.import_ident(for_in.name,LOCAL);
    Value init = self.compile_expression(for_in.initializer, function)!;
    function.current_block.copy(init, c3cubed::TYPE_DOUBLE, symbol);
    Block* start_block = function.current_block;
    Block* for_block = function.begin_block();
    Block* after_block = function.begin_block();
    start_block.jump(for_block);
    function.add_block(for_block);
    self.compile_expression(for_in.in, function)!;
    Value step = c3cubed::create_value((double)1.0);
    if (for_in.step) {
        step = self.compile_expression(for_in.step, function)!;
    }
    function.current_block.add(symbol,step,c3cubed::TYPE_DOUBLE, symbol);
    Value condition = self.compile_expression(for_in.condition, function)!;
    Identifier condition_compared = function.current_block.compare_inequality(c3cubed::TYPE_DOUBLE, condition, (double)0.0);
    function.current_block.conditional_jump(condition_compared, for_block, after_block);
    function.add_block(after_block);
    return c3cubed::create_value((double)0.0);
}

fn Value! Context.compile_if_then_else(&self, IfThenElse if_then_else, Function* function) {
    Value condition = self.compile_expression(if_then_else.condition, function)!;
    Identifier result = function.next_temporary();
    Identifier condition_compared = function.current_block.compare_inequality(c3cubed::TYPE_DOUBLE, condition, (double)0.0);
    Block* then = function.begin_block();
    Block* els = function.begin_block();
    Block* end = function.begin_block();
    function.current_block.conditional_jump(condition_compared, then, els);
    function.add_block(then);
    Value phi_true = self.compile_expression(if_then_else.on_true, function)!;
    then = function.current_block;
    function.add_block(els);
    Value phi_false = self.compile_expression(if_then_else.on_false, function)!;
    els = function.current_block;
    then.copy(phi_true,c3cubed::TYPE_DOUBLE,result);
    then.jump(end);
    els.copy(phi_false,c3cubed::TYPE_DOUBLE,result);
    els.jump(end);
    function.add_block(end);
    return c3cubed::create_value(result);
}

fn Value! Context.compile_call(&self, CallExpression call, Function* function) {
    if (!self.method_arity.has_key(call.callee)) {
        io::printf("Unknown method %s\n", call.callee);
        return CodegenFault.UNKNOWN_METHOD?;
    }
    usz arity = self.method_arity.get(call.callee)!;
    if (arity != call.arguments.len()) {
        io::printf("Incorrect arity in call to %s\n", call.callee);
        return CodegenFault.INCORRECT_ARITY?;
    }
    CallList clist = function.current_block.create_call_list();
    foreach (AstNode* argument : call.arguments) {
        clist.arg(c3cubed::TYPE_DOUBLE, self.compile_expression(argument,function)!);
    }
    return c3cubed::create_value(function.current_block.call(self.method_identifiers.get(call.callee)!, clist, c3cubed::TYPE_DOUBLE));
}

fn Value! Context.compile_binary_expression(&self, BinaryExpression expression, Function* function) {
    switch (expression.operator) {
        case '+':
        case '-':
        case '*':
        case '/':
        case '%':
            return self.compile_arithmetic_expression(expression, function);
        case '<':
        case '>':
            return self.compile_comparison_expression(expression, function);
        case '=':
            {
                // Assignment operator
                if (expression.lhs.type != VARIABLE) {
                    io::printf("LHS of assignment is not a name\n", expression.operator);
                    return CodegenFault.LHS_IS_NOT_NAME?;
                }
                Value rhs = self.compile_expression(expression.rhs, function)!;
                Identifier lhs = self.mod.import_ident(expression.lhs.variable,LOCAL);
                return c3cubed::create_value(function.current_block.copy(rhs,c3cubed::TYPE_DOUBLE,lhs));
            }
        case ':':
            {
                // Sequencing operator
                self.compile_expression(expression.lhs, function)!;
                Value rhs = self.compile_expression(expression.rhs, function)!;
                return rhs;
            }
        default:
            if (self.binary_operators.has_key(expression.operator)) {
                Identifier method = self.binary_operators.get(expression.operator)!;
                Value lhs = self.compile_expression(expression.lhs, function)!;
                Value rhs = self.compile_expression(expression.rhs, function)!;
                return c3cubed::create_value(function.current_block.call_typed(method, c3cubed::TYPE_DOUBLE, c3cubed::TYPE_DOUBLE, lhs, c3cubed::TYPE_DOUBLE, rhs));
            } else {
                io::printf("Unknown operator %c\n", expression.operator);
                return CodegenFault.UNKNOWN_OPERATOR?;
            }
    }
}

fn Value! Context.compile_arithmetic_expression(&self, BinaryExpression expression, Function* function) {
    InstructionType itype;
    switch (expression.operator) {
        case '+':
            itype = ADD;
        case '-':
            itype = SUBTRACT;
        case '*':
            itype = MULTIPLY;
        case '/':
            itype = DIVIDE;
        case '%':
            itype = REMAINDER;
        default:
            unreachable();
    }
    Value lhs = self.compile_expression(expression.lhs, function)!;
    Value rhs = self.compile_expression(expression.rhs, function)!;
    return c3cubed::create_value(function.current_block.create_three_address(itype, lhs, rhs, c3cubed::TYPE_DOUBLE));
}

fn Value! Context.compile_comparison_expression(&self, BinaryExpression expression, Function* function) {
    InstructionType itype;
    switch (expression.operator) {
        case '<':
            itype = COMPARE_LOWER_DOUBLE;
        case '>':
            itype = COMPARE_GREATER_DOUBLE;
        default:
            unreachable();
    }
    Value lhs = self.compile_expression(expression.lhs, function)!;
    Value rhs = self.compile_expression(expression.rhs, function)!;
    Identifier compared = function.current_block.create_three_address(itype, lhs, rhs, c3cubed::TYPE_WORD);
    return c3cubed::create_value(function.current_block.convert(c3cubed::TYPE_WORD, compared, c3cubed::TYPE_DOUBLE));
}

fn DString Context.output(&self) {
    return self.mod.write();
}


fn void Context.free(&self) {
    self.mod.free();
    self.method_arity.free();
    self.method_identifiers.free();
    self.binary_operators.free();
    self.unary_operators.free();
}