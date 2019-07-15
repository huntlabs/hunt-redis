module hunt.redis.Queable;

import hunt.redis.Response;

import hunt.collection.LinkedList;
import hunt.collection.Queue;

class Queable {
  private Queue!AbstractResponse pipelinedResponses;

  this() {
      pipelinedResponses = new LinkedList!AbstractResponse();
  }

  protected void clean() {
    pipelinedResponses.clear();
  }

  protected AbstractResponse generateResponse(Object data) {
    AbstractResponse response = pipelinedResponses.poll();
    if (response !is null) {
      response.set(data);
    }
    return response;
  }

  protected Response!(T) getResponse(T)(Builder!(T) builder) {
    Response!(T) lr = new Response!(T)(builder);
    pipelinedResponses.add(lr);
    return lr;
  }

  protected bool hasPipelinedResponse() {
    return !pipelinedResponses.isEmpty();
  }

  protected int getPipelinedResponseLength() {
    return pipelinedResponses.size();
  }
}
