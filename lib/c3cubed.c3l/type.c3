module c3cubed;
import std::collections::list;
/*                    Types                                                    */

enum AggregateType {
    AGGREGATE,
    UNION,
    OPAQUE
}

struct AggregateMember {
    TypeReference ref;
    uint amount; // This is by default 0, anything other than 0 is specified
}

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

struct Type {
    DString name;
    DString header_comment;
    Module* parent;
    Allocator allocator;
    uint align;
    AggregateType type;
    union {
        uint size;
        AggregateList aggregate_members;
        UnionList union_members;
    }
}

/*
 * @require !self.allocator "Type has already been initialized!"
 */
fn void Type.initialize(&self, Module* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);
    self.type = OPAQUE;
}

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

fn void Type.set_align(&self, uint align) {
    self.align = align;
}

fn void Type.set_size(&self, uint size) {
    self.set_type(OPAQUE);
    self.size = size;
}

fn void Type.add_aggregate_member(&self, AggregateMember member) {
    self.set_type(AGGREGATE);
    self.aggregate_members.push(member);
}

fn usz Type.make_union_member(&self) {
    self.set_type(UNION);
    AggregateList list;
    list.new_init(TYPE_CAPACITY, self.allocator);
    usz current = self.union_members.size;
    self.union_members.push(list);
    return current;
}

fn void Type.add_to_union_member(&self, usz idx, AggregateMember member) {
    self.union_members[idx].push(member);
}


fn TypeReference Type.reference(&self) {
    return {
        .type = AGGREGATE,
        .aggregate_name = self.name.str_view()
    };
}

fn void Type.set_header(&self, String header = "") {
    self.header_comment = dstring::new(header,self.allocator);
}

// This will use the temporary allocator, as it's meant to be called from Module.write inside it's pool
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


/*                    Type References                                          */
enum TypeReferenceType : char (bool firstClass){
    NONE = false,
    WORD = true,
    LONG = true,
    SINGLE = true,
    DOUBLE = true,
    BYTE = false,
    HALF = false,
    UWORD = false,
    ULONG = false,
    UBYTE = false,
    UHALF = false,
    AGGREGATE = false
}

struct TypeReference {
    TypeReferenceType type;
    String aggregate_name;
}

fn String TypeReference.get_string(&self) {
    switch (self.type) {
        case NONE:
            return dstring::new("",allocator::temp()).str_view();
        case WORD:
            return dstring::new("w",allocator::temp()).str_view();
        case LONG:
            return dstring::new("l",allocator::temp()).str_view();
        case SINGLE:
            return dstring::new("s",allocator::temp()).str_view();
        case DOUBLE:
            return dstring::new("d",allocator::temp()).str_view();
        case BYTE:
            return dstring::new("b",allocator::temp()).str_view();
        case HALF:
            return dstring::new("h",allocator::temp()).str_view();
        case UWORD:
            return dstring::new("uw",allocator::temp()).str_view();
        case ULONG:
            return dstring::new("ul",allocator::temp()).str_view();
        case UBYTE:
            return dstring::new("ub",allocator::temp()).str_view();
        case UHALF:
            return dstring::new("uh",allocator::temp()).str_view();
        case AGGREGATE:
            DString str = dstring::new(":",allocator::temp());
            str.append(self.aggregate_name);
            return str.str_view();
    }
}
const TypeReference TYPE_VOID = {
    .type = NONE
};

const TypeReference TYPE_WORD = {
    .type = WORD
};

const TypeReference TYPE_LONG = {
    .type = LONG
};

const TypeReference TYPE_SINGLE = {
    .type = SINGLE
};

const TypeReference TYPE_DOUBLE = {
    .type = DOUBLE
};

const TypeReference TYPE_BYTE = {
    .type = BYTE
};

const TypeReference TYPE_HALF = {
    .type = HALF
};

const TypeReference TYPE_UWORD = {
    .type = UWORD
};

const TypeReference TYPE_ULONG = {
    .type = ULONG
};

const TypeReference TYPE_UBYTE = {
    .type = UBYTE
};

const TypeReference TYPE_UHALF = {
    .type = UHALF
};