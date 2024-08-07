module c3cubed;
import std::collections::list;
import std::io;

enum InstructionArgumentType {
    THREE_ADDRESS,
    THREE_ADDRESS_NO_RET,
    TWO_ADDRESS,
    TWO_ADDRESS_NO_RET,
    ONE_ADDRESS,
    JUMP,
    CONDITIONAL,
    RETURN,
    HALT,
    CALL,
    PHI
}

/**
 *  Represents a QBE instruction type
 */
enum InstructionType : char ( String textual, InstructionArgumentType arg_type) {
    // Arithmetic Instructions
    ADD = {"add", THREE_ADDRESS},
    DIVIDE = {"div", THREE_ADDRESS},
    MULTIPLY = {"mul", THREE_ADDRESS},
    NEGATE = {"neg", TWO_ADDRESS},
    OR = {"or", THREE_ADDRESS},
    XOR = {"xor", THREE_ADDRESS},
    AND = {"and", THREE_ADDRESS},
    REMAINDER = {"rem", THREE_ADDRESS},
    ARITHMETIC_SHIFT_RIGHT = {"sar", THREE_ADDRESS},
    SHIFT_RIGHT = {"shr", THREE_ADDRESS},
    SHIFT_LEFT = {"shl", THREE_ADDRESS},
    SUBTRACT = {"sub", THREE_ADDRESS},
    UNSIGNED_DIVISION = {"udiv", THREE_ADDRESS},
    UNSIGNED_REMAINDER  = {"urem", THREE_ADDRESS},

    // Memory
    STORE_DOUBLE = {"stored", TWO_ADDRESS_NO_RET},
    STORE_SINGLE = {"stores", TWO_ADDRESS_NO_RET},
    STORE_LONG = {"storel", TWO_ADDRESS_NO_RET},
    STORE_WORD = {"storew", TWO_ADDRESS_NO_RET},
    STORE_HALF = {"storeh", TWO_ADDRESS_NO_RET},
    STORE_BYTE = {"storeb", TWO_ADDRESS_NO_RET},

    LOAD_DOUBLE = {"loadd", TWO_ADDRESS},
    LOAD_SINGLE = {"loads", TWO_ADDRESS},
    LOAD_LONG = {"loadl", TWO_ADDRESS},
    LOAD_WORD = {"loadw", TWO_ADDRESS},
    LOAD_SIGNED_HALF = {"loadsh", TWO_ADDRESS},
    LOAD_SIGNED_BYTE = {"loadsb", TWO_ADDRESS},
    LOAD_UNSIGNED_HALF = {"loaduh", TWO_ADDRESS},
    LOAD_UNSIGNED_BYTE = {"loadub", TWO_ADDRESS},
    
    BLIT = {"blit", THREE_ADDRESS_NO_RET},
    
    ALLOCATE_ALIGN_4 = {"alloc4", TWO_ADDRESS},
    ALLOCATE_ALIGN_8 = {"alloc8", TWO_ADDRESS},
    ALLOCATE_ALIGN_16 = {"alloc16", TWO_ADDRESS},

