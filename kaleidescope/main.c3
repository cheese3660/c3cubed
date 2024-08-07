module kaleidescope;
import std::io;
import std::collections::list;

fn int main(String[] args)
{
    if (args.len < 2) {
        io::printf("usage %s <file>\n",args[0]);
        return 1;
    }
    char[]! result = (String)file::load_new(args[1]);
    if (try char[] src = result) {
        defer free(src);
        String source = (String)src;
        Tokenizer t;
        t.init(source);
        Parser p;
        p.init(t);
        AstNode*! tree = p.parse();
        if (try AstNode* program = tree) {
            defer program.free();
            Context context;
            context.init();
            defer context.free();
            context.add_tree(program)!!;
            context.finalize();
            DString res = context.output();
            defer res.free();
            io::print(res.str_view());
            return 0;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}