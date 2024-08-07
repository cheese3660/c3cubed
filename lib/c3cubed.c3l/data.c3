module c3cubed;
import std::collections::list;

def DataMemberList = List(<DataMember>);
def LinkageList = List(<Linkage>);


/**
 *  Represents the type of a data member
 */
enum DataMemberType {
    // represents QBE "z N"
    ZERO,
    // represents QBE "$sym(+N)"
    SYMBOL_OFFSET,
    // represents QBE 'T "..."'
    STRING,
    // represents QBE "T N"
    INTEGER,
    // represents QBE "T f_..."
    FLOAT,
    // represents QBE "T d_..."
    DOUBLE
}

/**
 *  Represents a member of a data declaration in QBE
 */
struct DataMember {
    // The type of the data member
    DataMemberType type;
    // The datatype of the member or string
    TypeReference datatype;
    // The integer value, or the zero size, or the symbol offset
    ulong size;
    union {
        // The symbol when type is SYMBOL_OFFSET
        Identifier ident;
        // The string when type is STRING
        String str;
        // The float when type is FLOAT
        float flt;
        // The double when type is DOUBLE
        double dbl;
    }
}

/**
 *  Get the QBE textual representation of the data member
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String DataMember.get_string(&self) {
    DString result;
    result.temp_init();
    switch (self.type) {
        case ZERO:
            result.appendf("z %d", self.size);
        case SYMBOL_OFFSET:
            if (self.size == 0) {
                result.appendf("%s %s", self.datatype.get_string(), self.ident.get_string());
            } else {
                result.appendf("%s %s+%d", self.datatype.get_string(), self.ident.get_string(), self.size);
            }
        case STRING:
            result.appendf("%s \"%s\"", self.datatype.get_string(), self.str);
        case INTEGER:
            result.appendf("%s %d", self.datatype.get_string(), self.size);
        case FLOAT:
            result.appendf("%s f_%f", self.datatype.get_string(), self.flt);
        case DOUBLE:
            result.appendf("%s d_%f", self.datatype.get_string(), self.dbl);
    }
    return result.str_view();
}

/**
 *  Represents a data declaration in QBE
 */
struct Data {
    // The name of the declaration
    DString name;
    // The header comment of the declaration
    DString header_comment;
    // The module the declaration is registered in
    Module* parent;
    
    // The alignment of the data declaration (represents "align ...")
    usz alignment;
    
    // The allocator for the data declaration
    Allocator allocator;

    // The data members of the data declaration
    DataMemberList data;
    
    // The linkage declarations attached to the data declaration
    LinkageList linkage;
}

/**
 *  Initializes a type declaration, this is automatically called by Module.register_data
 *
 *  @param parent   "The parent module of the data declaration"
 *  @param name     "The name of the data declaration, can be a temporarily allocated string"
 *
 *  @require !self.allocator `Data declaration has already been initialized!`
 */
fn void Data.initialize(&self, Module* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);

    self.data.new_init(BLOCK_CAPACITY, self.allocator);
    self.linkage.new_init(TYPE_CAPACITY, self.allocator);
}

/**
 *  Creates a global identifier to reference the data declaration
 *
 *  @return "An identifier to reference the data declaration with" 
 */
fn Identifier Data.reference(&self) {
    return {
        .type = GLOBAL,
        .identifier_name = self.name.str_view()
    };
}

/**
 *  Set the header comment for the data declaration, that is the comment that comes before the declaration itself
 * 
 *  @param header "Header comment, can be temporarily allocated, and can be multiline"
 */
fn void Data.set_header(&self, String header = "") {
    if (self.header_comment) {
        self.header_comment.free();
        self.header_comment = null;
    }
    self.header_comment = dstring::new(header,self.allocator);
}

/**
 *  Add a linkage declaration to the data declaration
 *
 *  @param l    "The linkage declaration to add"
 */
fn void Data.add_linkage(&self, Linkage l) {
    self.linkage.push(l);
}

