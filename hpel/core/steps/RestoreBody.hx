package hpel.core.steps;

import promises.Promise;
import esb.core.bodies.RawBody;
import esb.core.Message;

class RestoreBody extends StepCommon {
    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var cachedMessage = @:privateAccess route().cachedMessage;
            var newMessage = message;
            if (cachedMessage != null) {
                newMessage = cachedMessage;
                @:privateAccess route().cachedMessage = null;
            }
            resolve({message: newMessage, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():RestoreBody {
        var c = new RestoreBody();
        return c;
    }
}