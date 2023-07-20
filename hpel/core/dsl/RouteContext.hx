package hpel.core.dsl;

import esb.core.config.sections.PropertiesConfig;

#if !hpel_core_impl

@:jsRequire("./hpel-core.js", "hpel.core.dsl.RouteContext")
extern class RouteContext {
    public var id:String;
    public var configProperties:PropertiesConfig;
    public function new();
}

#else

@:expose
@:native("hpel.core.dsl.RouteContext")
class RouteContext {
    public var id:String;
    public var configProperties:PropertiesConfig;

    public function new() {
    }
}

#end