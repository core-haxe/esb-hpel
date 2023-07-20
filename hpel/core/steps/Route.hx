package hpel.core.steps;

import esb.common.Uri;
import hpel.core.dsl.RouteContext;

using StringTools;

class Route extends StepCommon {
    private var context:RouteContext;

    public function new(context:RouteContext) {
        super();
        this.context = context;
    }

    private var routeCompletePromises:Array<{resolve:Dynamic, reject:Dynamic}> = [];

    private static var reg = new EReg("\\{\\{(.*?)\\}\\}", "gm");
    public override function interpolateString(s:String):String {
        if (s.contains("{{") && s.contains("}}")) {
            s = reg.map(s, f -> {
                if (context.configProperties != null) {
                    var v = context.configProperties.get(f.matched(1));
                    if (v != null) {
                        return v;
                    }
                }
                return null;
            });
        }
        return s;
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