    // Comparisons
    COMPARE_EQUALITY_LONG = {"ceql", THREE_ADDRESS},
    COMPARE_EQUALITY_WORD = {"ceqw", THREE_ADDRESS},
    COMPARE_INEQUALITY_LONG = {"cnel", THREE_ADDRESS},
    COMPARE_INEQUALITY_WORD = {"cnew", THREE_ADDRESS},
    COMPARE_SIGNED_LOWER_OR_EQUAL_LONG = {"cslel", THREE_ADDRESS},
    COMPARE_SIGNED_LOWER_OR_EQUAL_WORD = {"cslew", THREE_ADDRESS},
    COMPARE_SIGNED_LOWER_LONG = {"csltl", THREE_ADDRESS},
    COMPARE_SIGNED_LOWER_WORD = {"csltw", THREE_ADDRESS},
    COMPARE_SIGNED_GREATER_OR_EQUAL_LONG = {"csgel", THREE_ADDRESS},
    COMPARE_SIGNED_GREATER_OR_EQUAL_WORD = {"csgew", THREE_ADDRESS},
    COMPARE_SIGNED_GREATER_LONG = {"csgtl", THREE_ADDRESS},
    COMPARE_SIGNED_GREATER_WORD = {"csgtw", THREE_ADDRESS},
    COMPARE_UNSIGNED_LOWER_OR_EQUAL_LONG = {"culel", THREE_ADDRESS},
    COMPARE_UNSIGNED_LOWER_OR_EQUAL_WORD = {"culew", THREE_ADDRESS},
    COMPARE_UNSIGNED_LOWER_LONG = {"cultl", THREE_ADDRESS},
    COMPARE_UNSIGNED_LOWER_WORD = {"cultw", THREE_ADDRESS},
    COMPARE_UNSIGNED_GREATER_OR_EQUAL_LONG = {"cugel", THREE_ADDRESS},
    COMPARE_UNSIGNED_GREATER_OR_EQUAL_WORD = {"cugew", THREE_ADDRESS},
    COMPARE_UNSIGNED_GREATER_LONG = {"cugtl", THREE_ADDRESS},
    COMPARE_UNSIGNED_GREATER_WORD = {"cugtw", THREE_ADDRESS},

    
    COMPARE_EQUALITY_DOUBLE = {"ceqd", THREE_ADDRESS},
    COMPARE_EQUALITY_SINGLE = {"ceqs", THREE_ADDRESS},
    COMPARE_INEQUALITY_DOUBLE = {"cned", THREE_ADDRESS},
    COMPARE_INEQUALITY_SINGLE = {"cnes", THREE_ADDRESS},
    COMPARE_LOWER_OR_EQUAL_DOUBLE = {"cled", THREE_ADDRESS},
    COMPARE_LOWER_OR_EQUAL_SINGLE = {"cles", THREE_ADDRESS},
    COMPARE_LOWER_DOUBLE = {"cltd", THREE_ADDRESS},
    COMPARE_LOWER_SINGLE = {"clts", THREE_ADDRESS},
    COMPARE_GREATER_OR_EQUAL_DOUBLE = {"cged", THREE_ADDRESS},
    COMPARE_GREATER_OR_EQUAL_SINGLE = {"cges", THREE_ADDRESS},
    COMPARE_GREATER_DOUBLE = {"cgtd", THREE_ADDRESS},
    COMPARE_GREATER_SINGLE = {"cgts", THREE_ADDRESS},
    COMPARE_ORDERED_DOUBLE = {"cod", THREE_ADDRESS},
    COMPARE_ORDERED_SINGLE = {"cos", THREE_ADDRESS},
    COMPARE_UNORDERED_DOUBLE = {"cuod", THREE_ADDRESS},
    COMPARE_UNORDERED_SINGLE = {"cuos", THREE_ADDRESS},

    // Conversions
    SIGN_EXTEND_WORD = {"extsw", TWO_ADDRESS},
    ZERO_EXTEND_WORD = {"extuw", TWO_ADDRESS},
    SIGN_EXTEND_HALF = {"extsh", TWO_ADDRESS},
    ZERO_EXTEND_HALF = {"extuh", TWO_ADDRESS},
    SIGN_EXTEND_BYTE = {"extsb", TWO_ADDRESS},
    ZERO_EXTEND_BYTE = {"extub", TWO_ADDRESS},
    EXTEND_SINGLE = {"exts", TWO_ADDRESS},
    TRUNCATE_DOUBLE = {"truncd", TWO_ADDRESS},
    SINGLE_TO_SIGNED = {"stosi", TWO_ADDRESS},
    SINGLE_TO_UNSIGNED = {"stoui", TWO_ADDRESS},
    DOUBLE_TO_SIGNED = {"dtosi", TWO_ADDRESS},
    DOUBLE_TO_UNSIGNED = {"dtoui", TWO_ADDRESS},
    SIGNED_WORD_TO_FLOAT = {"swtof", TWO_ADDRESS},
    UNSIGNED_WORD_TO_FLOAT = {"uwtof", TWO_ADDRESS},
    SIGNED_LONG_TO_FLOAT = {"sltof", TWO_ADDRESS},
    UNSIGNED_LONG_TO_FLOAT = {"ultof", TWO_ADDRESS},

