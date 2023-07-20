package hpel.core.steps;

import esb.common.Uri;
import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;

class StepCommon {
    private var children:Array<StepCommon> = [];
    private var parentStep:StepCommon;

    private var log:esb.logging.Logger = new esb.logging.Logger("hpel.core.steps");

    public function new() {
    } 

    public function addChild(step:StepCommon) {
        step.parentStep = this;
        children.push(step);
    }

    private function effectiveChildren(message:Message<RawBody>):Array<StepCommon> {
        return children;
    }

    public function route():Route {
        var ref = this;
        while (ref != null) {
            if (ref is Route) {
                return cast ref;
            }
            ref = ref.parentStep;
        }
        return null;
    }

    private function executeInternal(message:Message<RawBody>):Promise<{message:Message<RawBody>, continueBranchExecution:Bool}> {
        return new Promise((resolve, reject) -> {
            resolve({message: message, continueBranchExecution: true});
        });
    }

    public function execute(message:Message<RawBody>):Promise<Message<RawBody>> {
        return new Promise((resolve, reject) -> {
            //log.info('executing step ${Type.getClassName(Type.getClass(this))}');
            executeInternal(message).then(result -> {
                if (result.continueBranchExecution) {
                    //log.info('step ${Type.getClassName(Type.getClass(this))} complete, continuing branch execution');
                    var copy = effectiveChildren(result.message).copy();
                    executeChildren(copy, result.message, (outMessage) -> {
                        resolve(outMessage);
                    });
                } else {
                    //log.info('step ${Type.getClassName(Type.getClass(this))} complete, stopping branch execution');
                    resolve(result.message);
                }
            }, error -> {
                reject(error);
            });
        });
    }

    private function executeChildren(list:Array<StepCommon>, message:Message<RawBody>, cb:Message<RawBody>->Void) {
        if (list.length == 0) {
            cb(message);
            return;
        }

        var item = list.shift();
        item.execute(message).then(result -> {
            executeChildren(list, result, cb);
        }, error -> {
            trace("--------------------> error", error, Type.getClassName(Type.getClass(this)), Type.getClassName(Type.getClass(item)));
            executeChildren(list, message, cb);
        });
    }

    private function interpolateString(s:String):String {
        return route().interpolateString(s);
    }

    public function interpolateUri(uri:Uri):Uri {
        return route().interpolateUri(uri);
    }
}