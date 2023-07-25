package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class Process extends StepCommon {
    public var process:IProcess = null;

    public function new(process:IProcess) {
        super();
        this.process = process;
    }

    private override function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            this.process.process(message).then(result -> {
                resolve({message: result, continueBranchExecution: true} );
            }, error -> {
                reject(error);
            });
        });
    }

    private override function cloneSelf():Process {
        var c = new Process(this.process);
        return c;
    }
}