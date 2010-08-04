/*
 * info.d
 *
 * This module describes an environment.
 *
 */

module kernel.environ.info;

import kernel.core.error;

import kernel.system.segment;

import architecture.context;

import kernel.sched.roundrobin;

// The configuration options are loaded:
//import Config = kernel.config;
//mixin(Config.Alias!("SchedulerImplementation"));

struct Environment {
	enum State {
		Inactive,
		Initializing,
		Uninitializing,
		Blocked,
		Ready,
		Running,
	}

	State state = State.Inactive;

	void* start;
	void* virtualStart;

	void* entry;

	ulong length;

	Context context;

	SchedulerInfo info;

	Environment* parent;
	bool hasRunYet;

	ErrorVal initialize() {
		// Create a page table for this environment
		context.initialize();

		context.preamble(entry);

		hasRunYet = false;
		state = State.Ready;

		return ErrorVal.Success;
	}

	ErrorVal uninitialize() {
		return context.uninitialize();
	}

	ErrorVal allocSegment(ref Segment s) {
		return context.allocSegment(s);
	}

	ErrorVal alloc(void* virtualAddress, ulong length, bool writeable) {
		return context.alloc(virtualAddress, length, writeable);
	}

	void* mapRegion(void* physAddr, ulong length) {
		return context.mapRegion(physAddr, length);
	}

	void execute() {
		if(!hasRunYet){
			hasRunYet = true;
			context.execute();
		}else{
			context.simpleExecute();
		}
	}
}

