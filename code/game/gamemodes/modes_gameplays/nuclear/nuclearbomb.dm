#define TIMER_MIN 600
#define TIMER_MAX 780

var/global/bomb_set

/obj/machinery/nuclearbomb
	name = "Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	can_buckle = 1
	use_power = NO_POWER_USE
	unacidable = TRUE	//aliens can't destroy the bomb

	resistance_flags = FULL_INDESTRUCTIBLE

	var/deployable = 0.0
	var/extended = 0.0
	var/lighthack = 0
	var/opened = 0.0
	var/timeleft = TIMER_MAX
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/weapon/disk/nuclear/auth = null
	var/datum/wires/nuclearbomb/wires = null
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open,
	                      // 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	var/detonated = 0 //used for scoreboard.
	var/lastentered = ""
	var/spray_icon_state
	var/nuketype = ""

	var/datum/announcement/station/nuke/announce_nuke = new

/obj/machinery/nuclearbomb/atom_init()
	. = ..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.
	wires = new(src)

/obj/machinery/nuclearbomb/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(auth)
	return ..()

/obj/machinery/nuclearbomb/process()
	if (timing > 0) // because explode() sets it to -1, which is TRUE.
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		playsound(src, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 30, FALSE)
		if (timeleft <= 0)
			explode()
		updateUsrDialog()

/obj/machinery/nuclearbomb/attackby(obj/item/weapon/O, mob/user)
	if (isscrewing(O))
		add_fingerprint(user)
		if (removal_stage == 5)
			if (src.opened == 0)
				src.opened = 1
				add_overlay(image(icon, "npanel_open"))
				to_chat(user, "You unscrew the control panel of [src].")
			else
				src.opened = 0
				cut_overlay(image(icon, "npanel_open"))
				to_chat(user, "You screw the control panel of [src] back on.")
		else if (src.auth)
			if (src.opened == 0)
				src.opened = 1
				add_overlay(image(icon, "npanel_open"))
				to_chat(user, "You unscrew the control panel of [src].")
			else
				src.opened = 0
				cut_overlay(image(icon, "npanel_open"))
				to_chat(user, "You screw the control panel of [src] back on.")
		else
			if (src.opened == 0)
				to_chat(user, "The [src] emits a buzzing noise, the panel staying locked in.")
			if (src.opened == 1)
				src.opened = 0
				cut_overlay(image(icon, "npanel_open"))
				to_chat(user, "You screw the control panel of [src] back on.")
			flick("nuclearbombc", src)
		return FALSE
	if (is_wire_tool(O) && opened)
		if(wires.interact(user))
			return FALSE

	if (src.extended)
		if (istype(O, /obj/item/weapon/disk/nuclear))
			usr.drop_from_inventory(O, src)
			src.auth = O
			add_fingerprint(user)
			return FALSE

	if (src.anchored)
		switch(removal_stage)
			if(0)
				if(iswelding(O))
					var/obj/item/weapon/weldingtool/WT = O
					if(!WT.isOn())
						return FALSE
					if (WT.get_fuel() < 5) // uses up 5 fuel.
						to_chat(user, "<span class = 'red'>You need more fuel to complete this task.</span>")
						return FALSE
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] starts cutting thru something on [src] like \he knows what to do.", "With [O] you start cutting thru first layer...")

					if(O.use_tool(src, user, SKILL_TASK_CHALLENGING, amount = 5, volume = 50))
						user.visible_message("[user] finishes cutting something on [src].", "You cut thru first layer.")
						removal_stage = 1
				return FALSE
			if(1)
				if(isprying(O))
					user.visible_message("[user] starts smashing [src].", "You start forcing open the covers with [O]...")
					if(user.is_busy())
						return FALSE
					if(O.use_tool(src, user, SKILL_TASK_AVERAGE, volume = 50))
						user.visible_message("[user] finishes smashing [src].", "You force open covers.")
						removal_stage = 2
				return FALSE
			if(2)
				if(iswelding(O))
					var/obj/item/weapon/weldingtool/WT = O
					if(!WT.isOn())
						return FALSE
					if (WT.get_fuel() < 5) // uses up 5 fuel.
						to_chat(user, "<span class = 'red'>You need more fuel to complete this task.</span>")
						return FALSE
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] starts cutting something on [src].. Again.", "You start cutting apart the safety plate with [O]...")

					if(O.use_tool(src, user, SKILL_TASK_DIFFICULT , amount = 5, volume = 50))
						user.visible_message("[user] finishes cutting something on [src].", "You cut apart the safety plate.")
						removal_stage = 3
				return FALSE
			if(3)
				if(iswrenching(O))
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] begins poking inside [src].", "You begin unwrenching bolts...")
					if(O.use_tool(src, user, SKILL_TASK_TOUGH, volume = 50))
						user.visible_message("[user] begins poking inside [src].", "You unwrench bolts.")
						removal_stage = 4
				return FALSE
			if(4)
				if(isprying(O))
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] begings hitting [src].", "You begin forcing open last safety layer...")
					if(O.use_tool(src, user, SKILL_TASK_TOUGH, volume = 50))
						user.visible_message("[user] finishes hitting [src].", "You can now get inside the [src]. Use screwdriver to open control panel")
						//anchored = FALSE
						removal_stage = 5
				return FALSE
	return ..()

