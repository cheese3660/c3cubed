module c3cubed;
import std::collections::list;

def InstructionList = List(<Instruction>);

/*                      Block Methods                                          */

struct Block {
    DString name;
    Function* parent;
    Allocator allocator;
    InstructionList insts;
}


/*
 * @require !self.allocator "Block has already been initialized!"
 */
fn void Block.initialize(&self, Function* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);
    self.insts.new_init(BLOCK_CAPACITY, self.allocator);
}

fn void Block.add_instruction(&self, Instruction inst) {
    self.insts.push(inst);
}

fn String Block.get_string(&self) {
    DString result;
    result.temp_init();
    result.appendf("@%s\n",self.name.str_view());
    foreach (Instruction* &inst : self.insts) {
        result.appendf("    %s\n", inst.get_string());
    }
    return result.str_view();
}

fn void Block.free(&self) {
    self.name.free();
    self.insts.free();
}


// Now we make all the instruction builders
fn Identifier Block.create_three_address(&self, InstructionType ty, Value a, Value b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    if (result_location.type == UNINITIALIZED) {
        result_location = self.parent.next_temporary();
    }
    Instruction inst = {
        .type = ty,
        .three_address = {
            .return_name = result_location,
            .return_type = result_type,
            .a = a,
            .b = b
        }
    };
    self.add_instruction(inst);
    return result_location;
}

fn Identifier Block.create_two_address(&self, InstructionType ty, Value a, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    if (result_location.type == UNINITIALIZED) {
        result_location = self.parent.next_temporary();
    }
    Instruction inst = {
        .type = ty,
        .two_address = {
            .return_name = result_location,
            .return_type = result_type,
            .a = a,
        }
    };
    self.add_instruction(inst);
    return result_location;
}

fn void Block.create_one_address(&self, InstructionType ty, Value a) {
    self.add_instruction(Instruction {
        .type = ty,
        .one_address = {
            .a = a,
        }
    });
}

fn void Block.create_two_address_no_ret(&self, InstructionType ty, Value a, Value b) {
    self.add_instruction(Instruction {
        .type = ty,
        .two_address_no_return = {
            .a = a,
            .b = b
        }
    });
}

fn void Block.create_three_address_no_ret(&self, InstructionType ty, Value a, Value b, Value c) {
    self.add_instruction(Instruction {
        .type = ty,
        .three_address_no_return = {
            .a = a,
            .b = b,
            .c = c
        }
    });
}

macro Block.add(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(ADD, create_value(a), create_value(b), result_type, result_location);
}

macro Block.divide(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(DIVIDE, create_value(a), create_value(b), result_type, result_location);
}

macro Block.negate(&sel, a, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(NEGATE, create_value(a), result_type, result_location);
}

macro Block.multiply(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(MULTIPLY, create_value(a), create_value(b), result_type, result_location);
}

macro Block.or(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(OR, create_value(a), create_value(b), result_type, result_location);
}

macro Block.xor(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(XOR, create_value(a), create_value(b), result_type, result_location);
}

macro Block.and(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(AND, create_value(a), create_value(b), result_type, result_location);
}

macro Block.remainder(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(REMAINDER, create_value(a), create_value(b), result_type, result_location);
}

macro Block.arithmetic_shift_right(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(ARITHMETIC_SHIFT_RIGHT, create_value(a), create_value(b), result_type, result_location);
}

macro Block.shift_right(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(SHIFT_RIGHT, create_value(a), create_value(b), result_type, result_location);
}

macro Block.shift_left(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(SHIFT_LEFT, create_value(a), create_value(b), result_type, result_location);
}

macro Block.subtract(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(SUBTRACT, create_value(a), create_value(b), result_type, result_location);
}

macro Block.unsigned_divide(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(UNSIGNED_DIVISION, create_value(a), create_value(b), result_type, result_location);
}

macro Block.unsigned_remainder(&self, a, b, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(UNSIGNED_REMAINDER, create_value(a), create_value(b), result_type, result_location);
}


fn void Block.create_store(&self, TypeReference type, Value value, Value location) {
    InstructionType itype;
    switch (type.type) {
        case DOUBLE:
            itype = STORE_DOUBLE;
        case SINGLE:
            itype = STORE_SINGLE;
        case ULONG:
        case LONG:
            itype = STORE_LONG;
        case UWORD:
        case WORD:
            itype = STORE_WORD;
        case UHALF:
        case HALF:
            itype = STORE_HALF;
        case UBYTE:
        case BYTE:
            itype = STORE_BYTE;
        default:
            itype = STORE_LONG;
    }
    self.create_two_address_no_ret(itype, value, location);
}

macro Block.store(&self, type, value, location) {
    self.create_store(type, create_value(value), create_value(location));
}

