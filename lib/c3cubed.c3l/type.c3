module c3cubed;
import std::collections::list;

/**
 *  Represents the type of a type declaration
 */
enum AggregateType {
    AGGREGATE,
    UNION,
    OPAQUE
}

/**
 *  Represents a member in an aggregate type declaration or in a union variant
 */
struct AggregateMember {
    // The type of the member
    TypeReference ref;
    // The array length of the member (if non-zero)
    uint amount;
}

/**
 *  Gets the QBE textual representation of an aggregate member
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String AggregateMember.get_string(&self) {
    DString str;
    str.temp_init();
    str.append(self.ref.get_string());
    if (self.amount > 0) {
        str.appendf(" %d", self.amount);
    }
    str.append(", ");
    return str.str_view();
}

def AggregateList = List(<AggregateMember>);
def UnionList = List(<AggregateList>);

/**
 *  Represents a QBE type declaration.
 */
struct Type {
    // The name of the type
    DString name;
    // The header comment for the type
    DString header_comment;
    // The module that the type 
    Module* parent;
    // The allocator that the type uses
    Allocator allocator;
    // The alignment of the type (corresponds to the QBE 'align') declaraation
    uint align;
    // The type of type declaration, defaults to OPAQUE
    AggregateType type;
    union {
        // If the type declaration is OPAQUE, this contains the size of the type in bytes
        uint size;
        // If the type declaration is AGGREGATE, this contains the list of aggregate members
        AggregateList aggregate_members;
        UnionList union_members;
    }
}

/**
 *  Initializes a type declaration, this is automatically called by Module.register_type
 *
 *  @param parent   "The parent module of the type declaration"
 *  @param name     "The name of the type declaration, can be a temporarily allocated string"
 *
 *  @require !self.allocator `Type declaration has already been initialized!`
 */
fn void Type.initialize(&self, Module* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);
    self.type = OPAQUE;
}

/**
 *  Sets the type of a type declaration
 *
 *  @param type     "The type of the type declaration to be set"  
 */
fn void Type.set_type(&self, AggregateType type) {
    if (type == self.type) {
        return;
    }
    switch (self.type) {
        case AGGREGATE:
            self.aggregate_members.free();
            self.aggregate_members = {};
        case UNION:
            foreach (AggregateList list : self.union_members) {
                list.free();
            }
            self.union_members.free();
            self.union_members = {};
        default:
            break;
    }
    self.type = type;
    switch (type) {
        case AGGREGATE:
            self.aggregate_members.new_init(TYPE_CAPACITY,self.allocator);
        case UNION:
            self.union_members.new_init(TYPE_CAPACITY,self.allocator);
        default:
            break;
    }
}

/**
 *  Sets the alignment of a type
 *
 *  @param align    "The alignment to be set"
 */
fn void Type.set_align(&self, uint align) {
    self.align = align;
}

/**
 *  Sets the size of an opaque type declaration
 *
 *  @param size     "The size of the opaque type"
 *
 *  @require self.type == OPAQUE    `Type declaration is not for an opaque type, use set_type(OPAQUE) to make the type opaque`
 */
fn void Type.set_size(&self, uint size) {
    self.size = size;
}

/**
 *  Adds a member to an aggregate type declaration
 *
 *  @param member   "The member to add to the type declaration"
 *
 *  @require self.type == AGGREGATE `Type declaration is not for an aggregate type, use set_type(AGGREGATE) to make the type an aggregate`
 */
fn void Type.add_aggregate_member(&self, AggregateMember member) {
    self.aggregate_members.push(member);
}

/**
 *  Creates a union variant in a union type declaration
 *
 *  @return "The index of the union variant"
 *
 *  @require self.type == UNION    `Type declaration is not for a union type, use set_type(UNION) to make the type a union`
 */
fn usz Type.make_union_member(&self) {
    AggregateList list;
    list.new_init(TYPE_CAPACITY, self.allocator);
    usz current = self.union_members.size;
    self.union_members.push(list);
    return current;
}

/**
 *  Adds a member to a union variant on a union type
 *
 *  @param idx      "The union variant index"
 *  @param member   "The member to add to the union variant"
 *
 *  @require self.type == UNION             `Type declaration is not for a union type, use set_type(UNION) to make the type a union`
 *  @require idx < self.union_members.size  `Index is out of range for the amount of union variants on the given union type`
 */
fn void Type.add_to_union_member(&self, usz idx, AggregateMember member) {
    self.union_members[idx].push(member);
}

/**
 *  Gets a TypeReference for the type
 *
 *  @return     "A TypeReference referencing the type declaration"
 */
fn TypeReference Type.reference(&self) {
    return {
        .type = AGGREGATE,
        .aggregate_name = self.name.str_view()
    };
}

/**
 *  Set the header comment for the type declaration, that is the comment that comes before the declaration itself
 * 
 *  @param header "Header comment, can be temporarily allocated, and can be multiline"
 */
fn void Type.set_header(&self, String header = "") {
    if (self.header_comment) {
        self.header_comment.free();
    }
    self.header_comment = dstring::new(header,self.allocator);
}

