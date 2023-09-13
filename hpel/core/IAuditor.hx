package hpel.core;

import hpel.core.steps.StepCommon;
import esb.core.Message;
import esb.core.bodies.RawBody;

interface IAuditor {
    public function auditStepStart(step:StepCommon, message:Message<RawBody>):Void;
    public function auditStepEnd(step:StepCommon, message:Message<RawBody>):Void;
    public function auditStepError(step:StepCommon, message:Message<RawBody>, error:Dynamic):Void;
}