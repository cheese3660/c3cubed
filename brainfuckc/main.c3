module brainfuckc;
import std::io;
import std::collections::list;
import c3cubed;
const ulong CELL_COUNT = 0x10000;
const ulong STDIN_COUNT = 0x10000;
def BlockStack = List(<Block*>);

fn Module brainfuck_to_module(String brainfuck) {
    Module mod;
    BlockStack blocks;
    BlockStack to_blocks;
    Data* cells = mod.register_data("cells");
    cells.zero(CELL_COUNT);
    Data* stdin = mod.register_data("stdin");
    stdin.zero(STDIN_COUNT);
    Data* prompt = mod.register_data("prompt");
    prompt.add_string("Input: ");
    Identifier puts = mod.import_ident("puts");
    Identifier putchar = mod.import_ident("putchar");
    Identifier gets = mod.import_ident("gets");
    Identifier cell_pointer = mod.import_ident("cell_pointer", LOCAL);
    Identifier input_pointer = mod.import_ident("input_pointer", LOCAL);
    uint next_block;

    // Make a simple function for reading and incrementing the input pointer
    Function* read_next = mod.register_function("read_next");
    read_next.set_return_type(c3cubed::TYPE_UBYTE);
    Identifier p0 = read_next.add_parameter(c3cubed::TYPE_LONG, "input_ptr");
    Block* start_block = read_next.begin_and_add_block();
    Identifier v0 = read_next.current_block.load(p0, c3cubed::TYPE_LONG);
    Identifier v1 = read_next.current_block.load(v0, c3cubed::TYPE_UBYTE);
    Block* success = read_next.begin_and_add_block("not_zero");
    Block* failure = read_next.begin_and_add_block("zero");
    start_block.conditional_jump(v1, success, failure);
    failure.ret(0);
    Identifier v2 = success.add(v0, 1, c3cubed::TYPE_LONG);
    success.store(c3cubed::TYPE_LONG, v2, p0);
    success.ret(v1);


    Function* method = mod.register_function("main");
    method.add_linkage({.type = EXPORT});
    method.set_return_type(c3cubed::TYPE_WORD);
    method.begin_and_add_block();
    method.current_block.allocate(4, 8, cell_pointer);
    method.current_block.allocate(4, 8, input_pointer);
    method.current_block.call_void(puts, c3cubed::TYPE_LONG, prompt);
    Identifier input = method.current_block.call_typed(gets, c3cubed::TYPE_LONG, c3cubed::TYPE_LONG, stdin);
    method.current_block.store(c3cubed::TYPE_LONG, input, input_pointer);
    Identifier half = method.current_block.add(cells, CELL_COUNT >> 1, c3cubed::TYPE_LONG);
    method.current_block.store(c3cubed::TYPE_LONG, half, cell_pointer);
    int add_sub_amount;
    bool collating_adds;
    bool collating_moves;
    foreach (char c : brainfuck) {
        if (collating_adds && (c == '<' || c == '>' || c == '[' || c == ']' || c == ',' || c == '.')) {
            if (add_sub_amount != 0) {
                Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
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
                Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
                Identifier result;
                if (add_sub_amount > 0) {
                    result = method.current_block.add(current_ptr, add_sub_amount, c3cubed::TYPE_LONG);
                } else {
                    result = method.current_block.subtract(current_ptr, -add_sub_amount, c3cubed::TYPE_LONG);
                }
                method.current_block.store(c3cubed::TYPE_LONG, result, cell_pointer);
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
                    Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
                    Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
                    method.current_block.call_void(putchar, c3cubed::TYPE_UBYTE, current_cell);
                }
            case ',':
                {
                    Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
                    Identifier current_input = method.current_block.call_typed(read_next, c3cubed::TYPE_UBYTE, c3cubed::TYPE_LONG, input_pointer);
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
                    Block* current = method.current_block;
                    Block* next = method.begin_and_add_block();
                    Block* past = method.begin_block();
                    current.jump(past);
                    blocks.push(method.current_block);
                    to_blocks.push(past);
                }
            case ']':
                {
                    Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
                    Identifier current_cell = method.current_block.load(current_ptr, c3cubed::TYPE_UBYTE);
                    Block* current = method.current_block;
                    Block* next = to_blocks.pop()!!;
                    method.add_block(next);
                    current.jump(next);
                    Block* next2 = method.begin_and_add_block();
                    next.conditional_jump(current_cell, blocks.pop()!!, next2);
                }
        
            default:
                continue;
        }
    }
    if (collating_adds) {
        if (add_sub_amount != 0) {
            Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
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
            Identifier current_ptr = method.current_block.load(cell_pointer, c3cubed::TYPE_LONG);
            Identifier result;
            if (add_sub_amount > 0) {
                result = method.current_block.add(current_ptr, add_sub_amount, c3cubed::TYPE_LONG);
            } else {
                result = method.current_block.subtract(current_ptr, -add_sub_amount, c3cubed::TYPE_LONG);
            }
            method.current_block.store(c3cubed::TYPE_LONG, result, cell_pointer);
            collating_moves = false;
        }
    }


    method.current_block.ret();
    return mod;
}

fn int main(String[] args)
{
    if (args.len < 2) {
        io::printf("usage %s <file>\n",args[0]);
        return 1;
    }
    String! result = (String)file::load_temp(args[1])!!;
    Module mod;
    if (try String s = result) {
        mod = brainfuck_to_module(s);
    } else {
        return 1;
    }
    defer mod.free();
    io::print(mod.write());
    return 0;
}
