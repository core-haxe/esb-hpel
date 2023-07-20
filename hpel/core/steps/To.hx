package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;
import esb.core.Bus;
import esb.common.Uri;

class To extends StepCommon {
    public var uri:Uri;

    public function new(uri:Uri) {
        super();
        this.uri = uri;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((hpelResolve, hpelReject) -> {
            Bus.to(interpolateUri(uri), message).then(result -> {
                hpelResolve({message: result, continueBranchExecution: true});
            }, error -> {
                trace("error", error);
            });
        });
    }
}