/**
 *  Add a member to the data declaration
 *
 *  @param member   "The member to add"
 */
fn void Data.add_member(&self, DataMember member) {
    self.data.push(member);
}

/**
 *  Get the QBE textual representation of the data declaration
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
fn String Data.get_string(&self) {
    DString result;
    result.temp_init();
    if (self.header_comment) {
        append_header(&result, self.header_comment.str_view());
    }
    DString prefix;
    prefix.temp_init();
    foreach (Linkage link : self.linkage) {
        if (link.type.newline) {
            result.appendf("%s\n",link.get_string());
        } else {
            prefix.appendf("%s ", link.get_string());
        }
    }
    result.appendf("%s", prefix);
    result.append("data ");
    result.appendf("$%s = ",self.name.str_view());
    if (self.alignment != 0) {
        result.appendf("align %d ", self.alignment);
    }
    result.append("{ ");
    bool started = false;
    foreach (DataMember* &data : self.data) {
        if (started) {
            result.append(", ");
        }
        started = true;
        result.appendf("%s", data.get_string());
    }
    result.append(" }\n");
    return result.str_view();
}

/**
 *  Free the data declaration, this is called automatically by Module.free
 */
fn void Data.free(&self) {
    if (!self.allocator) {
        return;
    }
    self.name.free();
    self.header_comment.free();
    self.linkage.free();
    self.data.free();
}

/**
 *  Adds an integer value as a data member
 *  
 *  @param value    "The integer value to add"
 *  @param t        "The type of the value to add"
 *
 *  @require t.type.integer_type    `Data type is not an integer type`
 */
fn void Data.add_integer(&self, ulong value, TypeReference t = TYPE_LONG) {
    self.add_member({
        .type = INTEGER,
        .datatype = t,
        .size = value
    });
}

/**
 *  Adds a zero declaration as a data member
 *
 *  @param amount   "The amount to zero"
 */
fn void Data.zero(&self, ulong amount) {
    self.add_member({
        .type = ZERO,
        .size = amount
    });
}

/**
 *  Adds a symbol as a data member
 *  
 *  @param ident    "The symbol to reference"
 *  @param offset   "The offset to the symbol"
 */
fn void Data.add_symbol(&self, Identifier ident, ulong offset=0) {
    self.add_member({
        .type = SYMBOL_OFFSET,
        .size = offset,
        .ident = ident
    });
}

/**
 *  Adds a float as a data member
 *
 *  @param flt  "The value to add"
 */
fn void Data.add_float(&self, float flt) {
    self.add_member({
        .type = FLOAT,
        .datatype = TYPE_SINGLE,
        .flt = flt
    });
}

/**
 *  Adds a double as a data member
 *
 *  @param dbl  "The value to add"
 */
fn void Data.add_double(&self, double dbl) {
    self.add_member({
        .type = DOUBLE,
        .datatype = TYPE_DOUBLE,
        .dbl = dbl
    });
}

/**
 *  Adds a string as possibly multiple data members, split on control characters and `"`
 *
 *  @param v        "The string to add"
 *  @param zstring  "Null terminate the string?"
 *  @param t        "The type of the characters in the string"
 *
 *  @require t.type.integer_type    `Character type is not an integer type`
 */
fn void Data.add_string(&self, String v, bool zstring=true, TypeReference t = TYPE_BYTE) {
    // Now we have to loop over the strings and get them interned by where breaks happen
    @pool() {
        DString temp_str;
        temp_str.temp_init();
        foreach (char c : v) {
            if (c < 32 || c > 127 || c == '"') {
                if (temp_str.len() > 0) {
                    self.add_member(self.parent.import_string(temp_str.str_view(),t));
                    temp_str.clear();
                }
                self.add_integer((ulong)c,t);
            } else {
                temp_str.append(c);
            }
        }
        if (temp_str.len() > 0) {
            self.add_member(self.parent.import_string(temp_str.str_view(),t));
        }
    };
    if (zstring) {
        self.add_integer(0,t);
    }
}