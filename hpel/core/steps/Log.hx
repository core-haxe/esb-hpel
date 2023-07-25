package hpel.core.steps;

import esb.core.bodies.RawBody;
import esb.logging.Logger;
import promises.Promise;
import esb.core.Message;

using StringTools;

class Log extends StepCommon {
    public var message:EvalType;
    public var ref:String;

    private static var logs:Map<String, Logger> = [];
    private static var reg = new EReg("\\${(.*?)\\}", "gm");

    public function new(message:EvalType, ref:String = null) {
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

            var finalMessage = evaluate(this.message, message, null, false);
            logger.info(Std.string(finalMessage));
            
            resolve({message: message, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():Log {
        var c = new Log(this.message, this.ref);
        return c;
    }
}