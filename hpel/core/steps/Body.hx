package hpel.core.steps;

import esb.core.Bus;
import haxe.io.Bytes;
import promises.Promise;
import esb.core.bodies.RawBody;
import esb.core.Message;

class Body extends StepCommon {
    public var value:String;
    public var convertTo:Class<RawBody>;

    public function new(value:String, convertTo:Class<RawBody> = null) {
        super();
        this.value = value;
        this.convertTo = convertTo;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var newMessage = message;
            if (convertTo != null) {
                newMessage = Bus.convertMessage(message, this.convertTo);
            }
            newMessage.body.fromBytes(Bytes.ofString(value));
            resolve({message: newMessage, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():Body {
        var c = new Body(this.value, this.convertTo);
        return c;
    }
}