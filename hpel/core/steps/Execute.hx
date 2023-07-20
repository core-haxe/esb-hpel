package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class Execute extends StepCommon {
    public var handler:Message<RawBody>->Promise<Message<RawBody>>;

    public function new(handler:Message<RawBody>->Promise<Message<RawBody>>) {
        super();
        this.handler = handler;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            this.handler(message).then(result -> {
                resolve({message: result, continueBranchExecution: true} );
            }, error -> {
                reject(error);
            });
        });
    }
}