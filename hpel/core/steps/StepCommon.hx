package hpel.core.steps;

import hpel.core.steps.scripting.ScriptPool;
import esb.common.Uri;
import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;
import hpel.core.steps.Helpers.*;

class StepCommon {
    private var children:Array<StepCommon> = [];
    private var parentStep:StepCommon;
    public var stepId:String;

    private var log:esb.logging.Logger = new esb.logging.Logger("hpel.core.steps");

    private var varMap:Map<String, Any> = [];

    public function new() {
    } 

    public function addChild(step:StepCommon) {
        step.parentStep = this;
        if (step.stepId == null) {
            step.stepId = route().generateStepId(step);
        }
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

    private function cloneSelf():StepCommon {
        return new StepCommon();
    }

    public function clone():StepCommon {
        var c = cloneSelf();
        c.parentStep = this.parentStep;
        c.varMap = this.varMap.copy();
        for (child in this.children) {
            c.children.push(child.clone());
        }
        return c;
    }

    public function variables():Map<String, Any> {
        var finalMap:Map<String, Any> = [];
        var stack = [];
        var ref = this;
        while (ref != null) {
            stack.push(ref);
            ref = ref.parentStep;
        }
        stack.reverse();
        for (item in stack) {
            for (key in item.varMap.keys()) {
                var v = item.varMap.get(key);
                finalMap.set(key, v);
            }
        }
        return finalMap;
    }

    public function variable(name:String, value:Any = null):Any {
        if (value == null) { // getter
            return variables().get(name);
        }
        varMap.set(name, value);
        return value;
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

    private function executeChildren(list:Array<StepCommon>, message:Message<RawBody>, cb:Message<RawBody>->Void, vars:Map<String, Any> = null) {
        if (list.length == 0) {
            cb(message);
            return;
        }

        var item = list.shift();
        if (vars != null) {
            for (key in vars.keys()) {
                item.variable(key, vars.get(key));
            }
        }

        executeChild(item, message).then(result -> {
            executeChildren(list, result, cb, vars);
        }, error -> {
            trace("--------------------> error", error, Type.getClassName(Type.getClass(this)), Type.getClassName(Type.getClass(item)));
            executeChildren(list, message, cb, vars);
        });
    }

    private function executeChild(child:StepCommon, message:Message<RawBody>):Promise<Message<RawBody>> {
        return child.execute(message);
    }

    private function interpolateString(s:String, message:Message<RawBody> = null, vars:Map<String, Any> = null):String {
        return route().interpolateString(s, message, vars);
    }

    private function interpolateVars(s:String, message:Message<RawBody>, vars:Map<String, Any> = null):String {
        return route().interpolateVars(s, message, vars);
    }

    public function interpolateUri(uri:Uri, message:Message<RawBody>, vars:Map<String, Any> = null):Uri {
        return route().interpolateUri(uri, message, vars);
    }

    public function evaluate(code:EvalType, message:Message<RawBody>, defaultValue:Any = null, expectScript:Bool = true):Any {
        var params = standardParams(message, variables());
        var result = defaultValue;
        if (code is String) {
            code = interpolateString(code, message, variables());
            if (expectScript) {
                var script = ScriptPool.get();
                result = script.execute(code, params);
                ScriptPool.put(script);
            } else {
                result = code;
            }
        } else if (Reflect.isFunction(code)) {
            var fn:EvalFunction = code;
            var vars:Dynamic = {};
            for (key in params.keys()) {
                if (key == "body" || key == "headers" || key == "properties") {
                    continue;
                }
                Reflect.setField(vars, key, params.get(key));
            }
            result = fn(params.get("body"), params.get("headers"), params.get("properties"), vars);
        }

        return result;
    }
}