module brainfuckc;
import std::io;
import std::collections::list;
import std::collections::map;
import c3cubed;
const ulong CELL_COUNT = 0x10000;
const ulong STDIN_COUNT = 0x10000;
def FunctionMap = HashMap(<String, Function*>);

struct BrainfuckContext {
    Module mod;
    Data* cells;
    Data* cell_pointer;
    Function* read_next;
    Function* zero;
    Function* halt_if_not_zero;
    Function* find_zero_left;
    Function* find_zero_right;
    Identifier putchar;
    uint next_function_name;
    FunctionMap functions;
}

fn Function* BrainfuckContext.get_temporary_function(&self) {
    Function* result;
    @pool() {
        DString name;
        name.temp_init();
        name.appendf("bf_%d",self.next_function_name++);
        result = self.mod.register_function(name.str_view());
    };
    return result;
}

// Returns zero if it does not match, otherwise the amount of characters that is the implementation of the algorithm
fn usz brainfuck_starts_with(String view, String algorithm) {
    usz algorithm_ptr = 0;
    for (usz i = 0; i < view.len; i++) {
        char c = view[i];
        if (c == '+' || c == '-' || c == '<' || c == '>' || c == '[' || c == ']' || c == ',' || c == '.') {
            if (algorithm[algorithm_ptr] == c) {
                algorithm_ptr += 1;
                if (algorithm_ptr >= algorithm.len) {
                    return i+1;
                }
            } else {
                return 0;
            }
        }
    }
    return 0;
}

