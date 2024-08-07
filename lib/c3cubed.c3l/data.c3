module c3cubed;
import std::collections::list;

def DataList = List(<DataMember>);
def LinkageList = List(<Linkage>);


enum DataMemberType {
    ZERO,
    SYMBOL_OFFSET,
    STRING,
    INTEGER,
    FLOAT,
    DOUBLE
}

struct DataMember {
    DataMemberType type;
    // Since this is used in 2/3 cases
    TypeReference datatype;
    ulong size; // This is used in symbol_offset and 0
    union {
        Identifier ident;
        String str;
        float flt;
        double dbl;
    }
}

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

struct Data {
    DString name;
    DString header_comment;
    Module* parent;
    
    usz alignment;
    Allocator allocator;
    DataList data;
    LinkageList linkage;
}

fn void Data.initialize(&self, Module* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);

    self.data.new_init(BLOCK_CAPACITY, self.allocator);
    self.linkage.new_init(TYPE_CAPACITY, self.allocator);
}


fn Identifier Data.reference(&self) {
    return {
        .type = GLOBAL,
        .identifier_name = self.name.str_view()
    };
}

fn void Data.set_header(&self, String header = "") {
    self.header_comment = dstring::new(header,self.allocator);
}

fn void Data.add_linkage(&self, Linkage l) {
    self.linkage.push(l);
}

fn void Data.add_member(&self, DataMember member) {
    self.data.push(member);
}

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

fn void Data.free(&self) {
    if (!self.allocator) {
        return;
    }
    self.name.free();
    self.header_comment.free();
    self.linkage.free();
    self.data.free();
}

fn void Data.add_integer(&self, ulong value, TypeReference t = TYPE_LONG) {
    self.add_member({
        .type = INTEGER,
        .datatype = t,
        .size = value
    });
}

fn void Data.zero(&self, ulong amount) {
    self.add_member({
        .type = ZERO,
        .size = amount
    });
}

fn void Data.add_symbol(&self, Identifier ident, ulong offset=0) {
    self.add_member({
        .type = SYMBOL_OFFSET,
        .size = offset,
        .ident = ident
    });
}

fn void Data.add_float(&self, float flt) {
    self.add_member({
        .type = FLOAT,
        .datatype = TYPE_SINGLE,
        .flt = flt
    });
}

fn void Data.add_double(&self, double dbl) {
    self.add_member({
        .type = DOUBLE,
        .datatype = TYPE_DOUBLE,
        .dbl = dbl
    });
}

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