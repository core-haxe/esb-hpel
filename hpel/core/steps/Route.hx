package hpel.core.steps;

import hpel.core.steps.scripting.ScriptPool;
import esb.core.bodies.RawBody;
import esb.core.Message;
import esb.common.Uri;
import hpel.core.dsl.RouteContext;
import hpel.core.steps.Helpers.*;

using StringTools;

class Route extends StepCommon {
    private var context:RouteContext;

    private var cachedMessage:Message<RawBody> = null;

    public function new(context:RouteContext) {
        super();
        this.context = context;
    }

    private var routeCompletePromises:Array<{resolve:Dynamic, reject:Dynamic}> = [];

    private static var regProperties = new EReg("\\{\\{(.*?)\\}\\}", "gm");
    public override function interpolateString(s:String, message:Message<RawBody> = null):String {
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
            s = interpolateVars(s, message);
        }
        return s;
    }

    private static var regVars = new EReg("\\${(.*?)\\}", "gm");
    public override function interpolateVars(s:String, message:Message<RawBody>):String {
        if (s.contains("${") && s.contains("}")) {
            s = regVars.map(s, f -> {
                var v = resolveVar(f.matched(1), message);
                return v;
            });
        }
        return s;
    }

    private function resolveVar(value:String, message:Message<RawBody>):Any {
        if (value == "body") {
            return message.body.toString();
        } else if (value == "headers") {
            return "" + message.headers;
        } else if (value == "properties") {
            return "" + message.properties;
        } else if (value.startsWith("headers.")) {
            return message.headers.get(value.split(".").pop());
        } else if (value.startsWith("property.")) {
            return message.properties.get(value.split(".").pop());
        }

        // assume script
        var script = ScriptPool.get();
        var v = script.execute(value, standardParams(message));
        ScriptPool.put(script);
        return v;
    }

    public override function interpolateUri(uri:Uri):Uri {
        var s = uri.toString();
        if (s.contains("{{") && s.contains("}}")) {
            s = interpolateString(s);
            return Uri.fromString(s);
        }
        return uri;
    }
}