package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;
import esb.core.Bus;
import esb.common.Uri;

class To extends StepCommon {
    public var uri:Uri;
    public var variableName:String;

    public function new(uri:Uri, variableName:String = null) {
        super();
        this.uri = uri;
        this.variableName = variableName;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((hpelResolve, hpelReject) -> {
            var toUri = interpolateUri(uri, message, variables());
            if (toUri.prefix == "direct") {
                hpel.core.dsl.Route.executeDirect(toUri, message).then(result -> {
                    var finalResult = result;
                    if (this.variableName != null) {
                        route().variable(this.variableName, result);
                        finalResult = message;
                    }
                    hpelResolve({message: finalResult, continueBranchExecution: true});
                }, error -> {
                    trace("error", error);
                    hpelReject(error);
                });
            } else {
                var originalCorrelationId = message.correlationId;
                Bus.to(toUri, message).then(result -> {
                    result.correlationId = originalCorrelationId;
                    var finalResult = result;
                    if (this.variableName != null) {
                        route().variable(this.variableName, result);
                        finalResult = message;
                    }
                    hpelResolve({message: finalResult, continueBranchExecution: true});
                }, error -> {
                    trace("error", error);
                    hpelReject(error);
                });
            }
        });
    }

    private override function cloneSelf():To {
        var c = new To(this.uri, this.variableName);
        return c;
    }
}