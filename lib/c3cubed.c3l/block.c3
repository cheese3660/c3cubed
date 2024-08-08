module c3cubed;
import std::collections::list;

def InstructionList = List(<Instruction>);

/**
 *  Represents a QBE block, that is a list of instructions that starts with a label
 */
struct Block {
    // The label of the block
    DString name;
    // The function the block is in
    Function* parent;
    // The allocator used for the block
    Allocator allocator;
    // The instructions in the block
    InstructionList insts;
    // Whether the block has been terminated (for example via a jump instruction)
    bool terminated;
}


/**
 *  Initializes a block, called automatically by Function.begin_block, and Function.begin_and_add_block
 *
 *  @param parent   "The parent function of the block"
 *  @param name     "The label of the block, can be a temporarily allocated string"
 *
 *  @require !self.allocator "Block has already been initialized!"
 */
fn void Block.initialize(&self, Function* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);
    self.insts.new_init(BLOCK_CAPACITY, self.allocator);
}

/**
 *  Adds an instruction to a block
 *
 *  @param inst     "The instruction to add to the block"
 */
fn void Block.add_instruction(&self, Instruction inst) {
    self.insts.push(inst);
}

/**
 *  Get the QBE textual representation of the block
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String Block.get_string(&self) {
    DString result;
    result.temp_init();
    result.appendf("@%s\n",self.name.str_view());
    foreach (Instruction* &inst : self.insts) {
        result.appendf("    %s\n", inst.get_string());
    }
    return result.str_view();
}

/**
 *  Free the block and its instructions, called automatically by Function.free, which is automatically called by Module.free
 */
fn void Block.free(&self) {
    self.name.free();
    foreach (Instruction* &inst : self.insts) {
        inst.free();
    }
    self.insts.free();
}

/**
 *  Create a three address instruction and add it to the block
 *
 *  @param ty               "The instruction type to add, must be a three address instruction"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require ty.arg_type == THREE_ADDRESS   `Instruction is not a three address instruction`
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
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

/**
 *  Create a two address instruction and add it to the block
 *
 *  @param ty               "The instruction type to add, must be a two address instruction"
 *  @param a                "The parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require ty.arg_type == TWO_ADDRESS     `Instruction is not a three address instruction`
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
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

/**
 *  Create a one address instruction and add it to the block
 *
 *  @param ty               "The instruction type to add, must be a two address instruction"
 *  @param a                "The parameter to the instruction"
 *
 *  @require ty.arg_type == ONE_ADDRESS     `Instruction is not a three address instruction`
 *  @require !self.terminated               `Block has already been terminated!`
 */
fn void Block.create_one_address(&self, InstructionType ty, Value a) {
    self.add_instruction(Instruction {
        .type = ty,
        .one_address = {
            .a = a,
        }
    });
}

/**
 *  Create a two address no return instruction and add it to the block
 *
 *  @param ty               "The instruction type to add, must be a two address no return instruction"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *
 *  @require ty.arg_type == TWO_ADDRESS_NO_RET  `Instruction is not a two address no return instruction`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
fn void Block.create_two_address_no_ret(&self, InstructionType ty, Value a, Value b) {
    self.add_instruction(Instruction {
        .type = ty,
        .two_address_no_return = {
            .a = a,
            .b = b
        }
    });
}

/**
 *  Create a three address no return instruction and add it to the block
 *
 *  @param ty               "The instruction type to add, must be a three address no return instruction"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param c                "The third parameter to the instruction"
 *
 *  @require ty.arg_type == THREE_ADDRESS_NO_RET    `Instruction is not a three address no return instruction`
 *  @require !self.terminated                       `Block has already been terminated!`
 */
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