    CAST = {"cast", TWO_ADDRESS},
    COPY = {"copy", TWO_ADDRESS},

    // Call
    CALL = {"call", CALL},

    // Variadic
    VARIADIC_START = {"vastart", ONE_ADDRESS},
    VARIADIC_ARG = {"vaarg", TWO_ADDRESS},

    // Phi
    PHI = {"phi", PHI},

    // Jumps
    UNCONDITIONAL_JUMP = {"jmp", JUMP},
    CONDITIONAL_JUMP = {"jnz", CONDITIONAL},
    RETURN = {"ret", RETURN},
    HALT = {"hlt", HALT},
}

struct ThreeAddress {
    Identifier return_name;
    TypeReference return_type;
    Value a;
    Value b;
}

struct ThreeAddressNoReturn {
    Value a;
    Value b;
    Value c;
}

struct TwoAddress {
    Identifier return_name;
    TypeReference return_type;
    Value a;
}

struct TwoAddressNoReturn {
    Value a;
    Value b;
}

struct OneAddress {
    Value a;
}

struct Jump {
    Block* where;
}

struct Conditional {
    Value condition;
    Block* success;
    Block* failure;
}

struct Return {
    Value retval;
}


/**
 *  Represents a single arm in a phi instruction
 */
struct PhiBranch {
    // The block that predicates the value
    Block* from;
    // The value to be given
    Value value;
}
def PhiList = List(<PhiBranch>);

/**
 *  Add a branch to a phi list
 *
 *  @param [&in] from   "The predicate block"
 *  @param value        "The value to set"
 */
macro PhiList.branch(&self, Block* from, value) {
    self.push({
        .from = from,
        .value = create_value(value)
    });
}

struct Phi {
    Identifier return_name;
    TypeReference return_type;
    PhiList branches;
}

enum CallArgType {
    ENV,
    VARIADIC,
    TYPED
}

/**
 *  Represents a single call argument
 */
struct CallArg {
    // The type of the call argument
    CallArgType type;
    // The datatype of the call argument
    TypeReference argument_type;
    // The value of the call argument
    Value value;
}

def CallList = List(<CallArg>);

/**
 *  Add var args to a parameter list
 */
fn void CallList.var_args(&self) {
    self.push({
        .type = VARIADIC
    });
}

/**
 *  Add an env parameter to a parameter list
 *
 *  @param e                    "The env parameter"
 *
 *  @require self.size == 0     `Env parameters must be the first parameter`
 */
fn void CallList.add_env(&self, Value e) {
    self.push({
        .type = ENV,
        .value = e
    });
}

/**
 *  Add an env parameter to a parameter list, automatically converting it to a value
 *
 *  @param e                    "The env parameter"
 *
 *  @require self.size == 0     `Env parameters must be the first parameter`
 */
macro CallList.env(&self, e) {
    self.add_env(create_value(e));
}

/**
 *  Add an argument to a parameter list
 *  
 *  @param t                    "The type of the parameter"
 *  @param a                    "The argument value"
 *
 *  @require t.type != NONE     `Parameter type cannot be TYPE_VOID`
 */
fn void CallList.add_arg(&self, TypeReference t, Value a) {
    self.push({
        .type = TYPED,
        .argument_type = t,
        .value = a
    });
}

