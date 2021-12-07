module hunt.util.pool.ObjectFactory;

import hunt.logging.ConsoleLogger;

abstract class ObjectFactory(T) {

    T makeObject();

    void destroyObject(T p) {
        version(HUNT_DEBUG) tracef("Do noting");
    }

    bool isValid(T p) {
        return true;
    }
}


class DefaultObjectFactory(T) : ObjectFactory!(T) {

    override T makeObject() {
        return new T();
    }

}
