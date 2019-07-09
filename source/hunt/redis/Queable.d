module hunt.redis.Queable;

import hunt.collection.LinkedList;
import hunt.collection.Queue;

// class Queable {
//   private Queue<Response<?>> pipelinedResponses = new LinkedList<Response<?>>();

//   protected void clean() {
//     pipelinedResponses.clear();
//   }

//   protected Response<?> generateResponse(Object data) {
//     Response<?> response = pipelinedResponses.poll();
//     if (response !is null) {
//       response.set(data);
//     }
//     return response;
//   }

//   protected Response!(T) getResponse(T)(Builder!(T) builder) {
//     Response!(T) lr = new Response!(T)(builder);
//     pipelinedResponses.add(lr);
//     return lr;
//   }

//   protected bool hasPipelinedResponse() {
//     return !pipelinedResponses.isEmpty();
//   }

//   protected int getPipelinedResponseLength() {
//     return pipelinedResponses.size();
//   }
// }