fn Identifier Block.create_load(&self, Value location, TypeReference type, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    TypeReference true_type = type;
    switch (type.type) {
        case DOUBLE:
            itype = LOAD_DOUBLE;
        case SINGLE:
            itype = LOAD_SINGLE;
        case ULONG:
            true_type = TYPE_LONG;
            nextcase;
        case LONG:
            itype = LOAD_LONG;
        case UWORD:
            true_type = TYPE_WORD;
            nextcase;
        case WORD:
            itype = LOAD_WORD;
        case UHALF:
            true_type = TYPE_WORD;
            itype = LOAD_UNSIGNED_HALF;
        case HALF:
            true_type = TYPE_WORD;
            itype = LOAD_SIGNED_HALF;
        case UBYTE:
            true_type = TYPE_WORD;
            itype = LOAD_UNSIGNED_BYTE;
        case BYTE:
            true_type = TYPE_WORD;
            itype = LOAD_SIGNED_BYTE;
        default:
            true_type = TYPE_LONG;
            itype = LOAD_LONG;
    }
    return self.create_two_address(itype, location, true_type, result_location);
}

macro Block.load(&self, location, type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_load(create_value(location), type, result_location);
}

macro Block.blit(&self, src, dest, length) {
    return self.create_three_address_no_ret(BLIT, create_value(src), create_value(dest), create_value(length));
}


fn Identifier Block.create_alloc(&self, usz alignment, Value amount, Identifier result_location = DEFAULT_IDENTIFIER) {
    assert(alignment == 4 || alignment == 8 || alignment == 16, "alignment must be one of 4, 8, or 16");
    InstructionType itype;
    if (alignment == 4) {
        itype = ALLOCATE_ALIGN_4;
    } else if (alignment == 8) {
        itype = ALLOCATE_ALIGN_8;
    } else if (alignment == 16) {
        itype = ALLOCATE_ALIGN_16;
    }
    return self.create_two_address(itype, create_value(amount),TYPE_LONG, result_location);
}

macro Block.allocate(&self, alignment, amount, result_location = DEFAULT_IDENTIFIER) {
    return self.create_alloc(alignment, create_value(amount), result_location);
}

// Now we need to do all the comparison functions

