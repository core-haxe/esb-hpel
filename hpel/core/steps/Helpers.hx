package hpel.core.steps;

import esb.core.bodies.RawBody;
import esb.core.Message;

class Helpers {
    public static function standardParams(message:Message<RawBody>, additional:Map<String, Any> = null):Map<String, Any> {
        var headers = {};
        for (key in message.headers.keys()) {
            Reflect.setField(headers, key, message.headers.get(key));
        }
        var properties = {};
        for (key in message.properties.keys()) {
            Reflect.setField(properties, key, message.properties.get(key));
        }

        var map = [
            "headers" => headers,
            "properties" => properties,
            "body" => message.body
        ];

        if (additional != null) {
            for (key in additional.keys()) {
                map.set(key, additional.get(key));
            }
        }
        return map;
    }
}