package hpel.core.dsl;

import esb.common.Uri;
import promises.Promise;

#if !hpel_core_impl

@:jsRequire("./hpel-core.js", "hpel.core.dsl.Route")
extern class Route extends DSLCore {
    public function new(context:RouteContext);
    public override function start():Void;
}

#else

@:expose
@:native("hpel.core.dsl.Route")
class Route extends DSLCore {
    private var context:RouteContext;
    private var route:hpel.core.steps.Route;

    public function new(context:RouteContext) {
        super();
        this.context = context;
        route = new hpel.core.steps.Route(this.context);
    }

    public override function start() {
        var firstStep = @:privateAccess route.children[0];
        if (firstStep is hpel.core.steps.From) {
            var fromStep:hpel.core.steps.From = cast firstStep;
            esb.core.Bus.from(route.interpolateUri(fromStep.uri), fromMessage -> {
                return new Promise((resolve, reject) -> {
                    route.execute(fromMessage).then(response -> {
                        for (details in @:privateAccess route.routeCompletePromises) {
                            details.resolve(response);
                        }
                        resolve(response);
                    }, error -> {
                        trace("error", error);
                    });
                });
            });
        } else {
            trace(">>>>>>>>>>>>>>>>>>>>>>>>>> ERROR FIRST STEP ISNT FROM!!!");
        }
    }

    private override function currentStep():hpel.core.steps.StepCommon {
        return route;
    }
}

#end