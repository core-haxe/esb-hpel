package hpel.core.steps;

import hpel.core.steps.scripting.ScriptPool;
import esb.core.bodies.RawBody;
import esb.logging.Logger;
import promises.Promise;
import esb.core.Message;

using StringTools;

class Log extends StepCommon {
    public var message:String;
    public var ref:String;

    private static var logs:Map<String, Logger> = [];
    private static var reg = new EReg("\\${(.*?)\\}", "gm");

    public function new(message:String, ref:String = null) {
        super();
        this.message = message;
        this.ref = ref;
        if (this.ref == null) {
            this.ref = "hpel.core.log";
        }
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var logger = logs.get(ref);
            if (logger == null) {
                logger = new Logger(ref);
                logs.set(ref, logger);
            }

            var finalMessage = this.message;
            if (finalMessage.contains("${") && finalMessage.contains("}")) {
                finalMessage = reg.map(this.message, f -> {
                    return handleVar(f.matched(1), message);
                });
            }
            logger.info(finalMessage);
            
            resolve({message: message, continueBranchExecution: true} );
        });
    }

    private function handleVar(varName:String, message:Message<RawBody>):String {
        if (varName == "body") {
            return message.body.toString();
        } else if (varName == "headers") {
            return "" + message.headers;
        } else if (varName == "properties") {
            return "" + message.properties;
        } else if (varName.startsWith("headers.")) {
            return message.headers.get(varName.split(".").pop());
        } else if (varName.startsWith("property.")) {
            return message.properties.get(varName.split(".").pop());
        }
        var script = ScriptPool.get();
        var v = script.execute(varName, ScriptPool.standardParams(message));
        ScriptPool.put(script);
        return v;
    }
}