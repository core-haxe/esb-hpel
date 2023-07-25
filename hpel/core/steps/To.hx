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
            var toUri = interpolateUri(uri, variables());
            if (toUri.prefix == "direct") {
                hpel.core.dsl.Route.executeDirect(toUri, message).then(result -> {
                    hpelResolve({message: result, continueBranchExecution: true});
                }, error -> {
                    trace("error", error);
                    hpelReject(error);
                });
            } else {
                var originalCorrelationId = message.correlationId;
                Bus.to(toUri, message).then(result -> {
                    result.correlationId = originalCorrelationId;
                    hpelResolve({message: result, continueBranchExecution: true});
                }, error -> {
                    trace("error", error);
                    hpelReject(error);
                });
            }
        });
    }

    private override function cloneSelf():To {
        var c = new To(this.uri);
        return c;
    }
}