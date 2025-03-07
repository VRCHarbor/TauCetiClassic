////////////////////////////////
///// Construction datums //////
////////////////////////////////

/datum/construction/reversible/mecha/custom_action(index, diff, obj/item/weapon/I, mob/user)
	if(iswelding(I))
		if (I.use(3, user))
			playsound(holder, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER)
			return 1
		else
			to_chat(user, ("There's not enough fuel."))
			return 0
	else if(iswrenching(I))
		playsound(holder, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		return 1
	else if(isscrewing(I))
		playsound(holder, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		return 1
	else if(iscutter(I))
		playsound(holder, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
		return 1
	else if(iscoil(I))
		var/obj/item/stack/cable_coil/C = I
		if(!C.use(4))
			to_chat(user, ("There's not enough cable to finish the task."))
			return 0
		playsound(holder, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	else if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		if(!S.use(5))
			to_chat(user, ("There's not enough material in this stack."))
			return 0
	if(istype(I, /obj))
		var/obj/part = I
		if(part.crit_fail || part.reliability < 50)
			user.visible_message("[user] was unable to connect [part] to [holder].", "You failed to connect [part] to [holder]")
			return 0
	return 1


/datum/construction/mecha/ripley_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg)//5
					)

/datum/construction/mecha/ripley_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/ripley(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "ripley0"
	const_holder.density = TRUE
	const_holder.cut_overlays()
	spawn()
		qdel(src)
	return


/datum/construction/reversible/mecha/ripley
	result_type = /obj/mecha/working/ripley
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //7
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //8
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //9
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //10
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //11
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //12
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/ripley/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/ripley/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(14)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "ripley1"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "ripley2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "ripley0"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "ripley3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "ripley1"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "ripley4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 4)
				holder.icon_state = "ripley2"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "ripley5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "ripley3"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "ripley6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ripley/main(get_turf(holder))
				holder.icon_state = "ripley4"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "ripley7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "ripley5"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "ripley8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ripley/peripherals(get_turf(holder))
				holder.icon_state = "ripley6"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "ripley9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "ripley7"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "ripley10"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/metal(get_turf(holder), 5)
				holder.icon_state = "ripley8"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "ripley11"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "ripley9"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
				holder.icon_state = "ripley12"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "ripley10"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				holder.icon_state = "ripley13"
			else
				user.visible_message("[user] pries external armor layer from [holder].", "You prie external armor layer from [holder].")
				new /obj/item/stack/sheet/plasteel(get_turf(holder), 5)
				holder.icon_state = "ripley11"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
			else
				user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
				holder.icon_state = "ripley12"
	return 1

/datum/construction/reversible/mecha/ripley/spawn_result()
	..()
	feedback_inc("mecha_ripley_created",1)
	return



/datum/construction/mecha/gygax_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/gygax_torso),//1
					 list("key"=/obj/item/mecha_parts/part/gygax_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/gygax_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/gygax_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/gygax_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/gygax_head)
					)

/datum/construction/mecha/gygax_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/gygax(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "gygax0"
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return


/datum/construction/reversible/mecha/gygax
	result_type = /obj/mecha/combat/gygax
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/gygax_armour,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Advanced capacitor is secured"),
					 //7
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Advanced capacitor is installed"),
					 //8
					 list("key"=/obj/item/weapon/stock_parts/capacitor/adv,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Advanced scanner module is secured"),
					 //9
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Advanced scanner module is installed"),
					 //10
					 list("key"=/obj/item/weapon/stock_parts/scanning_module/adv,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Targeting module is secured"),
					 //11
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Targeting module is installed"),
					 //12
					 list("key"=/obj/item/weapon/circuitboard/mecha/gygax/targeting,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //13
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //14
					 list("key"=/obj/item/weapon/circuitboard/mecha/gygax/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //15
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //16
					 list("key"=/obj/item/weapon/circuitboard/mecha/gygax/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //17
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //18
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/gygax/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/gygax/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(20)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "gygax1"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "gygax2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "gygax0"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "gygax3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "gygax1"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "gygax4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 4)
				holder.icon_state = "gygax2"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "gygax3"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "gygax6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/gygax/main(get_turf(holder))
				holder.icon_state = "gygax4"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "gygax5"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "gygax8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/gygax/peripherals(get_turf(holder))
				holder.icon_state = "gygax6"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "gygax7"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "gygax10"
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "You remove the weapon control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/gygax/targeting(get_turf(holder))
				holder.icon_state = "gygax8"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced scanner module to [holder].", "You install advanced scanner module to [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "gygax9"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced scanner module.", "You secure the advanced scanner module.")
				holder.icon_state = "gygax12"
			else
				user.visible_message("[user] removes the advanced scanner module from [holder].", "You remove the advanced scanner module from [holder].")
				new /obj/item/weapon/stock_parts/scanning_module/adv(get_turf(holder))
				holder.icon_state = "gygax10"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced capacitor to [holder].", "You install advanced capacitor to [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax13"
			else
				user.visible_message("[user] unfastens the advanced scanner module.", "You unfasten the advanced scanner module.")
				holder.icon_state = "gygax11"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced capacitor.", "You secure the advanced capacitor.")
				holder.icon_state = "gygax14"
			else
				user.visible_message("[user] removes the advanced capacitor from [holder].", "You remove the advanced capacitor from [holder].")
				new /obj/item/weapon/stock_parts/capacitor/adv(get_turf(holder))
				holder.icon_state = "gygax12"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "gygax15"
			else
				user.visible_message("[user] unfastens the advanced capacitor.", "You unfasten the advanced capacitor.")
				holder.icon_state = "gygax13"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "gygax16"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/metal(get_turf(holder), 5)
				holder.icon_state = "gygax14"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "gygax17"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "gygax15"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs Gygax Armour Plates to [holder].", "You install Gygax Armour Plates to [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax18"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "gygax16"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures Gygax Armour Plates.", "You secure Gygax Armour Plates.")
				holder.icon_state = "gygax19"
			else
				user.visible_message("[user] pries Gygax Armour Plates from [holder].", "You prie Gygax Armour Plates from [holder].")
				new /obj/item/mecha_parts/part/gygax_armour(get_turf(holder))
				holder.icon_state = "gygax17"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds Gygax Armour Plates to [holder].", "You weld Gygax Armour Plates to [holder].")
			else
				user.visible_message("[user] unfastens Gygax Armour Plates.", "You unfasten Gygax Armour Plates.")
				holder.icon_state = "gygax18"
	return 1

/datum/construction/reversible/mecha/gygax/spawn_result()
	..()
	feedback_inc("mecha_gygax_created",1)
	return

/datum/construction/mecha/firefighter_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg),//5
					 list("key"=/obj/item/clothing/suit/fire)//6
					)


/datum/construction/mecha/firefighter_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/firefighter(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "fireripley0"
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return


/datum/construction/reversible/mecha/firefighter
	result_type = /obj/mecha/working/ripley/firefighter
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is being installed."),
					 //4
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //5
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //6
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),

					 //7
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //8
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //9
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //10
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //11
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //12
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //13
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //14
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //15
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/firefighter/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/firefighter/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(15)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "fireripley1"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "fireripley2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "fireripley0"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "fireripley3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "fireripley1"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "fireripley4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 4)
				holder.icon_state = "fireripley2"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "fireripley5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "fireripley3"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "fireripley6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ripley/main(get_turf(holder))
				holder.icon_state = "fireripley4"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "fireripley7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "fireripley5"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "fireripley8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ripley/peripherals(get_turf(holder))
				holder.icon_state = "fireripley6"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "fireripley9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "fireripley7"

		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "fireripley10"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/plasteel(get_turf(holder), 5)
				holder.icon_state = "fireripley8"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "fireripley11"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "fireripley9"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] starts to install the external armor layer to [holder].", "You start to install the external armor layer to [holder].")
				holder.icon_state = "fireripley12"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "fireripley10"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
				holder.icon_state = "fireripley13"
			else
				user.visible_message("[user] removes the external armor from [holder].", "You remove the external armor from [holder].")
				new /obj/item/stack/sheet/plasteel(get_turf(holder), 5)
				holder.icon_state = "fireripley11"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				holder.icon_state = "fireripley14"
			else
				user.visible_message("[user] pries external armor layer from [holder].", "You prie external armor layer from [holder].")
				new /obj/item/stack/sheet/plasteel(get_turf(holder), 5)
				holder.icon_state = "fireripley12"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
			else
				user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
				holder.icon_state = "fireripley13"
	return 1

/datum/construction/reversible/mecha/firefighter/spawn_result()
	..()
	feedback_inc("mecha_firefighter_created",1)
	return



/datum/construction/mecha/honker_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/honker_torso),//1
					 list("key"=/obj/item/mecha_parts/part/honker_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/honker_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/honker_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/honker_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/honker_head)
					)

/datum/construction/mecha/honker_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/mecha/honker(const_holder)
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return


/datum/construction/mecha/honker
	result_type = /obj/mecha/combat/honker
	steps = list(list("key"=/obj/item/weapon/bikehorn),//1
					 list("key"=/obj/item/clothing/shoes/clown_shoes),//2
					 list("key"=/obj/item/weapon/bikehorn),//3
					 list("key"=/obj/item/clothing/mask/gas/clown_hat),//4
					 list("key"=/obj/item/weapon/bikehorn),//5
					 list("key"=/obj/item/weapon/circuitboard/mecha/honker/targeting),//6
					 list("key"=/obj/item/weapon/bikehorn),//7
					 list("key"=/obj/item/weapon/circuitboard/mecha/honker/peripherals),//8
					 list("key"=/obj/item/weapon/bikehorn),//9
					 list("key"=/obj/item/weapon/circuitboard/mecha/honker/main),//10
					 list("key"=/obj/item/weapon/bikehorn),//11
					 )

/datum/construction/mecha/honker/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/mecha/honker/custom_action(step, atom/used_atom, mob/user)
	if(!..())
		return 0

	if(istype(used_atom, /obj/item/weapon/bikehorn))
		playsound(holder, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("HONK!")

	//TODO: better messages.
	switch(step)
		if(10)
			user.visible_message("[user] installs the central control module into [holder].", "You install the central control module into [holder].")
			qdel(used_atom)
		if(8)
			user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
			qdel(used_atom)
		if(6)
			user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
			qdel(used_atom)
		if(4)
			user.visible_message("[user] puts clown wig and mask on [holder].", "You put clown wig and mask on [holder].")
			qdel(used_atom)
		if(2)
			user.visible_message("[user] puts clown boots on [holder].", "You put clown boots on [holder].")
			qdel(used_atom)
	return 1

/datum/construction/mecha/honker/spawn_result()
	..()
	feedback_inc("mecha_honker_created",1)
	return

/datum/construction/mecha/durand_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/durand_torso),//1
					 list("key"=/obj/item/mecha_parts/part/durand_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/durand_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/durand_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/durand_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/durand_head)
					)


/datum/construction/mecha/durand_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/durand(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "durand0"
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return

/datum/construction/reversible/mecha/durand
	result_type = /obj/mecha/combat/durand
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/durand_armour,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Advanced capacitor is secured"),
					 //7
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Advanced capacitor is installed"),
					 //8
					 list("key"=/obj/item/weapon/stock_parts/capacitor/adv,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Advanced scanner module is secured"),
					 //9
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Advanced scanner module is installed"),
					 //10
					 list("key"=/obj/item/weapon/stock_parts/scanning_module/adv,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Targeting module is secured"),
					 //11
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Targeting module is installed"),
					 //12
					 list("key"=/obj/item/weapon/circuitboard/mecha/durand/targeting,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //13
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //14
					 list("key"=/obj/item/weapon/circuitboard/mecha/durand/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //15
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //16
					 list("key"=/obj/item/weapon/circuitboard/mecha/durand/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //17
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //18
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)


/datum/construction/reversible/mecha/durand/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/durand/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(20)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "durand1"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "durand2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "durand0"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "durand3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "durand1"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "durand4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 4)
				holder.icon_state = "durand2"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "durand5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "durand3"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "durand6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/durand/main(get_turf(holder))
				holder.icon_state = "durand4"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "durand7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "durand5"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "durand8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/durand/peripherals(get_turf(holder))
				holder.icon_state = "durand6"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "durand9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "durand7"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "durand10"
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "You remove the weapon control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/durand/targeting(get_turf(holder))
				holder.icon_state = "durand8"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced scanner module to [holder].", "You install advanced scanner module to [holder].")
				qdel(used_atom)
				holder.icon_state = "durand11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "durand9"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced scanner module.", "You secure the advanced scanner module.")
				holder.icon_state = "durand12"
			else
				user.visible_message("[user] removes the advanced scanner module from [holder].", "You remove the advanced scanner module from [holder].")
				new /obj/item/weapon/stock_parts/scanning_module/adv(get_turf(holder))
				holder.icon_state = "durand10"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced capacitor to [holder].", "You install advanced capacitor to [holder].")
				qdel(used_atom)
				holder.icon_state = "durand13"
			else
				user.visible_message("[user] unfastens the advanced scanner module.", "You unfasten the advanced scanner module.")
				holder.icon_state = "durand11"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced capacitor.", "You secure the advanced capacitor.")
				holder.icon_state = "durand14"
			else
				user.visible_message("[user] removes the advanced capacitor from [holder].", "You remove the advanced capacitor from [holder].")
				new /obj/item/weapon/stock_parts/capacitor/adv(get_turf(holder))
				holder.icon_state = "durand12"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "durand15"
			else
				user.visible_message("[user] unfastens the advanced capacitor.", "You unfasten the advanced capacitor.")
				holder.icon_state = "durand13"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "durand16"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/metal(get_turf(holder), 5)
				holder.icon_state = "durand14"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "durand17"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "durand15"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs Durand Armour Plates to [holder].", "You install Durand Armour Plates to [holder].")
				qdel(used_atom)
				holder.icon_state = "durand18"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "durand16"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures Durand Armour Plates.", "You secure Durand Armour Plates.")
				holder.icon_state = "durand19"
			else
				user.visible_message("[user] pries Durand Armour Plates from [holder].", "You prie Durand Armour Plates from [holder].")
				new /obj/item/mecha_parts/part/durand_armour(get_turf(holder))
				holder.icon_state = "durand17"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds Durand Armour Plates to [holder].", "You weld Durand Armour Plates to [holder].")
			else
				user.visible_message("[user] unfastens Durand Armour Plates.", "You unfasten Durand Armour Plates.")
				holder.icon_state = "durand18"
	return 1

/datum/construction/reversible/mecha/durand/spawn_result()
	..()
	feedback_inc("mecha_durand_created",1)
	return


/datum/construction/mecha/phazon_chassis
	result_type = /obj/mecha/combat/phazon
	steps = list(list("key"=/obj/item/mecha_parts/part/phazon_torso),//1
					 list("key"=/obj/item/mecha_parts/part/phazon_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/phazon_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/phazon_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/phazon_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/phazon_head)
					)



/datum/construction/mecha/odysseus_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/odysseus_torso),//1
					 list("key"=/obj/item/mecha_parts/part/odysseus_head),//2
					 list("key"=/obj/item/mecha_parts/part/odysseus_left_arm),//3
					 list("key"=/obj/item/mecha_parts/part/odysseus_right_arm),//4
					 list("key"=/obj/item/mecha_parts/part/odysseus_left_leg),//5
					 list("key"=/obj/item/mecha_parts/part/odysseus_right_leg)//6
					)


/datum/construction/mecha/odysseus_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/odysseus(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "odysseus0"
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return


/datum/construction/reversible/mecha/odysseus
	result_type = /obj/mecha/medical/odysseus
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //7
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //8
					 list("key"=/obj/item/weapon/circuitboard/mecha/odysseus/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //9
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //10
					 list("key"=/obj/item/weapon/circuitboard/mecha/odysseus/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //11
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //12
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/odysseus/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/odysseus/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(14)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "odysseus1"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "odysseus2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "odysseus0"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "odysseus3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "odysseus1"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "odysseus4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 4)
				holder.icon_state = "odysseus2"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "odysseus5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "odysseus3"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "odysseus6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/odysseus/main(get_turf(holder))
				holder.icon_state = "odysseus4"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "odysseus7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "odysseus5"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "odysseus8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/odysseus/peripherals(get_turf(holder))
				holder.icon_state = "odysseus6"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "odysseus9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "odysseus7"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "odysseus10"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/metal(get_turf(holder), 5)
				holder.icon_state = "odysseus8"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "odysseus11"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "odysseus9"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs [used_atom] layer to [holder].", "You install external reinforced armor layer to [holder].")

				holder.icon_state = "odysseus12"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "odysseus10"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				holder.icon_state = "odysseus13"
			else
				var/obj/item/stack/sheet/plasteel/MS = new (get_turf(holder), 5)
				user.visible_message("[user] pries [MS] from [holder].", "You prie [MS] from [holder].")
				holder.icon_state = "odysseus11"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				holder.icon_state = "odysseus14"
			else
				user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
				holder.icon_state = "odysseus12"
	return 1

/datum/construction/reversible/mecha/odysseus/spawn_result()
	..()
	feedback_inc("mecha_odysseus_created",1)
	return

/datum/construction/mecha/vindicator_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/vindicator_torso),//1
					 list("key"=/obj/item/mecha_parts/part/vindicator_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/vindicator_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/vindicator_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/vindicator_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/vindicator_head)
					)

/datum/construction/mecha/vindicator_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/vindicator(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "vindicator0"
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return

/datum/construction/reversible/mecha/vindicator
	result_type = /obj/mecha/combat/durand/vindicator
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/vindicator_armour,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Advanced capacitor is secured"),
					 //7
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Advanced capacitor is installed"),
					 //8
					 list("key"=/obj/item/weapon/stock_parts/capacitor/super,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Advanced scanner module is secured"),
					 //9
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Advanced scanner module is installed"),
					 //10
					 list("key"=/obj/item/weapon/stock_parts/scanning_module/phasic,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Targeting module is secured"),
					 //11
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Targeting module is installed"),
					 //12
					 list("key"=/obj/item/weapon/circuitboard/mecha/vindicator/targeting,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //13
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //14
					 list("key"=/obj/item/weapon/circuitboard/mecha/vindicator/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //15
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //16
					 list("key"=/obj/item/weapon/circuitboard/mecha/vindicator/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //17
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //18
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)


/datum/construction/reversible/mecha/vindicator/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/vindicator/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(20)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "vindicator1"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "vindicator2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "vindicator0"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "vindicator3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "vindicator1"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "vindicator4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 30)
				holder.icon_state = "vindicator2"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "vindicator5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "vindicator3"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "vindicator6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/vindicator/main(get_turf(holder))
				holder.icon_state = "vindicator4"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "vindicator7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "vindicator5"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "vindicator8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/vindicator/peripherals(get_turf(holder))
				holder.icon_state = "vindicator6"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "vindicator9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "vindicator7"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "vindicator10"
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "You remove the weapon control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/vindicator/targeting(get_turf(holder))
				holder.icon_state = "vindicator8"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs phasic scanner module to [holder].", "You install phasic scanner module to [holder].")
				qdel(used_atom)
				holder.icon_state = "vindicator11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "vindicator9"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phasic scanner module.", "You secure the phasic scanner module.")
				holder.icon_state = "vindicator12"
			else
				user.visible_message("[user] removes the phasic scanner module from [holder].", "You remove the phasic scanner module from [holder].")
				new /obj/item/weapon/stock_parts/scanning_module/phasic(get_turf(holder))
				holder.icon_state = "vindicator10"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs super capacitor to [holder].", "You install super capacitor to [holder].")
				qdel(used_atom)
				holder.icon_state = "vindicator13"
			else
				user.visible_message("[user] unfastens the phasic scanner module.", "You unfasten the phasic scanner module.")
				holder.icon_state = "vindicator11"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the super capacitor.", "You secure the super capacitor.")
				holder.icon_state = "vindicator14"
			else
				user.visible_message("[user] removes the super capacitor from [holder].", "You remove the super capacitor from [holder].")
				new /obj/item/weapon/stock_parts/capacitor/super(get_turf(holder))
				holder.icon_state = "vindicator12"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "vindicator15"
			else
				user.visible_message("[user] unfastens the super capacitor.", "You unfasten the super capacitor.")
				holder.icon_state = "vindicator13"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "vindicator16"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/metal(get_turf(holder), 30)
				holder.icon_state = "vindicator14"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "vindicator17"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "vindicator15"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs Vindicator Armour Plates to [holder].", "You install Vindicator Armour Plates to [holder].")
				qdel(used_atom)
				holder.icon_state = "vindicator18"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "vindicator16"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures Vindicator Armour Plates.", "You secure Vindicator Armour Plates.")
				holder.icon_state = "vindicator19"
			else
				user.visible_message("[user] pries Vindicator Armour Plates from [holder].", "You prie Vindicator Armour Plates from [holder].")
				new /obj/item/mecha_parts/part/vindicator_armour(get_turf(holder))
				holder.icon_state = "vindicator17"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds Vindicator Armour Plates to [holder].", "You weld Vindicator Armour Plates to [holder].")
			else
				user.visible_message("[user] unfastens Vindicator Armour Plates.", "You unfasten Vindicator Armour Plates.")
				holder.icon_state = "vindicator18"
	return 1

/datum/construction/reversible/mecha/vindicator/spawn_result()
	..()
	feedback_inc("mecha_vindicator_created",1)
	return

/datum/construction/mecha/ultra_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ultra_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ultra_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ultra_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ultra_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ultra_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/ultra_head)
					)

/datum/construction/mecha/ultra_chassis/spawn_result()
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/ultra(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "ultra0"
	const_holder.density = TRUE
	spawn()
		qdel(src)
	return


/datum/construction/reversible/mecha/ultra
	result_type = /obj/mecha/combat/gygax/ultra
	steps = list(
					//1
					list("key"=QUALITY_WELDING,
							"backkey"=QUALITY_WRENCHING,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/ultra_armour,
					 		"backkey"=QUALITY_WELDING,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=QUALITY_WELDING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=QUALITY_WRENCHING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Super capacitor is secured"),
					 //7
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Super capacitor is installed"),
					 //8
					 list("key"=/obj/item/weapon/stock_parts/capacitor/super,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Phasic scanner module is secured"),
					 //9
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Phasic scanner module is installed"),
					 //10
					 list("key"=/obj/item/weapon/stock_parts/scanning_module/phasic,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Targeting module is secured"),
					 //11
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Targeting module is installed"),
					 //12
					 list("key"=/obj/item/weapon/circuitboard/mecha/ultra/targeting,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Peripherals control module is secured"),
					 //13
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Peripherals control module is installed"),
					 //14
					 list("key"=/obj/item/weapon/circuitboard/mecha/ultra/peripherals,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="Central control module is secured"),
					 //15
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_PRYING,
					 		"desc"="Central control module is installed"),
					 //16
					 list("key"=/obj/item/weapon/circuitboard/mecha/ultra/main,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is adjusted"),
					 //17
					 list("key"=QUALITY_CUTTING,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The wiring is added"),
					 //18
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=QUALITY_SCREWING,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=QUALITY_SCREWING,
					 		"backkey"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=QUALITY_WRENCHING,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/ultra/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/ultra/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(20)
			user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			holder.icon_state = "ultra1"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				holder.icon_state = "ultra2"
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
				holder.icon_state = "ultra0"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				holder.icon_state = "ultra3"
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
				holder.icon_state = "ultra1"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				holder.icon_state = "ultra4"
			else
				user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
				new /obj/item/stack/cable_coil/random(get_turf(holder), 4)
				holder.icon_state = "ultra2"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				qdel(used_atom)
				holder.icon_state = "ultra5"
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
				holder.icon_state = "ultra3"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "ultra6"
			else
				user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ultra/main(get_turf(holder))
				holder.icon_state = "ultra4"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "ultra7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "ultra5"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "ultra8"
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ultra/peripherals(get_turf(holder))
				holder.icon_state = "ultra6"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
				qdel(used_atom)
				holder.icon_state = "ultra9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "ultra7"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "ultra10"
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "You remove the weapon control module from [holder].")
				new /obj/item/weapon/circuitboard/mecha/ultra/targeting(get_turf(holder))
				holder.icon_state = "ultra8"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced scanner module to [holder].", "You install phasic scanner module to [holder].")
				qdel(used_atom)
				holder.icon_state = "ultra11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "ultra9"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phasic scanner module.", "You secure the phasic scanner module.")
				holder.icon_state = "ultra12"
			else
				user.visible_message("[user] removes the phasic scanner module from [holder].", "You remove the phasic scanner module from [holder].")
				new /obj/item/weapon/stock_parts/scanning_module/phasic(get_turf(holder))
				holder.icon_state = "ultra10"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs super capacitor to [holder].", "You install super capacitor to [holder].")
				qdel(used_atom)
				holder.icon_state = "ultra13"
			else
				user.visible_message("[user] unfastens the phasic scanner module.", "You unfasten the phasic scanner module.")
				holder.icon_state = "ultra11"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the super capacitor.", "You secure the super capacitor.")
				holder.icon_state = "ultra14"
			else
				user.visible_message("[user] removes the super capacitor from [holder].", "You remove the super capacitor from [holder].")
				new /obj/item/weapon/stock_parts/capacitor/super(get_turf(holder))
				holder.icon_state = "ultra12"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				holder.icon_state = "ultra15"
			else
				user.visible_message("[user] unfastens the super capacitor.", "You unfasten the super capacitor.")
				holder.icon_state = "ultra13"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				holder.icon_state = "ultra16"
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
				new /obj/item/stack/sheet/metal(get_turf(holder), 5)
				holder.icon_state = "ultra14"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				holder.icon_state = "ultra17"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "ultra15"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs Gygax Ultra Armour Plates to [holder].", "You install Gygax Ultra Armour Plates to [holder].")
				qdel(used_atom)
				holder.icon_state = "ultra18"
			else
				user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
				holder.icon_state = "ultra16"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures Gygax Ultra Armour Plates.", "You secure Gygax Ultra Armour Plates.")
				holder.icon_state = "ultra19"
			else
				user.visible_message("[user] pries Gygax Ultra Armour Plates from [holder].", "You prie Gygax Ultra Armour Plates from [holder].")
				new /obj/item/mecha_parts/part/ultra_armour(get_turf(holder))
				holder.icon_state = "ultra17"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds Gygax Ultra Armour Plates to [holder].", "You weld Gygax Ultra Armour Plates to [holder].")
			else
				user.visible_message("[user] unfastens Gygax Ultra Armour Plates.", "You unfasten Gygax Ultra Armour Plates.")
				holder.icon_state = "ultra18"
	return 1

/datum/construction/reversible/mecha/ultra/spawn_result()
	..()
	feedback_inc("mecha_ultra_created",1)
	return
