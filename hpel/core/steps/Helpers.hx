package hpel.core.steps;

import esb.core.bodies.RawBody;
import esb.core.Message;

class Helpers {
    public static function standardParams(message:Message<RawBody>, additional:Map<String, Any> = null):Map<String, Any> {
        var headers = {};
        if (message != null) {
            for (key in message.headers.keys()) {
                Reflect.setField(headers, key, message.headers.get(key));
            }
        }
        var properties = {};
        if (message != null) {
            for (key in message.properties.keys()) {
                Reflect.setField(properties, key, message.properties.get(key));
            }
        }

        var map = [
            "headers" => headers,
            "properties" => properties,
        ];
        if (message != null) {
            map.set("body", message.body);
        }

        if (additional != null) {
            for (key in additional.keys()) {
                map.set(key, additional.get(key));
            }
        }
        return map;
    }
}