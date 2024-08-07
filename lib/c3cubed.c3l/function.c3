module c3cubed;

import std::collections::list;
def BlockList = List(<Block*>);
def ParameterList = List(<Parameter>);

struct Parameter {
    TypeReference type;
    DString name;
}

struct Function {
    DString name;

    DString header_comment;

    DString env;

    Module* parent;

    BlockList blocks;

    Block* current_block;

    Allocator allocator;

    uint next_temp_name;
    uint next_block_name;

    TypeReference return_type;

    bool variadic;

    LinkageList linkage;

    ParameterList parameters;
}

/*
 * @require !self.allocator "Function has already been initialized!"
 */
fn void Function.initialize(&self, Module* parent, String name) {
    self.parent = parent;
    self.allocator = parent.allocator;
    self.name = dstring::new(name,self.allocator);
    self.return_type = TYPE_VOID;
    self.blocks.new_init(BLOCK_CAPACITY, self.allocator);
    self.linkage.new_init(TYPE_CAPACITY, self.allocator);
    self.parameters.new_init(TYPE_CAPACITY, self.allocator);
}

fn Identifier Function.add_env(&self, String name) {
    self.env = dstring::new(name, self.allocator);
    return make_identifier(self.env.str_view());
}

fn Identifier Function.add_parameter(&self, TypeReference type, String name) {
    DString owned = dstring::new(name, self.allocator);
    self.parameters.push({
        .type = type,
        .name = owned
    });
    return make_identifier(owned.str_view());
}

fn Identifier Function.reference(&self) {
    return {
        .type = GLOBAL,
        .identifier_name = self.name.str_view()
    };
}
fn void Function.set_return_type(&self, TypeReference type) {
    self.return_type = type;
}

// This begins a block, but does not yet add it to the current function
fn Block* Function.begin_block(&self, String name="") {
    Block* block = allocator::alloc(self.allocator, Block);
    @pool() {
        if (name.len == 0) {
            if (self.next_block_name == 0) {
                name = "start";
                self.next_block_name++;
            } else {
                DString new_name;
                new_name.temp_init();
                new_name.appendf("_%d", self.next_block_name++);
                name = new_name.str_view();
            }
        }
        block.initialize(self, name);
    };
    return block;
}

fn Block* Function.begin_and_add_block(&self, String name="") {
    Block* block = self.begin_block(name);
    self.add_block(block);
    return block;
}

fn void Function.add_block(&self, Block* block) {
    self.blocks.push(block);
    self.current_block = block;
}

fn Identifier Function.next_temporary(&self) {
    return {
        .type = TEMPORARY,
        .temp_ident = self.next_temp_name++
    };
}

fn void Function.add_linkage(&self, Linkage l) {
    self.linkage.push(l);
}

fn String Function.get_string(&self) {
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
    result.append("function ");
    if (self.return_type.type != NONE) {
        result.appendf("%s ",self.return_type.get_string());
    }
    result.appendf("$%s(",self.name.str_view());
    bool started = false;
    if (self.env) {
        started = true;
        result.appendf("env %%%s", self.env.str_view());
    }

    foreach (Parameter* &param : self.parameters) {
        if (started) {
            result.append(", ");
        }
        started = true;
        result.appendf("%s %%%s",param.type.get_string(), param.name.str_view());
    }

    if (self.variadic) {
        if (started) {
            result.append(", ");
        }
        result.append("...");
    }
    result.append(") {\n");
    foreach (Block* block : self.blocks) {
        result.appendf("%s\n", block.get_string());
    }
    result.append("}\n");
    return result.str_view();
}

fn void Function.set_header(&self, String header = "") {
    self.header_comment = dstring::new(header,self.allocator);
}

fn void Function.free(&self) {
    if (!self.allocator) {
        return;
    }
    self.name.free();
    self.header_comment.free();
    self.env.free();
    foreach (Block* block : self.blocks) {
        block.free();
        allocator::free(self.allocator, block);
    }
    foreach (Parameter parameter : self.parameters) {
        parameter.name.free();
    }
    self.parameters.free();
    self.linkage.free();
    self.blocks.free();
}