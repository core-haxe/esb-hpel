package hpel.core.steps;

import esb.core.Bus;
import promises.Promise;
import esb.core.Message;
import esb.core.bodies.RawBody;

class CreateMessage extends StepCommon {
    private var cls:Class<RawBody> = null;
    private var variableName:String = null;
    
    public function new(cls:Class<RawBody>, variableName:String = null) {
        super();
        this.cls = cls;
        this.variableName = variableName;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var newMessage = Bus.createMessage(this.cls);
            var resultMessage = newMessage;
            if (this.variableName != null) {
                route().variable(this.variableName, newMessage);
                resultMessage = message;
            }
            resolve({message: resultMessage, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():CreateMessage {
        var c = new CreateMessage(this.cls, this.variableName);
        return c;
    }
}