/**
 *  Get the QBE textual representation of the type declaration
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String Type.get_string(&self) {
    DString result;
    result.temp_init();
    if (self.header_comment) {
        append_header(&result, self.header_comment.str_view());
    }
    result.appendf("type :%s = ", self.name.str_view());
    if (self.align != 0) {
        result.appendf("align %d ", self.align);
    }
    result.append("{ ");

    switch (self.type) {
        case OPAQUE:
            result.appendf("%d ", self.size);
        case AGGREGATE:
            foreach (AggregateMember member : self.aggregate_members) {
                result.append(member.get_string());
            }
        case UNION:
            foreach (AggregateList list : self.union_members) {
                result.append("{ ");
                foreach (AggregateMember member : list) {
                    result.append(member.get_string());
                }
                result.append("}, ");
            }
    }

    result.append("}\n");
    return result.str_view();
}

/**
 *  Free the type declaration, this is called automatically by Module.free
 */
fn void Type.free(&self) {
    self.name.free();
    self.header_comment.free();
    switch (self.type) {
        case AGGREGATE:
            self.aggregate_members.free();
        case OPAQUE:
            foreach (AggregateList list : self.union_members) {
                list.free();
            }
            self.union_members.free();
        default:
    }
}


/**
 *  Represents the type of a type reference
 */
enum TypeReferenceType : char (bool base_type, bool extended_type, bool store_load_type, bool parameter_type, bool integer_type, bool float_type, String format){
    // represents the absence of a type, used only in function return types, and return statements
    NONE = {false, false, false, false, false, false, ""},
    // represents the QBE type "w", a 32 bit integer
    WORD = {true, true, true, true, true, false, "w"},
    // represents the QBE type "l", a 64 bit integer
    LONG = {true, true, true, true, true, false, "l"},
    // represents the QBE type "s", a 32 bit floating point number
    SINGLE = {true, true, true, true, false, true, "s"},
    // represents the QBE type "d", a 64 bit floating point number
    DOUBLE = {true, true, true, true, false, true, "d"},
    // represents the QBE type "b", an 8 bit integer
    BYTE = {false, true, true, true, true, false, "b"},
    // represents the QBE type "h", a 16 bit integer
    HALF = {false, true, true, true, true, false, "h"},
    // represents the QBE type "w", a 32 bit integer, but explicitly unsigned for generating conversions
    UWORD = {true, true, true, true, true, false, "w"},
    // represents the QBE type "l", a 64 bit integer, but explicitly unsigned for generating conversions
    ULONG = {true, true, true, true, true, false, "l"},
    // represents the QBE type "ub", an 8 bit unsigned integer
    UBYTE = {false, false, true, true, true, false, "ub"},
    // represents the QBE type "uh", a 16 bit unsigned integer
    UHALF = {false, false, true, true, true, false, "uh"},
    // represents the QBE type "sb", an 8 bit signed integer
    SBYTE = {false, false, true, true, true, false, "sb"},
    // represents the QBE type "sh", a 16 bit signed integer
    SHALF = {false, false, true, true, true, false, "sh"},
    // represents QBE aggregate types (those prefixed by ":")
    AGGREGATE = {false, false, false, true, false, false, ":%s"},
}

/**
 *  Represents a type keyword in QBE
 */
struct TypeReference {
    TypeReferenceType type;
    String aggregate_name;
}

/**
 *  Get the QBE textual representation of the type reference
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String TypeReference.get_string(&self) {
    DString str;
    str.temp_init();
    str.appendf(self.type.format, self.aggregate_name);
    return str.str_view();
}

// Represents the absence of a type, used only in function return types, and return statements 
const TypeReference TYPE_VOID = {
    .type = NONE
};

// represents the QBE type "w", a 32 bit integer
const TypeReference TYPE_WORD = {
    .type = WORD
};

// represents the QBE type "l", a 64 bit integer
const TypeReference TYPE_LONG = {
    .type = LONG
};

// represents the QBE type "s", a 32 bit floating point number
const TypeReference TYPE_SINGLE = {
    .type = SINGLE
};

// represents the QBE type "d", a 64 bit floating point number
const TypeReference TYPE_DOUBLE = {
    .type = DOUBLE
};

// represents the QBE type "b", an 8 bit integer
const TypeReference TYPE_BYTE = {
    .type = BYTE
};

// represents the QBE type "h", a 16 bit integer
const TypeReference TYPE_HALF = {
    .type = HALF
};

// represents the QBE type "w", a 32 bit integer, but explicitly unsigned for generating conversions
const TypeReference TYPE_UWORD = {
    .type = UWORD
};

// represents the QBE type "w", a 32 bit integer, but explicitly signed for generating conversions
const TypeReference TYPE_SWORD = {
    .type = WORD
};

// represents the QBE type "l", a 64 bit integer, but explicitly unsigned for generating conversions
const TypeReference TYPE_ULONG = {
    .type = ULONG
};

// represents the QBE type "l", a 64 bit integer, but explicitly signed for generating conversions
const TypeReference TYPE_SLONG = {
    .type = LONG
};

// represents the QBE type "ub", an 8 bit unsigned integer
const TypeReference TYPE_UBYTE = {
    .type = UBYTE
};

// represents the QBE type "sb", an 8 bit signed integer
const TypeReference TYPE_SBYTE = {
    .type = SBYTE
};

// represents the QBE type "uh", a 16 bit unsigned integer
const TypeReference TYPE_UHALF = {
    .type = UHALF
};

// represents the QBE type "sh", a 16 bit signed integer
const TypeReference TYPE_SHALF = {
    .type = SHALF
};