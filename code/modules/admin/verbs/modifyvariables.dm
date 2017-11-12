var/list/forbidden_varedit_object_types = list(
		/datum/admins,                     //Admins editing their own admin-power object? Yup, sounds like a good idea.
		/datum/configuration,
		/obj/machinery/blackbox_recorder,  //Prevents people messing with feedback gathering
		/datum/feedback_variable,          //Prevents people messing with feedback gathering
		/datum/timedevent,                 //Nope.avi
		/datum/craft_or_build,
		/datum/stack_recipe
	)

/client/proc/cmd_modify_ticker_variables()
	set category = "Debug"
	set name = "Edit Ticker Variables"

	if (ticker == null)
		to_chat(src, "Game hasn't started yet.")
	else
		src.modify_variables(ticker)
		feedback_add_details("admin_verb","ETV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mod_list_add_ass() //haha

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
	else
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = input("Enter new text:","Text") as null|text

		if("num")
			var_value = input("Enter new number:","Num") as null|num

		if("type")
			var_value = input("Enter type:","Type") as null|anything in typesof(/obj,/mob,/area,/turf)

		if("reference")
			var_value = input("Select reference:","Reference") as null|mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as null|mob in world

		if("file")
			var_value = input("Pick file:","File") as null|file

		if("icon")
			var_value = input("Pick icon:","Icon") as null|icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	return var_value


/client/proc/mod_list_add(list/L)

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
	else
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = input("Enter new text:","Text") as text

		if("num")
			var_value = input("Enter new number:","Num") as num

		if("type")
			var_value = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			var_value = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as mob in world

		if("file")
			var_value = input("Pick file:","File") as file

		if("icon")
			var_value = input("Pick icon:","Icon") as icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	switch(alert("Would you like to associate a var with the list entry?",,"Yes","No"))
		if("Yes")
			L += var_value
			L[var_value] = mod_list_add_ass() //haha
		if("No")
			L += var_value

/client/proc/mod_list(list/L)
	if(!check_rights(R_VAREDIT))	return

	if(!istype(L,/list))
		to_chat(src, "Not a List.")

	var/list/locked = list("vars", "key", "ckey", "client", "virus", "viruses", "icon", "icon_state")
	var/list/names = sortList(L)

	var/variable = input("Which var?","Var") as null|anything in names + "(ADD VAR)"

	if(variable == "(ADD VAR)")
		mod_list_add(L)
		return

	if(!variable)
		return

	var/default

	var/dir

	if(variable in locked)
		if(!check_rights(R_DEBUG))	return

	if(isnull(variable))
		to_chat(usr, "Unable to determine variable type.")

	else if(isnum(variable))
		to_chat(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"

	else if(istext(variable))
		to_chat(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if(isloc(variable))
		to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if(isicon(variable))
		to_chat(usr, "Variable appears to be <b>ICON</b>.")
		variable = "[bicon(variable)]"
		default = "icon"

	else if(istype(variable,/atom) || istype(variable,/datum))
		to_chat(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if(istype(variable,/list))
		to_chat(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if(istype(variable,/client))
		to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		to_chat(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	to_chat(usr, "Variable contains: [variable]")
	if(dir)
		switch(variable)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null

		if(dir)
			to_chat(usr, "If a direction, direction is: [dir]")

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])", "DELETE FROM LIST")
	else
		class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default", "DELETE FROM LIST")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.

		if("list")
			mod_list(variable)

		if("restore to default")
			L[L.Find(variable)]=initial(variable)

		if("edit referenced object")
			modify_variables(variable)

		if("DELETE FROM LIST")
			L -= variable
			return

		if("text")
			L[L.Find(variable)] = input("Enter new text:","Text") as text

		if("num")
			L[L.Find(variable)] = input("Enter new number:","Num") as num

		if("type")
			L[L.Find(variable)] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			L[L.Find(variable)] = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			L[L.Find(variable)] = input("Select reference:","Reference") as mob in world

		if("file")
			L[L.Find(variable)] = input("Pick file:","File") as file

		if("icon")
			L[L.Find(variable)] = input("Pick icon:","Icon") as icon

		if("marked datum")
			L[L.Find(variable)] = holder.marked_datum


/client/proc/modify_variables(atom/O, param_var_name = null, autodetect_class = 0)
	if(!check_rights(R_VAREDIT))	return

	var/list/icons_modifying = list("resize", "resize_rev")
	var/list/locked = list("vars", "key", "ckey", "client", "virus", "viruses", "mutantrace", "player_ingame_age", "summon_type")
	var/list/typechange_locked = list("player_next_age_tick","player_ingame_age")
	var/list/fully_locked = list("holder", "player_next_age_tick")

	if(is_type_in_list(O, forbidden_varedit_object_types))
		to_chat(usr, "\red It is forbidden to edit this object's variables.")
		return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!(param_var_name in O.vars))
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this atom ([O])")
			return

		if(param_var_name in fully_locked)
			to_chat(usr, "\red It is forbidden to edit this variable.")
			return

		if(!autodetect_class && (param_var_name in typechange_locked))
			return

		if((param_var_name in locked) && !check_rights(R_DEBUG))
			return

		if((param_var_name in icons_modifying) && !check_rights(R_DEBUG|R_EVENT))
			return

		variable = param_var_name

		var_value = O.vars[variable]

		if(autodetect_class)
			if(isnull(var_value))
				to_chat(usr, "Unable to determine variable type.")
				class = null
				autodetect_class = null
			else if(isnum(var_value))
				to_chat(usr, "Variable appears to be <b>NUM</b>.")
				class = "num"

			else if(istext(var_value))
				to_chat(usr, "Variable appears to be <b>TEXT</b>.")
				class = "text"

			else if(isloc(var_value))
				to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
				class = "reference"

			else if(isicon(var_value))
				to_chat(usr, "Variable appears to be <b>ICON</b>.")
				var_value = "[bicon(var_value)]"
				class = "icon"

			else if(istype(var_value,/atom) || istype(var_value,/datum))
				to_chat(usr, "Variable appears to be <b>TYPE</b>.")
				class = "type"

			else if(istype(var_value,/list))
				to_chat(usr, "Variable appears to be <b>LIST</b>.")
				class = "list"

			else if(istype(var_value,/client))
				to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
				class = "cancel"

			else
				to_chat(usr, "Variable appears to be <b>FILE</b>.")
				class = "file"

	else

		var/list/names = list()
		for (var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)	return
		var_value = O.vars[variable]

		if(variable == "holder" || (variable in locked))
			if(!check_rights(R_DEBUG))	return

	if(!autodetect_class)

		var/dir
		var/default
		if(isnull(var_value))
			to_chat(usr, "Unable to determine variable type.")

		else if(isnum(var_value))
			to_chat(usr, "Variable appears to be <b>NUM</b>.")
			default = "num"

		else if(istext(var_value))
			to_chat(usr, "Variable appears to be <b>TEXT</b>.")
			default = "text"

		else if(isloc(var_value))
			to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
			default = "reference"

		else if(isicon(var_value))
			to_chat(usr, "Variable appears to be <b>ICON</b>.")
			var_value = "[bicon(var_value)]"
			default = "icon"

		else if(istype(var_value,/atom) || istype(var_value,/datum))
			to_chat(usr, "Variable appears to be <b>TYPE</b>.")
			default = "type"

		else if(istype(var_value,/list))
			to_chat(usr, "Variable appears to be <b>LIST</b>.")
			default = "list"

		else if(istype(var_value,/client))
			to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
			default = "cancel"

		else
			to_chat(usr, "Variable appears to be <b>FILE</b>.")
			default = "file"

		to_chat(usr, "Variable contains: [var_value]")
		if(dir)
			switch(var_value)
				if(1)
					dir = "NORTH"
				if(2)
					dir = "SOUTH"
				if(4)
					dir = "EAST"
				if(8)
					dir = "WEST"
				if(5)
					dir = "NORTHEAST"
				if(6)
					dir = "SOUTHEAST"
				if(9)
					dir = "NORTHWEST"
				if(10)
					dir = "SOUTHWEST"
				else
					dir = null
			if(dir)
				to_chat(usr, "If a direction, direction is: [dir]")

		if(src.holder && src.holder.marked_datum)
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
		else
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

		if(!class)
			return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/log_handled = FALSE

	switch(class)

		if("list")
			mod_list(O.vars[variable])
			return

		if("restore to default")
			if(variable=="resize")
				world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.resize_rev]")]"
				log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.resize_rev]")
				message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.resize_rev]")
				log_handled = TRUE
				O.vars[variable] = O.resize_rev
				O.update_transform()
				O.resize_rev = initial(O.resize_rev)
			else
				O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/var_new = sanitize(input("Enter new text:", "Text", O.vars[variable])) as null|text
			if(isnull(var_new))
				return
			O.vars[variable] = var_new

		if("num")
			switch(variable)
				if("light_range")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					O.set_light(var_new)
				if("player_ingame_age")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new) || var_new < 0)
						return
					O.vars[variable] = var_new
					if(istype(O,/client))
						var/client/C = O
						if(C) C.log_client_ingame_age_to_db()
				if("stat")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					if((O.vars[variable] == 2) && (var_new < 2))//Bringing the dead back to life
						dead_mob_list -= O
						living_mob_list += O
					if((O.vars[variable] < 2) && (var_new == 2))//Kill him
						living_mob_list -= O
						dead_mob_list += O
					O.vars[variable] = var_new
				if("resize")
					var/var_new = input("Enter new coefficient: \n(object will be resized by multiplying this number)", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					if(var_new == 0)
						to_chat(usr, "<b>Resize coefficient can't be equal 0</b>")
						return
					O.vars[variable] = var_new
					world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.resize]")]"
					log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.resize]")
					message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.resize]")
					log_handled = TRUE
					O.update_transform()
				else
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					O.vars[variable] = var_new

		if("type")
			var/var_new = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob|obj|turf|area in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("mob reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("file")
			var/var_new = input("Pick file:","File",O.vars[variable]) as null|file
			if(var_new==null) return
			O.vars[variable] = var_new

		if("icon")
			var/var_new = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(var_new==null) return
			O.vars[variable] = var_new

		if("marked datum")
			O.vars[variable] = holder.marked_datum

	if(!log_handled)
		world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.vars[variable]]")]"
		log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.vars[variable]]")
		message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.vars[variable]]")
