package hpel.core.steps;

import esb.core.Bus;
import haxe.io.Bytes;
import promises.Promise;
import esb.core.bodies.RawBody;
import esb.core.Message;

class Body extends StepCommon {
    public var value:EvalType;
    public var convertTo:Class<RawBody>;

    public function new(value:EvalType, convertTo:Class<RawBody> = null) {
        super();
        this.value = value;
        this.convertTo = convertTo;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var newMessage = message;
            if (convertTo != null) {
                newMessage = Bus.convertMessage(message, this.convertTo, false);
            }
            var finalValue = evaluate(this.value, message, null, false);
            var isMessageBody = Bus.isMessageBody(finalValue);
            var stringValue:String = null;
            if (isMessageBody && this.convertTo == null) {
                var resultBodyType = Type.getClassName(Type.getClass(finalValue));
                if (newMessage.bodyType != resultBodyType) {
                    newMessage = Bus.convertMessage(message, Type.getClass(finalValue), false);
                }
                stringValue = Std.string(finalValue);
            } else {
                stringValue = Std.string(finalValue);
            }
            if (stringValue != null) {
                newMessage.body.fromBytes(Bytes.ofString(stringValue));
            }
            resolve({message: newMessage, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():Body {
        var c = new Body(this.value, this.convertTo);
        return c;
    }
}