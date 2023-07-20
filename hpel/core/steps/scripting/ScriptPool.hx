package hpel.core.steps.scripting;

class ScriptPool {
    private static var pool:Array<IScriptProvider> = [];

    public static function get():IScriptProvider {
        var scriptProvider:IScriptProvider = null;
        if (pool.length == 0) {
            scriptProvider = new HScriptProvider();
        } else {
            scriptProvider = pool.pop();
        }
        return scriptProvider;
    }

    public static function put(item:IScriptProvider) {
        pool.push(item);
    }
}

private class HScriptProvider implements IScriptProvider {
    private var parser = new hscript.Parser();
    private var interp = new hscript.Interp();

    public function new() {
    }

    public function execute(script:String, variables:Map<String, Any> = null):Any {
        var ast = parser.parseString(script);
        if (variables != null) {
            interp.variables.clear();
            for (key in variables.keys()) {
                interp.variables.set(key, variables.get(key));
            }
        }

        //trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> EXECUTING", script);
        var result = interp.execute(ast);
        //trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> EXECUTING RESULT", result);
        return result;
    }
}