fn Identifier Block.create_compare_equality(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_EQUALITY_DOUBLE;
        case SINGLE:
            itype = COMPARE_EQUALITY_SINGLE;
        case LONG:
        case ULONG:
            itype = COMPARE_EQUALITY_LONG;
        case WORD:
        case HALF:
        case BYTE:
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_EQUALITY_WORD;
        default:
            itype = COMPARE_EQUALITY_LONG;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_equality(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_equality(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_inequality(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_INEQUALITY_DOUBLE;
        case SINGLE:
            itype = COMPARE_INEQUALITY_SINGLE;
        case LONG:
        case ULONG:
            itype = COMPARE_INEQUALITY_LONG;
        case WORD:
        case HALF:
        case BYTE:
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_INEQUALITY_WORD;
        default:
            itype = COMPARE_INEQUALITY_LONG;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_inequality(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_inequality(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_lower_equal(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_LOWER_OR_EQUAL_DOUBLE;
        case SINGLE:
            itype = COMPARE_LOWER_OR_EQUAL_SINGLE;
        case LONG:
            itype = COMPARE_SIGNED_LOWER_OR_EQUAL_LONG;
        case ULONG:
            itype = COMPARE_UNSIGNED_LOWER_OR_EQUAL_LONG;
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_LOWER_OR_EQUAL_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_LOWER_OR_EQUAL_WORD;
        default:
            itype = COMPARE_UNSIGNED_LOWER_OR_EQUAL_WORD;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_lower_equal(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_lower_equal(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_lower(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_LOWER_DOUBLE;
        case SINGLE:
            itype = COMPARE_LOWER_SINGLE;
        case LONG:
            itype = COMPARE_SIGNED_LOWER_LONG;
        case ULONG:
            itype = COMPARE_UNSIGNED_LOWER_LONG;
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_LOWER_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_LOWER_WORD;
        default:
            itype = COMPARE_UNSIGNED_LOWER_WORD;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_lower(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_lower(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_greater_equal(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_GREATER_OR_EQUAL_DOUBLE;
        case SINGLE:
            itype = COMPARE_GREATER_OR_EQUAL_SINGLE;
        case LONG:
            itype = COMPARE_SIGNED_GREATER_OR_EQUAL_LONG;
        case ULONG:
            itype = COMPARE_UNSIGNED_GREATER_OR_EQUAL_LONG;
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_GREATER_OR_EQUAL_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_GREATER_OR_EQUAL_WORD;
        default:
            itype = COMPARE_UNSIGNED_GREATER_OR_EQUAL_WORD;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_greater_equal(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_greater_equal(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_greater(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_GREATER_DOUBLE;
        case SINGLE:
            itype = COMPARE_GREATER_SINGLE;
        case LONG:
            itype = COMPARE_SIGNED_GREATER_LONG;
        case ULONG:
            itype = COMPARE_UNSIGNED_GREATER_LONG;
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_GREATER_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_GREATER_WORD;
        default:
            itype = COMPARE_UNSIGNED_GREATER_WORD;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_greater(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_greater(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_ordered(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_ORDERED_DOUBLE;
        case SINGLE:
            itype = COMPARE_ORDERED_SINGLE;
        default:
            itype = COMPARE_ORDERED_DOUBLE;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_ordered(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_ordered(comparison_type, create_value(a), create_value(b), result_location);
}

fn Identifier Block.create_compare_unordered(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_UNORDERED_DOUBLE;
        case SINGLE:
            itype = COMPARE_UNORDERED_SINGLE;
        default:
            itype = COMPARE_UNORDERED_DOUBLE;
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

macro Block.compare_unordered(&self, comparison_type, a, b, result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_unordered(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 * @require from.type != AGGREGATE, from.type != NONE, to.type != AGGREGATE, to.type != NONE
 */
fn Identifier Block.create_convert(&self, TypeReference from, Value a, TypeReference to, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    TypeReference result_type = to;
    switch (to.type) {
        case ULONG:
            result_type = TYPE_LONG;
        case BYTE:
        case UBYTE:
        case HALF:
        case UHALF:
        case UWORD:
            result_type = TYPE_WORD;
        default:
            break;
    }
    switch (from.type) {
        case SINGLE:
            switch (to.type) {
                case SINGLE:
                    itype = COPY;
                case DOUBLE:
                    itype = EXTEND_SINGLE;
                case UBYTE:
                case UHALF:
                case UWORD:
                case ULONG:
                    itype = SINGLE_TO_UNSIGNED;
                case BYTE:
                case HALF:
                case WORD:
                case LONG:
                    itype = SINGLE_TO_SIGNED;
                default:
                    break;
            }
        case DOUBLE:
            switch (to.type) {
                case SINGLE:
                    itype = TRUNCATE_DOUBLE;
                case DOUBLE:
                    itype = COPY;
                case UBYTE:
                case UHALF:
                case UWORD:
                case ULONG:
                    itype = DOUBLE_TO_UNSIGNED;
                case BYTE:
                case HALF:
                case WORD:
                case LONG:
                    itype = DOUBLE_TO_SIGNED;
                default:
                    break;
            }
        case UBYTE:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    itype = UNSIGNED_WORD_TO_FLOAT;
                case UBYTE:
                    itype = COPY;
                case BYTE:
                    itype = COPY;
                case UHALF:
                case HALF:
                case UWORD:
                case WORD:
                case ULONG:
                case LONG:
                    itype = ZERO_EXTEND_BYTE;
                default:
                    break;
            }
        case BYTE:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    a = create_value(self.convert(from, a, TYPE_WORD));
                    itype = SIGNED_WORD_TO_FLOAT;
                case UBYTE:
                    itype = COPY;
                case BYTE:
                    itype = COPY;
                case UHALF:
                case HALF:
                case UWORD:
                case WORD:
                case ULONG:
                case LONG:
                    itype = SIGN_EXTEND_BYTE;
                default:
                    break;
            }
        case UHALF:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    itype = UNSIGNED_WORD_TO_FLOAT;
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                    itype = COPY;
                case HALF:
                    itype = COPY;
                case UWORD:
                case WORD:
                case ULONG:
                case LONG:
                    itype = ZERO_EXTEND_HALF;
                default:
                    break;
            }
        case HALF:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    a = create_value(self.convert(from, a, TYPE_WORD));
                    itype = SIGNED_WORD_TO_FLOAT;
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                    itype = COPY;
                case HALF:
                    itype = COPY;
                case UWORD:
                case WORD:
                case ULONG:
                case LONG:
                    itype = SIGN_EXTEND_HALF;
                default:
                    break;
            }
        case UWORD:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    itype = UNSIGNED_WORD_TO_FLOAT;
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                case HALF:
                    return self.and(a, 0xffff, TYPE_WORD, result_location);
                case UWORD:
                case WORD:
                    itype = COPY;
                case ULONG:
                case LONG:
                    itype = ZERO_EXTEND_WORD;
                default:
                    break;
            }
        case WORD:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    itype = SIGNED_WORD_TO_FLOAT;
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                case HALF:
                    return self.and(a, 0xffff, TYPE_WORD, result_location);
                case UWORD:
                case WORD:
                    itype = COPY;
                case ULONG:
                case LONG:
                    itype = SIGN_EXTEND_WORD;
                default:
                    break; 
            }
        case ULONG:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    itype = UNSIGNED_LONG_TO_FLOAT;
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                case HALF:
                    return self.and(a, 0xffff, TYPE_WORD, result_location);
                case UWORD:
                case WORD:
                case ULONG:
                case LONG:
                    itype = COPY;
                default:
                    break;
            }
        case LONG:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    itype = SIGNED_LONG_TO_FLOAT;
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                case HALF:
                    return self.and(a, 0xffff, TYPE_WORD, result_location);
                case UWORD:
                case WORD:
                case ULONG:
                case LONG:
                    itype = COPY;
                default:
                    break;
            }
        default:
            break;
    }
    return self.create_two_address(itype, create_value(a), result_type, result_location);
}

macro Block.convert(&self, from, a, to, result_location = DEFAULT_IDENTIFIER) {
    return self.create_convert(from, create_value(a), to, result_location);
}

macro Block.bitcast(&self, a, type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(CAST, create_value(a), type, result_location);
}

macro Block.copy(&self, a, type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(COPY, create_value(a), type, result_location);
}

fn CallList Block.create_call_list(&self) {
    CallList list;
    list.new_init(TYPE_CAPACITY, self.allocator);
    return list;
}

fn Identifier Block.create_call(&self, Value method, CallList arguments, TypeReference return_type = TYPE_VOID, Identifier result_location = DEFAULT_IDENTIFIER) {
    if (result_location.type == UNINITIALIZED && return_type.type != NONE) {
        result_location = self.parent.next_temporary();
    }
    self.add_instruction(
        {
            .type = CALL,
            .call = {
                .return_type = return_type,
                .return_name = result_location,
                .method = method,
                .arguments = arguments
            }
        }
    );
    return result_location;
}

macro Block.call(&self, method, arguments, return_type = TYPE_VOID, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_call(create_value(method), arguments, return_type, result_location);
}

// Both of the following don't allow vaargs or env parameters

macro Block.call_void(&self, method, ...) {
    CallList temp = self.create_call_list();
    $assert ($vacount % 2 == 0);
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.arg($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_call(create_value(method), temp);
}

macro Block.call_typed(&self, method, return_type, ...) {
    CallList temp = self.create_call_list();
    $assert ($vacount % 2 == 0);
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.arg($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_call(create_value(method), temp, return_type);
}

macro Block.call_typed_value(&self, method, return_type, result_location, ...) {
    CallList temp = self.create_call_list();
    $assert ($vacount % 2 == 0);
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.arg($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_call(create_value(method), temp, return_type, result_location);
}

macro Block.variadic_start(&self, pointer) {
    self.create_one_address(VARIADIC_START, create_value(pointer));
}

macro Block.variadic_arg(&self, pointer, result_type, result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(VARIADIC_ARG, create_value(pointer), result_type, result_location);
}


fn PhiList Block.create_phi_list(&self) {
    PhiList list;
    list.new_init(TYPE_CAPACITY, self.allocator);
    return list;
}

fn Identifier Block.create_phi(&self, PhiList branches, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    if (result_location.type == UNINITIALIZED) {
        result_location = self.parent.next_temporary();
    }
    self.add_instruction({
        .type = PHI,
        .phi = {
            .return_name = result_location,
            .return_type = result_type,
            .branches = branches
        }
    });
    return result_location;
}

macro Block.phi_temp(&self, result_type, ...) {
    PhiList temp = self.create_phi_list();
    $assert ($vacount % 2 == 0);
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.branch($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_phi(temp, result_type);
}

macro Block.phi(&self, result_type, result_location, ...) {
    PhiList temp = self.create_phi_list();
    $assert ($vacount % 2 == 0);
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.branch($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_phi(temp, result_type, result_location);
}

fn void Block.jump(&self, Block* to) {
    self.add_instruction({
        .type = UNCONDITIONAL_JUMP,
        .jump = {
            .where = to
        }
    });
}

fn void Block.halt(&self) {
    self.add_instruction({
        .type = HALT
    });
}

fn void Block.create_return(&self, Value v) {
    self.add_instruction({
        .type = RETURN,
        .ret = {
            .retval = v
        }
    });
}

macro void Block.ret(&self, ...) {
    $if $vacount == 0:
        return self.create_return(NO_VALUE);
    $else
        return self.create_return(create_value($vaarg(0)));
    $endif
}

fn void Block.create_conditional_jump(&self, Value condition, Block* success, Block* failure) {
    self.add_instruction({
        .type = CONDITIONAL_JUMP,
        .conditional = {
            .condition = condition,
            .success = success,
            .failure = failure
        }
    });
}

macro Block.conditional_jump(&self, condition, success, failure) {
    self.create_conditional_jump(create_value(condition), success, failure);
}