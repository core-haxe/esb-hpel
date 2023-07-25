package hpel.core.steps;

import promises.Promise;
import esb.core.bodies.RawBody;
import esb.core.Message;

class CacheBody extends StepCommon {
    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            @:privateAccess route().cachedMessage = message;
            resolve({message: message, continueBranchExecution: true} );
        });
    }

    private override function cloneSelf():CacheBody {
        var c = new CacheBody();
        return c;
    }
}