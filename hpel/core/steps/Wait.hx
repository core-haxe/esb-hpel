package hpel.core.steps;

import promises.Promise;
import esb.core.bodies.RawBody;
import esb.core.Message;

class Wait extends StepCommon {
    public var amount:Int;
    public function new(amount:Int) {
        super();
        this.amount = amount;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            haxe.Timer.delay(() -> {
                resolve({message: message, continueBranchExecution: true});
            }, this.amount);
        });
    }

    private override function cloneSelf():Wait {
        var c = new Wait(this.amount);
        return c;
    }
}