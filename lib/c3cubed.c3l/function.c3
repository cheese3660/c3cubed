module c3cubed;

import std::collections::list;
def BlockList = List(<Block*>);
def ParameterList = List(<Parameter>);

/**
 *  Represents a function parameter
 */
struct Parameter {
    // The type of the parameter
    TypeReference type;
    // The name of the parameter
    DString name;
}

/**
 *  Represents a QBE function declaration
 */
struct Function {
    // The name of the function
    DString name;

    // The header comment for the function
    DString header_comment;

    // The name of the environment parameter if the function has one
    DString env;

    // The module the function is registered in
    Module* parent;

    // The blocks that the function has
    BlockList blocks;

    // The last added block, useful for adding to the "current" block of the function
    Block* current_block;

    // The allocator used for the function
    Allocator allocator;

    // The next temporary identifier name
    uint next_temp_name;
    // The next anonynmous block name, if this is "0" then the next name is "start"
    uint next_block_name;

    // The return type of the function, defaults to TYPE_VOID
    TypeReference return_type;

    // Is the function variadic?
    bool variadic;

    // The linkage declarations attached to the function
    LinkageList linkage;

    // The parameters of this function
    ParameterList parameters;
}

/**
 *  Initializes a function declaration, this is automatically called by Module.register_function
 *
 *  @param parent   "The parent module of the type declaration"
 *  @param name     "The name of the type declaration, can be a temporarily allocated string"
 *
 *  @require !self.allocator `Type declaration has already been initialized!`
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

/**
 *  Set the environment paramater name
 *
 *  @param name     "The name of the environment parameter"
 *
 *  @return         "An identifier representing the environment parameter"
 */
fn Identifier Function.add_env(&self, String name) {
    if (self.env) {
        self.env.free();
    }
    self.env = dstring::new(name, self.allocator);
    return make_identifier(self.env.str_view());
}

/**
 *  Add a parameter to the function
 *
 *  @param type     "The type of the parameter, must not be void"
 *  @param name     "The name of the parameter"
 *
 *  @return         "An identifier representing the parameter"
 *
 *  @require type.type != NONE `type cannot be void`
 */
fn Identifier Function.add_parameter(&self, TypeReference type, String name) {
    DString owned = dstring::new(name, self.allocator);
    self.parameters.push({
        .type = type,
        .name = owned
    });
    return make_identifier(owned.str_view());
}

/**
 *  Reference this function as a global symbol
 *
 *  @return "An identifier referencing this function as a global symbol"
 */
fn Identifier Function.reference(&self) {
    return {
        .type = GLOBAL,
        .identifier_name = self.name.str_view()
    };
}

/**
 *  Set the return type of the function
 *
 *  @param type     "The function return type"
 */
fn void Function.set_return_type(&self, TypeReference type) {
    self.return_type = type;
}

/**
 *  Begin a block in the function, but do not add it just yet
 *
 *  @param name     "The name of the block to begin, if not passed a name is automatically generated, and if it is the first block that name is 'start'"
 *
 *  @return         "The newly created block"
 */
fn Block* Function.begin_block(&self, String name="") {
    Block* block = allocator::alloc(self.allocator, Block);
    *block = {};
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

/**
 *  Begin a block in the function and add it
 *
 *  @param name     "The name of the block to begin, if not passed a name is automatically generated, and if it is the first block that name is 'start'"
 *
 *  @return         "The newly created block"
 */
fn Block* Function.begin_and_add_block(&self, String name="") {
    Block* block = self.begin_block(name);
    self.add_block(block);
    return block;
}

/**
 *  Add a block to the function, updating the current block
 *  
 *  @param block                    "The block to add, must be a block for this function"
 *
 *  @require block.parent == self   `block is not a block for this function`
 */
fn void Function.add_block(&self, Block* block) {
    self.blocks.push(block);
    self.current_block = block;
}

/**
 *  Get a temporary identifier
 *
 *  @return "A temporary identifier"
 */
fn Identifier Function.next_temporary(&self) {
    return {
        .type = TEMPORARY,
        .temp_ident = self.next_temp_name++
    };
}

/**
 *  Add a linkage declaration to the function declaration
 *
 *  @param l    "The linkage declaration to add"
 */
fn void Function.add_linkage(&self, Linkage l) {
    self.linkage.push(l);
}

/**
 *  Get the QBE textual representation of the function declaration
 *
 *  @return "The textual representation allocated with the temporary allocator"
 */
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

/**
 *  Set the header comment for the function declaration, that is the comment that comes before the declaration itself
 * 
 *  @param header "Header comment, can be temporarily allocated, and can be multiline"
 */
fn void Function.set_header(&self, String header = "") {
    if (self.header_comment) {
        self.header_comment.free();
    }
    self.header_comment = dstring::new(header,self.allocator);
}

/**
 *  Free the function declaration, this is called automatically by Module.free
 */
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