fn Function* BrainfuckContext.get_function(&self, String brainfuck, bool top_level = false) {
    if (self.functions.has_key(brainfuck)) {
        return self.functions.get(brainfuck)!!;
    }
    Function* method = self.get_temporary_function();
    method.begin_and_add_block();
    self.functions.set(brainfuck, method);
    bool collating_adds;
    bool collating_moves;
    bool next_is_comment = top_level;
    int add_sub_amount;
    for (usz i = 0; i < brainfuck.len; i++) {
        char c = brainfuck[i];
        if (collating_adds && (c == '<' || c == '>' || c == '[' || c == ']' || c == ',' || c == '.')) {
            if (add_sub_amount != 0) {
                Identifier current_ptr = method.current_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
                Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
                Identifier result;
                if (add_sub_amount > 0) {
                    result = method.current_block.add(current_cell, add_sub_amount, c3cubed::TYPE_WORD);
                } else {
                    result = method.current_block.subtract(current_cell, -add_sub_amount, c3cubed::TYPE_WORD);
                }
                method.current_block.store(c3cubed::TYPE_UBYTE, result, current_ptr);
                collating_adds = false;
            }
        }
        if (collating_moves && (c == '+' || c == '-' || c == '[' || c == ']' || c == ',' || c == '.')) {
            if (add_sub_amount != 0) {
                Identifier current_ptr = method.current_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
                Identifier result;
                if (add_sub_amount > 0) {
                    result = method.current_block.add(current_ptr, add_sub_amount, c3cubed::TYPE_LONG);
                } else {
                    result = method.current_block.subtract(current_ptr, -add_sub_amount, c3cubed::TYPE_LONG);
                }
                method.current_block.store(c3cubed::TYPE_LONG, result, self.cell_pointer);
                collating_moves = false;
            }
        }
        switch (c) {
            case '+':
                if (collating_adds) {
                    add_sub_amount += 1;
                } else {
                    collating_adds = true;
                    add_sub_amount = 1;
                }
            case '-':
                if (collating_adds) {
                    add_sub_amount -= 1;
                } else {
                    collating_adds = true;
                    add_sub_amount = -1;
                }
            case '.':
                {
                    Identifier current_ptr = method.current_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
                    Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
                    method.current_block.call_void(self.putchar, c3cubed::TYPE_UBYTE, current_cell);
                }
            case ',':
                {
                    Identifier current_ptr = method.current_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
                    Identifier current_input = method.current_block.call_typed(self.read_next, c3cubed::TYPE_UBYTE);
                    method.current_block.store(c3cubed::TYPE_UBYTE, current_input, current_ptr);
                }
            case '<':
                {
                    if (collating_moves) {
                        add_sub_amount -= 1;
                    } else {
                        collating_moves = true;
                        add_sub_amount = -1;
                    }
                }
            case '>':
                {
                    if (collating_moves) {
                        add_sub_amount += 1;
                    } else {
                        collating_moves = true;
                        add_sub_amount = 1;
                    }
                }
            case '[':
                {
                    // First we collect the body into one string
                    usz begin = i+1;
                    int expected = 1;
                    do {
                        i+=1;
                        if (brainfuck[i] == '[') expected += 1;
                        if (brainfuck[i] == ']') expected -= 1;
                    } while(i < brainfuck.len-1 && expected != 0);
                    usz end = i-1;
                    if (next_is_comment) {
                        continue;
                    }
                    if (end < begin) {
                        method.current_block.call_void(self.halt_if_not_zero);
                        next_is_comment = true;
                        continue;
                    }
                    String view = brainfuck[begin..end];
                    if (view == "-" || view == "+") {
                        method.current_block.call_void(self.zero);
                        next_is_comment = true;
                        continue;
                    } else if (view == ">") {
                        method.current_block.call_void(self.find_zero_right);
                        next_is_comment = true;
                        continue;
                    } else if (view == "<") {
                        method.current_block.call_void(self.find_zero_left);
                        next_is_comment = true;
                        continue;
                    }
                    Function* to_call = self.get_function(view);
                    Block* call_block = method.begin_block();
                    call_block.call_void(to_call);
                    Block* check_block = method.begin_block();
                    call_block.jump(check_block);
                    method.current_block.jump(check_block);
                    Block* continue_block = method.begin_block();
                    Identifier current_ptr = check_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
                    Identifier current_cell = check_block.load(current_ptr, c3cubed::TYPE_UBYTE);
                    check_block.conditional_jump(current_cell, call_block, continue_block);
                    method.add_block(call_block);
                    method.add_block(check_block);
                    method.add_block(continue_block);
                    next_is_comment = true;
                }
            default:
                continue;
        }
        next_is_comment = false;
    }
    if (collating_adds) {
        if (add_sub_amount != 0) {
            Identifier current_ptr = method.current_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
            Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
            Identifier result;
            if (add_sub_amount > 0) {
                result = method.current_block.add(current_cell, add_sub_amount, c3cubed::TYPE_WORD);
            } else {
                result = method.current_block.subtract(current_cell, -add_sub_amount, c3cubed::TYPE_WORD);
            }
            method.current_block.store(c3cubed::TYPE_UBYTE, result, current_ptr);
            collating_adds = false;
        }
    }

    if (collating_moves) {
        if (add_sub_amount != 0) {
            Identifier current_ptr = method.current_block.load(self.cell_pointer, c3cubed::TYPE_LONG);
            Identifier result;
            if (add_sub_amount > 0) {
                result = method.current_block.add(current_ptr, add_sub_amount, c3cubed::TYPE_LONG);
            } else {
                result = method.current_block.subtract(current_ptr, -add_sub_amount, c3cubed::TYPE_LONG);
            }
            method.current_block.store(c3cubed::TYPE_LONG, result, self.cell_pointer);
            collating_moves = false;
        }
    }
    method.current_block.ret();
    return method;
}

