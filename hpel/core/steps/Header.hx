package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class Header extends StepCommon {
    public var name:String;
    public var value:Any;

    public function new(name:String, value:Any) {
        super();
        this.name = name;
        this.value = value;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            message.headers.set(this.name, this.value);
            resolve({message: message, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():Header {
        var c = new Header(this.name, this.value);
        return c;
    }
}