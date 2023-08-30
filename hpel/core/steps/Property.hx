package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class Property extends StepCommon {
    public var name:String;
    public var value:EvalType;

    public function new(name:String, value:EvalType) {
        super();
        this.name = name;
        this.value = value;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var finalValue = evaluate(this.value, message, null, false);
            message.properties.set(this.name, finalValue);
            resolve({message: message, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():Property {
        var c = new Property(this.name, this.value);
        return c;
    }
}