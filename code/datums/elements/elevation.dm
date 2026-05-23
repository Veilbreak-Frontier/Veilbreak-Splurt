/datum/element/elevation
    element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
    argument_hash_start_idx = 2
    var/pixel_shift

/datum/element/elevation/Attach(datum/target, pixel_shift)
    . = ..()
    if(!ismovable(target))
        return ELEMENT_INCOMPATIBLE

    ADD_TRAIT(target, TRAIT_ELEVATING_OBJECT, ref(src))

    src.pixel_shift = pixel_shift

    RegisterSignal(target, COMSIG_ATOM_ENTERING, PROC_REF(on_source_entering))
    RegisterSignal(target, COMSIG_ATOM_EXITING, PROC_REF(on_source_exiting))

    var/atom/atom_target = target
    register_turf(atom_target, atom_target.loc)

/datum/element/elevation/Detach(atom/movable/source)
    UnregisterSignal(source, list(COMSIG_ATOM_ENTERING, COMSIG_ATOM_EXITING))
    unregister_turf(source, source.loc)
    REMOVE_TRAIT(source, TRAIT_ELEVATING_OBJECT, ref(src))
    return ..()

/datum/element/elevation/proc/reset_elevation(turf/target)
    var/list/current_values[2]
    SEND_SIGNAL(target, COMSIG_TURF_RESET_ELEVATION, current_values)
    var/current_pixel_shift = current_values[ELEVATION_CURRENT_PIXEL_SHIFT]
    var/new_pixel_shift = current_values[ELEVATION_MAX_PIXEL_SHIFT]
    if(new_pixel_shift == current_pixel_shift)
        return
    if(current_pixel_shift)
        target.RemoveElement(/datum/element/elevation_core, current_pixel_shift)
    if(new_pixel_shift)
        target.AddElement(/datum/element/elevation_core, new_pixel_shift)

/datum/element/elevation/proc/check_elevation(turf/source, list/current_values)
    SIGNAL_HANDLER
    current_values[ELEVATION_MAX_PIXEL_SHIFT] = max(current_values[ELEVATION_MAX_PIXEL_SHIFT], pixel_shift)

/datum/element/elevation/proc/on_source_entering(atom/movable/source, atom/entering, atom/old_loc)
    SIGNAL_HANDLER
    register_turf(source, entering)

/datum/element/elevation/proc/on_source_exiting(atom/movable/source, atom/exiting)
    SIGNAL_HANDLER
    unregister_turf(source, exiting)

/datum/element/elevation/proc/register_turf(atom/movable/source, atom/location)
    if(!isturf(location))
        return
    var/turf/target_turf = location

    if(!HAS_TRAIT(target_turf, "turf_has_elevated_obj_any"))
        RegisterSignal(target_turf, COMSIG_TURF_RESET_ELEVATION, PROC_REF(check_elevation))
        reset_elevation(target_turf)
        RegisterSignal(target_turf, COMSIG_TURF_CHANGE, PROC_REF(pre_change_turf))

    ADD_TRAIT(target_turf, "turf_has_elevated_obj_any", ref(src))
    ADD_TRAIT(target_turf, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))

/datum/element/elevation/proc/unregister_turf(atom/movable/source, atom/location)
    if(!isturf(location))
        return
    var/turf/target_turf = location
    REMOVE_TRAIT(target_turf, TRAIT_TURF_HAS_ELEVATED_OBJ(pixel_shift), ref(source))
    REMOVE_TRAIT(target_turf, "turf_has_elevated_obj_any", ref(src))

    if(!HAS_TRAIT(target_turf, "turf_has_elevated_obj_any"))
        UnregisterSignal(target_turf, list(COMSIG_TURF_RESET_ELEVATION, COMSIG_TURF_CHANGE))
        reset_elevation(target_turf)

/datum/element/elevation/proc/pre_change_turf(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
    SIGNAL_HANDLER
    for (var/atom/movable/content as anything in changed)
        if(HAS_TRAIT_FROM(content, TRAIT_ELEVATING_OBJECT, ref(src)))
            unregister_turf(content, changed)

#define ELEVATE_TIME 0.2 SECONDS
#define ELEVATION_SOURCE(datum) "elevation_[REF(datum)]"

/datum/element/elevation_core
    element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
    argument_hash_start_idx = 2
    var/pixel_shift

/datum/element/elevation_core/Attach(datum/target, pixel_shift)
    . = ..()
    if(!isturf(target))
        return ELEMENT_INCOMPATIBLE
    if(!pixel_shift)
        CRASH("attempted attaching /datum/element/elevation_core with a pixel_shift value of [isnull(pixel_shift) ? "null" : 0]")

    RegisterSignal(target, COMSIG_ATOM_ABSTRACT_ENTERED, PROC_REF(on_entered))
    RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_initialized_on))
    RegisterSignal(target, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(on_exited))
    RegisterSignal(target, COMSIG_TURF_RESET_ELEVATION, PROC_REF(on_reset_elevation))

    src.pixel_shift = pixel_shift

    ADD_TRAIT(target, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))

    for(var/mob/living/living in target)
        register_new_mob(living)

