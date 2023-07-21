package hpel.core.dsl;

import haxe.macro.Expr;

class DSLHelpers {
    public static macro function eval(e:Expr):Expr {
        return macro (body:Dynamic, headers:Dynamic, properties:Dynamic) -> {
            return ${e};
        };
    }
}