/**
 *  Create and add an ADD instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.add(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(ADD, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a DIVIDE instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.divide(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(DIVIDE, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a NEGATE instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.negate(&sel, a, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(NEGATE, create_value(a), result_type, result_location);
}

/**
 *  Create and add a MULTIPLY instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.multiply(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(MULTIPLY, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add an OR instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.or(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(OR, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add an XOR instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.xor(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(XOR, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add an AND instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.and(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(AND, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a REMAINDER instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.remainder(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(REMAINDER, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add an ARITHMETIC_SHIFT_RIGHT instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.arithmetic_shift_right(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(ARITHMETIC_SHIFT_RIGHT, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a SHIFT_RIGHT instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.shift_right(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(SHIFT_RIGHT, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a SHIFT_LEFT instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.shift_left(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(SHIFT_LEFT, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a SUBTRACT instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.subtract(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(SUBTRACT, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add an UNSIGNED_DIVISION instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.unsigned_divide(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(UNSIGNED_DIVISION, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add an UNSIGNED_REMAINDER instruction to the block, automatically converting the parameters to values
 *  
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.unsigned_remainder(&self, a, b, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_three_address(UNSIGNED_REMAINDER, create_value(a), create_value(b), result_type, result_location);
}

/**
 *  Create and add a store instruction to the block
 *  
 *  @param type             "The type of value to store, must not be an aggregate type"
 *  @param value            "The value to store"
 *  @param location         "The location to store the value in"
 *
 *  @require type.type.store_load_type  `Type is not valid for storing`
 *  @require !self.terminated           `Block has already been terminated!`
 */
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
        case SHALF:
        case UHALF:
        case HALF:
            itype = STORE_HALF;
        case SBYTE:
        case UBYTE:
        case BYTE:
            itype = STORE_BYTE;
        default:
            itype = STORE_LONG;
    }
    self.create_two_address_no_ret(itype, value, location);
}

/**
 *  Create and add a store instruction to the block, automatically converting the parameters to values
 *  
 *  @param type             "The type of value to store, must not be an aggregate type"
 *  @param value            "The value to store"
 *  @param location         "The location to store the value in"
 *
 *  @require type.type.store_load_type      `Type is not valid for storing`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.store(&self, Identifier type, value, location) {
    self.create_store(type, create_value(value), create_value(location));
}

/**
 *  Create and add a load instruction to the block
 *  
 *  @param type             "The type of value to load, must not be an aggregate type"
 *  @param location         "The location to store the value in"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require type.type.store_load_type      `Type is not valid for loading`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
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
        case SHALF:
        case HALF:
            true_type = TYPE_WORD;
            itype = LOAD_SIGNED_HALF;
        case UBYTE:
            true_type = TYPE_WORD;
            itype = LOAD_UNSIGNED_BYTE;
        case SBYTE:
        case BYTE:
            true_type = TYPE_WORD;
            itype = LOAD_SIGNED_BYTE;
        default:
            true_type = TYPE_LONG;
            itype = LOAD_LONG;
    }
    return self.create_two_address(itype, location, true_type, result_location);
}

/**
 *  Create and add a load instruction to the block, automatically converting the parameters to values
 *  
 *  @param type             "The type of value to load, must not be an aggregate type"
 *  @param location         "The location to store the value in"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require type.type.store_load_type      `Type is not valid for loading`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.load(&self, location, TypeReference type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_load(create_value(location), type, result_location);
}

/**
 *  Create and add a BLIT instruction to the block, automatically converting the parameters to values
 *  
 *  @param src              "Where to blit from"
 *  @param dest             "Where to blit to"
 *  @param length           "How many bytes to blit"
 */
macro Block.blit(&self, src, dest, length) {
    self.create_three_address_no_ret(BLIT, create_value(src), create_value(dest), create_value(length));
}

/**
 *  Create and add a stack allocation instruction to the block
 *
 *  @param alignment        "The alignment of the stack allocation"
 *  @param amount           "How many bytes to allocate on the stack"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require alignment==4 || alignment == 8 || alignment == 16  `alignment must be one of 4, 8, or 16`
 *  @require result_location.type != GLOBAL                     `Result cannot be a global symbol`
 *  @require !self.terminated                                   `Block has already been terminated!`
 */