fn Module better_brainfuck_to_module(String brainfuck) {
    BrainfuckContext context;

    context.cells = context.mod.register_data("cells");
    context.cells.zero(CELL_COUNT);
    Data* stdin = context.mod.register_data("stdin");
    stdin.zero(STDIN_COUNT);
    Data* prompt = context.mod.register_data("prompt");
    prompt.add_string("Input: ");
    context.cell_pointer = context.mod.register_data("cell_pointer");
    context.cell_pointer.add_symbol(context.cells.reference(), CELL_COUNT >> 1);
    Data* input_pointer = context.mod.register_data("input_pointer");
    input_pointer.add_symbol(stdin.reference());

    Identifier puts = context.mod.import_ident("puts");
    context.putchar = context.mod.import_ident("putchar");
    Identifier gets = context.mod.import_ident("gets");

    Function* read_next = context.mod.register_function("read_next");
    read_next.set_return_type(c3cubed::TYPE_UBYTE);
    Block* start_block = read_next.begin_and_add_block();
    Identifier v0 = read_next.current_block.load(input_pointer, c3cubed::TYPE_LONG);
    Identifier v1 = read_next.current_block.load(v0, c3cubed::TYPE_UBYTE);
    Block* success = read_next.begin_and_add_block("not_zero");
    Block* failure = read_next.begin_and_add_block("zero");
    start_block.conditional_jump(v1, success, failure);
    failure.ret(0);
    Identifier v2 = success.add(v0, 1, c3cubed::TYPE_LONG);
    success.store(c3cubed::TYPE_LONG, v2, input_pointer);
    success.ret(v1);
    context.read_next = read_next;

    Function* zero = context.mod.register_function("zero_current_cell");
    zero.begin_and_add_block();
    Identifier current_loc = zero.current_block.load(context.cell_pointer, c3cubed::TYPE_LONG);
    zero.current_block.store(c3cubed::TYPE_BYTE, 0, current_loc);
    zero.current_block.ret();
    context.zero = zero;
    
    Data* program_terminated_due_to_infinite_loop = context.mod.register_data("halt_message");
    program_terminated_due_to_infinite_loop.add_string("Program terminated due to infinite loop!\n");
    Function* halt_if_not_zero = context.mod.register_function("halt_if_current_cell_is_not_zero");
    halt_if_not_zero.begin_and_add_block();
    current_loc = halt_if_not_zero.current_block.load(context.cell_pointer, c3cubed::TYPE_LONG);
    Identifier value = halt_if_not_zero.current_block.load(current_loc, c3cubed::TYPE_BYTE);
    Block* ret_block = halt_if_not_zero.begin_block("zero");
    ret_block.ret();
    Block* halt_block = halt_if_not_zero.begin_block("not_zero");
    halt_block.call_void(puts, c3cubed::TYPE_LONG, program_terminated_due_to_infinite_loop);
    halt_block.halt();
    halt_if_not_zero.current_block.conditional_jump(value, halt_block, ret_block);
    halt_if_not_zero.add_block(halt_block);
    halt_if_not_zero.add_block(ret_block);
    context.halt_if_not_zero = halt_if_not_zero;

    Function* find_zero_left = context.mod.register_function("find_zero_left");
    find_zero_left.begin_and_add_block();
    start_block = find_zero_left.begin_block();
    find_zero_left.current_block.jump(start_block);
    find_zero_left.add_block(start_block);
    Block* add_block = find_zero_left.begin_block();
    ret_block = find_zero_left.begin_block();
    current_loc = start_block.load(context.cell_pointer, c3cubed::TYPE_LONG);
    value = start_block.load(current_loc, c3cubed::TYPE_BYTE);
    start_block.conditional_jump(value, add_block, ret_block);
    find_zero_left.add_block(add_block);
    value = add_block.subtract(current_loc, 1, c3cubed::TYPE_LONG);
    add_block.store(c3cubed::TYPE_LONG, value, context.cell_pointer);
    add_block.jump(start_block);
    find_zero_left.add_block(ret_block);
    ret_block.ret();

    context.find_zero_left = find_zero_left;

    Function* find_zero_right = context.mod.register_function("find_zero_right");
    find_zero_right.begin_and_add_block();
    start_block = find_zero_right.begin_block();
    find_zero_right.current_block.jump(start_block);
    find_zero_right.add_block(start_block);
    add_block = find_zero_right.begin_block();
    ret_block = find_zero_right.begin_block();
    current_loc = start_block.load(context.cell_pointer, c3cubed::TYPE_LONG);
    value = start_block.load(current_loc, c3cubed::TYPE_BYTE);
    find_zero_right.add_block(add_block);
    value = add_block.add(current_loc, 1, c3cubed::TYPE_LONG);
    add_block.store(c3cubed::TYPE_LONG, value, context.cell_pointer);
    add_block.jump(start_block);
    find_zero_right.add_block(ret_block);
    ret_block.ret();
    context.find_zero_right = find_zero_right;


    Function* main = context.mod.register_function("main");
    main.add_linkage({.type = EXPORT});
    main.set_return_type(c3cubed::TYPE_WORD);
    main.begin_and_add_block();
    main.current_block.call_void(puts, c3cubed::TYPE_LONG, prompt);
    main.current_block.call_void(gets, c3cubed::TYPE_LONG, stdin);

    main.current_block.call_void(context.get_function(brainfuck, true));

    main.current_block.call_void(context.putchar, c3cubed::TYPE_UBYTE, '\n');

    main.current_block.ret(0);

    return context.mod;
}

