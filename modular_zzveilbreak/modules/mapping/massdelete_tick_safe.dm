// Modular override: Tick-safe massdelete module

// Time-budgeted massdelete batcher.
// Process as many turfs as available within `modular_massdelete_time_budget - modular_time_budget_buffer` seconds per iteration.

/proc/modular_massdelete_generate_async(list/turfs, ignore_cache = FALSE, should_delete_turfs = FALSE)
    if(!turfs || !turfs.len)
        return

    var/index = 1

    // Determine allowed time per processing slice (seconds)
    var/allowed = GLOB.modular_massdelete_time_budget - GLOB.modular_time_budget_buffer
    if(allowed <= 0)
        allowed = 0.002

    while(index <= turfs.len)
        var/start_time = world.time


        // Process until we hit the time budget or finish the list
        while(index <= turfs.len && (world.time - start_time) < allowed)
            var/turf/T = turfs[index]
            index++
            if(!T)
                continue
            T.empty(should_delete_turfs ? null : T.type, null, ignore_cache, CHANGETURF_FORCEOP)

        // Yield to the next tick so other server work can run
        sleep(1)

    return

GLOBAL_VAR_INIT(modular_massdelete_override, TRUE)
