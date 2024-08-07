module c3cubed;

import std::collections::list;

/*
    C3 Cubed Library
    Provides a convenient interface for outputting QBE code in C3
*/

const usz BLOCK_CAPACITY = 16;
const usz TYPE_CAPACITY = 4;

fn void append_header(DString* to, String header, String prefix="") {
    String[] lines = header.split("\n");
    foreach (String line : lines) {
        to.appendf("%s# %s\n",prefix,line);
    }
}


/* Linkage */
enum LinkageType : char (bool newline) {
    EXPORT = false,
    THREAD = false,
    SECTION = true,
    SECTION_FLAGS = true,
}

struct Linkage {
    LinkageType type;
    String section;
    String flags;
}


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