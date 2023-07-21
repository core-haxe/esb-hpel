package hpel.core.steps;

import esb.core.bodies.RawBody;
import esb.core.Message;

class Choice extends StepCommon {
    private override function effectiveChildren(message:Message<RawBody>):Array<StepCommon> {
        var list = [];
        var otherwise:Otherwise = null;
        for (c in children) {
            if (c is When) {
                var when = cast(c, When);
                if (evaluate(when.condition, message)) {
                    list.push(c);
                    break;
                }
            } else if (c is Otherwise) {
                otherwise = cast c;
            }
        }

        if (list.length == 0 && otherwise != null) {
            list.push(otherwise);
        }

        return list;
    }
}