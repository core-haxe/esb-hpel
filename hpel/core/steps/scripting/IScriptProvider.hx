package hpel.core.steps.scripting;

interface IScriptProvider {
    public function execute(script:String, variables:Map<String, Any> = null):Any;
}