// fn Module brainfuck_to_module(String brainfuck) {
//     Module mod;
//     BlockStack blocks;
//     BlockStack to_blocks;
//     Data* cells = mod.register_data("cells");
//     cells.zero(CELL_COUNT);
//     Data* stdin = mod.register_data("stdin");
//     stdin.zero(STDIN_COUNT);
//     Data* prompt = mod.register_data("prompt");
//     prompt.add_string("Input: ");
//     Identifier puts = mod.import_ident("puts");
//     Identifier putchar = mod.import_ident("putchar");
//     Identifier gets = mod.import_ident("gets");
//     Identifier cell_pointer = mod.import_ident("cell_pointer", LOCAL);
//     Identifier input_pointer = mod.import_ident("input_pointer", LOCAL);
//     uint next_block;

//     // Make a simple function for reading and incrementing the input pointer
//     Function* read_next = mod.register_function("read_next");
//     read_next.set_return_type(c3cubed::TYPE_UBYTE);
//     Identifier p0 = read_next.add_parameter(c3cubed::TYPE_LONG, "input_ptr");
//     Block* start_block = read_next.begin_and_add_block();
//     Identifier v0 = read_next.current_block.load(p0, c3cubed::TYPE_LONG);
//     Identifier v1 = read_next.current_block.load(v0, c3cubed::TYPE_UBYTE);
//     Block* success = read_next.begin_and_add_block("not_zero");
//     Block* failure = read_next.begin_and_add_block("zero");
//     start_block.conditional_jump(v1, success, failure);
//     failure.ret(0);
//     Identifier v2 = success.add(v0, 1, c3cubed::TYPE_LONG);
//     success.store(c3cubed::TYPE_LONG, v2, p0);
//     success.ret(v1);


