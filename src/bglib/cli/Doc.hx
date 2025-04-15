package bglib.cli;

import haxe.ds.ArraySort;

import tink.cli.DocFormatter;

using Lambda;
using StringTools;

typedef DocStringParam = {
    doc:String,
    ?name:String,
    ?type:String,
    ?optional:Bool,
}

typedef DocString = {
    doc:String,
    params:Array<DocStringParam>,
    ?returns:DocStringParam,
}

/**
 * TODO: make this a macro
 * Helper class for building Doc.
**/
class DocBuilder {
    var doc:Doc;

    @:allow(bglib.cli.Doc)
    function new() {
        doc = new Doc();
    }

    /**
     * Set the indent string.
     * @param indent The indent string.
     * @return DocBuilder
    **/
    public function setIndent(indent:String):DocBuilder {
        doc.indent = indent;
        return this;
    }

    public function setSmartIndent(smartIndent:Bool):DocBuilder {
        doc.smartIndent = smartIndent;
        return this;
    }

    public function setSubParamDescriptor(subParamDescriptor:Bool):DocBuilder {
        doc.subParamDescriptor = subParamDescriptor;
        return this;
    }

    public function setFlagParamDescriptor(
        flagParamDescriptor:Bool
    ):DocBuilder {
        doc.flagParamDescriptor = flagParamDescriptor;
        return this;
    }

    public function setParamDescriptorDelimiter(
        paramDescriptorDelimiter:String
    ):DocBuilder {
        doc.paramDescriptorDelimiter = paramDescriptorDelimiter;
        return this;
    }

    public function setAliasDelimiter(aliasDelimiter:String):DocBuilder {
        doc.aliasDelimiter = aliasDelimiter;
        return this;
    }

    public function setCommandsStr(commandsStr:String):DocBuilder {
        doc.commandsStr = commandsStr;
        return this;
    }

    public function setFlagsStr(flagsStr:String):DocBuilder {
        doc.flagsStr = flagsStr;
        return this;
    }

    /**
     * Build the Doc with the set configurations.
     * @return Doc
    **/
    public function build():Doc {
        return doc;
    }
}

/**
 * Custom dpc formatter.
 * @parma hi bio
 * @returns B
**/
@:allow(bglib.cli.DocBuilder)
class Doc implements DocFormatter<String> {
    var indent:String = "    ";
    var smartIndent:Bool = true;

    var subParamDescriptor:Bool = false;
    var flagParamDescriptor:Bool = false;
    var paramDescriptorDelimiter:String = " : ";

    var aliasDelimiter:String = ", ";

    var commandsStr:String = "commands:";
    var flagsStr:String = "flags:";

    function new() {}

    /**
     * Formats the documentation.
     * @param spec The documentation spec.
     * @return The formatted documentation.
    **/
    public function format(spec:DocSpec):String {
        return '${formatSpec(spec)}';
    }

    function indentLines(str:String):String {
        return str.split("\n")
            .map((l) -> l == "" ? l : indent + l)
            .join("\n");
    }

    function formatSpec(spec:DocSpec):String {
        var out = "";
        if (spec.doc != null) out += normalizeDoc(spec.doc) + "\n";

        // format default command
        ArraySort.sort(
            spec.commands, (a, b) -> a.isDefault ? -1 : b.isDefault ? 1 : 0
        );
        out += formatCommand(spec.commands[0]);

        // format subcommands
        if (spec.commands.length > 1) {
            out += commandsStr + "\n";
            for (i in 1...spec.commands.length) {
                var cmd = spec.commands[i];
                out += indentLines(formatCommand(cmd));
            }
        }

        // format flags
        out += flagsStr + "\n";
        for (flg in spec.flags) {
            out += indentLines(formatFlag(flg));
        }

        return out;
    }

    function docParamMap(p:DocStringParam):String {
        if (p.type != null && p.type.startsWith("Array<")) {
            return "[" + p.name + "...]";
        }
        if (p.optional) {
            return "[" + p.name + "]";
        }
        return "<" + p.name + ">";
    }

