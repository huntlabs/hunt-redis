/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.redis.ShardedRedisPipeline;

import hunt.redis.Client;
import hunt.redis.BinaryShardedRedis;
import hunt.redis.PipelineBase;

import hunt.collection;
import hunt.Exceptions;


private class FutureResult {
    private Client client;

    this(Client client) {
        this.client = client;
    }

    Object get() {
        return client.getOne();
    }
}

/**
*/
class ShardedRedisPipeline : PipelineBase {
    private BinaryShardedRedis jedis;
    private List!(FutureResult) results;
    private Queue!(Client) clients;

    this() {
        results = new ArrayList!(FutureResult)();
        clients = new LinkedList!(Client)();
    }


    void setShardedRedis(BinaryShardedRedis jedis) {
        this.jedis = jedis;
    }

    List!(Object) getResults() {
        List!(Object) r = new ArrayList!(Object)();
        foreach(FutureResult fr ; results) {
            r.add(fr.get());
        }
        return r;
    }

    /**
     * Synchronize pipeline by reading all responses. This operation closes the pipeline. In order to
     * get return values from pipelined commands, capture the different Response&lt;?&gt; of the
     * commands you execute.
     */
    void sync() {
        foreach(Client client ; clients) {
            generateResponse(client.getOne());
        }
    }

    /**
     * Synchronize pipeline by reading all responses. This operation closes the pipeline. Whenever
     * possible try to avoid using this version and use ShardedRedisPipeline.sync() as it won't go
     * through all the responses and generate the right response type (usually it is a waste of time).
     * @return A list of all the responses in the order you executed them.
     */
    List!(Object) syncAndReturnAll() {
        // List!(Object) formatted = new ArrayList!(Object)();
        // foreach(Client client ; clients) {
        //     formatted.add(generateResponse(client.getOne()).get());
        // }
        // return formatted;
        implementationMissing(false);
        return null;
    }

    override
    protected Client getClient(string key) {
        Client client = jedis.getShard(key).getClient();
        clients.add(client);
        results.add(new FutureResult(client));
        return client;
    }

    override
    protected Client getClient(const(ubyte)[] key) {
        Client client = jedis.getShard(key).getClient();
        clients.add(client);
        results.add(new FutureResult(client));
        return client;
    }
}