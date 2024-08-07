module c3cubed;
import std::collections::list;

/**
 *  Represents the type of an identifier
 */
enum IdentifierType {
    // A global identifier, represented by $(identifier_name)
    GLOBAL,
    // A local identifier, represented by %(identifier_name)
    LOCAL,
    // A temporary local identifier, represented by %_(temp_ident)
    TEMPORARY,
    // An uninitialized identifier, used to signal that one should be made
    UNINITIALIZED,
}

/**
 *  Represents an identifier
 */
struct Identifier {
    // The type of identifier
    IdentifierType type;
    union {
        // The name of identifier if it has a name
        String identifier_name;
        // The temporary identifier for the identifier
        uint temp_ident;
    }
}

/**
 *  Make an identifier from a string view
 *
 *  @param view     "The view to make the identifier from, its lifetime must encompass the entirety of the lifetime of the usage of the identifier"
 *  @param type     "The identifier type to make"
 *
 *  @return "The identifier"
 */
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

/**
 *  Reference an identifier as a thread local symbol
 *
 *  @return "A value that references the thread local symbol"
 *
 *  @require self.type == GLOBAL    `Must be a global identifier`
 */
fn Value Identifier.thread_local(self) {
    return {
        .type = THREAD_LOCAL_SYMBOL,
        .symbol = self
    };
}

// An uninitialized identifier for usage in signaling that one needs to be made
const Identifier DEFAULT_IDENTIFIER = {.type = UNINITIALIZED };