//     Function* method = mod.register_function("main");
//     method.add_linkage({.type = EXPORT});
//     method.set_return_type(c3cubed::TYPE_WORD);
//     method.begin_and_add_block();
//     method.current_block.allocate(4, 8, cell_pointer);
//     method.current_block.allocate(4, 8, input_pointer);
//     method.current_block.call_void(puts, c3cubed::TYPE_LONG, prompt);
//     Identifier input = method.current_block.call_typed(gets, c3cubed::TYPE_LONG, c3cubed::TYPE_LONG, stdin);
//     method.current_block.store(c3cubed::TYPE_LONG, input, input_pointer);
//     Identifier half = method.current_block.add(cells, CELL_COUNT >> 1, c3cubed::TYPE_LONG);
//     method.current_block.store(c3cubed::TYPE_LONG, half, cell_pointer);
//     int add_sub_amount;
//     bool collating_adds;
//     bool collating_moves;
//     foreach (char c : brainfuck) {
//         if (collating_adds && (c == '<' || c == '>' || c == '[' || c == ']' || c == ',' || c == '.')) {
//             if (add_sub_amount != 0) {
//                 Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//                 Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
//                 Identifier result;
//                 if (add_sub_amount > 0) {
//                     result = method.current_block.add(current_cell, add_sub_amount, c3cubed::TYPE_WORD);
//                 } else {
//                     result = method.current_block.subtract(current_cell, -add_sub_amount, c3cubed::TYPE_WORD);
//                 }
//                 method.current_block.store(c3cubed::TYPE_UBYTE, result, current_ptr);
//                 collating_adds = false;
//             }
//         }
//         if (collating_moves && (c == '+' || c == '-' || c == '[' || c == ']' || c == ',' || c == '.')) {
//             if (add_sub_amount != 0) {
//                 Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//                 Identifier result;
//                 if (add_sub_amount > 0) {
//                     result = method.current_block.add(current_ptr, add_sub_amount, c3cubed::TYPE_LONG);
//                 } else {
//                     result = method.current_block.subtract(current_ptr, -add_sub_amount, c3cubed::TYPE_LONG);
//                 }
//                 method.current_block.store(c3cubed::TYPE_LONG, result, cell_pointer);
//                 collating_moves = false;
//             }
//         }
//         switch (c) {
//             case '+':
//                 if (collating_adds) {
//                     add_sub_amount += 1;
//                 } else {
//                     collating_adds = true;
//                     add_sub_amount = 1;
//                 }
//             case '-':
//                 if (collating_adds) {
//                     add_sub_amount -= 1;
//                 } else {
//                     collating_adds = true;
//                     add_sub_amount = -1;
//                 }
//             case '.':
//                 {
//                     Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//                     Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
//                     method.current_block.call_void(putchar, c3cubed::TYPE_UBYTE, current_cell);
//                 }
//             case ',':
//                 {
//                     Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//                     Identifier current_input = method.current_block.call_typed(read_next, c3cubed::TYPE_UBYTE, c3cubed::TYPE_LONG, input_pointer);
//                     method.current_block.store(c3cubed::TYPE_UBYTE, current_input, current_ptr);
//                 }
//             case '<':
//                 {
//                     if (collating_moves) {
//                         add_sub_amount -= 1;
//                     } else {
//                         collating_moves = true;
//                         add_sub_amount = -1;
//                     }
//                 }
//             case '>':
//                 {
//                     if (collating_moves) {
//                         add_sub_amount += 1;
//                     } else {
//                         collating_moves = true;
//                         add_sub_amount = 1;
//                     }
//                 }
//             case '[':
//                 {
//                     Block* current = method.current_block;
//                     Block* next = method.begin_and_add_block();
//                     Block* past = method.begin_block();
//                     current.jump(past);
//                     blocks.push(method.current_block);
//                     to_blocks.push(past);
//                 }
//             case ']':
//                 {
//                     Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//                     Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
//                     Block* current = method.current_block;
//                     Block* next = to_blocks.pop()!!;
//                     method.add_block(next);
//                     current.jump(next);
//                     Block* next2 = method.begin_and_add_block();
//                     next.conditional_jump(current_cell, blocks.pop()!!, next2);
//                 }
        
//             default:
//                 continue;
//         }
//     }
//     if (collating_adds) {
//         if (add_sub_amount != 0) {
//             Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//             Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
//             Identifier result;
//             if (add_sub_amount > 0) {
//                 result = method.current_block.add(current_cell, add_sub_amount, c3cubed::TYPE_WORD);
//             } else {
//                 result = method.current_block.subtract(current_cell, -add_sub_amount, c3cubed::TYPE_WORD);
//             }
//             method.current_block.store(c3cubed::TYPE_UBYTE, result, current_ptr);
//             collating_adds = false;
//         }
//     }

//     if (collating_moves) {
//         if (add_sub_amount != 0) {
//             Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
//             Identifier result;
//             if (add_sub_amount > 0) {
//                 result = method.current_block.add(current_ptr, add_sub_amount, c3cubed::TYPE_LONG);
//             } else {
//                 result = method.current_block.subtract(current_ptr, -add_sub_amount, c3cubed::TYPE_LONG);
//             }
//             method.current_block.store(c3cubed::TYPE_LONG, result, cell_pointer);
//             collating_moves = false;
//         }
//     }


//     method.current_block.ret();
//     return mod;
// }

fn int main(String[] args)
{
    if (args.len < 2) {
        io::printf("usage %s <file>\n",args[0]);
        return 1;
    }
    String! result = (String)file::load_temp(args[1])!!;
    Module mod;
    if (try String s = result) {
        mod = better_brainfuck_to_module(s);
    } else {
        return 1;
    }
    defer mod.free();
    io::print(mod.write());
    return 0;
}
