package hpel.core.steps;

import esb.core.Bus;
import haxe.io.Bytes;
import esb.core.Message;
import promises.Promise;
import esb.core.bodies.RawBody;

class Execute extends StepCommon {
    public var code:EvalType;
    public var setBody:Bool = true;
    
    public function new(code:EvalType, setBody:Bool = true) {
        super();
        this.code = code;
        this.setBody = setBody;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var result:Dynamic = evaluate(this.code, message);
            var newMessage = message;
            if (setBody && result != null) {
                var canConvert = Bus.canConvertMessage(message, Type.getClass(result));
                if (canConvert) {
                    newMessage = Bus.convertMessage(message, Type.getClass(result), false);
                    newMessage.body.fromBytes(Bytes.ofString(Std.string(result)));
                } else {
                    newMessage.body.fromBytes(Bytes.ofString(Std.string(result)));
                }
            }
            resolve({message: newMessage, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():Execute {
        var c = new Execute(this.code, this.setBody);
        return c;
    }
}