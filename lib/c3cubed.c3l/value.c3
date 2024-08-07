module c3cubed;
import std::collections::list;
import std::io;

/**
 *  Represents the type of a value used in an instruction in QBE
 */
enum ValueType : char (String info) {
    // This represents the absence of a value, only used in ret instructions
    NONE = "none",
    // This represents an integer value (N)
    INTEGER = "integer",
    // This represents a float value (f_)
    FLOAT = "single",
    // This represents a double value (d_)
    DOUBLE = "double",
    // This represents a symbol value (SYM)
    SYMBOL = "symbol",
    // THis represents a thread local symbol value (thread SYM)
    THREAD_LOCAL_SYMBOL = "thread local symbol"
}

/**
 *  Represents a value used in an instruction in QBE
 */
struct Value {
    // The type of value
    ValueType type;
    union {
        // type = INTEGER -> the integer value
        ulong integer;
        // type = FLOAT -> the float value
        float flt;
        // type = DOUBLE -> the double value
        double dbl;
        // type = SYMBOL | THREAD_LOCAL_SYMBOL -> the symbol
        Identifier symbol;
    }
}

/**
 *  Create a value from an input, automatically converting integer values, floating point values, identifiers, data references, and function references to a value
 *  @param in   "The value to make a Value from"
 */
macro create_value(in) {
    $switch
        $case $typeof(in).typeid == ulong.typeid:
            return Value {
                .type = INTEGER,
                .integer = in
            };
        $case $typeof(in).typeid == uint.typeid:
            return Value{
                .type = INTEGER,
                .integer = (ulong)in
            };
        $case $typeof(in).typeid == long.typeid:
            return Value{
                .type = INTEGER,
                .integer = bitcast(in, ulong)
            };
        $case $typeof(in).typeid == int.typeid:
            return Value{
                .type = INTEGER,
                .integer = (ulong)bitcast(in, uint)
            };
        $case $typeof(in).typeid == ushort.typeid:
            return Value{
                .type = INTEGER,
                .integer = (ulong)in
            };
        $case $typeof(in).typeid == short.typeid:
            return Value{
                .type = INTEGER,
                .integer = (ulong)bitcast(in, ushort)
            };
        $case $typeof(in).typeid == ichar.typeid:
            return Value{
                .type = INTEGER,
                .integer = (ulong)bitcast(in, char)
            };
        $case $typeof(in).typeid == char.typeid:
            return Value{
                .type = INTEGER,
                .integer = (ulong)in
            };
        $case $typeof(in).typeid == float.typeid:
            return Value{
                .type = FLOAT,
                .flt = in
            };
        $case $typeof(in).typeid == double.typeid:
            return Value{
                .type = DOUBLE,
                .dbl = in
            };
        $case $typeof(in).typeid == Identifier.typeid:
            return Value{
                .type = SYMBOL,
                .symbol = in
            };
        $case $typeof(in).typeid == Data*.typeid:
            return Value{
                .type = SYMBOL,
                .symbol = in.reference()
            };
        $case $typeof(in).typeid == Function*.typeid:
            return Value{
                .type = SYMBOL,
                .symbol = in.reference()
            };
        $case $typeof(in).typeid == Value.typeid:
            return in;
        $default:
            return Value{
                .type = NONE
            };
    $endswitch
}

/**
 *  Get the QBE textual representation of a value
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String Value.get_string(&self) {
    DString str;
    str.temp_init();
    switch (self.type) {
        case INTEGER:
            str.appendf("%d",self.integer);
        case FLOAT:
            str.append("f_");
            str.appendf("%f",self.flt);
        case DOUBLE:
            str.append("d_");
            str.appendf("%f",self.dbl);
        case SYMBOL:
            str.append(self.symbol.get_string());
        default:
            break;
    }
    return str.str_view();
}

// A default uninitialized value, used for return instructions
const Value NO_VALUE = {.type = NONE};