/obj/machinery/nuclearbomb/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if (!extended)
		if (!ishuman(user) && !isobserver(user))
			to_chat(usr, "<span class = 'red'>You don't have the dexterity to do this!</span>")
			return
		var/turf/current_location = get_turf(user)//What turf is the user on?
		if((!current_location || is_centcom_level(current_location.z)) && isnukeop(user))//If turf was not found or they're on z level 2.
			to_chat(user, "<span class = 'red'>It's not the best idea to plant a bomb on your own base.</span>")
			return
		if (!istype(get_area(src), /area/station)) // If outside of station
			to_chat(user, "<span class = 'red'>Bomb cannot be deployed here.</span>")
			return
	if (deployable)
		if(removal_stage < 5)
			anchored = TRUE
			visible_message("<span class = 'red'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class = 'red'>The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		if(!lighthack)
			flick("nuclearbombc", src)
			icon_state = "nuclearbomb1"
		extended = TRUE

/obj/machinery/nuclearbomb/ui_interact(mob/user)
	if(!extended)
		return

	var/dat = text("<TT><B>Nuclear Fission Explosive</B><BR>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (auth ? "++++++++++" : "----------"))
	if (auth)
		if (yes_code)
			dat += text("\n<B>Status</B>: []-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] <A href='?src=\ref[];timer=1'>Toggle</A><BR>\nTime: <A href='?src=\ref[];time=-10'>-</A> <A href='?src=\ref[];time=-1'>-</A> [] <A href='?src=\ref[];time=1'>+</A> <A href='?src=\ref[];time=10'>+</A><BR>\n<BR>\n[] Safety: <A href='?src=\ref[];safety=1'>Toggle</A><BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (timing ? "Func/Set" : "Functional"), (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), src, src, src, timeleft, src, src, (safety ? "On" : "Off"), src, (anchored ? "Engaged" : "Off"), src)
		else
			dat += text("\n<B>Status</B>: Auth. S2-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), timeleft, (safety ? "On" : "Off"), (anchored ? "Engaged" : "Off"), src)
	else
		if (timing)
			dat += text("\n<B>Status</B>: Set-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), timeleft, (safety ? "On" : "Off"), (anchored ? "Engaged" : "Off"))
		else
			dat += text("\n<B>Status</B>: Auth. S1-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (safety ? "Safe" : "Engaged"), timeleft, (timing ? "On" : "Off"), timeleft, (safety ? "On" : "Off"), (anchored ? "Engaged" : "Off"))
	var/message = "AUTH"
	if (auth)
		message = text("[]", code)
		if (yes_code)
			message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)

	var/datum/browser/popup = new(user, "window=nuclearbomb", src.name, 300, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	deploy(usr)

/obj/machinery/nuclearbomb/proc/deploy(mob/user)
	if (user.incapacitated())
		return
	if (!ishuman(user))
		to_chat(usr, "<span class = 'red'>You don't have the dexterity to do this!</span>")
		return 1

	if (src.deployable)
		to_chat(user, "<span class = 'red'>You close several panels to make [src] undeployable.</span>")
		src.deployable = 0
	else
		to_chat(user, "<span class = 'red'>You adjust some panels to make [src] deployable.</span>")
		src.deployable = 1

/obj/machinery/nuclearbomb/is_operational()
	return TRUE

/obj/machinery/nuclearbomb/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!extended)
		return

	if (href_list["auth"])
		if (src.auth)
			src.auth.loc = src.loc
			src.yes_code = 0
			src.auth = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/disk/nuclear))
				usr.drop_from_inventory(I, src)
				src.auth = I
	if (src.auth)
		if (href_list["type"])
			if (href_list["type"] == "E")
				if (src.code == src.r_code)
					src.yes_code = 1
					src.code = null
				else
					src.code = "ERROR"
			else
				if (href_list["type"] == "R")
					src.yes_code = 0
					src.code = null
				else
					lastentered = text("[]", href_list["type"])
					if (text2num(lastentered) == null)
						var/turf/LOC = get_turf(usr)
						message_admins("[key_name_admin(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: <a href='?_src_=vars;Vars=\ref[src]'>[lastentered]</a> ! ([LOC ? "[ADMIN_JMP(LOC)]" : "null"])", 0)
						log_admin("EXPLOIT : [key_name(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: [lastentered] !")
					else
						src.code += lastentered
						if (length(src.code) > 5)
							src.code = "ERROR"
		if (src.yes_code)
			if (href_list["time"])
				var/time = text2num(href_list["time"])
				src.timeleft += time
				src.timeleft = clamp(round(timeleft), TIMER_MIN, TIMER_MAX)
			if (href_list["timer"])
				if (src.timing == -1.0)
					return FALSE
				if (src.safety)
					to_chat(usr, "<span class = 'red'>The safety is still on.</span>")
					return FALSE
				src.timing = !( src.timing )
				if (src.timing)
					if(!src.lighthack)
						src.icon_state = "nuclearbomb2"
					if(!src.safety)
						var/area/nuclearbombloc = get_area(loc)
						announce_nuke.play(nuclearbombloc)
						set_security_level("delta")
						notify_ghosts("[src] has been activated!", source = src, action = NOTIFY_ORBIT, header = "Nuclear bomb")
						bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
					else
						bomb_set = 0
				else
					bomb_set = 0
					if(!src.lighthack)
						src.icon_state = "nuclearbomb1"
			if (href_list["safety"])
				src.safety = !( src.safety )
				if(safety)
					src.timing = 0
					bomb_set = 0
		if (href_list["anchor"])

			//if(removal_stage == 5)
			//	src.anchored = FALSE
			//	visible_message("<span class='warning'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
			//	return

			src.anchored = !( src.anchored )
			if(src.anchored)
				visible_message("<span class = 'red'>With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
			else
				icon_state = "nuclearbomb1"
				safety = 1.0
				timing = -1.0
				timeleft = TIMER_MAX
				visible_message("<span class = 'red'>The anchoring bolts slide back into the depths of [src] and timer has stopped.</span>")

	updateUsrDialog()

/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/blob_act()
	if (src.timing == -1.0)
		return
	return ..()

#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if (src.safety)
		src.timing = 0
		return
	if(detonated)
		return
	src.detonated = 1
	src.timing = -1.0
	src.yes_code = 0
	src.safety = 1
	if(!src.lighthack)
		src.icon_state = "nuclearbomb3"
	playsound(src, 'sound/machines/Alarm.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, 5)
	if (SSticker)
		SSticker.explosion_in_progress = 1
	sleep(100)

	enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if( bomb_location && is_station_level(bomb_location.z) )
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
			off_station = 1
		else
			SSStatistics.score.nuked++
			sleep(10)
			explosion(src, 15, 70, 200)
	else
		off_station = 2

	if(SSticker)
		var/datum/faction/nuclear/N = find_faction_by_type(/datum/faction/nuclear)
		if(N)
			var/obj/machinery/computer/syndicate_station/syndie_location = locate(/obj/machinery/computer/syndicate_station)
			if(syndie_location)
				N.syndies_didnt_escape = is_station_level(syndie_location.z)
			N.nuke_off_station = off_station
		SSticker.station_explosion_cinematic(off_station,null)
		SSticker.explosion_in_progress = 0
		if(N)
			N.nukes_left = FALSE
		else
			to_chat(world, "<B>The station was destoyed by the nuclear blast!</B>")

		SSticker.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
														//kinda shit but I couldn't  get permission to do what I wanted to do.

		if(!SSticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
			to_chat(world, "<B>Resetting in 45 seconds!</B>")

			feedback_set_details("end_error","nuke - unhandled ending")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			sleep(450)
			log_game("Rebooting due to nuclear detonation")
			world.Reboot(end_state = "nuke - unhandled ending")

/obj/machinery/nuclearbomb/MouseDrop_T(mob/living/M, mob/living/user)
	if(!ishuman(M) || !ishuman(user))
		return
	if(user.is_busy())
		return
	if(buckled_mob)
		do_after(usr, 30, 1, src)
		unbuckle_mob()
	else if(do_after(usr, 30, 1, src))
		M.loc = loc
		..()

/obj/machinery/nuclearbomb/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		M.pixel_y = 10
	else
		M.pixel_y = M.default_pixel_y

/obj/machinery/nuclearbomb/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(buckled_mob)
		buckled_mob.bullet_act(Proj)
		if(buckled_mob.weakened || buckled_mob.health < 0 || buckled_mob.halloss > 80)
			unbuckle_mob()

/obj/machinery/nuclearbomb/MouseDrop(over_object, src_location, over_location)
	..()
	if(!istype(over_object, /obj/structure/droppod))
		return
	if(!ishuman(usr) || !Adjacent(usr) || !Adjacent(over_object) || !usr.Adjacent(over_object))
		return
	var/obj/structure/droppod/D = over_object
	if(!timing && !auth && !buckled_mob)
		if(usr.is_busy())
			return
		visible_message("<span class='notice'>[usr] start putting [src] into [D]!</span>","<span class='notice'>You start putting [src] into [D]!</span>")
		if(do_after(usr, 100, 1, src) && !timing && !auth && !buckled_mob)
			D.Stored_Nuclear = src
			loc = D
			D.icon_state = "dropod_opened_n[D.item_state]"
			visible_message("<span class='notice'>[usr] put [src] into [D]!</span>","<span class='notice'>You succesfully put [src] into [D]!</span>")
			D.verbs += /obj/structure/droppod/proc/Nuclear

//==========DAT FUKKEN DISK===============
/obj/item/weapon/disk
	icon = 'icons/obj/items.dmi'
	w_class = SIZE_MINUSCULE
	item_state = "card-id"
	icon_state = "datadisk0"

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"

/obj/item/weapon/disk/nuclear/atom_init()
	. = ..()
	poi_list += src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/disk/nuclear/process()
	var/turf/disk_loc = get_turf(src)
	if(!is_centcom_level(disk_loc.z) && !is_station_level(disk_loc.z))
		to_chat(get(src, /mob), "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		qdel(src)

/obj/item/weapon/disk/nuclear/Destroy()
	if(blobstart.len > 0)
		var/turf/targetturf = get_turf(pick(blobstart))
		var/turf/diskturf = get_turf(src)
		forceMove(targetturf) //move the disc, so ghosts remain orbitting it even if it's "destroyed"
		message_admins("[src] has been destroyed in ([COORD(diskturf)] - [ADMIN_JMP(diskturf)]). Moving it to ([COORD(targetturf)] - [ADMIN_JMP(targetturf)]).")
		log_game("[src] has been destroyed in [COORD(diskturf)]. Moving it to [COORD(targetturf)].")
	else
		throw EXCEPTION("Unable to find a blobstart landmark")
	return QDEL_HINT_LETMELIVE //Cancel destruction regardless of success

#undef TIMER_MIN
#undef TIMER_MAX

/obj/machinery/nuclearbomb/fake
	var/false_activation = FALSE

/obj/machinery/nuclearbomb/fake/atom_init()
	. = ..()
	r_code = "HONK"
	if(SSticker)
		var/image/I = image('icons/obj/clothing/masks.dmi', src, "sexyclown")
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/faction, "fake_nuke", I, /datum/faction/nuclear)

/obj/machinery/nuclearbomb/fake/explode()
	if(safety)
		timing = 0
		return
	if(detonated)
		return
	detonated = 1
	timing = -1.0
	yes_code = 0
	safety = 1
	if(!lighthack)
		icon_state = "nuclearbomb3"
	addtimer(CALLBACK(src, .proc/fail), 10 SECONDS) //Good taste, right?
	playsound(src, 'sound/effects/scary_honk.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, 30)

/obj/machinery/nuclearbomb/fake/examine(mob/user, distance)
	. = ..()
	if(isnukeop(user) || isobserver(user))
		to_chat(user, "<span class ='boldwarning'>This is a fake one!</span>")

/obj/machinery/nuclearbomb/fake/process() //Yes, it's alike normal, but not exactly
	if(timing > 0) // because explode() sets it to -1, which is TRUE.
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		playsound(src, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 30, FALSE)
		if(timeleft <= 0)
			explode()
		updateUsrDialog()

/obj/machinery/nuclearbomb/fake/proc/fail(mob/user) //Resetting theatre of one actor and many watchers
	if(!lighthack)
		icon_state = "nuclearbomb1"

/obj/machinery/nuclearbomb/fake/deploy(mob/user)
	if(false_activation)
		return
	..()

	if(!isnukeop(user))
		return
	if(!anchored)
		return
	if(tgui_alert(user, "False decoy activation. Continue?", "Decoy activation", list("Yes","No")) != "Yes")
		return
	icon_state = "nuclearbomb2"
	timing = 1.0
	yes_code = 1
	safety = 0
	false_activation = TRUE
	return