fn Identifier Block.create_alloc(&self, usz alignment, Value amount, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (alignment) {
        case 4: itype == ALLOCATE_ALIGN_4;
        case 8: itype == ALLOCATE_ALIGN_8;
        case 16: itype == ALLOCATE_ALIGN_16;
    }
    return self.create_two_address(itype, create_value(amount),TYPE_LONG, result_location);
}

/**
 *  Create and add a stack allocation instruction to the block, automatically converting the parameters to values
 *
 *  @param alignment        "The alignment of the stack allocation. must be one of 4, 8, or 16"
 *  @param amount           "How many bytes to allocate on the stack"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require alignment==4 || alignment == 8 || alignment == 16  `alignment must be one of 4, 8, or 16`
 *  @require result_location.type != GLOBAL                     `Result cannot be a global symbol`
 *  @require !self.terminated                                   `Block has already been terminated!`
 */
macro Block.allocate(&self, alignment, amount, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_alloc(alignment, create_value(amount), result_location);
}

/**
 *  Create and add an equality comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
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
        case SHALF:
        case SBYTE:
        case WORD:
        case HALF:
        case BYTE:
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_EQUALITY_WORD;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add an equality comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
macro Block.compare_equality(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_equality(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add an inequality comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
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
        case SHALF:
        case SBYTE:
        case WORD:
        case HALF:
        case BYTE:
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_INEQUALITY_WORD;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add an inequality comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
macro Block.compare_inequality(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_inequality(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add lower-equal comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
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
        case SHALF:
        case SBYTE:
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_LOWER_OR_EQUAL_WORD;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add a lower-equal comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
macro Block.compare_lower_equal(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_lower_equal(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add lower comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
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
        case SHALF:
        case SBYTE:
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_LOWER_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_LOWER_WORD;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add a lower comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
macro Block.compare_lower(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_lower(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add a greater-equal comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
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
        case SHALF:
        case SBYTE:
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_GREATER_OR_EQUAL_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_GREATER_OR_EQUAL_WORD;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add a greater-equal comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
macro Block.compare_greater_equal(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_greater_equal(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add a greater comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
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
        case SHALF:
        case SBYTE:
        case WORD:
        case HALF:
        case BYTE:
            itype = COMPARE_SIGNED_GREATER_WORD;
        case UWORD:
        case UHALF:
        case UBYTE:
            itype = COMPARE_UNSIGNED_GREATER_WORD;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add a greater comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, can't be an aggregate type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.store_load_type                   `Comparison type is invalid`
 *  @require result_location.type != GLOBAL                         `Result cannot be a global symbol`
 *  @require !self.terminated                                       `Block has already been terminated!`
 */
