module c3cubed;

import std::collections::list;


const usz BLOCK_CAPACITY = 16;
const usz TYPE_CAPACITY = 4;

fn void append_header(DString* to, String header, String prefix="") {
    String[] lines = header.split("\n");
    foreach (String line : lines) {
        to.appendf("%s# %s\n",prefix,line);
    }
}


/**
 *  Represents the type of a linkage declaration
 */
enum LinkageType : char (bool newline) {
    // export
    EXPORT = false,
    // thread
    THREAD = false,
    // section "section"
    SECTION = true,
    // section "section" "flags"
    SECTION_FLAGS = true,
}

/**
 *  Represents a QBE linkage declaration
 */
struct Linkage {
    LinkageType type;
    String section;
    String flags;
}

/**
 *  Constant linkage declaration representing "export" linkage
 */
const Linkage LINKAGE_EXPORT = {.type = EXPORT};

/**
 *  Constant linkage declaration representing "thread" linkage
 */
const Linkage LINKAGE_THREAD = {.type = THREAD};

/**
 *  Get the QBE textual representation of a linkage declaration
 *  
 *  @return "a string representing the linkage declaration, allocated using the temporary allocator"
 */
fn String Linkage.get_string(&self) {
    DString result;
    result.temp_init();
    switch (self.type) {
        case EXPORT:
            result.append("export");
        case THREAD:
            result.append("thread");
        case SECTION:
            result.appendf("section \"%s\"", self.section);
        case SECTION_FLAGS:
            result.appendf("section \"%s\" \"%s\"", self.section, self.flags);
    }
    return result.str_view();
}