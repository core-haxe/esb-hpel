package hpel.core.steps;

import esb.core.bodies.RawBody;
import promises.Promise;
import esb.core.Message;
import promises.PromiseUtils.*;
import esb.core.Bus.*;

class Loop extends StepCommon {
    var items:EvalType = null;
    var sequential:Bool = false;

    public function new(items:EvalType, sequential:Bool = false) {
        super();
        this.items = items;    
        this.sequential = sequential;    
    }

    public override function execute(message:Message<RawBody>):Promise<Message<RawBody>> {
        return new Promise((resolve, reject) -> {
            var itemsResult = evaluate(items, message, false);
            var itemsArray = [];
            switch (Type.typeof(itemsResult)) {
                case TInt | TFloat:
                    for (i in 0...Std.int(itemsResult)) {
                        itemsArray.push(i);
                    }
                case TClass(Array):
                    itemsArray = itemsResult;
                case TClass(List) | TClass(haxe.ds.List):    
                    var itemsList:List<Any> = cast itemsResult;
                    for (item in itemsList) {
                        itemsArray.push(item);
                    }
                case _:
                    trace(">>>>>>>>>>>>>>>>>>>>>>>>>>> UNKOWN LOOP ITEMS: ", Type.typeof(itemsResult));
            }

            var originalCorrelationId = message.correlationId;

            var promises = [];
            var index = 0;
            for (item in itemsArray) {
                promises.push(loopStep.bind(item, index, message));
                index++;
            }
            
            runAll(promises).then(results -> {
                var array:Array<Message<RawBody>> = cast results;
                // TODO: aggregator
                message.correlationId = originalCorrelationId;
                resolve(message);
            }, error -> {
                reject(error);
            });


        });
    }

    private function loopStep(item:Any, index:Int, message:Message<RawBody>):Promise<Message<RawBody>> {
        return new Promise((resolve, reject) -> {
            var inMessage = copyMessage(message, RawBody);
            if (canConvertMessage(inMessage, Type.getClass(item))) {
                var inBody:RawBody = cast item;
                inMessage = convertMessage(inMessage, Type.getClass(item), false);
                inMessage.body.fromBytes(inBody.toBytes());
            }
            var clones = [];
            for (c in effectiveChildren(inMessage)) {
                clones.push(c.clone());
            }
            executeChildren(clones, inMessage, (outMessage) -> {
                resolve(outMessage);
            }, [
                "loopItem" => item,
                "loopIndex" => index
            ]);
        });
    }

    private override function cloneSelf():Loop {
        var c = new Loop(this.items, this.sequential);
        return c;
    }
}