module hunt.redis.Transaction;

import hunt.util.Common;
import hunt.collection.ArraryList;
import hunt.collection.List;

import hunt.redis.exceptions.RedisDataException;

/**
 * Transaction is nearly identical to Pipeline, only differences are the multi/discard behaviors
 */
class Transaction : MultiKeyPipelineBase implements Closeable {

  protected bool inTransaction = true;

  protected Transaction() {
    // client will be set later in transaction block
  }

  Transaction(Client client) {
    this.client = client;
  }

  override
  protected Client getClient(string key) {
    return client;
  }

  override
  protected Client getClient(byte[] key) {
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
    foreach(Object o ; unformatted) {
      try {
        formatted.add(generateResponse(o).get());
      } catch (RedisDataException e) {
        formatted.add(e);
      }
    }
    return formatted;
  }

  List<Response<?>> execGetResponse() {
    // Discard QUEUED or ERROR
    client.getMany(getPipelinedResponseLength());
    client.exec();
    inTransaction = false;

    List!(Object) unformatted = client.getObjectMultiBulkReply();
    if (unformatted is null) {
      return null;
    }
    List<Response<?>> response = new ArrayList<Response<?>>();
    foreach(Object o ; unformatted) {
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

  override
  void close() {
    clear();
  }
}