/**
 *  Add an argument to a parameter list, automatically converting it to a value
 *  
 *  @param t                    "The type of the parameter"
 *  @param a                    "The argument value"
 *
 *  @require t.type != NONE     `Parameter type cannot be TYPE_VOID`
 */
macro CallList.arg(&self, TypeReference t, a) {
    self.add_arg(t, create_value(a));
}


struct Call {
    TypeReference return_type; // If this is none, then we don't have a return value
    Identifier return_name;
    Value method;
    CallList arguments;
}

struct Instruction {
    InstructionType type;
    union {
        ThreeAddress three_address;
        ThreeAddressNoReturn three_address_no_return;
        TwoAddress two_address;
        TwoAddressNoReturn two_address_no_return;
        OneAddress one_address;
        Jump jump;
        Conditional conditional;
        Return ret;
        Phi phi;
        Call call;
    }
}

/**
 *  Get the QBE textual representation of an instruction
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String Instruction.get_string(&self) {
    DString str = dstring::temp_new();
    bool started = false;
    switch (self.type.arg_type) {
        case THREE_ADDRESS:
            str.appendf("%s =%s %s %s, %s", self.three_address.return_name.get_string(), self.three_address.return_type.get_string(), self.type.textual,  self.three_address.a.get_string(), self.three_address.b.get_string());
        case THREE_ADDRESS_NO_RET:
            str.appendf("%s %s, %s, %s", self.type.textual, self.three_address_no_return.a.get_string(), self.three_address_no_return.b.get_string(), self.three_address_no_return.c.get_string());
        case TWO_ADDRESS:
            str.appendf("%s =%s %s %s", self.two_address.return_name.get_string(), self.two_address.return_type.get_string(), self.type.textual, self.two_address.a.get_string());
        case TWO_ADDRESS_NO_RET:
            str.appendf("%s %s, %s", self.type.textual, self.two_address_no_return.a.get_string(), self.two_address_no_return.b.get_string());
        case ONE_ADDRESS:
            str.appendf("%s %s", self.type.textual, self.one_address.a.get_string());
        case JUMP:
            str.appendf("%s @%s", self.type.textual, self.jump.where.name.str_view());
        case CONDITIONAL:
            str.appendf("%s %s, @%s, @%s", self.type.textual, self.conditional.condition.get_string(), self.conditional.success.name.str_view(), self.conditional.failure.name.str_view());
        case RETURN:
            if (self.ret.retval.type == NONE) {
                str.appendf("%s", self.type.textual);
            } else {
                str.appendf("%s %s", self.type.textual, self.ret.retval.get_string());
            }
        case PHI:
            Phi* phi = &self.phi;
            str.appendf("%s =%s %s ", phi.return_name.get_string(), phi.return_type.get_string(), self.type.textual);
            foreach (PhiBranch* &branch : phi.branches) {
                if (started) {
                    str.append(", ");
                }
                started = true;
                str.appendf("@%s %s",branch.from.name, branch.value.get_string());
            }
        case CALL:
            Call* call = &self.call;
            if (call.return_type.type != NONE) {
                str.appendf("%s =%s ", call.return_name.get_string(), call.return_type.get_string());
            }
            str.appendf("%s %s(", self.type.textual, call.method.get_string());
            foreach (CallArg* &arg : call.arguments) {
                if (started) {
                    str.append(", ");
                }
                started = true;
                switch (arg.type) {
                    case ENV:
                        str.appendf("env %s", arg.value.get_string());
                    case VARIADIC:
                        str.append("...");
                    case TYPED:
                        str.appendf("%s %s", arg.argument_type.get_string(), arg.value.get_string());
                }
            }
            str.append(')');
        default:
            str.appendf("%s", self.type.textual);
    }
    return str.str_view();
}


/**
 *  Free an instruction, automatically called by Block.free
 */
fn void Instruction.free(&self) {
    switch (self.type.arg_type) {
        case CALL:
            self.call.arguments.free();
        case PHI:
            self.phi.branches.free();
        default:
            break;
    }
}