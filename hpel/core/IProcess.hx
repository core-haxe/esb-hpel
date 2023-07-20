package hpel.core;

import esb.core.bodies.RawBody;
import esb.core.Message;
import promises.Promise;

interface IProcess {
    public function process(message:Message<RawBody>):Promise<Message<RawBody>>;
}