package hpel.core.steps;

import hpel.core.steps.scripting.ScriptPool;
import esb.core.Message;
import promises.Promise;
import esb.core.bodies.RawBody;

class Script extends StepCommon {
    public var script:String;
    
    public function new(script:String) {
        super();
        this.script = script;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var conditionResult = evaluate(message);
            resolve({message: message, continueBranchExecution: true} );
        });
    }

    public function evaluate(message:Message<RawBody>):Bool {
        var conditionResult = false;
        var headers = {};
        for (key in message.headers.keys()) {
            Reflect.setField(headers, key, message.headers.get(key));
        }
        var properties = {};
        for (key in message.properties.keys()) {
            Reflect.setField(properties, key, message.properties.get(key));
        }

        var script = ScriptPool.get();
        conditionResult = script.execute(this.script, [
            "headers" => headers,
            "properties" => properties,
            "body" => message.body
        ]);
        ScriptPool.put(script);

        return conditionResult;
    }
}