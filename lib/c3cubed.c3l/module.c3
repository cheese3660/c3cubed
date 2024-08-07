module c3cubed;
import std::collections::list;
def DataList = List(<Data*>);
def TypeList = List(<Type*>);
def FunctionList = List(<Function*>);
def StringList = List(<DString>);

/**
 *  A Module, represents one QBE source file
 */
struct Module {
    // Contains all of the registered types in the module
    TypeList types;
    // Contains all of the registered functions in the module
    FunctionList functions;
    // Contains all of the registered functions in the module
    DataList data;
    // Contains the modules header comment
    DString header_comment;
    // Contains the allocator used by the module
    Allocator allocator;
    // Contains all of the interned strings in the module
    StringList interned_strings;
}


/**
 *  Initialize the module, if you wish to use the current heap allocator, then you do not need to do this
 *
 *  @param allocator "Allocator for the module to use"
 *
 *  @require !self.allocator `Module has already been initialized!`
 */
fn void Module.initialize(&self, Allocator allocator = allocator::heap()) {
    self.allocator = allocator::heap();
    self.header_comment = null;
    self.types.new_init(BLOCK_CAPACITY,allocator);
    self.functions.new_init(BLOCK_CAPACITY,allocator);
    self.data.new_init(BLOCK_CAPACITY,allocator);
    self.interned_strings.new_init(TYPE_CAPACITY,allocator);
}

/**
 *  Set the header comment for the module, that is the comment that comes before the body of the module itself
 * 
 *  @param header "Header comment, can be temporarily allocated, and can be multiline"
 */
fn void Module.set_header(&self, String header = "") {
    if (!self.allocator) {
        self.initialize();
    }
    if (self.header_comment) {
        self.header_comment.free();
    }
    self.header_comment = dstring::new(header,self.allocator);
}

/**
 *  Import an identifier into the module for use in code.
 *  
 *  @param name         "The name of the identifier to import, can be temporarily allocated"
 *  @param type         "The type of the identifier to import, must be either GLOBAL or LOCAL"
 *  @param intern       "Whether to check previously imported strings for the name, saves on memory at the cost of cycles"
 *
 *  @return "A newly created Identifier representing the symbol"
 *
 *  @require type != TEMPORARY, type != UNINITIALIZED `type must either "GLOBAL" or "LOCAL"`
 */
fn Identifier Module.import_ident(&self, String name, IdentifierType type = GLOBAL, bool intern=true) {
    if (!self.allocator) {
        self.initialize();
    }
    if (intern) {
        foreach (DString str : self.interned_strings) {
            if (str.str_view() == name) {
                return Identifier {
                    .type = type,
                    .identifier_name = str.str_view()
                };
            }
        }
    }
    DString to_add = dstring::new(name,self.allocator);
    self.interned_strings.push(to_add);
    return Identifier {
        .type = type,
        .identifier_name = to_add.str_view()
    };
}

/**
 *  Import a string into the module for use in a data member.
 *
 *  @param value        "The string to import, can be temporarily allocated"
 *  @param type         "The data type of the string, must be a valid QBE data type (extended type)"
 *  @param intern       "Whether to check previously imported strings for the string, saves on memory at the cost of cycles"
 *
 *  @return             "A newly created DataMember representing the string"
 *
 *  @require type.type.extended_type `type must be a QBE extended type, i.e. TYPE_WORD, TYPE_LONG, TYPE_SHORT, TYPE_DOUBLE, TYPE_BYTE, TYPE_HALF`
 */
fn DataMember Module.import_string(&self, String value, TypeReference type=TYPE_BYTE, bool intern=true) {
    if (!self.allocator) {
        self.initialize();
    }
    if (intern) {
        foreach (DString str : self.interned_strings) {
            if (str.str_view() == value) {
                return DataMember {
                    .type = STRING,
                    .datatype = type,
                    .str = str.str_view()
                };
            }
        }
    }
    DString to_add = dstring::new(value,self.allocator);
    self.interned_strings.push(to_add);
    return DataMember {
        .type = STRING,
        .datatype = type,
        .str = to_add.str_view()
    };
}

