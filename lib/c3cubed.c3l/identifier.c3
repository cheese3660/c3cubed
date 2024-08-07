module c3cubed;
import std::collections::list;

enum IdentifierType {
    GLOBAL,
    LOCAL,
    TEMPORARY,
    UNINITIALIZED,
}

struct Identifier {
    IdentifierType type;
    union {
        String identifier_name;
        uint temp_ident;
    }
}

fn Identifier make_identifier(String view, IdentifierType type=LOCAL) {
    return {
        .type = type,
        .identifier_name = view
    };
}

fn String Identifier.get_string(&self) {
    DString result = dstring::temp_new();
    switch (self.type) {
        case GLOBAL:
            result.appendf("$%s",self.identifier_name);
        case LOCAL:
            result.appendf("%%%s",self.identifier_name);
        case TEMPORARY:
            result.appendf("%%_%d",self.temp_ident);
        case UNINITIALIZED:
            result.appendf("<! Unitialized Identifier !>");
    }
    return result.str_view();
}

fn Value Identifier.thread_local(self) {
    return {
        .type = THREAD_LOCAL_SYMBOL,
        .symbol = self
    };
}

const Identifier DEFAULT_IDENTIFIER = {.type = UNINITIALIZED };