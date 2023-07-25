package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class When extends StepCommon {
    public var condition:EvalType;

    public function new(condition:EvalType) {
        super();
        this.condition = condition;    
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            var conditionResult = evaluate(condition, message, false);
            resolve({message: message, continueBranchExecution: conditionResult} );
        });
    }

    private override function cloneSelf():When {
        var c = new When(this.condition);
        return c;
    }
}