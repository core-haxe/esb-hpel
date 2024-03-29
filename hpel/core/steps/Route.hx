package hpel.core.steps;

import hpel.core.steps.scripting.ScriptPool;
import esb.core.bodies.RawBody;
import esb.core.Message;
import esb.common.Uri;
import hpel.core.dsl.RouteContext;
import hpel.core.steps.Helpers.*;

using StringTools;

class Route extends StepCommon {
    public var context:RouteContext;

    private var cachedMessage:Message<RawBody> = null;
    private var stepIdCounters:Map<String, Int> = [];

    public var auditors:Array<IAuditor> = [];

    public function new(context:RouteContext) {
        super();
        this.context = context;
        stepId = this.context.id;
    }

    private var routeCompletePromises:Array<{resolve:Dynamic, reject:Dynamic}> = [];

    public function auditStepStart(step:StepCommon, message:Message<RawBody>) {
        for (auditor in auditors) {
            auditor.auditStepStart(step, message);
        }
    }

    public function auditStepEnd(step:StepCommon, message:Message<RawBody>) {
        for (auditor in auditors) {
            auditor.auditStepEnd(step, message);
        }
    }

    public function auditStepError(step:StepCommon, message:Message<RawBody>, error:Dynamic) {
        for (auditor in auditors) {
            auditor.auditStepError(step, message, error);
        }
    }

    public function generateStepId(instance:StepCommon):String {
        var className = Type.getClassName(Type.getClass(instance));
        var counter = -1;
        if (stepIdCounters.exists(className)) {
            counter = stepIdCounters.get(className);
        }
        counter++;
        stepIdCounters.set(className, counter);

        var name = className.split(".").pop().toLowerCase();
        return name + "-" + counter;
    }

    private static var regProperties = new EReg("\\{\\{(.*?)\\}\\}", "gm");
    public override function interpolateString(s:String, message:Message<RawBody> = null, vars:Map<String, Any> = null):String {
        if (s.contains("{{") && s.contains("}}")) {
            s = regProperties.map(s, f -> {
                if (context.configProperties != null) {
                    var v = context.configProperties.get(f.matched(1));
                    if (v != null) {
                        return v;
                    }
                }
                return null;
            });
        }
        if (message != null) {
            s = interpolateVars(s, message, vars);
        }
        return s;
    }

    private static var regVars = new EReg("\\${(.*?)\\}", "gm");
    public override function interpolateVars(s:String, message:Message<RawBody>, vars:Map<String, Any> = null):String {
        if (s.contains("${") && s.contains("}")) {
            s = regVars.map(s, f -> {
                var v = resolveVar(f.matched(1), message, vars);
                return v;
            });
        }
        return s;
    }

    private function resolveVar(value:String, message:Message<RawBody>, vars:Map<String, Any> = null):Any {
        if (value == "body" && message != null) {
            return message.body.toString();
        } else if (value == "headers" && message != null) {
            return "" + message.headers;
        } else if (value == "properties" && message != null) {
            return "" + message.properties;
        } else if (value.startsWith("headers.") && message != null) {
            return message.headers.get(value.split(".").pop());
        } else if (value.startsWith("property.") && message != null) {
            return message.properties.get(value.split(".").pop());
        } else if (vars != null && vars.exists(value)) {
            return vars.get(value);
        }

        // assume script
        var script = ScriptPool.get();
        var v = script.execute(value, standardParams(message, variables()));
        ScriptPool.put(script);
        return v;
    }

    public override function interpolateUri(uri:Uri, message:Message<RawBody>, vars:Map<String, Any> = null):Uri {
        var s = uri.toString();
        if (s.contains("{{") && s.contains("}}")) {
            s = interpolateString(s, message, vars);
        }
        if (s.contains("${") && s.contains("}")) {
            s = interpolateVars(s, message, vars);
        }
        return Uri.fromString(s);
    }

    private override function cloneSelf():Route {
        var c = new Route(this.context);
        return c;
    }
}