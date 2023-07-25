package hpel.core.steps;

import esb.core.Bus;
import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class ConvertTo extends StepCommon {
    private var cls:Class<RawBody> = null;
    
    public function new(cls:Class<RawBody>) {
        super();
        this.cls = cls;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var newMessage = Bus.convertMessage(message, this.cls);
            resolve({message: newMessage, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():ConvertTo {
        var c = new ConvertTo(this.cls);
        return c;
    }
}