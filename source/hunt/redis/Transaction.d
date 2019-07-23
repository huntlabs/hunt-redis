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
 
module hunt.redis.Transaction;

import hunt.redis.Client;
import hunt.redis.MultiKeyPipelineBase;
import hunt.redis.Response;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.collection.ArrayList;
import hunt.collection.List;

import hunt.redis.Exceptions;

/**
 * Transaction is nearly identical to Pipeline, only differences are the multi/discard behaviors
 */
class Transaction : MultiKeyPipelineBase, Closeable {

    protected bool inTransaction = true;

    protected this() {
        // client will be set later in transaction block
    }

    this(Client client) {
        this.client = client;
    }

    override protected Client getClient(string key) {
        return client;
    }

    override protected Client getClient(const(ubyte)[] key) {
        return client;
    }    

    void clear() {
        if (inTransaction) {
            discard();
        }
    }

    List!(Object) exec() {
        // Discard QUEUED or ERROR
        client.getMany(getPipelinedResponseLength());
        client.exec();
        inTransaction = false;

        List!(Object) unformatted = client.getObjectMultiBulkReply();
        if (unformatted is null) {
            return null;
        }
        List!(Object) formatted = new ArrayList!(Object)();
        foreach (Object o; unformatted) {
            try {
                implementationMissing(false);
                trace(typeid(generateResponse(o)));
                

                // formatted.add(generateResponse(o).get());
                // FIXME: Needing refactor or cleanup -@zxp at 7/17/2019, 11:21:20 AM
                // 
            } catch (RedisDataException e) {
                formatted.add(e);
            }
        }
        return formatted;
    }

    List!(AbstractResponse) execGetResponse() {
        // Discard QUEUED or ERROR
        client.getMany(getPipelinedResponseLength());
        client.exec();
        inTransaction = false;

        List!(Object) unformatted = client.getObjectMultiBulkReply();
        if (unformatted is null) {
            return null;
        }
        List!AbstractResponse response = new ArrayList!AbstractResponse();
        foreach (Object o; unformatted) {
            response.add(generateResponse(o));
        }
        return response;
    }

    string discard() {
        client.getMany(getPipelinedResponseLength());
        client.discard();
        inTransaction = false;
        clean();
        return client.getStatusCodeReply();
    }

    void setClient(Client client) {
        this.client = client;
    }

    override void close() {
        clear();
    }
}