/datum/element/elevation_core/Detach(datum/source)
    UnregisterSignal(source, list(
        COMSIG_ATOM_ABSTRACT_ENTERED,
        COMSIG_ATOM_ABSTRACT_EXITED,
        COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON,
        COMSIG_TURF_RESET_ELEVATION,
    ))
    REMOVE_TRAIT(source, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))
    for(var/mob/living/living in source)
        deelevate_mob(living)
        UnregisterSignal(living, list(COMSIG_LIVING_SET_BUCKLED, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION)))
    return ..()

/datum/element/elevation_core/proc/on_entered(turf/source, atom/movable/entered, atom/old_loc)
    SIGNAL_HANDLER
    if((isnull(old_loc) || !HAS_TRAIT_FROM(old_loc, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))) && isliving(entered))
        register_new_mob(entered, elevate_time = isturf(old_loc) && source.Adjacent(old_loc) ? ELEVATE_TIME : 0)

/datum/element/elevation_core/proc/on_initialized_on(turf/source, atom/movable/spawned)
    SIGNAL_HANDLER
    if(isliving(spawned))
        register_new_mob(spawned, elevate_time = 0)

/datum/element/elevation_core/proc/on_exited(turf/source, atom/movable/gone)
    SIGNAL_HANDLER
    if((isnull(gone.loc) || !HAS_TRAIT_FROM(gone.loc, TRAIT_ELEVATED_TURF, ELEVATION_SOURCE(src))) && isliving(gone))
        UnregisterSignal(gone, list(COMSIG_LIVING_SET_BUCKLED, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION)))
        deelevate_mob(gone, isturf(gone.loc) && source.Adjacent(gone.loc) ? ELEVATE_TIME : 0)

/datum/element/elevation_core/proc/register_new_mob(mob/living/new_mob, elevate_time = ELEVATE_TIME)
    elevate_mob(new_mob, elevate_time = elevate_time)
    RegisterSignal(new_mob, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_set_buckled), override = TRUE)
    RegisterSignal(new_mob, SIGNAL_ADDTRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_add), override = TRUE)
    RegisterSignal(new_mob, SIGNAL_REMOVETRAIT(TRAIT_IGNORE_ELEVATION), PROC_REF(on_ignore_elevation_remove), override = TRUE)

/datum/element/elevation_core/proc/elevate_mob(mob/living/target, elevate_time = ELEVATE_TIME, force = FALSE)
    if(HAS_TRAIT(target, TRAIT_IGNORE_ELEVATION) && !force)
        return
    if(target.has_offset(source = ELEVATION_SOURCE(src)))
        return
    ADD_TRAIT(target, TRAIT_MOB_ELEVATED, ELEVATION_SOURCE(src))
    if(target.buckled)
        if(isvehicle(target.buckled))
            animate(target.buckled, pixel_z = pixel_shift, time = elevate_time, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
        else if(isliving(target.buckled))
            pass()
        else
            return
    target.add_offsets(ELEVATION_SOURCE(src), z_add = pixel_shift, animate = elevate_time > 0)

/datum/element/elevation_core/proc/deelevate_mob(mob/living/target, elevate_time = ELEVATE_TIME)
    REMOVE_TRAIT(target, TRAIT_MOB_ELEVATED, ELEVATION_SOURCE(src))
    target.remove_offsets(ELEVATION_SOURCE(src), animate = elevate_time > 0)
    if(isvehicle(target.buckled))
        animate(target.buckled, pixel_z = -pixel_shift, time = elevate_time, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)

/datum/element/elevation_core/proc/on_set_buckled(mob/living/source, atom/movable/new_buckled)
    SIGNAL_HANDLER
    if(HAS_TRAIT(source, TRAIT_IGNORE_ELEVATION))
        return
    if(source.buckled)
        if(isvehicle(source.buckled))
            animate(source.buckled, pixel_z = -pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
        else if(isliving(source.buckled))
            deelevate_mob(source)
        else
            source.add_offsets(ELEVATION_SOURCE(src), z_add = pixel_shift)
    if(new_buckled)
        if(isvehicle(new_buckled))
            animate(new_buckled, pixel_z = pixel_shift, time = ELEVATE_TIME, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
        else if(isliving(new_buckled))
            elevate_mob(source)
        else
            source.remove_offsets(ELEVATION_SOURCE(src))

/datum/element/elevation_core/proc/on_ignore_elevation_add(mob/living/source, trait)
    SIGNAL_HANDLER
    deelevate_mob(source)

/datum/element/elevation_core/proc/on_ignore_elevation_remove(mob/living/source, trait)
    SIGNAL_HANDLER
    elevate_mob(source)

/datum/element/elevation_core/proc/on_reset_elevation(turf/source, list/current_values)
    SIGNAL_HANDLER
    current_values[ELEVATION_CURRENT_PIXEL_SHIFT] = pixel_shift

#undef ELEVATE_TIME
#undef ELEVATION_SOURCE
