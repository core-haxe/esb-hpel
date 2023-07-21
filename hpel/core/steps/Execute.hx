package hpel.core.steps;

import haxe.io.Bytes;
import esb.core.Message;
import promises.Promise;
import esb.core.bodies.RawBody;

class Execute extends StepCommon {
    public var code:EvalType;
    
    public function new(code:EvalType) {
        super();
        this.code = code;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var result = evaluate(this.code, message);
            if (result != null) {
                message.body.fromBytes(Bytes.ofString(Std.string(result)));
            }
            resolve({message: message, continueBranchExecution: true} );
        });
    }
}