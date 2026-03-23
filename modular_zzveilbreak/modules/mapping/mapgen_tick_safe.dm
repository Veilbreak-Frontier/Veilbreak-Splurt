// Tick-safe map generation helpers for reload_station_map

// Time-budgeted reload generator: favor time-sliced work over fixed batch sizes

/proc/modular_reload_generate_async(x_low, y_low, x_high, y_high)
    // Validate numeric bounds
    if(!x_low || !y_low || !x_high || !y_high)
        return

    GLOB.reloading_map = TRUE

    // Phase 1: parse and load map pieces incrementally (one file per tick to be safe)
    var/z_offset = SSmapping.station_start
    var/list/bounds
    for (var/path in SSmapping.current_map.GetFullMapPaths())
        var/datum/parsed_map/parsed = load_map(
            file(path),
            1,
            1,
            z_offset,
            no_changeturf = FALSE,
            crop_map = TRUE,
            x_lower = x_low,
            y_lower = y_low,
            x_upper = x_high,
            y_upper = y_high,
        )
        bounds = parsed?.bounds
        z_offset += bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1

        // yield to avoid blocking when parsing many map files
        sleep(1)

    // Phase 2: collect atoms/turfs and prepare templates
    var/list/obj/machinery/atmospherics/atmos_machines = list()
    var/list/obj/structure/cable/cables = list()
    var/list/atom/atoms = list()

    require_area_resort()

    var/list/generation_turfs = block(
        bounds[MAP_MINX], bounds[MAP_MINY], SSmapping.station_start,
        bounds[MAP_MAXX], bounds[MAP_MAXY], z_offset - 1
    )

    // Time-based processing of generation_turfs: process as many turfs as allowed per slice
    var/idx = 1
    var/len = generation_turfs.len
    var/allowed = GLOB.modular_reload_time_budget - GLOB.modular_time_budget_buffer
    if(allowed <= 0)
        allowed = 0.002

    while(idx <= len)
        var/start_time = world.time
        while(idx <= len && (world.time - start_time) < allowed)
            var/turf/gen_turf = generation_turfs[idx]
            idx++
            atoms += gen_turf
            for(var/atom in gen_turf)
                atoms += atom
                if(istype(atom, /obj/structure/cable))
                    cables += atom
                    continue
                if(istype(atom, /obj/machinery/atmospherics))
                    atmos_machines += atom

        // yield to the next tick
        sleep(1)

    // yield before heavy initialization
    sleep(1)

    // Phase 3: initialize subsystems (batched where possible)
    SSatoms.InitializeAtoms(atoms)
    sleep(1)
    SSmachines.setup_template_powernets(cables)
    sleep(1)
    SSair.setup_template_machinery(atmos_machines)

    GLOB.reloading_map = FALSE
    return

GLOBAL_VAR_INIT(modular_reload_override, TRUE)
