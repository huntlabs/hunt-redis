/*
 * Hunt - A refined core library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.redis.FuturePromise;

import hunt.redis.Future;
import hunt.redis.Promise;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import core.atomic;
import core.thread;
import core.sync.mutex;
import core.sync.condition;

import std.conv;
import std.format;
import std.datetime;

alias ThenHandler(T) = void delegate(T);

/**
 * 
 */
class FuturePromise(T) : Future!T, Promise!T {
	alias VoidHandler = void delegate();
	
	private shared bool _isCompleting = false;
	private bool _isCompleted = false;
	private Throwable _cause;
	private string _id;
	private Mutex _waiterLocker;
	private Condition _waiterCondition;

	this(string id="") {
		_id = id;
		_waiterLocker = new Mutex(this);
		_waiterCondition = new Condition(_waiterLocker);
	}

	string id() {
		return _id;
	}

	// void id(string id) {
	// 	_id = id;
	// }

	ThenHandler!(Throwable) _thenFailedHandler;

static if(is(T == void)) {
	VoidHandler _thenSucceededHandler;

	FuturePromise!R then(R)(R delegate() handler) {
		FuturePromise!R result = new FuturePromise!(R);
		_thenSucceededHandler = () {
			try {
				R r = handler();
				result.succeeded(r);
			} catch(Exception ex) {
				Exception e = new Exception("then exception", ex);
				result.failed(e);
			}
		};

		_thenFailedHandler = (Throwable ex) {
			Exception e = new Exception("then exception", ex);
			result.failed(e);
		};

		return result;
	}

	/**
	 * TODO: 
	 * 	1) keep this operation atomic
	 * 	2) return a flag to indicate whether this option is successful.
	 */
	bool succeeded() {
		if (cas(&_isCompleting, false, true)) {
			onCompleted();
			return true;
		} else {
			warningf("This promise has completed, and can't be set again. cause: %s", 
				_cause is null ? "null" : _cause.msg);
			return false;
		}
	}

} else {
	ThenHandler!(T) _thenSucceededHandler;

	FuturePromise!R then(R)(R delegate(T) handler) {
		FuturePromise!R result = new FuturePromise!(R);
		_thenSucceededHandler = (T t) {
			try {
				static if(is(R == void)) {
					handler(t);
					result.succeeded();
				} else {
					R r = handler(t);
					result.succeeded(r);
				}
			} catch(Exception ex) {
				Exception e = new Exception("then exception", ex);
				result.failed(e);
			}
		};

		_thenFailedHandler = (Throwable ex) {
			Exception e = new Exception("then exception", ex);
			result.failed(e);
		};

		return result;
	}

	/**
	 * 
	 */
	bool succeeded(T result) {
		version(HUNT_DEBUG_MORE) tracef("completing promise [%s]", id());

		if (cas(&_isCompleting, false, true)) {
			_result = result;
			onCompleted();
			return true;
		} else {
			warningf("The promise [%s] has completed, and can't be set again. Result: %s, Cause: %s", id(), 
				_result.to!string(),  _cause is null ? "null" : _cause.msg);
			return false;
		}
	}
	private T _result;
}

	/**
	 * 
	 */
	bool failed(Throwable cause) {
		if (cas(&_isCompleting, false, true)) {
			_cause = cause;	
			onCompleted();	
			return true;	
		} else {
			warningf("This promise [%s] has been done, and can't be set again. cause: %s", 
				id(), (cause is null) ? "null" : cause.msg);
			return false;
		}
	}

	bool cancel(bool mayInterruptIfRunning) {
		if (cas(&_isCompleting, false, true)) {
			static if(!is(T == void)) {
				_result = T.init;
			}
			_cause = new CancellationException("");
			onCompleted();
			return true;
		}
		return false;
	}

	private void onCompleted() {

		version(HUNT_DEBUG_MORE) tracef("Promise [%s] completed", id());

		_waiterLocker.lock();
		scope(exit) {
			_waiterLocker.unlock();
		}
		_isCompleted = true;
		
		_waiterCondition.notifyAll();

		if(_cause is null) {
			if(_thenSucceededHandler !is null) {
				static if(is(T == void)) {
					_thenSucceededHandler();
				} else {
					_thenSucceededHandler(_result);
				}
			}
		} else {
			if(_thenFailedHandler !is null) {
				_thenFailedHandler(_cause);
			}
		}
	}

	bool isCancelled() {
		if (_isCompleted) {
			try {
				// _latch.await();
				// TODO: Tasks pending completion -@zhangxueping at 2019-12-26T15:18:42+08:00
				// 
			} catch (InterruptedException e) {
				throw new RuntimeException(e.msg);
			}
			return typeid(_cause) == typeid(CancellationException);
		}
		return false;
	}

	bool isDone() {
		return _isCompleted;
	}

	T get() {
		return get(-1.msecs);
	}

	T get(Duration timeout) {
		// waitting for the completion
		if(!_isCompleted) {
			_waiterLocker.lock();
			scope(exit) {
				_waiterLocker.unlock();
			}

			if(timeout.isNegative()) {
				version (HUNT_DEBUG) info("Waiting for promise [%s]...", id());
				_waiterCondition.wait();
			} else {
				version (HUNT_DEBUG) {
					tracef("Waiting for promise [%s] in %s...", id(), timeout);
				}
				bool r = _waiterCondition.wait(timeout);
				if(!r) {
					version(HUNT_DEBUG_MORE) {
						warningf("Timeout for promise [%s] in %s...  isCompleting=%s", id(), timeout, _isCompleting);
					}

					if (cas(&_isCompleting, false, true)) {
						_isCompleted = true;
						string str = format("Promise [%s] timeout in %s", id(), timeout);
						_cause = new TimeoutException(str);
					} else {
						static if(is(T == void)) {
							warningf("It seems that a result has got in promise %s.", id());
						} else {
							warningf("It seems that a result has got in promise %s: %s", id(), _result.to!string());
						}
					}
				}
			}
			
			if(_cause is null) {
				version (HUNT_DEBUG) tracef("Got a succeeded promise [%s].", id());
			} else {
				version (HUNT_DEBUG) warningf("Got a failed promise [%s]: %s", id(), _cause.msg);
			}
		} 

		// succeeded
		if (_cause is null) {
			static if(is(T == void)) {
				return;
			} else {
				return _result;
			}
		}

		CancellationException c = cast(CancellationException) _cause;
		if (c !is null) {
			version(HUNT_DEBUG) info("A promise cancelled.");
			throw c;
		}
		
		debug warningf("Get a exception in promise %s: %s", id(), _cause.msg);
		// version (HUNT_DEBUG) warning(_cause);
		throw new ExecutionException(_cause);
	}	

	override string toString() {
		static if(is(T == void)) {
			return format("FutureCallback@%x{%b, %b, void}", toHash(), _isCompleted, _cause is null);
		} else {
			return format("FutureCallback@%x{%b, %b, %s}", toHash(), _isCompleted, _cause is null, _result);
		}
	}
}
