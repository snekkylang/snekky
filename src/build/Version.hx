package build;

import haxe.macro.Expr;

class Version {

    public static final SemVersion = "0.9.0";

    static function getFormattedData() {
        final date = Date.now();
        
        final dd = StringTools.lpad(Std.string(date.getDate()), "0", 2);
        final mm = StringTools.lpad(Std.string(date.getMonth() + 1), "0", 2);
        final yyyy = date.getFullYear();

        return '$yyyy-$mm-$dd';    
    }

    public static macro function getVersionString():Expr {
        final s = new StringBuf();
        s.add(SemVersion);
        s.add(" ");

        final sha = Sys.getEnv("GITHUB_SHA");
        if (sha != null) {
            s.add("[");
            s.add(sha.substr(0, 7));
            s.add("] ");
        }

        final buildTime = getFormattedData();
        s.add("(");
        s.add(buildTime);
        s.add(")");

        return macro $v{s.toString()};
    }
}
