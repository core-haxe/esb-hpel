package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;
import esb.common.Uri;

class From extends StepCommon {
    public var uri:Uri;

    public function new(uri:Uri) {
        super();
        this.uri = uri;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((hpelResolve, hpelReject) -> {
            hpelResolve({message: message, continueBranchExecution: true});
        });
    }
}