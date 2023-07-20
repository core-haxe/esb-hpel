package hpel.core.steps;

import esb.core.bodies.RawBody;
import hpel.core.steps.scripting.ScriptPool;
import promises.Promise;
import esb.core.Message;

class When extends StepCommon {
    public var condition:String;

    public function new(condition:String) {
        super();
        this.condition = condition;    
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var conditionResult = evaluate(message);
            resolve({message: message, continueBranchExecution: conditionResult} );
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
        conditionResult = script.execute(condition, [
            "headers" => headers,
            "properties" => properties,
            "body" => message.body
        ]);
        ScriptPool.put(script);

        return conditionResult;
    }
}