    function formatCommand(cmd:DocCommand):String {
        var out = "";

        // format aliases
        if (cmd.names.length < 1) return out;
        out += cmd.names.join(aliasDelimiter);

        var ds = extractDoc(cmd.doc);
        if (ds == null) return out + "\n";

        // format parameters
        if (ds.params.length > 0) {
            out += " " + ds.params.map(docParamMap).join(" ");
        }
        out += "\n";

        // format description
        var desc = ds.doc;
        if (ds.doc == null) desc = "";
        if (subParamDescriptor && ds.params.length > 0) {
            for (p in ds.params) {
                if (p.doc == null) continue;
                if (p.doc == "") continue;
                desc += '\n<${p.name}>' + paramDescriptorDelimiter + p.doc;
            }
        }

        out += indentLines(desc) + "\n";
        return out;
    }

    function formatFlag(flg:DocFlag):String {
        var out = "";

        // format aliases
        var names = flg.names.concat(flg.aliases.map((a) -> '-$a'));
        if (names.length < 1) return out;
        out += names.join(aliasDelimiter);

        var ds = extractDoc(flg.doc);
        if (ds == null) return out + "\n";

        // format parameters
        if (ds.params.length == 1) {
            out += " " + docParamMap(ds.params[0]);
        }
        out += "\n";

        // format description
        var desc = ds.doc;
        if (ds.doc == null) desc = "";
        if (
            flagParamDescriptor &&
            ds.params.length == 1 &&
            ds.params[0].doc != null &&
            ds.params[0].doc != ""
        ) {
            desc +=
                '\n<${ds.params[0].name}>' +
                paramDescriptorDelimiter +
                ds.params[0].doc;
        }
        out += indentLines(desc) + "\n";
        return out;
    }

    /**
     * Normalizes the documentation.
     * Removes stars and the first and last newlines.
     * @param doc to normalize
     * @returns String The normalized documentation
    **/
    function normalizeDoc(doc:String):String {
        if (doc == null) return null;
        var norm = doc;
        var trim = ~/^\n?|(\n *)?$/g;
        norm = trim.replace(norm, "");

        var lines = norm.split("\n");
        var star = ~/^\s*\*/;
        var starred = lines.foreach(star.match);
        if (starred) {
            lines = lines.map(star.replace.bind(_, ""));
        }

        var wsLead = -1;
        for (line in lines) {
            var ws = ~/^(\s*)\S/;
            if (!ws.match(line)) continue;
            var len = ws.matched(1).length;
            if (wsLead == -1) wsLead = len;
            if (len < wsLead) wsLead = len;
        }

        if (smartIndent) {
            lines = lines.map((l) -> l.substring(wsLead));
        }
        return lines.join("\n");
    }

    /**
     * Extracts the parameters and return values from the documentation.
     * @param doc to extract.
     * @returns DocString the extracted documentation
    **/
    function extractDoc(doc:String):DocString {
        if (doc == null) return null;
        doc = normalizeDoc(doc);
        var multiLineDescriptor = "(.*?)\n?(?=@param|@return(s)?|@throw(s)?|$)";
        var type = "\\w+(<[\\S ]*>)?";

        var paramReg = new EReg(
            '@param +(\\?)?(\\w+)(:($type))? *$multiLineDescriptor', "gis"
        );
        var returnReg = new EReg(
            '@return(s)? +($type) *$multiLineDescriptor', "gis"
        );

        var params:Array<DocStringParam> = [];
        var head = doc;
        if (paramReg.match(doc)) {
            var trim = ~/(\n *)?$/g;
            head = paramReg.matchedLeft();
            head = trim.replace(head, "");
            do {
                var opt = paramReg.matched(1) == "?" ? true : false;
                var name = paramReg.matched(2);
                var type = paramReg.matched(4);
                var desc = paramReg.matched(6);
                params.push({
                    name: name,
                    type: type,
                    doc: desc,
                    optional: opt
                });
            } while (paramReg.match(paramReg.matchedRight()));
        }

        var docString:DocString = {doc: head, params: params};
        if (returnReg.match(doc)) {
            var type = returnReg.matched(2);
            var desc = returnReg.matched(4);
            docString.returns = {type: type, doc: desc};
        }
        return docString;
    }

    /**
     * Create builder for Doc.
     * @return DocBuilder
    **/
    public static function builder():DocBuilder {
        return new DocBuilder();
    }
}
