package hpel.core.dsl;

import esb.common.Uuid;
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
            var fromUri = route.interpolateUri(fromStep.uri, null);
            if (fromUri.prefix == "direct") {
                esb.core.Bus.registerDirectConsumer(fromUri, (uri, fromMessage) -> {
                    return new Promise((resolve, reject) -> {
                        if (!fromMessage.properties.exists("breadcrumbId")) {
                            fromMessage.properties.set("breadcrumbId", Uuid.generate());
                        }
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
                esb.core.Bus.from(fromUri, (fromUri, fromMessage) -> {
                    return new Promise((resolve, reject) -> {
                        if (!fromMessage.properties.exists("breadcrumbId")) {
                            fromMessage.properties.set("breadcrumbId", Uuid.generate());
                        }
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
            }
        } else {
            trace(">>>>>>>>>>>>>>>>>>>>>>>>>> ERROR FIRST STEP ISNT FROM!!!");
        }
    }

    private override function currentStep():hpel.core.steps.StepCommon {
        return route;
    }
}

#end