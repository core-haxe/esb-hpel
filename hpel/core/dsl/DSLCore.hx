package hpel.core.dsl;

import promises.Promise;
import esb.core.Message;
import esb.core.bodies.RawBody;
import haxe.Constraints;
import esb.common.Uri;

#if !hpel_core_impl

@:jsRequire("./hpel-core.js", "hpel.core.dsl.DSLCore")
extern class DSLCore {    
    public function new();
    public function from(uri:Uri):DSLCore;
    public function to(uri:Uri):DSLCore;
    public function log(message:EvalType):DSLCore;
    public function when(condition:EvalType):DSLCore;
    public function choice():DSLCore;
    public function otherwise():DSLCore;
    public function convertTo(cls:Class<RawBody>):DSLCore;
    public function execute(data:EvalType, setBody:Bool = true):DSLCore;
    public function end():DSLCore;
    public function start():Void;
    public function process(cls:IProcess):DSLCore;
    public function call(handler:Message<RawBody>->Promise<Message<RawBody>>):DSLCore;
    public function body(value:String, convertTo:Class<RawBody> = null):DSLCore;
    public function property(name:String, value:Any):DSLCore;
    public function header(name:String, value:Any):DSLCore;
    public function cacheBody():DSLCore;
    public function restoreBody():DSLCore;
    public function loop(items:EvalType, sequential:Bool = false):DSLCore;
    public function wait(amount:Int):DSLCore;
}

#else

@:expose
@:native("hpel.core.dsl.DSLCore")
class DSLCore {    
    private var _currentStep:hpel.core.steps.StepCommon = null;
    private var _parentDSL:DSLCore = null;

    public function new() {
        if (currentStep() == null) {
            _currentStep = new hpel.core.steps.StepCommon();
        }
    }

    public function from(uri:Uri):DSLCore {
        var fromStep = new hpel.core.steps.From(uri);
        currentStep().addChild(fromStep);
        return this;
    }

    public function to(uri:Uri):DSLCore {
        var toStep = new hpel.core.steps.To(uri);
        currentStep().addChild(toStep);
        return this;
    }

    public function log(message:EvalType):DSLCore {
        var logStep = new hpel.core.steps.Log(message);
        currentStep().addChild(logStep);
        return this;
    }

    public function when(condition:EvalType):DSLCore {
        var whenStep = new hpel.core.steps.When(condition);
        currentStep().addChild(whenStep);

        var branch = new DSLCore();
        branch._currentStep = whenStep;
        branch._parentDSL = this;
        return branch;
    }

    public function choice():DSLCore {
        var choiceStep = new hpel.core.steps.Choice();
        currentStep().addChild(choiceStep);

        var branch = new DSLCore();
        branch._currentStep = choiceStep;
        branch._parentDSL = this;
        return branch;
    }

    public function otherwise():DSLCore {
        var otherwiseStep = new hpel.core.steps.Otherwise();
        currentStep().addChild(otherwiseStep);

        var branch = new DSLCore();
        branch._currentStep = otherwiseStep;
        branch._parentDSL = this;
        return branch;
    }

    public function convertTo(cls:Class<RawBody>):DSLCore {
        var convertToStep = new hpel.core.steps.ConvertTo(cls);
        currentStep().addChild(convertToStep);
        return this;
    }

    public function execute(data:EvalType, setBody:Bool = true):DSLCore {
        var executeStep = new hpel.core.steps.Execute(data, setBody);
        currentStep().addChild(executeStep);
        return this;
    }

    public function process(cls:IProcess):DSLCore {
        var processStep = new hpel.core.steps.Process(cls);
        currentStep().addChild(processStep);
        return this;
    }

    public function call(handler:Message<RawBody>->Promise<Message<RawBody>>):DSLCore {
        var callStep = new hpel.core.steps.Call(handler);
        currentStep().addChild(callStep);
        return this;
    }

    public function body(value:String, convertTo:Class<RawBody> = null):DSLCore {
        var bodyStep = new hpel.core.steps.Body(value, convertTo);
        currentStep().addChild(bodyStep);
        return this;
    }

    public function property(name:String, value:Any):DSLCore {
        var propertyStep = new hpel.core.steps.Property(name, value);
        currentStep().addChild(propertyStep);
        return this;
    }

    public function header(name:String, value:Any):DSLCore {
        var headerStep = new hpel.core.steps.Header(name, value);
        currentStep().addChild(headerStep);
        return this;
    }

    public function cacheBody():DSLCore {
        var cacheBodyStep = new hpel.core.steps.CacheBody();
        currentStep().addChild(cacheBodyStep);
        return this;
    }

    public function restoreBody():DSLCore {
        var restoreBodyStep = new hpel.core.steps.RestoreBody();
        currentStep().addChild(restoreBodyStep);
        return this;
    }

    public function loop(items:EvalType, sequential:Bool = false):DSLCore {
        var loopStep = new hpel.core.steps.Loop(items, sequential);
        currentStep().addChild(loopStep);

        var branch = new DSLCore();
        branch._currentStep = loopStep;
        branch._parentDSL = this;
        return branch;
    }

    public function wait(amount:Int):DSLCore {
        var waitStep = new hpel.core.steps.Wait(amount);
        currentStep().addChild(waitStep);
        return this;
    }

    private function currentStep():hpel.core.steps.StepCommon {
        return _currentStep;
    }

    public function end():DSLCore {
        return this._parentDSL;
    }

    public function start() {
        
    }
}

#end