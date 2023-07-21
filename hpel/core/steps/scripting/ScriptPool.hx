package hpel.core.steps.scripting;

import esb.core.bodies.RawBody;
import esb.core.Message;

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

    public static function standardParams(message:Message<RawBody>, additional:Map<String, Any> = null):Map<String, Any> {
        var headers = {};
        for (key in message.headers.keys()) {
            Reflect.setField(headers, key, message.headers.get(key));
        }
        var properties = {};
        for (key in message.properties.keys()) {
            Reflect.setField(properties, key, message.properties.get(key));
        }

        trace(Type.getClassName(Type.getClass(message.body)));
        var map = [
            "headers" => headers,
            "properties" => properties,
            "body" => message.body
        ];

        if (additional != null) {
            for (key in additional.keys()) {
                map.set(key, additional.get(key));
            }
        }
        return map;
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

        var result = interp.execute(ast);
        return result;
    }
}