macro Block.compare_greater(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_greater(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add an ordered comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, must be a float type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.float_type    `Comparison type is invalid`
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
fn Identifier Block.create_compare_ordered(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_ORDERED_DOUBLE;
        case SINGLE:
            itype = COMPARE_ORDERED_SINGLE;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add an ordered comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, must be a float type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.float_type    `Comparison type is invalid`
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
macro Block.compare_ordered(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_ordered(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add an unordered comparison instruction
 *
 *  @param comparison_type  "The type of values to compare, must be a float type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.float_type    `Comparison type is invalid`
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
fn Identifier Block.create_compare_unordered(&self, TypeReference comparison_type, Value a, Value b, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    switch (comparison_type.type) {
        case DOUBLE:
            itype = COMPARE_UNORDERED_DOUBLE;
        case SINGLE:
            itype = COMPARE_UNORDERED_SINGLE;
        default:
            unreachable();
    }
    return self.create_three_address(itype, a, b, TYPE_WORD, result_location);
}

/**
 *  Create and add an unordered comparison instruction, automatically converting the parameters to values
 *
 *  @param comparison_type  "The type of values to compare, must be a float type"
 *  @param a                "The first parameter to the instruction"
 *  @param b                "The second parameter to the instruction"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require comparison_type.type.float_type    `Comparison type is invalid`
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
macro Block.compare_unordered(&self, TypeReference comparison_type, a, b, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_compare_unordered(comparison_type, create_value(a), create_value(b), result_location);
}

/**
 *  Create and add a conversion instruction
 *
 *  @param from             "The type to convert from, cannot be an aggregate type"
 *  @param a                "The value to convert"
 *  @param to               "The type to convert to, cannot be an aggregate type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require from.type.store_load_type          `Cannot convert from given type`
 *  @require to.type.store_load_type            `Cannot convert to given type`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
fn Identifier Block.create_convert(&self, TypeReference from, Value a, TypeReference to, Identifier result_location = DEFAULT_IDENTIFIER) {
    InstructionType itype;
    TypeReference result_type = to;
    switch (to.type) {
        case ULONG:
            result_type = TYPE_LONG;
        case SBYTE:
        case SHALF:
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
                case SBYTE:
                case BYTE:
                case SHALF:
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
                case SBYTE:
                case BYTE:
                case SHALF:
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
                case SBYTE:
                case UBYTE:
                case BYTE:
                    itype = COPY;
                case SHALF:
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
        case SBYTE:
        case BYTE:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    a = create_value(self.convert(from, a, TYPE_WORD));
                    itype = SIGNED_WORD_TO_FLOAT;
                case UBYTE:
                    itype = COPY;
                case SBYTE:
                case BYTE:
                    itype = COPY;
                case SHALF:
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
                case SBYTE:
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                    itype = COPY;
                case SHALF:
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
        case SHALF:
        case HALF:
            switch (to.type) {
                case SINGLE:
                case DOUBLE:
                    a = create_value(self.convert(from, a, TYPE_WORD));
                    itype = SIGNED_WORD_TO_FLOAT;
                case SBYTE:
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case UHALF:
                    itype = COPY;
                case SHALF:
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
                case SBYTE:
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case SHALF:
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
                case SBYTE:
                case BYTE:
                case UBYTE:
                    return self.and(a, 0xff, TYPE_WORD, result_location);
                case SHALF:
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

/**
 *  Create and add a conversion instruction, automatically converting the parameters to values
 *
 *  @param from             "The type to convert from, cannot be an aggregate type"
 *  @param a                "The value to convert"
 *  @param to               "The type to convert to, cannot be an aggregate type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require from.type.store_load_type          `Cannot convert from given type`
 *  @require to.type.store_load_type            `Cannot convert to given type`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
macro Block.convert(&self, TypeReference from, a, TypeReference to, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_convert(from, create_value(a), to, result_location);
}


/**
 *  Create and add a bitcast instruction, automatically converting the parameters to values 
 *
 *  @param a                "The parameter to the instruction"
 *  @param type             "The type to bitcast to, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require type.type.base_type            `Type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.bitcast(&self, a, TypeReference type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(CAST, create_value(a), type, result_location);
}

/**
 *  Create and add a copy instruction, automatically converting the parameters to values 
 *
 *  @param a                "The parameter to the instruction"
 *  @param type             "The type to copy, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require type.type.base_type            `Type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.copy(&self, a, TypeReference type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(COPY, create_value(a), type, result_location);
}


/**
 *  Create a parameter list to be used in a call instruction
 *
 *  @return "a newly created parameter list"
 */
fn CallList Block.create_call_list(&self) {
    CallList list;
    list.new_init(TYPE_CAPACITY, self.allocator);
    return list;
}

/**
 *  Create and add a call instruction
 *
 *  @param method           "The function to call"
 *  @param arguments        "The parameters to the function"
 *  @param return_type      "The type of the result of the instruction"
 *  @param result_location  "Where to store the result of the instruction if the return type is not void, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the call, if the return type is not void"
 *
 *  @require result_location.type != GLOBAL     `Result cannot be a global symbol`
 *  @require !self.terminated                   `Block has already been terminated!`
 */
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

/**
 *  Create and add a call instruction, automatically converting the parameters to values
 *
 *  @param method           "The function to call"
 *  @param arguments        "The parameters to the function"
 *  @param return_type      "The type of the result of the instruction"
 *  @param result_location  "Where to store the result of the instruction if the return type is not void, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the call, if the return type is not void"
 *
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated               `Block has already been terminated!`
 */
macro Block.call(&self, method, CallList arguments, TypeReference return_type = TYPE_VOID, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_call(create_value(method), arguments, return_type, result_location);
}

/**
 *  Call a function that returns void, automatically converting the parameters to values, the varargs are a list of type then parameter pairs
 *
 *  Example being: `block.call_void(add5, TYPE_WORD, 1, TYPE_WORD, 2, TYPE_WORD, value, TYPE_WORD, some_other_value, TYPE_WORD, 4)`
 *
 *  @param method   "The function to call"
 *
 *  @require $vacount % 2 == 0  `Must provide an even number of varargs to the macro for type-value pairs`
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.call_void(&self, method, ...) {
    CallList temp = self.create_call_list();
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.arg($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    self.create_call(create_value(method), temp);
}

/**
 *  Call a function that returns a value, automatically converting the parameters to values, the varargs are a list of type then parameter pairs
 *
 *  Example being: `block.call_typed(add5, TYPE_WORD, TYPE_WORD, 1, TYPE_WORD, 2, TYPE_WORD, value, TYPE_WORD, some_other_value, TYPE_WORD, 4)`
 *
 *  @param method       "The function to call"
 *  @param return_type  "The return type of the function call"
 *
 *  @return             "An identifier that represents the result of the call, if the return type is not void"
 *
 *  @require $vacount % 2 == 0  `Must provide an even number of varargs to the macro for type-value pairs`
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.call_typed(&self, method, TypeReference return_type, ...) {
    CallList temp = self.create_call_list();
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.arg($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_call(create_value(method), temp, return_type);
}

/**
 *  Call a function that returns a value, automatically converting the parameters to values, the varargs are a list of type then parameter pairs
 *
 *  Example being: `block.call_typed_value(add5, TYPE_WORD, result_symbol, TYPE_WORD, 1, TYPE_WORD, 2, TYPE_WORD, value, TYPE_WORD, some_other_value, TYPE_WORD, 4)`
 *
 *  @param method           "The function to call"
 *  @param return_type      "The return type of the function call"
 *  @param result_location  "Where to store the result of the instruction if the return type is not void, must not be a global symbol"
 *
 *  @return             "An identifier that represents the result of the call, if the return type is not void (result_location)"
 *
 *  @require $vacount % 2 == 0  `Must provide an even number of varargs to the macro for type-value pairs`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.call_typed_value(&self, method, TypeReference return_type, Identifier result_location, ...) {
    CallList temp = self.create_call_list();
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.arg($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_call(create_value(method), temp, return_type, result_location);
}

/**
 *  Create and add a VARIADIC_START instruction, automatically converting the parameters to values
 *
 *  @param pointer  "Where to store the valist"
 */
macro Block.variadic_start(&self, pointer) {
    self.create_one_address(VARIADIC_START, create_value(pointer));
}

/**
 *  Create and add a VARIADIC_ARG instruction, automatically converting the parameters to values
 *
 *  @param pointer          "The pointer to the valist"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.variadic_arg(&self, pointer, TypeReference result_type, Identifier result_location = DEFAULT_IDENTIFIER) {
    return self.create_two_address(VARIADIC_ARG, create_value(pointer), result_type, result_location);
}

/**
 *  Create a phi list to be used in a phi instruction
 *
 *  @return "a newly created phi list"
 */
fn PhiList Block.create_phi_list(&self) {
    PhiList list;
    list.new_init(TYPE_CAPACITY, self.allocator);
    return list;
}

/**
 *  Create and add a PHI instruction
 *  PHI instructions are generally not recommended as QBE can handle non SSA code
 *
 *  @param branches         "The list of branches that this phi value can take"
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol, if not passed a temporary location is used"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated   `Block has already been terminated!`
 */
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

/**
 *  Create and add a PHI instruction, automatically converting parameters into values, the varargs are a list of block-value pairs
 *  
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *
 *  @return                 "An identifier that represents the result of the instruction"
 *
 *  @require $vacount % 2 == 0  `Must provide an even number of varargs to the macro for block-value pairs`
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.phi_temp(&self, TypeReference result_type, ...) {
    PhiList temp = self.create_phi_list();
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.branch($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_phi(temp, result_type);
}

/**
 *  Create and add a PHI instruction, automatically converting parameters into values, the varargs are a list of block-value pairs
 *  
 *  @param result_type      "The type of the result of the instruction, must be a first class type"
 *  @param result_location  "Where to store the result of the instruction, must not be a global symbol"
 *
 *  @return                 "An identifier that represents the result of the instruction (result_location)"
 *
 *  @require $vacount % 2 == 0  `Must provide an even number of varargs to the macro for block-value pairs`
 *
 *  @require result_type.type.base_type     `Result type is not a first class type`
 *  @require result_location.type != GLOBAL `Result cannot be a global symbol`
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.phi(&self, TypeReference result_type, Identifier result_location, ...) {
    PhiList temp = self.create_phi_list();
    $for (var $i = 0; $i < $vacount; $i+=2)
        temp.branch($vaarg($i), create_value($vaarg($i+1)));
    $endfor
    return self.create_phi(temp, result_type, result_location);
}

/**
 *  Create and add an UNCONDITIONAL_JUMP instruction
 *
 *  @param [&in] to     "The block to jump to"
 *
 *  @require !self.terminated   `Block has already been terminated!`
 */
fn void Block.jump(&self, Block* to) {
    self.terminated = true;
    self.add_instruction({
        .type = UNCONDITIONAL_JUMP,
        .jump = {
            .where = to
        }
    });
}

/**
 *  Create and add a HALT instruction
 *
 *  @require !self.terminated   `Block has already been terminated!`
 */
fn void Block.halt(&self) {
    self.terminated = true;
    self.add_instruction({
        .type = HALT
    });
}

/**
 *  Create and add a RETURN instruction
 *
 *  @param v    "The value to return, if none is passed, then it returns void"
 *
 *  @require !self.terminated   `Block has already been terminated!`
 */
fn void Block.create_return(&self, Value v = NO_VALUE) {
    self.terminated = true;
    self.add_instruction({
        .type = RETURN,
        .ret = {
            .retval = v
        }
    });
}

/**
 *  Create and add a RETURN instruction, automatically converting the parameters to values
 *
 *  @param retval    "The value to return, if none is passed, then it returns void"
 *
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro void Block.ret(&self, retval = NO_VALUE) {
    self.terminated = true;
    return self.create_return(create_value(retval));
}

/**
 *  Create and add a CONDITIONAL_JUMP instruction
 *
 *  @param condition        "The condition to test"
 *  @param [&in] success    "Where to jump if the condition is true"
 *  @param [&in] failure    "Where to jump if the condition is false"
 *
 *  @require !self.terminated   `Block has already been terminated!`
 */
fn void Block.create_conditional_jump(&self, Value condition, Block* success, Block* failure) {
    self.terminated = true;
    self.add_instruction({
        .type = CONDITIONAL_JUMP,
        .conditional = {
            .condition = condition,
            .success = success,
            .failure = failure
        }
    });
}

/**
 *  Create and add a CONDITIONAL_JUMP instruction, automatically converting the parameters to values
 *
 *  @param condition            "The condition to test"
 *  @param [&in] success        "Where to jump if the condition is true"
 *  @param [&in] failure        "Where to jump if the condition is false"
 *
 *  @require !self.terminated   `Block has already been terminated!`
 */
macro Block.conditional_jump(&self, condition, Block* success, Block* failure) {
    self.create_conditional_jump(create_value(condition), success, failure);
}