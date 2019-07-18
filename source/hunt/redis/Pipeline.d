module hunt.redis.Pipeline;

import hunt.redis.Builder;
import hunt.redis.BuilderFactory;
import hunt.redis.Client;
import hunt.redis.Exceptions;
import hunt.redis.MultiKeyPipelineBase;
import hunt.redis.Response;

import hunt.util.Common;
import hunt.collection;

import hunt.Boolean;
import hunt.Double;
import hunt.Long;

import std.conv;

class Pipeline : MultiKeyPipelineBase, Closeable {

    private MultiResponseBuilder currentMulti;

    private class MultiResponseBuilder : Builder!(List!(Object)) {
        private List!AbstractResponse responses;

        this() {
                responses = new ArrayList!AbstractResponse();
        }

        override
        List!(Object) build(Object data) {
            
            List!(Object) list = cast(List!(Object)) data;
            List!(Object) values = new ArrayList!(Object)();

            if (list.size() != responses.size()) {
                throw new RedisDataException("Expected data size " ~ responses.size().to!string() ~ " but was "
                        ~ list.size().to!string());
            }

            for (int i = 0; i < list.size(); i++) {
                // FIXME: Needing refactor or cleanup -@zxp at 7/16/2019, 8:15:19 PM
                // 
                AbstractResponse response = responses.get(i);
                response.set(list.get(i));
                Object builtResponse;
                try {
                    builtResponse = response;
                } catch (RedisDataException e) {
                    builtResponse = e;
                }
                values.add(builtResponse);
            }
            return values;
        }

        void setResponseDependency(AbstractResponse dependency) {
            foreach(AbstractResponse response ; responses) {
                response.setDependency(dependency);
            }
        }

        void addResponse(AbstractResponse response) {
            responses.add(response);
        }
    }

//   override
//   protected <T> Response!(T) getResponse(Builder!(T) builder) {
//     if (currentMulti !is null) {
//       super.getResponse(BuilderFactory.STRING); // Expected QUEUED

//       Response!(T) lr = new Response!(T)(builder);
//       currentMulti.addResponse(lr);
//       return lr;
//     } else {
//       return super.getResponse(builder);
//     }
//   }

    void setClient(Client client) {
        this.client = client;
    }

    override
    protected Client getClient(string key) {
        return client;
    }

    void clear() {
        if (isInMulti()) {
            discard();
        }

        sync();
    }

    bool isInMulti() {
        return currentMulti !is null;
    }

    /**
     * Synchronize pipeline by reading all responses. This operation close the pipeline. In order to
     * get return values from pipelined commands, capture the different Response&lt;?&gt; of the
     * commands you execute.
     */
    void sync() {
        if (getPipelinedResponseLength() > 0) {
            List!(Object) unformatted = client.getMany(getPipelinedResponseLength());
            foreach(Object o ; unformatted) {
                generateResponse(o);
            }
        }
    }

    /**
     * Synchronize pipeline by reading all responses. This operation close the pipeline. Whenever
     * possible try to avoid using this version and use Pipeline.sync() as it won't go through all the
     * responses and generate the right response type (usually it is a waste of time).
     * @return A list of all the responses in the order you executed them.
     */
    List!(Object) syncAndReturnAll() {
        if (getPipelinedResponseLength() > 0) {
            List!(Object) unformatted = client.getMany(getPipelinedResponseLength());
            List!(Object) formatted = new ArrayList!(Object)();
            foreach(Object o ; unformatted) {
                try {
                    formatted.add(generateResponse(o));
                } catch (RedisDataException e) {
                    formatted.add(e);
                }
            }
            return formatted;
        } else {
            return Collections.emptyList!Object();
        }
    }

    Response!(string) discard() {
        if (currentMulti is null) throw new RedisDataException("DISCARD without MULTI");
        client.discard();
        currentMulti = null;
        return getResponse(BuilderFactory.STRING);
    }

    Response!(List!(Object)) exec() {
        if (currentMulti is null) throw new RedisDataException("EXEC without MULTI");

        client.exec();
        Response!(List!(Object)) response = super.getResponse(currentMulti);
        currentMulti.setResponseDependency(response);
        currentMulti = null;
        return response;
    }

    Response!(string) multi() {
        if (currentMulti !is null) throw new RedisDataException("MULTI calls can not be nested");

        client.multi();
        Response!(string) response = getResponse(BuilderFactory.STRING); // Expecting
        // OK
        currentMulti = new MultiResponseBuilder();
        return response;
    }

    override
    void close() {
        clear();
    }

}