/**
 *  Allocates a type in the module, and initializes it with the given name.
 *
 *  @param name "The name for the type, can be a temporarily allocated string"
 *
 *  @return     "A newly created and registered type"
 */
fn Type* Module.register_type(&self, String name) {
    if (!self.allocator) {
        self.initialize();
    }
    Type* ptr = allocator::alloc(self.allocator, Type);
    *ptr = {};
    ptr.initialize(self, name);
    self.types.push(ptr);
    return ptr;
}

/**
 *  Allocates a function in the module, and initializes it with the given name.
 *
 *  @param name "The name for the function, can be a temporarily allocated string"
 *
 *  @return     "A newly created and registered function"
 */
fn Function* Module.register_function(&self, String name) {
    if (!self.allocator) {
        self.initialize();
    }
    Function* ptr = allocator::alloc(self.allocator, Function);
    *ptr = {};
    ptr.initialize(self, name);
    self.functions.push(ptr);
    return ptr;
}

/**
 *  Allocates a data definition in the module, and initializes it with the given name.
 *
 *  @param name     "The name for the data data definition, can be a temporarily allocated string"
 *
 *  @return         "A newly created and registered data definition"
 */
fn Data* Module.register_data(&self, String name) {
    if (!self.allocator) {
        self.initialize();
    }
    Data* ptr = allocator::alloc(self.allocator, Data);
    *ptr = {};
    ptr.initialize(self, name);
    self.data.push(ptr);
    return ptr;
}

/**
 *  Imports a section and flags into the module.
 *
 *  @param name         "The section name, can be a temporarily allocated string"
 *  @param flags        "The flags for the section, only used if not empty, can be a temporarily allocated string"
 *  @param intern       "Whether to check previously imported strings for the section name or flags, saves on memory at the cost of cycles"
 *
 *  @return             "A linkage declaration for the given section and flags"
 */
fn Linkage Module.import_section(&self, String name, String flags="", bool intern=true) {
    if (!self.allocator) {
        self.initialize();
    }
    String name_view;
    bool found_name;
    bool has_flags = flags != "";
    if (intern) {
        foreach (DString str : self.interned_strings) {
            if (str.str_view() == name) {
                name_view = str.str_view();
                found_name = true;
                break;
            }
        }
    }
    if (!found_name) {
        DString to_add = dstring::new(name,self.allocator);
        self.interned_strings.push(to_add);
        name_view = to_add.str_view();
    }
    String flags_view;
    if (has_flags) {
        bool found_flags;
        if (intern) {
            foreach (DString str : self.interned_strings) {
                if (str.str_view() == flags) {
                    flags_view = str.str_view();
                    found_flags = true;
                    break;
                }
            }
        }
        if (!found_name) {
            DString to_add = dstring::new(flags,self.allocator);
            self.interned_strings.push(to_add);
            flags_view = to_add.str_view();
        }
    }
    if (has_flags) {
        return {
            .type = SECTION_FLAGS,
            .section = name_view,
            .flags = flags_view
        };
    } else {
        return {
            .type = SECTION,
            .section = name_view
        };
    }
}

/**
 *  Generates the textual representation of the module
 *  
 *  @return "A string containing the textual representation allocated using the current heap allocator"
 */
fn DString Module.write(&self) {
    DString result;
    if (self.header_comment) {
        append_header(&result, self.header_comment.str_view());
        result.append('\n');
    }
    @pool() {
        foreach (Type* type : self.types) {
            result.appendf("%s\n",type.get_string());
        }
        foreach (Function* function : self.functions) {
            result.appendf("%s\n",function.get_string());
        }
        foreach (Data* data : self.data) {
            result.appendf("%s\n",data.get_string());
        }
    };
    return result;
}

/**
 *  Frees the module and all registered types, functions, and data
 */
fn void Module.free(&self) {
    if (!self.allocator) {
        return;
    }
    self.header_comment.free();
    foreach (Type* type : self.types) {
        type.free();
        allocator::free(self.allocator,type);
    }
    foreach (Function* function : self.functions) {
        function.free();
        allocator::free(self.allocator,function);
    }
    foreach (Data* data : self.data) {
        data.free();
        allocator::free(self.allocator,data);
    }
    foreach (DString str : self.interned_strings) {
        str.free();
    }
}