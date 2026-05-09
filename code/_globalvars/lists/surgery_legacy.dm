/// Builds singleton instances for [/datum/surgery_step] types (legacy surgery system).
/proc/init_legacy_surgery_steps()
	var/list/result = list()
	for(var/datum/surgery_step/step_type as anything in subtypesof(/datum/surgery_step))
		if(initial(step_type.abstract_type) == step_type)
			continue
		result[step_type] = new step_type()
	return result

GLOBAL_LIST_INIT(surgery_steps, init_legacy_surgery_steps())
